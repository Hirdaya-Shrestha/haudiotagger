use crate::api::api::{read, read_from_bytes, write, write_to_bytes};
use crate::api::error::HaudiotaggerError;
use crate::api::picture::Picture;
use crate::api::tag::Tag;

/// A partial set of tag fields to apply on top of an existing tag.
///
/// Every field is optional. When applying via `update`, a `Some` value replaces
/// the corresponding field on the existing tag, while `None` leaves it untouched.
#[derive(Debug, Clone, Default, PartialEq)]
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
    pub replay_gain_track_gain: Option<String>,
    pub replay_gain_track_peak: Option<String>,
    pub replay_gain_album_gain: Option<String>,
    pub replay_gain_album_peak: Option<String>,
}

impl TagChanges {
    /// Returns `true` if no fields are set.
    pub fn is_empty(&self) -> bool {
        *self == Self::default()
    }

    /// Merges these changes onto `base`, returning the combined tag.
    pub(crate) fn merge(&self, base: &Tag) -> Tag {
        macro_rules! or_clone {
            ($self:expr, $base:expr) => {
                $self.clone().or_else(|| $base.clone())
            };
        }
        Tag {
            title: or_clone!(self.title, base.title),
            track_artist: or_clone!(self.track_artist, base.track_artist),
            album: or_clone!(self.album, base.album),
            album_artist: or_clone!(self.album_artist, base.album_artist),
            year: self.year.or(base.year),
            genre: or_clone!(self.genre, base.genre),
            track_number: self.track_number.or(base.track_number),
            track_total: self.track_total.or(base.track_total),
            disc_number: self.disc_number.or(base.disc_number),
            disc_total: self.disc_total.or(base.disc_total),
            lyrics: or_clone!(self.lyrics, base.lyrics),
            comment: or_clone!(self.comment, base.comment),
            pictures: self
                .pictures
                .clone()
                .unwrap_or_else(|| base.pictures.clone()),
            duration: base.duration,
            bpm: self.bpm.or(base.bpm),
            replay_gain_track_gain: or_clone!(
                self.replay_gain_track_gain,
                base.replay_gain_track_gain
            ),
            replay_gain_track_peak: or_clone!(
                self.replay_gain_track_peak,
                base.replay_gain_track_peak
            ),
            replay_gain_album_gain: or_clone!(
                self.replay_gain_album_gain,
                base.replay_gain_album_gain
            ),
            replay_gain_album_peak: or_clone!(
                self.replay_gain_album_peak,
                base.replay_gain_album_peak
            ),
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
