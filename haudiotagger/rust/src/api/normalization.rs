use unicode_normalization::UnicodeNormalization;

use super::tag::Tag;

#[derive(Debug, Clone)]
pub struct NormalizeOptions {
    /// Trim leading/trailing whitespace from all string fields.
    pub trim_values: bool,
    /// Collapse multiple whitespace characters into a single space.
    pub normalize_whitespace: bool,
    /// Apply Unicode NFKC normalization (full compatibility decomposition + canonical composition).
    pub normalize_unicode: bool,
    /// Remove fields that are empty strings after normalization.
    pub remove_empty_values: bool,
}

impl Default for NormalizeOptions {
    fn default() -> Self {
        Self {
            trim_values: true,
            normalize_whitespace: true,
            normalize_unicode: true,
            remove_empty_values: true,
        }
    }
}

fn normalize_string(s: &str, opts: &NormalizeOptions) -> Option<String> {
    let mut result = s.to_string();

    if opts.normalize_unicode {
        result = result.nfkc().collect();
    }

    if opts.normalize_whitespace {
        result = result.split_whitespace().collect::<Vec<&str>>().join(" ");
    }

    if opts.trim_values {
        result = result.trim().to_string();
    }

    if result.is_empty() {
        None
    } else {
        Some(result)
    }
}

fn apply_normalize(val: &Option<String>, opts: &NormalizeOptions) -> Option<String> {
    val.as_ref().and_then(|s| normalize_string(s, opts))
}

pub fn normalize(tag: &Tag, opts: &NormalizeOptions) -> Tag {
    Tag {
        title: apply_normalize(&tag.title, opts),
        track_artist: apply_normalize(&tag.track_artist, opts),
        album: apply_normalize(&tag.album, opts),
        album_artist: apply_normalize(&tag.album_artist, opts),
        year: tag.year,
        genre: apply_normalize(&tag.genre, opts),
        track_number: tag.track_number,
        track_total: tag.track_total,
        disc_number: tag.disc_number,
        disc_total: tag.disc_total,
        lyrics: apply_normalize(&tag.lyrics, opts),
        comment: apply_normalize(&tag.comment, opts),
        duration: tag.duration,
        pictures: tag.pictures.clone(),
        bpm: tag.bpm,
        replay_gain_track_gain: apply_normalize(&tag.replay_gain_track_gain, opts),
        replay_gain_track_peak: apply_normalize(&tag.replay_gain_track_peak, opts),
        replay_gain_album_gain: apply_normalize(&tag.replay_gain_album_gain, opts),
        replay_gain_album_peak: apply_normalize(&tag.replay_gain_album_peak, opts),
    }
}
