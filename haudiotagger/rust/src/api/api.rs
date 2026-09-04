use std::io::Cursor;

use super::{
    error::HaudiotaggerError,
    tag::Tag,
    tag_changes::{TagChanges, read_bytes_or_empty, read_or_empty},
    tag_field::TagField,
};
use lofty::config::WriteOptions;
use lofty::file::FileType;
use lofty::file::TaggedFile;
use lofty::file::{AudioFile, TaggedFileExt};
use lofty::probe::Probe;
use lofty::tag::Tag as LoftyTag;
use lofty::tag::items::Timestamp;
use lofty::tag::{Accessor, ItemKey, TagExt, TagType};
use rayon::prelude::*;

/// Returns a `TaggedFile` at the given path.
pub(crate) fn get_file(path: &str) -> Result<TaggedFile, HaudiotaggerError> {
    let probe = Probe::open(path)
        .map_err(|err| HaudiotaggerError::OpenFile {
            message: err.to_string(),
        })?
        .guess_file_type()
        .map_err(|err| HaudiotaggerError::OpenFile {
            message: err.to_string(),
        })?;

    match probe.read() {
        Ok(file) => Ok(file),
        Err(err) => Err(HaudiotaggerError::OpenFile {
            message: err.to_string(),
        }),
    }
}

/// Returns a `TaggedFile` from in-memory bytes.
pub(crate) fn get_file_from_bytes(bytes: &[u8]) -> Result<TaggedFile, HaudiotaggerError> {
    let mut cursor = Cursor::new(bytes);
    let probe =
        Probe::new(&mut cursor)
            .guess_file_type()
            .map_err(|e| HaudiotaggerError::OpenFile {
                message: e.to_string(),
            })?;
    probe.read().map_err(|e| HaudiotaggerError::OpenFile {
        message: e.to_string(),
    })
}

fn tag_from_file(file: &TaggedFile) -> Result<Tag, HaudiotaggerError> {
    let tag = match file.primary_tag() {
        Some(primary_tag) => Ok(primary_tag),
        None => match file.first_tag() {
            Some(first_tag) => Ok(first_tag),
            None => Err(HaudiotaggerError::NoTags),
        },
    }?;

    let mut tag = Tag::from(tag);
    let duration = file.properties().duration().as_secs() as u32;
    tag.duration = Some(duration);

    Ok(tag)
}

fn apply_tag_to_lofty_tag(
    tag: &Tag,
    lo_tag: &mut lofty::tag::Tag,
) -> Result<(), HaudiotaggerError> {
    if let Some(title) = &tag.title {
        lo_tag.insert_text(ItemKey::TrackTitle, title.clone());
    }
    if let Some(track_artist) = &tag.track_artist {
        lo_tag.insert_text(ItemKey::TrackArtist, track_artist.clone());
    }
    if let Some(album) = &tag.album {
        lo_tag.insert_text(ItemKey::AlbumTitle, album.clone());
    }
    if let Some(album_artist) = &tag.album_artist {
        lo_tag.insert_text(ItemKey::AlbumArtist, album_artist.clone());
    }
    if let Some(year) = tag.year {
        if year > u16::MAX as u32 {
            return Err(HaudiotaggerError::Write {
                message: format!("Year {year} out of valid range"),
            });
        }
        lo_tag.set_date(Timestamp {
            year: year as u16,
            ..Default::default()
        });
    }
    if let Some(track_number) = tag.track_number {
        lo_tag.set_track(track_number);
    }
    if let Some(track_total) = tag.track_total {
        lo_tag.set_track_total(track_total);
    }
    if let Some(disc_number) = tag.disc_number {
        lo_tag.set_disk(disc_number);
    }
    if let Some(disc_total) = tag.disc_total {
        lo_tag.set_disk_total(disc_total);
    }
    if let Some(genre) = &tag.genre {
        lo_tag.insert_text(ItemKey::Genre, genre.clone());
    }
    for (i, picture) in tag.pictures.iter().enumerate() {
        let mut builder = lofty::picture::Picture::unchecked(picture.bytes.clone())
            .pic_type(picture.picture_type.clone().into());
        if let Some(mime_type) = &picture.mime_type {
            builder = builder.mime_type(mime_type.clone().into());
        }
        lo_tag.set_picture(i, builder.build());
    }
    if let Some(lyrics) = &tag.lyrics {
        // ID3v2 (MP3, etc.) has no `ItemKey::Lyrics`; lyrics live in the USLT
        // frame, addressed by `ItemKey::UnsyncLyrics`. Other formats (MP4,
        // Vorbis, APE) use `ItemKey::Lyrics`.
        let key = if lo_tag.tag_type() == TagType::Id3v2 {
            ItemKey::UnsyncLyrics
        } else {
            ItemKey::Lyrics
        };
        lo_tag.insert_text(key, lyrics.clone());
    }
    if let Some(comment) = &tag.comment {
        lo_tag.insert_text(ItemKey::Comment, comment.clone());
    }
    if let Some(bpm) = tag.bpm {
        if !lo_tag.insert_text(ItemKey::Bpm, bpm.to_string()) {
            lo_tag.insert_text(ItemKey::IntegerBpm, (bpm as u32).to_string());
        }
    }
    if let Some(val) = &tag.replay_gain_track_gain {
        lo_tag.insert_text(ItemKey::ReplayGainTrackGain, val.clone());
    }
    if let Some(val) = &tag.replay_gain_track_peak {
        lo_tag.insert_text(ItemKey::ReplayGainTrackPeak, val.clone());
    }
    if let Some(val) = &tag.replay_gain_album_gain {
        lo_tag.insert_text(ItemKey::ReplayGainAlbumGain, val.clone());
    }
    if let Some(val) = &tag.replay_gain_album_peak {
        lo_tag.insert_text(ItemKey::ReplayGainAlbumPeak, val.clone());
    }
    Ok(())
}

pub fn read(path: String) -> Result<Tag, HaudiotaggerError> {
    let file = get_file(&path)?;
    tag_from_file(&file)
}

/// Read metadata from in-memory bytes (for web/WASM).
pub fn read_from_bytes(bytes: Vec<u8>) -> Result<Tag, HaudiotaggerError> {
    let file = get_file_from_bytes(&bytes)?;
    tag_from_file(&file)
}

/// Returns true when `path`/`bytes` should be written via the byte-level MP3
/// path (`write_mp3_bytes`). lofty's content probe (`guess_file_type`) mis-
/// identifies some real MP3s (returns non-`Mpeg`), which would otherwise route
/// them through lofty's writer and abort with `FileEncodingError { format: None }`.
/// So we additionally key off the `.mp3` extension and a leading "ID3" marker.
#[inline]
fn is_mp3(path: &str, bytes: &[u8]) -> bool {
    if path.to_lowercase().ends_with(".mp3") {
        return true;
    }
    if bytes.starts_with(b"ID3") {
        return true;
    }
    Probe::new(Cursor::new(bytes))
        .guess_file_type()
        .ok()
        .and_then(|p| p.file_type())
        == Some(FileType::Mpeg)
}

pub fn write(path: String, data: Tag) -> Result<(), HaudiotaggerError> {
    let bytes = std::fs::read(&path).map_err(|e| HaudiotaggerError::OpenFile {
        message: format!("Could not read file: {e}"),
    })?;

    // MP3s are often content-sniffed incorrectly by lofty (e.g. embedded/generated
    // tags), which makes lofty's `save_to_path` abort with
    // `FileEncodingError { format: None }` on write. We strip the existing tag at the
    // byte level (ID3v2 at the head, ID3v1/APE at the tail) and prepend a freshly
    // serialized ID3v2, which never re-probes the file. Detection keys off the
    // extension / "ID3" marker (not lofty's unreliable content probe) so an MP3 is
    // never routed through lofty's writer.
    if is_mp3(&path, &bytes) {
        let out = write_mp3_bytes(bytes, data)?;
        std::fs::write(&path, out).map_err(|e| HaudiotaggerError::Write {
            message: format!("Could not write file: {e}"),
        })?;
        return Ok(());
    }

    // Other formats: replace the in-memory primary tag and let lofty's
    // `save_to_path` rewrite the file. It replaces the existing on-disk tag, and
    // strips it when the new tag is empty. We deliberately avoid
    // `TagType::remove_from`, whose write step re-probes the file format and
    // aborts with `FileEncodingError { format: None }` for some files (and can
    // corrupt others on a second write).
    let mut file = get_file(&path)?;
    let mut new_tag = LoftyTag::new(file.primary_tag_type());
    if !data.is_empty() {
        apply_tag_to_lofty_tag(&data, &mut new_tag)?;
    }
    file.insert_tag(new_tag);

    file.save_to_path(&path, WriteOptions::new())
        .map_err(|e| HaudiotaggerError::Write {
            message: format!("Failed to write tag to file. {e:#?}"),
        })
}

/// Strip a leading ID3v2 tag (starts with "ID3", syncsafe size at bytes 6..10).
/// Strip a leading ID3v2 tag. Returns the audio portion after the tag.
#[inline]
fn strip_id3v2(bytes: &[u8]) -> &[u8] {
    if bytes.len() >= 10 && &bytes[0..3] == b"ID3" {
        let size = ((bytes[6] as usize & 0x7F) << 21)
            | ((bytes[7] as usize & 0x7F) << 14)
            | ((bytes[8] as usize & 0x7F) << 7)
            | (bytes[9] as usize & 0x7F);
        let total = 10 + size;
        if total <= bytes.len() {
            return &bytes[total..];
        }
    }
    bytes
}

/// Strip a trailing ID3v1 tag (last 128 bytes start with "TAG").
#[inline]
fn strip_id3v1(bytes: &[u8]) -> &[u8] {
    if bytes.len() >= 128 && &bytes[bytes.len() - 128..bytes.len() - 125] == b"TAG" {
        return &bytes[..bytes.len() - 128];
    }
    bytes
}

/// Strip a trailing APEv2 tag (footer "APETAGEX" at the end; its size field
/// covers the whole tag including the footer).
#[inline]
fn strip_ape(bytes: &[u8]) -> &[u8] {
    if bytes.len() >= 32 && &bytes[bytes.len() - 32..bytes.len() - 24] == b"APETAGEX" {
        let size = u32::from_le_bytes([
            bytes[bytes.len() - 20],
            bytes[bytes.len() - 19],
            bytes[bytes.len() - 18],
            bytes[bytes.len() - 17],
        ]) as usize;
        if size >= 32 && size <= bytes.len() {
            return &bytes[..bytes.len() - size];
        }
    }
    bytes
}

fn write_mp3_bytes(bytes: Vec<u8>, data: Tag) -> Result<Vec<u8>, HaudiotaggerError> {
    let audio = strip_ape(strip_id3v1(strip_id3v2(&bytes)));

    if data.is_empty() {
        let mut out = Vec::with_capacity(audio.len());
        out.extend_from_slice(audio);
        return Ok(out);
    }

    let mut lo_tag = LoftyTag::new(TagType::Id3v2);
    apply_tag_to_lofty_tag(&data, &mut lo_tag)?;

    let mut tag_bytes = Vec::with_capacity(1024);
    lo_tag
        .dump_to(&mut tag_bytes, WriteOptions::new())
        .map_err(|e| HaudiotaggerError::Write {
            message: format!("Could not serialize tag: {e:?}"),
        })?;

    let mut out = Vec::with_capacity(tag_bytes.len() + audio.len());
    out.extend_from_slice(&tag_bytes);
    out.extend_from_slice(audio);
    Ok(out)
}

/// Shared helper: strip existing tags from MP3 bytes, build a new lofty Tag via
/// the supplied closure, serialize, and concatenate with the raw audio.
/// This avoids duplicating the strip→build→dump→concat pattern across
/// `write_to_bytes`, `set_custom_tag_from_bytes`, and `remove_custom_tag_from_bytes`.
fn write_lofty_tag_to_mp3_bytes<F>(bytes: &[u8], build: F) -> Result<Vec<u8>, HaudiotaggerError>
where
    F: FnOnce(LoftyTag) -> Result<LoftyTag, HaudiotaggerError>,
{
    let audio = strip_ape(strip_id3v1(strip_id3v2(bytes)));
    let file = get_file_from_bytes(bytes)?;
    let tag_type = file.primary_tag_type();

    let mut lo_tag = LoftyTag::new(tag_type);
    if let Some(existing_tag) = file.primary_tag() {
        let std_tag = Tag::from(existing_tag);
        apply_tag_to_lofty_tag(&std_tag, &mut lo_tag)?;
    }

    let lo_tag = build(lo_tag)?;

    let mut tag_bytes = Vec::with_capacity(1024);
    lo_tag
        .dump_to(&mut tag_bytes, WriteOptions::new())
        .map_err(|e| HaudiotaggerError::Write {
            message: format!("Could not serialize tag: {e:?}"),
        })?;

    let mut out = Vec::with_capacity(tag_bytes.len() + audio.len());
    out.extend_from_slice(&tag_bytes);
    out.extend_from_slice(audio);
    Ok(out)
}

/// Write metadata to in-memory bytes, returns modified bytes (for web/WASM).
pub fn write_to_bytes(bytes: Vec<u8>, data: Tag) -> Result<Vec<u8>, HaudiotaggerError> {
    // Web/WASM has no file path, so extension detection is unavailable; we still
    // share the same "ID3 prefix or lofty probe" logic via `is_mp3`.
    if is_mp3("", &bytes) {
        return write_mp3_bytes(bytes, data);
    }

    let mut file = {
        let mut cursor = Cursor::new(&bytes);
        let probe =
            Probe::new(&mut cursor)
                .guess_file_type()
                .map_err(|e| HaudiotaggerError::OpenFile {
                    message: e.to_string(),
                })?;
        probe.read().map_err(|e| HaudiotaggerError::OpenFile {
            message: e.to_string(),
        })?
    };

    let mut new_tag = LoftyTag::new(file.primary_tag_type());
    if !data.is_empty() {
        apply_tag_to_lofty_tag(&data, &mut new_tag)?;
    }
    file.insert_tag(new_tag);

    let mut out = Cursor::new(Vec::new());
    file.save_to(&mut out, WriteOptions::new())
        .map_err(|e| HaudiotaggerError::Write {
            message: format!("Failed to write tag to buffer. {e:?}"),
        })?;
    Ok(out.into_inner())
}

/// Clears the given `field` from `tag`.
fn clear_field(tag: &mut Tag, field: TagField) {
    match field {
        TagField::Title => tag.title = None,
        TagField::Artist => tag.track_artist = None,
        TagField::Album => tag.album = None,
        TagField::AlbumArtist => tag.album_artist = None,
        TagField::Year => tag.year = None,
        TagField::Genre => tag.genre = None,
        TagField::TrackNumber => tag.track_number = None,
        TagField::TrackTotal => tag.track_total = None,
        TagField::DiscNumber => tag.disc_number = None,
        TagField::DiscTotal => tag.disc_total = None,
        TagField::Lyrics => tag.lyrics = None,
        TagField::Comment => tag.comment = None,
        TagField::Bpm => tag.bpm = None,
        TagField::Pictures => tag.pictures = Vec::new(),
    }
}

/// Remove the given `fields` from the tag at `path`, keeping everything else.
pub fn remove(path: String, fields: Vec<TagField>) -> Result<(), HaudiotaggerError> {
    let mut tag = read_or_empty(&path)?;
    for field in fields {
        clear_field(&mut tag, field);
    }
    write(path, tag)
}

/// Remove the given `fields` from a tag held in `bytes`, returning the modified bytes.
pub fn remove_from_bytes(
    bytes: Vec<u8>,
    fields: Vec<TagField>,
) -> Result<Vec<u8>, HaudiotaggerError> {
    let mut tag = read_bytes_or_empty(&bytes)?;
    for field in fields {
        clear_field(&mut tag, field);
    }
    write_to_bytes(bytes, tag)
}

/// Remove all metadata from the file at `path`.
pub fn clear(path: String) -> Result<(), HaudiotaggerError> {
    write(path, Tag::default())
}

/// Remove all metadata from a tag held in `bytes`, returning the modified bytes.
pub fn clear_from_bytes(bytes: Vec<u8>) -> Result<Vec<u8>, HaudiotaggerError> {
    write_to_bytes(bytes, Tag::default())
}

/// Result of a batch operation on file paths.
#[derive(Debug, Clone)]
pub struct BatchResult {
    /// Number of files successfully processed.
    pub successes: u32,
    /// Number of files that failed.
    pub failures: u32,
    /// Paths that failed, paired with error messages.
    pub errors: Vec<(String, String)>,
}

/// Result of a batch operation on in-memory bytes.
#[derive(Debug, Clone)]
pub struct BatchBytesResult {
    /// Successfully processed byte arrays, in the same order as input.
    pub results: Vec<Vec<u8>>,
    /// Number of files that failed.
    pub failures: u32,
    /// Indices that failed (0-based), paired with error messages.
    pub errors: Vec<(u32, String)>,
}

/// Write the same tag to multiple files. Returns the number of successes and failures.
pub fn batch_write(paths: Vec<String>, data: Tag) -> BatchResult {
    let len = paths.len();

    // Pre-build and serialize the tag once for all files.
    let prebuilt_tag: Result<Vec<u8>, HaudiotaggerError> = if data.is_empty() {
        Ok(Vec::new())
    } else {
        let mut lo_tag = LoftyTag::new(TagType::Id3v2);
        let mut tag_bytes = Vec::with_capacity(1024);
        match apply_tag_to_lofty_tag(&data, &mut lo_tag) {
            Ok(()) => {}
            Err(e) => return err_result_batch(len, e),
        }
        match lo_tag.dump_to(&mut tag_bytes, WriteOptions::new()) {
            Ok(()) => Ok(tag_bytes),
            Err(e) => {
                return err_result_batch(
                    len,
                    HaudiotaggerError::Write {
                        message: format!("Could not serialize tag: {e:?}"),
                    },
                );
            }
        }
    };

    let processed: Vec<(String, Result<(), HaudiotaggerError>)> = match &prebuilt_tag {
        Ok(tag_bytes) => {
            // Fast path: tag already serialized, just strip audio and concat.
            paths
                .into_par_iter()
                .map(|path| {
                    let bytes = std::fs::read(&path).map_err(|e| HaudiotaggerError::OpenFile {
                        message: format!("Could not read file: {e}"),
                    })?;
                    let audio = strip_ape(strip_id3v1(strip_id3v2(&bytes)));
                    let mut out = Vec::with_capacity(tag_bytes.len() + audio.len());
                    out.extend_from_slice(tag_bytes);
                    out.extend_from_slice(audio);
                    std::fs::write(&path, out).map_err(|e| HaudiotaggerError::Write {
                        message: format!("Could not write file: {e}"),
                    })?;
                    Ok(())
                })
                .map(|r| (String::new(), r))
                .collect()
        }
        Err(e) => {
            let err_msg = e.to_string();
            paths
                .into_iter()
                .map(|path| {
                    (
                        path,
                        Err(HaudiotaggerError::Write {
                            message: err_msg.clone(),
                        }),
                    )
                })
                .collect()
        }
    };

    let mut successes = 0u32;
    let mut failures = 0u32;
    let mut errors = Vec::new();

    for (path, result) in processed {
        match result {
            Ok(()) => successes += 1,
            Err(e) => {
                failures += 1;
                errors.push((path, e.to_string()));
            }
        }
    }

    BatchResult {
        successes,
        failures,
        errors,
    }
}

/// Apply the same [TagChanges] to multiple files. Returns the number of successes and failures.
pub fn batch_update_changes(paths: Vec<String>, changes: TagChanges) -> BatchResult {
    let processed: Vec<(String, Result<(), HaudiotaggerError>)> = paths
        .into_par_iter()
        .map(|path| {
            let base = match read_or_empty(&path) {
                Ok(tag) => tag,
                Err(e) => return (path, Err(e)),
            };
            let merged = changes.merge(&base);
            let result = write(path.clone(), merged);
            (path, result)
        })
        .collect();

    let mut successes = 0u32;
    let mut failures = 0u32;
    let mut errors = Vec::new();

    for (path, result) in processed {
        match result {
            Ok(()) => successes += 1,
            Err(e) => {
                failures += 1;
                errors.push((path, e.to_string()));
            }
        }
    }

    BatchResult {
        successes,
        failures,
        errors,
    }
}

/// Helper: return a BatchBytesResult with the same error for all `count` entries.
fn err_result(count: usize, err: HaudiotaggerError) -> BatchBytesResult {
    let msg = err.to_string();
    BatchBytesResult {
        results: Vec::new(),
        failures: count as u32,
        errors: (0..count as u32).map(|i| (i, msg.clone())).collect(),
    }
}

/// Helper: return a BatchResult with the same error for all `count` entries.
fn err_result_batch(count: usize, err: HaudiotaggerError) -> BatchResult {
    let msg = err.to_string();
    BatchResult {
        successes: 0,
        failures: count as u32,
        errors: (0..count)
            .map(|i| (format!("file_{i}"), msg.clone()))
            .collect(),
    }
}

/// Write the same tag to multiple in-memory byte arrays. Returns modified bytes.
///
/// Optimized path: builds the lofty tag and serializes it **once**, then
/// reuses the pre-serialized bytes for every file. This eliminates redundant
/// tag construction and serialization across the batch.
pub fn batch_write_from_bytes(byte_arrays: Vec<Vec<u8>>, data: Tag) -> BatchBytesResult {
    let len = byte_arrays.len();

    // Pre-build and serialize the tag once for all files.
    let prebuilt_tag: Result<Vec<u8>, HaudiotaggerError> = if data.is_empty() {
        Ok(Vec::new())
    } else {
        let mut lo_tag = LoftyTag::new(TagType::Id3v2);
        let mut tag_bytes = Vec::with_capacity(1024);
        match apply_tag_to_lofty_tag(&data, &mut lo_tag) {
            Ok(()) => {}
            Err(e) => return err_result(len, e),
        }
        match lo_tag.dump_to(&mut tag_bytes, WriteOptions::new()) {
            Ok(()) => Ok(tag_bytes),
            Err(e) => {
                return err_result(
                    len,
                    HaudiotaggerError::Write {
                        message: format!("Could not serialize tag: {e:?}"),
                    },
                );
            }
        }
    };

    let processed: Vec<(usize, Result<Vec<u8>, HaudiotaggerError>)> = match &prebuilt_tag {
        Ok(tag_bytes) => {
            // Fast path: tag already serialized, just strip audio and concat.
            byte_arrays
                .into_par_iter()
                .enumerate()
                .map(|(i, bytes)| {
                    let audio = strip_ape(strip_id3v1(strip_id3v2(&bytes)));
                    let mut out = Vec::with_capacity(tag_bytes.len() + audio.len());
                    out.extend_from_slice(tag_bytes);
                    out.extend_from_slice(audio);
                    (i, Ok(out))
                })
                .collect()
        }
        Err(e) => {
            // Tag build failed — return error for all files.
            let err_msg = e.to_string();
            byte_arrays
                .into_iter()
                .enumerate()
                .map(|(i, _)| {
                    (
                        i,
                        Err(HaudiotaggerError::Write {
                            message: err_msg.clone(),
                        }),
                    )
                })
                .collect()
        }
    };

    let mut results = Vec::with_capacity(len);
    let mut errors = Vec::new();
    let mut failures = 0u32;

    for (i, result) in processed {
        match result {
            Ok(modified) => results.push(modified),
            Err(e) => {
                failures += 1;
                errors.push((i as u32, e.to_string()));
            }
        }
    }

    BatchBytesResult {
        results,
        failures,
        errors,
    }
}

/// Apply the same [TagChanges] to multiple in-memory byte arrays. Returns modified bytes.
pub fn batch_update_changes_from_bytes(
    byte_arrays: Vec<Vec<u8>>,
    changes: TagChanges,
) -> BatchBytesResult {
    let len = byte_arrays.len();

    let processed: Vec<(usize, Result<Vec<u8>, HaudiotaggerError>)> = byte_arrays
        .into_par_iter()
        .enumerate()
        .map(|(i, bytes)| {
            (
                i,
                super::tag_changes::update_from_bytes(bytes, changes.clone()),
            )
        })
        .collect();

    let mut results = Vec::with_capacity(len);
    let mut errors = Vec::new();
    let mut failures = 0u32;

    for (i, result) in processed {
        match result {
            Ok(modified) => results.push(modified),
            Err(e) => {
                failures += 1;
                errors.push((i as u32, e.to_string()));
            }
        }
    }

    BatchBytesResult {
        results,
        failures,
        errors,
    }
}

fn extract_tag_formats(file: &TaggedFile) -> Result<Vec<String>, HaudiotaggerError> {
    let formats = file
        .tags()
        .iter()
        .map(|t| format_tag_type(t.tag_type()).to_string())
        .collect::<std::collections::HashSet<_>>()
        .into_iter()
        .collect();
    Ok(formats)
}

/// Returns the list of tag formats present in the file at `path`.
/// Possible values: "ID3v1", "ID3v2", "APE", "iTunes", "VorbisComments", "RiffInfo", "AiffText".
pub fn get_tag_formats(path: String) -> Result<Vec<String>, HaudiotaggerError> {
    let file = get_file(&path)?;
    extract_tag_formats(&file)
}

/// Returns the list of tag formats present in the in-memory `bytes`.
/// Possible values: "ID3v1", "ID3v2", "APE", "iTunes", "VorbisComments", "RiffInfo", "AiffText".
pub fn get_tag_formats_from_bytes(bytes: Vec<u8>) -> Result<Vec<String>, HaudiotaggerError> {
    let file = get_file_from_bytes(&bytes)?;
    extract_tag_formats(&file)
}

fn format_tag_type(tag_type: TagType) -> &'static str {
    match tag_type {
        TagType::Id3v1 => "ID3v1",
        TagType::Id3v2 => "ID3v2",
        TagType::Ape => "APE",
        TagType::Mp4Ilst => "iTunes",
        TagType::VorbisComments => "VorbisComments",
        TagType::RiffInfo => "RiffInfo",
        TagType::AiffText => "AiffText",
        _ => "Unknown",
    }
}

/// Get all custom tags from the file at `path`.
/// Returns a map of key -> value for format-specific custom tags.
/// For ID3v2: TXXX frames (user-defined text).
/// For Vorbis Comments: non-standard keys.
/// For APE: non-standard keys.
pub fn get_custom_tags(
    path: String,
) -> Result<std::collections::HashMap<String, String>, HaudiotaggerError> {
    let file = get_file(&path)?;
    extract_custom_tags_from_file(&file)
}

/// Get all custom tags from in-memory `bytes`.
pub fn get_custom_tags_from_bytes(
    bytes: Vec<u8>,
) -> Result<std::collections::HashMap<String, String>, HaudiotaggerError> {
    let file = get_file_from_bytes(&bytes)?;
    extract_custom_tags_from_file(&file)
}

fn extract_custom_tags_from_file(
    file: &TaggedFile,
) -> Result<std::collections::HashMap<String, String>, HaudiotaggerError> {
    let tag = match file.primary_tag() {
        Some(tag) => tag,
        None => match file.first_tag() {
            Some(tag) => tag,
            None => return Err(HaudiotaggerError::NoTags),
        },
    };
    extract_custom_tags_from_lofty_tag(tag)
}

fn extract_custom_tags_from_lofty_tag(
    tag: &LoftyTag,
) -> Result<std::collections::HashMap<String, String>, HaudiotaggerError> {
    let mut custom_tags = std::collections::HashMap::new();

    match tag.tag_type() {
        TagType::Id3v2 => {
            // Convert to Id3v2Tag to access TXXX frames
            let id3v2: lofty::id3::v2::Id3v2Tag = tag.clone().into();
            for frame in &id3v2 {
                if let lofty::id3::v2::Frame::UserText(extended_text) = frame {
                    let description = extended_text.description.to_string();
                    let content = extended_text.content.to_string();
                    if !description.is_empty() {
                        custom_tags.insert(description, content);
                    }
                }
            }
        }
        TagType::VorbisComments => {
            // Vorbis Comments: convert and iterate
            let vorbis: lofty::ogg::tag::VorbisComments = tag.clone().into();
            for (key, value) in vorbis.items() {
                // Filter out standard keys
                if !is_standard_vorbis_key(key) {
                    custom_tags.insert(key.to_string(), value.to_string());
                }
            }
        }
        _ => {
            // Custom tags only supported for ID3v2 and Vorbis
        }
    }

    Ok(custom_tags)
}

fn is_standard_vorbis_key(key: &str) -> bool {
    matches!(
        key.to_lowercase().as_str(),
        "title"
            | "artist"
            | "album"
            | "albumartist"
            | "date"
            | "year"
            | "genre"
            | "tracknumber"
            | "tracktotal"
            | "discnumber"
            | "disctotal"
            | "lyrics"
            | "comment"
            | "bpm"
            | "composer"
            | "conductor"
            | "isrc"
            | "label"
            | "copyright"
            | "description"
    )
}

fn set_custom_tag_impl(
    file: &TaggedFile,
    key: String,
    value: String,
) -> Result<LoftyTag, HaudiotaggerError> {
    let tag_type = file.primary_tag_type();

    let mut new_tag = LoftyTag::new(tag_type);

    // First apply existing standard tags
    if let Some(existing_tag) = file.primary_tag() {
        let std_tag = Tag::from(existing_tag);
        apply_tag_to_lofty_tag(&std_tag, &mut new_tag)?;
    }

    // Now apply the custom tag based on format
    match tag_type {
        TagType::Id3v2 => {
            let mut id3v2: lofty::id3::v2::Id3v2Tag = new_tag.into();
            id3v2.insert_user_text(key, value);
            new_tag = id3v2.into();
        }
        TagType::VorbisComments => {
            let mut vorbis: lofty::ogg::tag::VorbisComments = new_tag.into();
            vorbis.insert(key, value);
            new_tag = vorbis.into();
        }
        _ => {
            return Err(HaudiotaggerError::Write {
                message: "Custom tags only supported for ID3v2 and Vorbis formats".to_string(),
            });
        }
    }

    Ok(new_tag)
}

/// Set a custom tag on the file at `path`.
/// For ID3v2: creates a TXXX frame with the key as description.
/// For Vorbis Comments: inserts with the key directly.
/// For APE: inserts with the key directly.
pub fn set_custom_tag(path: String, key: String, value: String) -> Result<(), HaudiotaggerError> {
    let mut file = get_file(&path)?;
    let new_tag = set_custom_tag_impl(&file, key, value)?;
    file.insert_tag(new_tag);
    file.save_to_path(&path, WriteOptions::new())
        .map_err(|e| HaudiotaggerError::Write {
            message: format!("Failed to write custom tag: {e}"),
        })
}

/// Set a custom tag on in-memory `bytes`, returning the modified bytes.
pub fn set_custom_tag_from_bytes(
    bytes: Vec<u8>,
    key: String,
    value: String,
) -> Result<Vec<u8>, HaudiotaggerError> {
    if is_mp3("", &bytes) {
        return write_lofty_tag_to_mp3_bytes(&bytes, |lo_tag| match lo_tag.tag_type() {
            TagType::Id3v2 => {
                let mut id3v2: lofty::id3::v2::Id3v2Tag = lo_tag.into();
                id3v2.insert_user_text(key, value);
                Ok(id3v2.into())
            }
            TagType::VorbisComments => {
                let mut vorbis: lofty::ogg::tag::VorbisComments = lo_tag.into();
                vorbis.insert(key, value);
                Ok(vorbis.into())
            }
            _ => Err(HaudiotaggerError::Write {
                message: "Custom tags only supported for ID3v2 and Vorbis formats".to_string(),
            }),
        });
    }
    let mut file = get_file_from_bytes(&bytes)?;
    let new_tag = set_custom_tag_impl(&file, key, value)?;
    file.insert_tag(new_tag);
    let mut out = Cursor::new(Vec::new());
    file.save_to(&mut out, WriteOptions::new())
        .map_err(|e| HaudiotaggerError::Write {
            message: format!("Failed to write custom tag: {e}"),
        })?;
    Ok(out.into_inner())
}

fn remove_custom_tag_impl(file: &TaggedFile, key: String) -> Result<LoftyTag, HaudiotaggerError> {
    let tag_type = file.primary_tag_type();

    let mut new_tag = LoftyTag::new(tag_type);

    // First apply existing standard tags
    if let Some(existing_tag) = file.primary_tag() {
        let std_tag = Tag::from(existing_tag);
        apply_tag_to_lofty_tag(&std_tag, &mut new_tag)?;
    }

    // Now remove the custom tag based on format
    match tag_type {
        TagType::Id3v2 => {
            let mut id3v2: lofty::id3::v2::Id3v2Tag = new_tag.into();
            id3v2.remove_user_text(&key);
            new_tag = id3v2.into();
        }
        TagType::VorbisComments => {
            let mut vorbis: lofty::ogg::tag::VorbisComments = new_tag.into();
            // Consume the iterator to actually remove the items
            for _ in vorbis.remove(&key) {}
            new_tag = vorbis.into();
        }
        _ => {
            return Err(HaudiotaggerError::Write {
                message: "Custom tags only supported for ID3v2 and Vorbis formats".to_string(),
            });
        }
    }

    Ok(new_tag)
}

/// Remove a custom tag from the file at `path`.
pub fn remove_custom_tag(path: String, key: String) -> Result<(), HaudiotaggerError> {
    let mut file = get_file(&path)?;
    let new_tag = remove_custom_tag_impl(&file, key)?;
    file.insert_tag(new_tag);
    file.save_to_path(&path, WriteOptions::new())
        .map_err(|e| HaudiotaggerError::Write {
            message: format!("Failed to remove custom tag: {e}"),
        })
}

/// Remove a custom tag from in-memory `bytes`, returning the modified bytes.
pub fn remove_custom_tag_from_bytes(
    bytes: Vec<u8>,
    key: String,
) -> Result<Vec<u8>, HaudiotaggerError> {
    if is_mp3("", &bytes) {
        return write_lofty_tag_to_mp3_bytes(&bytes, |lo_tag| match lo_tag.tag_type() {
            TagType::Id3v2 => {
                let mut id3v2: lofty::id3::v2::Id3v2Tag = lo_tag.into();
                id3v2.remove_user_text(&key);
                Ok(id3v2.into())
            }
            TagType::VorbisComments => {
                let mut vorbis: lofty::ogg::tag::VorbisComments = lo_tag.into();
                for _ in vorbis.remove(&key) {}
                Ok(vorbis.into())
            }
            _ => Err(HaudiotaggerError::Write {
                message: "Custom tags only supported for ID3v2 and Vorbis formats".to_string(),
            }),
        });
    }
    let mut file = get_file_from_bytes(&bytes)?;
    let new_tag = remove_custom_tag_impl(&file, key)?;
    file.insert_tag(new_tag);
    let mut out = Cursor::new(Vec::new());
    file.save_to(&mut out, WriteOptions::new())
        .map_err(|e| HaudiotaggerError::Write {
            message: format!("Failed to remove custom tag: {e}"),
        })?;
    Ok(out.into_inner())
}

/// Represents the ID3v2 version to use when writing.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Id3v2Version {
    /// ID3v2.2 (3-character frame IDs, limited features)
    V2,
    /// ID3v2.3 (widely supported, recommended for compatibility)
    V3,
    /// ID3v2.4 (latest spec, but less software support)
    V4,
}

/// Get the ID3v2 version of the tag in the file at `path`.
/// Returns None if the file has no ID3v2 tag.
pub fn get_id3v2_version(path: String) -> Result<Option<Id3v2Version>, HaudiotaggerError> {
    let file = get_file(&path)?;
    extract_id3v2_version(&file)
}

/// Get the ID3v2 version of the tag in in-memory `bytes`.
/// Returns None if the bytes have no ID3v2 tag.
pub fn get_id3v2_version_from_bytes(
    bytes: Vec<u8>,
) -> Result<Option<Id3v2Version>, HaudiotaggerError> {
    let file = get_file_from_bytes(&bytes)?;
    extract_id3v2_version(&file)
}

fn extract_id3v2_version(file: &TaggedFile) -> Result<Option<Id3v2Version>, HaudiotaggerError> {
    for tag in file.tags() {
        if tag.tag_type() == TagType::Id3v2 {
            let id3v2: lofty::id3::v2::Id3v2Tag = tag.clone().into();
            let version = match id3v2.original_version() {
                lofty::id3::v2::Id3v2Version::V2 => Id3v2Version::V2,
                lofty::id3::v2::Id3v2Version::V3 => Id3v2Version::V3,
                lofty::id3::v2::Id3v2Version::V4 => Id3v2Version::V4,
            };
            return Ok(Some(version));
        }
    }
    Ok(None)
}

fn convert_id3v2_impl(
    std_tag: &Tag,
    version: Id3v2Version,
) -> Result<(Vec<u8>, WriteOptions), HaudiotaggerError> {
    let mut lo_tag = LoftyTag::new(TagType::Id3v2);
    apply_tag_to_lofty_tag(std_tag, &mut lo_tag)?;

    let mut write_options = WriteOptions::new();
    if version == Id3v2Version::V3 {
        write_options = write_options.use_id3v23(true);
    }

    let mut tag_bytes = Vec::new();
    lo_tag
        .dump_to(&mut tag_bytes, write_options.clone())
        .map_err(|e| HaudiotaggerError::Write {
            message: format!("Could not serialize tag: {e:?}"),
        })?;

    Ok((tag_bytes, write_options))
}

/// Convert the ID3v2 tag in the file at `path` to the specified version.
/// ID3v2.2 is not supported for writing (lofty doesn't support it).
/// ID3v2.3 uses `WriteOptions::use_id3v23(true)`.
/// ID3v2.4 uses default `WriteOptions`.
pub fn convert_id3v2(path: String, version: Id3v2Version) -> Result<(), HaudiotaggerError> {
    match version {
        Id3v2Version::V2 => {
            return Err(HaudiotaggerError::Write {
                message: "ID3v2.2 is not supported for writing. Use V3 or V4.".to_string(),
            });
        }
        Id3v2Version::V3 | Id3v2Version::V4 => {}
    }

    // Read the existing tag via our API
    let std_tag = read(path.clone())?;

    // Read raw bytes and strip existing tags
    let bytes = std::fs::read(&path).map_err(|e| HaudiotaggerError::OpenFile {
        message: format!("Could not read file: {e}"),
    })?;
    let audio = strip_ape(strip_id3v1(strip_id3v2(&bytes)));

    if std_tag.is_empty() {
        // No tag data, just write back the audio
        std::fs::write(&path, audio).map_err(|e| HaudiotaggerError::Write {
            message: format!("Could not write file: {e}"),
        })?;
        return Ok(());
    }

    let (tag_bytes, _) = convert_id3v2_impl(&std_tag, version)?;

    let mut out = tag_bytes;
    out.extend_from_slice(audio);
    std::fs::write(&path, out).map_err(|e| HaudiotaggerError::Write {
        message: format!("Could not write file: {e}"),
    })?;
    Ok(())
}

/// Convert the ID3v2 tag in in-memory `bytes` to the specified version, returning modified bytes.
pub fn convert_id3v2_from_bytes(
    bytes: Vec<u8>,
    version: Id3v2Version,
) -> Result<Vec<u8>, HaudiotaggerError> {
    match version {
        Id3v2Version::V2 => {
            return Err(HaudiotaggerError::Write {
                message: "ID3v2.2 is not supported for writing. Use V3 or V4.".to_string(),
            });
        }
        Id3v2Version::V3 | Id3v2Version::V4 => {}
    }

    let std_tag = read_from_bytes(bytes.clone())?;
    let audio = strip_ape(strip_id3v1(strip_id3v2(&bytes)));

    if std_tag.is_empty() {
        return Ok(audio.to_vec());
    }

    let (tag_bytes, _) = convert_id3v2_impl(&std_tag, version)?;

    let mut out = tag_bytes;
    out.extend_from_slice(audio);
    Ok(out)
}

fn remove_id3v1_impl(file: &mut TaggedFile) -> bool {
    let has_id3v1 = file.tags().iter().any(|t| t.tag_type() == TagType::Id3v1);
    if has_id3v1 {
        file.remove(TagType::Id3v1);
    }
    has_id3v1
}

/// Remove the ID3v1 tag from the file at `path`.
pub fn remove_id3v1(path: String) -> Result<(), HaudiotaggerError> {
    let mut file = get_file(&path)?;

    if !remove_id3v1_impl(&mut file) {
        return Ok(()); // Nothing to remove
    }

    file.save_to_path(&path, WriteOptions::new())
        .map_err(|e| HaudiotaggerError::Write {
            message: format!("Failed to remove ID3v1 tag: {e}"),
        })
}

/// Remove the ID3v1 tag from in-memory `bytes`, returning the modified bytes.
pub fn remove_id3v1_from_bytes(bytes: Vec<u8>) -> Result<Vec<u8>, HaudiotaggerError> {
    let mut file = get_file_from_bytes(&bytes)?;

    if !remove_id3v1_impl(&mut file) {
        return Ok(bytes); // Nothing to remove
    }

    let mut out = Cursor::new(Vec::new());
    file.save_to(&mut out, WriteOptions::new())
        .map_err(|e| HaudiotaggerError::Write {
            message: format!("Failed to remove ID3v1 tag: {e}"),
        })?;
    Ok(out.into_inner())
}

use super::audio_properties::AudioProperties;
use super::picture::Picture;

/// Comprehensive info about an audio file, returned by `inspect`.
#[derive(Debug, Clone)]
pub struct AudioFileInfo {
    /// The audio format (e.g. `MP3`, `FLAC`).
    pub format: String,
    /// The tag format (e.g. `ID3v2`, `VorbisComments`).
    pub tag_format: String,
    /// Technical audio properties.
    pub properties: AudioProperties,
    /// The metadata tag, if present.
    pub metadata: Option<Tag>,
    /// Embedded pictures, if any.
    pub pictures: Vec<Picture>,
    /// File size in bytes.
    pub size: u64,
}

fn tag_format_name(file: &TaggedFile) -> String {
    let primary = file.primary_tag().map(|t| t.tag_type());
    match primary {
        Some(TagType::Id3v2) => "ID3v2".into(),
        Some(TagType::Id3v1) => "ID3v1".into(),
        Some(TagType::VorbisComments) => "VorbisComments".into(),
        Some(TagType::Ape) => "APE".into(),
        Some(TagType::Mp4Ilst) => "iTunes".into(),
        Some(TagType::RiffInfo) => "RiffInfo".into(),
        Some(TagType::AiffText) => "AiffText".into(),
        _ => "Unknown".into(),
    }
}

fn file_format_name(ft: FileType) -> String {
    match ft {
        FileType::Aac => "AAC",
        FileType::Aiff => "AIFF",
        FileType::Ape => "APE",
        FileType::Flac => "FLAC",
        FileType::Mpeg => "MP3",
        FileType::Mp4 => "MP4",
        FileType::Mpc => "Musepack",
        FileType::Opus => "Opus",
        FileType::Vorbis => "Ogg Vorbis",
        FileType::Speex => "Speex",
        FileType::Wav => "WAV",
        FileType::WavPack => "WavPack",
        _ => "Unknown",
    }
    .into()
}

fn build_file_info(file: &TaggedFile, file_size: u64) -> AudioFileInfo {
    use lofty::file::AudioFile;
    let format = file_format_name(file.file_type());
    let tag_format = tag_format_name(file);

    let props = file.properties();
    let (codec, container_format, lossless) = match file.file_type() {
        FileType::Aac => ("AAC".into(), "ADTS".into(), false),
        FileType::Aiff => ("AIFF".into(), "AIFF".into(), false),
        FileType::Ape => ("APE".into(), "APE".into(), true),
        FileType::Flac => ("FLAC".into(), "FLAC".into(), true),
        FileType::Mpeg => ("MP3".into(), "MP3".into(), false),
        FileType::Mp4 => ("AAC".into(), "MP4".into(), false),
        FileType::Mpc => ("Musepack".into(), "Musepack".into(), false),
        FileType::Opus => ("Opus".into(), "Ogg".into(), false),
        FileType::Vorbis => ("Vorbis".into(), "Ogg".into(), false),
        FileType::Speex => ("Speex".into(), "Ogg".into(), false),
        FileType::Wav => ("PCM".into(), "WAV".into(), true),
        FileType::WavPack => ("WavPack".into(), "WavPack".into(), true),
        _ => ("Unknown".into(), "Unknown".into(), false),
    };

    let properties = AudioProperties {
        duration_micros: Some(props.duration().as_micros() as i64),
        bitrate: props.overall_bitrate().or_else(|| props.audio_bitrate()),
        sample_rate: props.sample_rate(),
        channels: props.channels().map(u32::from),
        bits_per_sample: props.bit_depth().map(u32::from),
        codec,
        container_format,
        lossless,
        bitrate_mode: super::audio_properties::BitrateMode::Unknown,
        file_size: Some(file_size),
    };

    let (metadata, pictures) = match tag_from_file(file) {
        Ok(tag) => {
            let pictures = tag.pictures.clone();
            (Some(tag), pictures)
        }
        Err(_) => (None, vec![]),
    };

    AudioFileInfo {
        format,
        tag_format,
        properties,
        metadata,
        pictures,
        size: file_size,
    }
}

/// Inspect an audio file, returning all available information in one call.
pub fn inspect(path: String) -> Result<AudioFileInfo, HaudiotaggerError> {
    let file = get_file(&path)?;
    let file_size =
        std::fs::metadata(&path)
            .map(|m| m.len())
            .map_err(|e| HaudiotaggerError::OpenFile {
                message: format!("Cannot read file metadata: {e}"),
            })?;
    Ok(build_file_info(&file, file_size))
}

/// Inspect audio data from in-memory bytes.
pub fn inspect_from_bytes(bytes: Vec<u8>) -> Result<AudioFileInfo, HaudiotaggerError> {
    let file = get_file_from_bytes(&bytes)?;
    Ok(build_file_info(&file, bytes.len() as u64))
}

/// Validate the tag at `path` and return any issues found.
pub fn validate(path: String) -> Result<super::validation::ValidationResult, HaudiotaggerError> {
    let tag = read(path)?;
    Ok(super::validation::validate(&tag))
}

/// Validate in-memory `bytes` and return any issues found.
pub fn validate_from_bytes(
    bytes: Vec<u8>,
) -> Result<super::validation::ValidationResult, HaudiotaggerError> {
    let tag = read_from_bytes(bytes)?;
    Ok(super::validation::validate(&tag))
}

/// Validate a Tag directly (for use after manual edits).
pub fn validate_tag(tag: Tag) -> super::validation::ValidationResult {
    super::validation::validate(&tag)
}

/// Normalize the tag at [path] using default options, returning the cleaned tag.
/// Does NOT write to disk — use [write] to persist the result.
pub fn normalize(path: String) -> Result<Tag, HaudiotaggerError> {
    let tag = read(path)?;
    Ok(super::normalization::normalize(
        &tag,
        &super::normalization::NormalizeOptions::default(),
    ))
}

/// Normalize in-memory bytes using default options, returning the cleaned bytes.
pub fn normalize_bytes(bytes: Vec<u8>) -> Result<Vec<u8>, HaudiotaggerError> {
    let tag = read_from_bytes(bytes.clone())?;
    let normalized =
        super::normalization::normalize(&tag, &super::normalization::NormalizeOptions::default());
    write_to_bytes(bytes, normalized)
}

/// Normalize a Tag directly with custom options.
pub fn normalize_tag(tag: Tag, options: super::normalization::NormalizeOptions) -> Tag {
    super::normalization::normalize(&tag, &options)
}

/// Format a filename from a tag using a pattern string.
///
/// Supported placeholders:
/// `{title}`, `{artist}`, `{album}`, `{albumArtist}`, `{track}`,
/// `{trackTotal}`, `{disc}`, `{discTotal}`, `{year}`, `{genre}`
///
/// Example: `format_filename(tag, "{track}. {title}")` → `"01. My Song"`
pub fn format_filename(tag: &Tag, pattern: &str) -> String {
    let replacements: Vec<(&str, String)> = vec![
        ("{title}", tag.title.clone().unwrap_or_default()),
        ("{artist}", tag.track_artist.clone().unwrap_or_default()),
        ("{album}", tag.album.clone().unwrap_or_default()),
        (
            "{albumArtist}",
            tag.album_artist.clone().unwrap_or_default(),
        ),
        (
            "{track}",
            tag.track_number
                .map(|n| format!("{n:02}"))
                .unwrap_or_default(),
        ),
        (
            "{trackTotal}",
            tag.track_total.map(|n| n.to_string()).unwrap_or_default(),
        ),
        (
            "{disc}",
            tag.disc_number.map(|n| n.to_string()).unwrap_or_default(),
        ),
        (
            "{discTotal}",
            tag.disc_total.map(|n| n.to_string()).unwrap_or_default(),
        ),
        (
            "{year}",
            tag.year.map(|n| n.to_string()).unwrap_or_default(),
        ),
        ("{genre}", tag.genre.clone().unwrap_or_default()),
    ];

    let mut result = pattern.to_string();
    for (placeholder, value) in &replacements {
        result = result.replace(placeholder, value);
    }

    // Clean up multiple spaces and leading/trailing whitespace
    while result.contains("  ") {
        result = result.replace("  ", " ");
    }
    result = result.trim().to_string();

    // Remove trailing dots, dashes, or spaces
    while result.ends_with('.') || result.ends_with('-') || result.ends_with(' ') {
        result.pop();
    }

    result
}

/// Rename a file based on its metadata using a pattern.
///
/// Returns the new file path on success.
pub fn rename_file(path: String, pattern: String) -> Result<String, HaudiotaggerError> {
    let tag = read(path.clone())?;
    let new_name = format_filename(&tag, &pattern);

    let file_path = std::path::Path::new(&path);
    let dir = file_path
        .parent()
        .ok_or_else(|| HaudiotaggerError::OpenFile {
            message: "Could not get parent directory".to_string(),
        })?;

    let extension = file_path
        .extension()
        .and_then(|e| e.to_str())
        .unwrap_or("mp3");

    let new_path = dir.join(format!("{new_name}.{extension}"));
    let new_path_str = new_path.to_string_lossy().to_string();

    std::fs::rename(&path, &new_path).map_err(|e| HaudiotaggerError::OpenFile {
        message: format!("Could not rename file: {e}"),
    })?;

    Ok(new_path_str)
}

/// Apply a pipeline of transformation rules to a tag.
pub fn apply_pipeline(tag: Tag, rules: Vec<super::pipeline::TransformRule>) -> Tag {
    let pipeline = super::pipeline::TagPipeline::from_rules(rules);
    pipeline.apply(&tag)
}

/// Apply a pipeline of rules to multiple files. Returns successes and failures.
pub fn batch_transform(
    paths: Vec<String>,
    rules: Vec<super::pipeline::TransformRule>,
) -> BatchResult {
    let pipeline = super::pipeline::TagPipeline::from_rules(rules);

    let processed: Vec<(String, Result<(), HaudiotaggerError>)> = paths
        .into_par_iter()
        .map(|path| {
            let tag = match read(path.clone()) {
                Ok(t) => t,
                Err(e) => return (path, Err(e)),
            };
            let transformed = pipeline.apply(&tag);
            let result = write(path.clone(), transformed);
            (path, result)
        })
        .collect();

    let successes = processed.iter().filter(|(_, r)| r.is_ok()).count() as u32;
    let failures = processed.iter().filter(|(_, r)| r.is_err()).count() as u32;
    let errors: Vec<(String, String)> = processed
        .into_iter()
        .filter_map(|(path, result)| result.err().map(|e| (path, e.to_string())))
        .collect();

    BatchResult {
        successes,
        failures,
        errors,
    }
}
