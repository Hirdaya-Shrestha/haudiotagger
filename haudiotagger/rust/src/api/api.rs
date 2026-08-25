use std::io::Cursor;

use super::{error::HaudiotaggerError, tag::Tag};
use lofty::config::WriteOptions;
use lofty::file::TaggedFile;
use lofty::file::{AudioFile, TaggedFileExt};
use lofty::probe::Probe;
use lofty::tag::items::Timestamp;
use lofty::tag::{Accessor, ItemKey, TagType};

/// Returns a `TaggedFile` at the given path.
fn get_file(path: &str) -> Result<TaggedFile, HaudiotaggerError> {
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
fn get_file_from_bytes(bytes: &[u8]) -> Result<TaggedFile, HaudiotaggerError> {
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

pub fn write(path: String, data: Tag) -> Result<(), HaudiotaggerError> {
    let mut file = get_file(&path)?;

    // Remove every existing tag from the file so the new tag fully replaces them.
    // `TagType::remove_from` is used (not `remove_from_path`) because the latter
    // opens a probe without guessing the file type and fails with `format: None`.
    let tag_types: Vec<lofty::tag::TagType> = file.tags().iter().map(|t| t.tag_type()).collect();
    if !tag_types.is_empty() {
        let mut handle = std::fs::OpenOptions::new()
            .read(true)
            .write(true)
            .open(&path)
            .map_err(|e| HaudiotaggerError::Write {
                message: format!("Could not open file for tag removal: {e}"),
            })?;
        for tag_type in tag_types {
            tag_type
                .remove_from(&mut handle, WriteOptions::new())
                .map_err(|e| HaudiotaggerError::Write {
                    message: format!("Could not remove existing tag: {e:?}"),
                })?;
        }
    }

    // Drop the stale in-memory tags, then write the new one (if any).
    file.clear();

    if data.is_empty() {
        return Ok(());
    }

    file.insert_tag(lofty::tag::Tag::new(file.primary_tag_type()));
    let lo_tag = file
        .primary_tag_mut()
        .ok_or_else(|| HaudiotaggerError::Write {
            message: "Failed to create primary tag for this format".to_string(),
        })?;

    apply_tag_to_lofty_tag(&data, lo_tag)?;

    file.save_to_path(&path, WriteOptions::new())
        .map_err(|e| HaudiotaggerError::Write {
            message: format!("Failed to write tag to file. {e:?}"),
        })
}

/// Write metadata to in-memory bytes, returns modified bytes (for web/WASM).
pub fn write_to_bytes(bytes: Vec<u8>, data: Tag) -> Result<Vec<u8>, HaudiotaggerError> {
    let tag_types: Vec<lofty::tag::TagType> = {
        let mut cursor = Cursor::new(&bytes);
        let probe =
            Probe::new(&mut cursor)
                .guess_file_type()
                .map_err(|e| HaudiotaggerError::OpenFile {
                    message: e.to_string(),
                })?;
        probe
            .read()
            .map_err(|e| HaudiotaggerError::OpenFile {
                message: e.to_string(),
            })?
            .tags()
            .iter()
            .map(|t| t.tag_type())
            .collect()
    };

    // Strip existing tags from the bytes before writing the new tag.
    let cleared_bytes = if tag_types.is_empty() {
        bytes
    } else {
        let mut handle = Cursor::new(bytes);
        for tag_type in tag_types {
            tag_type
                .remove_from(&mut handle, WriteOptions::new())
                .map_err(|e| HaudiotaggerError::Write {
                    message: format!("Could not remove existing tag: {e:?}"),
                })?;
        }
        handle.into_inner()
    };

    if data.is_empty() {
        return Ok(cleared_bytes);
    }

    let mut file = {
        let mut cursor = Cursor::new(&cleared_bytes);
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

    file.clear();
    file.insert_tag(lofty::tag::Tag::new(file.primary_tag_type()));
    let lo_tag = file
        .primary_tag_mut()
        .ok_or_else(|| HaudiotaggerError::Write {
            message: "Failed to create primary tag for this format".to_string(),
        })?;

    apply_tag_to_lofty_tag(&data, lo_tag)?;

    let mut out = Cursor::new(Vec::new());
    file.save_to(&mut out, WriteOptions::new())
        .map_err(|e| HaudiotaggerError::Write {
            message: format!("Failed to write tag to buffer. {e:?}"),
        })?;
    Ok(out.into_inner())
}
