use crate::api::api::{read, read_from_bytes, write, write_to_bytes};
use crate::api::error::HaudiotaggerError;
use crate::api::picture::Picture;
use crate::api::tag::Tag;

/// A partial set of tag fields to apply on top of an existing tag.
///
/// Every field is optional. When applying via `update`, a `Some` value replaces
/// the corresponding field on the existing tag, while `None` leaves it untouched.
#[derive(Debug, Clone, Default)]
pub struct TagChanges {
    pub title: Option<String>,
    pub track_artist: Option<String>,
    pub album: Option<String>,
    pub album_artist: Option<String>,
    pub year: Option<u32>,
    pub genre: Option<String>,
    pub track_number: Option<u32>,
    pub track_total: Option<u32>,
    pub disc_number: Option<u32>,
    pub disc_total: Option<u32>,
    pub lyrics: Option<String>,
    pub comment: Option<String>,
    pub pictures: Option<Vec<Picture>>,
    pub bpm: Option<f32>,
}

impl TagChanges {
    /// Returns `true` if no fields are set.
    pub fn is_empty(&self) -> bool {
        self.title.is_none()
            && self.track_artist.is_none()
            && self.album.is_none()
            && self.album_artist.is_none()
            && self.year.is_none()
            && self.genre.is_none()
            && self.track_number.is_none()
            && self.track_total.is_none()
            && self.disc_number.is_none()
            && self.disc_total.is_none()
            && self.lyrics.is_none()
            && self.comment.is_none()
            && self.pictures.is_none()
            && self.bpm.is_none()
    }

    /// Merges these changes onto `base`, returning the combined tag.
    fn merge(&self, base: &Tag) -> Tag {
        Tag {
            title: self.title.clone().or_else(|| base.title.clone()),
            track_artist: self
                .track_artist
                .clone()
                .or_else(|| base.track_artist.clone()),
            album: self.album.clone().or_else(|| base.album.clone()),
            album_artist: self
                .album_artist
                .clone()
                .or_else(|| base.album_artist.clone()),
            year: self.year.or(base.year),
            genre: self.genre.clone().or_else(|| base.genre.clone()),
            track_number: self.track_number.or(base.track_number),
            track_total: self.track_total.or(base.track_total),
            disc_number: self.disc_number.or(base.disc_number),
            disc_total: self.disc_total.or(base.disc_total),
            lyrics: self.lyrics.clone().or_else(|| base.lyrics.clone()),
            comment: self.comment.clone().or_else(|| base.comment.clone()),
            pictures: self
                .pictures
                .clone()
                .or_else(|| Some(base.pictures.clone()))
                .unwrap_or_default(),
            duration: base.duration,
            bpm: self.bpm.or(base.bpm),
        }
    }
}

/// Apply [changes] to the tag at `path`, preserving any fields not mentioned.
pub fn update(path: String, changes: TagChanges) -> Result<(), HaudiotaggerError> {
    let base = read_or_empty(&path)?;
    write(path, changes.merge(&base))
}

/// Apply [changes] to a tag held in `bytes`, returning the modified bytes.
pub fn update_from_bytes(
    bytes: Vec<u8>,
    changes: TagChanges,
) -> Result<Vec<u8>, HaudiotaggerError> {
    let base = read_bytes_or_empty(&bytes)?;
    write_to_bytes(bytes, changes.merge(&base))
}

/// Reads the tag at `path`, or an empty tag if the file has none.
pub(crate) fn read_or_empty(path: &str) -> Result<Tag, HaudiotaggerError> {
    match read(path.to_string()) {
        Ok(tag) => Ok(tag),
        Err(HaudiotaggerError::NoTags) => Ok(Tag::default()),
        Err(e) => Err(e),
    }
}

/// Reads the tag from `bytes`, or an empty tag if the data has none.
pub(crate) fn read_bytes_or_empty(bytes: &[u8]) -> Result<Tag, HaudiotaggerError> {
    match read_from_bytes(bytes.to_vec()) {
        Ok(tag) => Ok(tag),
        Err(HaudiotaggerError::NoTags) => Ok(Tag::default()),
        Err(e) => Err(e),
    }
}
