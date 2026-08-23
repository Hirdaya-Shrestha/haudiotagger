use super::{error::HaudiotaggerError, tag::Tag};
use lofty::config::WriteOptions;
use lofty::file::TaggedFile;
use lofty::file::{AudioFile, TaggedFileExt};
use lofty::probe::Probe;
use lofty::tag::items::Timestamp;
use lofty::tag::{Accessor, ItemKey, TagExt};

/// Returns a `TaggedFile` at the given path.
fn get_file(path: &str) -> Result<TaggedFile, HaudiotaggerError> {
    match Probe::open(path) {
        Ok(probe) => match probe.read() {
            Ok(file) => Ok(file),
            Err(err) => Err(HaudiotaggerError::OpenFile {
                message: err.to_string(),
            }),
        },
        Err(err) => Err(HaudiotaggerError::OpenFile {
            message: err.to_string(),
        }),
    }
}

pub fn read(path: String) -> Result<Tag, HaudiotaggerError> {
    let file = get_file(&path)?;

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

pub fn write(path: String, data: Tag) -> Result<(), HaudiotaggerError> {
    let mut file = get_file(&path)?;

    // Remove the existing tags.
    for tag in file.tags() {
        if let Err(err) = tag.remove_from_path(&path, WriteOptions::new()) {
            return Err(HaudiotaggerError::Write {
                message: format!("Could not remove existing tag. {err:?}"),
            });
        }
    }

    // If there is no data to be written, then return.
    if data.is_empty() {
        return Ok(());
    }

    // Create a new tag.
    file.insert_tag(lofty::tag::Tag::new(file.primary_tag_type()));
    let tag = file
        .primary_tag_mut()
        .ok_or_else(|| HaudiotaggerError::Write {
            message: "Failed to create primary tag for this format".to_string(),
        })?;

    // Title
    if let Some(title) = data.title {
        tag.insert_text(ItemKey::TrackTitle, title);
    }

    // Track Artist
    if let Some(track_artist) = data.track_artist {
        tag.insert_text(ItemKey::TrackArtist, track_artist);
    }

    // Album Title
    if let Some(album) = data.album {
        tag.insert_text(ItemKey::AlbumTitle, album);
    }

    // Album Artist
    if let Some(album_artist) = data.album_artist {
        tag.insert_text(ItemKey::AlbumArtist, album_artist);
    }

    // Year
    if let Some(year) = data.year {
        if year > u16::MAX as u32 {
            return Err(HaudiotaggerError::Write {
                message: format!("Year {year} out of valid range"),
            });
        }
        tag.set_date(Timestamp {
            year: year as u16,
            ..Default::default()
        });
    }

    // Track number
    if let Some(track_number) = data.track_number {
        tag.set_track(track_number);
    }

    // Track total
    if let Some(track_total) = data.track_total {
        tag.set_track_total(track_total);
    }

    // Disc number
    if let Some(disc_number) = data.disc_number {
        tag.set_disk(disc_number);
    }

    // Disc total
    if let Some(disc_total) = data.disc_total {
        tag.set_disk_total(disc_total);
    }

    // Genre
    if let Some(genre) = data.genre {
        tag.insert_text(ItemKey::Genre, genre);
    }

    // Pictures
    for (i, picture) in data.pictures.into_iter().enumerate() {
        let mut builder =
            lofty::picture::Picture::unchecked(picture.bytes).pic_type(picture.picture_type.into());
        if let Some(mime_type) = picture.mime_type {
            builder = builder.mime_type(mime_type.into());
        }
        tag.set_picture(i, builder.build());
    }

    // Lyrics
    if let Some(lyrics) = data.lyrics {
        tag.insert_text(ItemKey::Lyrics, lyrics);
    }

    // Bpm
    if let Some(bpm) = data.bpm {
        if !tag.insert_text(ItemKey::Bpm, bpm.to_string()) {
            tag.insert_text(ItemKey::IntegerBpm, (bpm as u32).to_string());
        }
    }

    match tag.save_to_path(path, WriteOptions::new()) {
        Ok(_) => Ok(()),
        Err(err) => Err(HaudiotaggerError::Write {
            message: format!("Failed to write tag to file. {err:?}"),
        }),
    }
}
