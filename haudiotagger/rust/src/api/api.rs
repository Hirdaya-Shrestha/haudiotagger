use std::io::Cursor;

use super::{
    error::HaudiotaggerError,
    tag::Tag,
    tag_changes::{read_bytes_or_empty, read_or_empty},
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
fn strip_id3v1(bytes: &[u8]) -> &[u8] {
    if bytes.len() >= 128 && &bytes[bytes.len() - 128..bytes.len() - 125] == b"TAG" {
        return &bytes[..bytes.len() - 128];
    }
    bytes
}

/// Strip a trailing APEv2 tag (footer "APETAGEX" at the end; its size field
/// covers the whole tag including the footer).
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
        return Ok(audio.to_vec());
    }

    let mut lo_tag = LoftyTag::new(TagType::Id3v2);
    apply_tag_to_lofty_tag(&data, &mut lo_tag)?;

    let mut tag_bytes = Vec::new();
    lo_tag
        .dump_to(&mut tag_bytes, WriteOptions::new())
        .map_err(|e| HaudiotaggerError::Write {
            message: format!("Could not serialize tag: {e:?}"),
        })?;

    let mut out = tag_bytes;
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
