use unicode_normalization::UnicodeNormalization;

use super::tag::Tag;

/// A single transformation rule that can be applied to a `Tag`.
#[derive(Debug, Clone)]
pub enum TransformRule {
    // ── Whitespace / Unicode ──────────────────────────────
    TrimWhitespace,
    NormalizeWhitespace,
    NormalizeUnicode,

    // ── Setters ──────────────────────────────────────────
    SetTitle(String),
    SetArtist(String),
    SetAlbum(String),
    SetAlbumArtist(String),
    SetGenre(String),
    SetYear(u32),
    SetTrackNumber(u32),
    SetDiscNumber(u32),
    SetTrackTotal(u32),
    SetDiscTotal(u32),
    SetBpm(f32),
    SetComment(String),

    // ── Remove ───────────────────────────────────────────
    RemoveLyrics,
    RemoveComment,
    RemovePictures,
    RemoveBpm,
    RemoveReplayGain,
    RemoveTitle,
    RemoveArtist,
    RemoveAlbum,
    RemoveAlbumArtist,
    RemoveGenre,
    RemoveYear,
    RemoveTrackNumber,
    RemoveDiscNumber,

    // ── Normalize numbers ────────────────────────────────
    NormalizeTrackNumbers,
    NormalizeDiscNumbers,
    NormalizeYear,

    // ── Copy between fields ──────────────────────────────
    CopyArtistToAlbumArtist,
    CopyAlbumArtistToArtist,
    CopyTitleToComment,

    // ── Prefix / Suffix ──────────────────────────────────
    PrefixTitle(String),
    SuffixTitle(String),
    PrefixAlbum(String),
    SuffixAlbum(String),
    PrefixArtist(String),
    SuffixArtist(String),

    // ── Case transformations ─────────────────────────────
    TitleCaseTitle,
    TitleCaseArtist,
    TitleCaseAlbum,
    LowerCaseAll,
    UpperCaseAll,

    // ── Search / Replace ─────────────────────────────────
    ReplaceInTitle { find: String, replace: String },
    ReplaceInArtist { find: String, replace: String },
    ReplaceInAlbum { find: String, replace: String },
    ReplaceInAll { find: String, replace: String },

    // ── Conditional ──────────────────────────────────────
    SetTitleIfEmpty(String),
    SetArtistIfEmpty(String),
    SetAlbumIfEmpty(String),
    SetGenreIfEmpty(String),
    SetAlbumArtistIfEmpty(String),

    // ── Remove empty ─────────────────────────────────────
    RemoveEmptyFields,

    // ── Pictures ─────────────────────────────────────────
    RemoveNonCoverPictures,
}

/// A pipeline of transformation rules to apply to tags.
#[derive(Debug, Clone, Default)]
pub struct TagPipeline {
    pub rules: Vec<TransformRule>,
}

impl TagPipeline {
    /// Create a new empty pipeline.
    pub fn new() -> Self {
        Self::default()
    }

    /// Create a pipeline from a list of rules.
    pub fn from_rules(rules: Vec<TransformRule>) -> Self {
        Self { rules }
    }

    /// Apply all rules to a tag and return the transformed tag.
    pub fn apply(&self, tag: &Tag) -> Tag {
        let mut result = tag.clone();
        for rule in &self.rules {
            result = apply_rule(&result, rule);
        }
        result
    }

    /// Get the number of rules in this pipeline.
    pub fn len(&self) -> usize {
        self.rules.len()
    }

    /// Check if the pipeline has no rules.
    pub fn is_empty(&self) -> bool {
        self.rules.is_empty()
    }
}

// ── Helpers ───────────────────────────────────────────────

fn trim(s: &str) -> String {
    s.trim().to_string()
}

fn collapse_ws(s: &str) -> String {
    s.split_whitespace().collect::<Vec<&str>>().join(" ")
}

fn nfkc(s: &str) -> String {
    s.nfkc().collect()
}

fn title_case(s: &str) -> String {
    s.split_whitespace()
        .map(|word| {
            let mut chars = word.chars();
            match chars.next() {
                None => String::new(),
                Some(first) => {
                    let upper: String = first.to_uppercase().collect();
                    let rest: String = chars.collect::<String>().to_lowercase();
                    format!("{upper}{rest}")
                }
            }
        })
        .collect::<Vec<String>>()
        .join(" ")
}

fn normalize_year(year: u32) -> u32 {
    if year > 0 && year < 100 {
        if year >= 30 { 1900 + year } else { 2000 + year }
    } else {
        year
    }
}

fn apply_to_strings(tag: &Tag, f: impl Fn(&str) -> String) -> Tag {
    Tag {
        title: tag.title.as_ref().map(|s| f(s)),
        track_artist: tag.track_artist.as_ref().map(|s| f(s)),
        album: tag.album.as_ref().map(|s| f(s)),
        album_artist: tag.album_artist.as_ref().map(|s| f(s)),
        genre: tag.genre.as_ref().map(|s| f(s)),
        lyrics: tag.lyrics.as_ref().map(|s| f(s)),
        comment: tag.comment.as_ref().map(|s| f(s)),
        replay_gain_track_gain: tag.replay_gain_track_gain.as_ref().map(|s| f(s)),
        replay_gain_track_peak: tag.replay_gain_track_peak.as_ref().map(|s| f(s)),
        replay_gain_album_gain: tag.replay_gain_album_gain.as_ref().map(|s| f(s)),
        replay_gain_album_peak: tag.replay_gain_album_peak.as_ref().map(|s| f(s)),
        ..tag.clone()
    }
}

// ── Rule application ──────────────────────────────────────

/// Apply a single rule to a tag.
pub fn apply_rule(tag: &Tag, rule: &TransformRule) -> Tag {
    match rule {
        // ── Whitespace / Unicode ─────────────────────────
        TransformRule::TrimWhitespace => apply_to_strings(tag, trim),
        TransformRule::NormalizeWhitespace => apply_to_strings(tag, collapse_ws),
        TransformRule::NormalizeUnicode => apply_to_strings(tag, nfkc),

        // ── Setters ─────────────────────────────────────
        TransformRule::SetTitle(v) => Tag {
            title: Some(v.clone()),
            ..tag.clone()
        },
        TransformRule::SetArtist(v) => Tag {
            track_artist: Some(v.clone()),
            ..tag.clone()
        },
        TransformRule::SetAlbum(v) => Tag {
            album: Some(v.clone()),
            ..tag.clone()
        },
        TransformRule::SetAlbumArtist(v) => Tag {
            album_artist: Some(v.clone()),
            ..tag.clone()
        },
        TransformRule::SetGenre(v) => Tag {
            genre: Some(v.clone()),
            ..tag.clone()
        },
        TransformRule::SetYear(y) => Tag {
            year: Some(*y),
            ..tag.clone()
        },
        TransformRule::SetTrackNumber(n) => Tag {
            track_number: Some(*n),
            ..tag.clone()
        },
        TransformRule::SetDiscNumber(n) => Tag {
            disc_number: Some(*n),
            ..tag.clone()
        },
        TransformRule::SetTrackTotal(n) => Tag {
            track_total: Some(*n),
            ..tag.clone()
        },
        TransformRule::SetDiscTotal(n) => Tag {
            disc_total: Some(*n),
            ..tag.clone()
        },
        TransformRule::SetBpm(b) => Tag {
            bpm: Some(*b),
            ..tag.clone()
        },
        TransformRule::SetComment(v) => Tag {
            comment: Some(v.clone()),
            ..tag.clone()
        },

        // ── Remove ──────────────────────────────────────
        TransformRule::RemoveLyrics => Tag {
            lyrics: None,
            ..tag.clone()
        },
        TransformRule::RemoveComment => Tag {
            comment: None,
            ..tag.clone()
        },
        TransformRule::RemovePictures => Tag {
            pictures: vec![],
            ..tag.clone()
        },
        TransformRule::RemoveBpm => Tag {
            bpm: None,
            ..tag.clone()
        },
        TransformRule::RemoveReplayGain => Tag {
            replay_gain_track_gain: None,
            replay_gain_track_peak: None,
            replay_gain_album_gain: None,
            replay_gain_album_peak: None,
            ..tag.clone()
        },
        TransformRule::RemoveTitle => Tag {
            title: None,
            ..tag.clone()
        },
        TransformRule::RemoveArtist => Tag {
            track_artist: None,
            ..tag.clone()
        },
        TransformRule::RemoveAlbum => Tag {
            album: None,
            ..tag.clone()
        },
        TransformRule::RemoveAlbumArtist => Tag {
            album_artist: None,
            ..tag.clone()
        },
        TransformRule::RemoveGenre => Tag {
            genre: None,
            ..tag.clone()
        },
        TransformRule::RemoveYear => Tag {
            year: None,
            ..tag.clone()
        },
        TransformRule::RemoveTrackNumber => Tag {
            track_number: None,
            ..tag.clone()
        },
        TransformRule::RemoveDiscNumber => Tag {
            disc_number: None,
            ..tag.clone()
        },

        // ── Normalize numbers ───────────────────────────
        TransformRule::NormalizeTrackNumbers => Tag {
            track_number: tag.track_number.map(|n| n.clamp(0, 999)),
            ..tag.clone()
        },
        TransformRule::NormalizeDiscNumbers => Tag {
            disc_number: tag.disc_number.map(|n| n.clamp(0, 99)),
            ..tag.clone()
        },
        TransformRule::NormalizeYear => Tag {
            year: tag.year.map(normalize_year),
            ..tag.clone()
        },

        // ── Copy between fields ─────────────────────────
        TransformRule::CopyArtistToAlbumArtist => {
            if tag.album_artist.as_deref() == Some("") || tag.album_artist.is_none() {
                Tag {
                    album_artist: tag.track_artist.clone(),
                    ..tag.clone()
                }
            } else {
                tag.clone()
            }
        }
        TransformRule::CopyAlbumArtistToArtist => {
            if tag.track_artist.as_deref() == Some("") || tag.track_artist.is_none() {
                Tag {
                    track_artist: tag.album_artist.clone(),
                    ..tag.clone()
                }
            } else {
                tag.clone()
            }
        }
        TransformRule::CopyTitleToComment => {
            if tag.comment.as_deref() == Some("") || tag.comment.is_none() {
                Tag {
                    comment: tag.title.clone(),
                    ..tag.clone()
                }
            } else {
                tag.clone()
            }
        }

        // ── Prefix / Suffix ─────────────────────────────
        TransformRule::PrefixTitle(p) => Tag {
            title: tag.title.as_ref().map(|s| format!("{p}{s}")),
            ..tag.clone()
        },
        TransformRule::SuffixTitle(s) => Tag {
            title: tag.title.as_ref().map(|t| format!("{t}{s}")),
            ..tag.clone()
        },
        TransformRule::PrefixAlbum(p) => Tag {
            album: tag.album.as_ref().map(|a| format!("{p}{a}")),
            ..tag.clone()
        },
        TransformRule::SuffixAlbum(s) => Tag {
            album: tag.album.as_ref().map(|a| format!("{a}{s}")),
            ..tag.clone()
        },
        TransformRule::PrefixArtist(p) => Tag {
            track_artist: tag.track_artist.as_ref().map(|a| format!("{p}{a}")),
            ..tag.clone()
        },
        TransformRule::SuffixArtist(s) => Tag {
            track_artist: tag.track_artist.as_ref().map(|a| format!("{a}{s}")),
            ..tag.clone()
        },

        // ── Case transformations ────────────────────────
        TransformRule::TitleCaseTitle => Tag {
            title: tag.title.as_ref().map(|s| title_case(s)),
            ..tag.clone()
        },
        TransformRule::TitleCaseArtist => Tag {
            track_artist: tag.track_artist.as_ref().map(|s| title_case(s)),
            ..tag.clone()
        },
        TransformRule::TitleCaseAlbum => Tag {
            album: tag.album.as_ref().map(|s| title_case(s)),
            ..tag.clone()
        },
        TransformRule::LowerCaseAll => apply_to_strings(tag, |s| s.to_lowercase()),
        TransformRule::UpperCaseAll => apply_to_strings(tag, |s| s.to_uppercase()),

        // ── Search / Replace ────────────────────────────
        TransformRule::ReplaceInTitle { find, replace } => Tag {
            title: tag.title.as_ref().map(|s| s.replace(find, replace)),
            ..tag.clone()
        },
        TransformRule::ReplaceInArtist { find, replace } => Tag {
            track_artist: tag.track_artist.as_ref().map(|s| s.replace(find, replace)),
            ..tag.clone()
        },
        TransformRule::ReplaceInAlbum { find, replace } => Tag {
            album: tag.album.as_ref().map(|s| s.replace(find, replace)),
            ..tag.clone()
        },
        TransformRule::ReplaceInAll { find, replace } => {
            apply_to_strings(tag, |s| s.replace(find, replace))
        }

        // ── Conditional ─────────────────────────────────
        TransformRule::SetTitleIfEmpty(v) => {
            if tag.title.as_deref() == Some("") || tag.title.is_none() {
                Tag {
                    title: Some(v.clone()),
                    ..tag.clone()
                }
            } else {
                tag.clone()
            }
        }
        TransformRule::SetArtistIfEmpty(v) => {
            if tag.track_artist.as_deref() == Some("") || tag.track_artist.is_none() {
                Tag {
                    track_artist: Some(v.clone()),
                    ..tag.clone()
                }
            } else {
                tag.clone()
            }
        }
        TransformRule::SetAlbumIfEmpty(v) => {
            if tag.album.as_deref() == Some("") || tag.album.is_none() {
                Tag {
                    album: Some(v.clone()),
                    ..tag.clone()
                }
            } else {
                tag.clone()
            }
        }
        TransformRule::SetGenreIfEmpty(v) => {
            if tag.genre.as_deref() == Some("") || tag.genre.is_none() {
                Tag {
                    genre: Some(v.clone()),
                    ..tag.clone()
                }
            } else {
                tag.clone()
            }
        }
        TransformRule::SetAlbumArtistIfEmpty(v) => {
            if tag.album_artist.as_deref() == Some("") || tag.album_artist.is_none() {
                Tag {
                    album_artist: Some(v.clone()),
                    ..tag.clone()
                }
            } else {
                tag.clone()
            }
        }

        // ── Remove empty ────────────────────────────────
        TransformRule::RemoveEmptyFields => Tag {
            title: tag.title.as_ref().and_then(|s| {
                let t = s.trim();
                if t.is_empty() {
                    None
                } else {
                    Some(t.to_string())
                }
            }),
            track_artist: tag.track_artist.as_ref().and_then(|s| {
                let t = s.trim();
                if t.is_empty() {
                    None
                } else {
                    Some(t.to_string())
                }
            }),
            album: tag.album.as_ref().and_then(|s| {
                let t = s.trim();
                if t.is_empty() {
                    None
                } else {
                    Some(t.to_string())
                }
            }),
            album_artist: tag.album_artist.as_ref().and_then(|s| {
                let t = s.trim();
                if t.is_empty() {
                    None
                } else {
                    Some(t.to_string())
                }
            }),
            genre: tag.genre.as_ref().and_then(|s| {
                let t = s.trim();
                if t.is_empty() {
                    None
                } else {
                    Some(t.to_string())
                }
            }),
            lyrics: tag.lyrics.as_ref().and_then(|s| {
                let t = s.trim();
                if t.is_empty() {
                    None
                } else {
                    Some(t.to_string())
                }
            }),
            comment: tag.comment.as_ref().and_then(|s| {
                let t = s.trim();
                if t.is_empty() {
                    None
                } else {
                    Some(t.to_string())
                }
            }),
            ..tag.clone()
        },

        // ── Pictures ────────────────────────────────────
        TransformRule::RemoveNonCoverPictures => Tag {
            pictures: tag
                .pictures
                .iter()
                .filter(|p| {
                    matches!(
                        p.picture_type,
                        super::picture::PictureType::CoverFront
                            | super::picture::PictureType::CoverBack
                    )
                })
                .cloned()
                .collect(),
            ..tag.clone()
        },
    }
}

/// Apply a pipeline of rules to a tag.
pub fn apply_pipeline(tag: &Tag, pipeline: &TagPipeline) -> Tag {
    pipeline.apply(tag)
}
