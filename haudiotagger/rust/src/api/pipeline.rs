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
            apply_rule(&mut result, rule);
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
    let mut out = String::new();
    for (i, word) in s.split_whitespace().enumerate() {
        if i > 0 {
            out.push(' ');
        }
        out.push_str(word);
    }
    out
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

fn apply_to_strings(tag: &mut Tag, f: impl Fn(&str) -> String) {
    tag.title = tag.title.as_ref().map(|s| f(s));
    tag.track_artist = tag.track_artist.as_ref().map(|s| f(s));
    tag.album = tag.album.as_ref().map(|s| f(s));
    tag.album_artist = tag.album_artist.as_ref().map(|s| f(s));
    tag.genre = tag.genre.as_ref().map(|s| f(s));
    tag.lyrics = tag.lyrics.as_ref().map(|s| f(s));
    tag.comment = tag.comment.as_ref().map(|s| f(s));
    tag.replay_gain_track_gain = tag.replay_gain_track_gain.as_ref().map(|s| f(s));
    tag.replay_gain_track_peak = tag.replay_gain_track_peak.as_ref().map(|s| f(s));
    tag.replay_gain_album_gain = tag.replay_gain_album_gain.as_ref().map(|s| f(s));
    tag.replay_gain_album_peak = tag.replay_gain_album_peak.as_ref().map(|s| f(s));
}

// ── Rule application ──────────────────────────────────────

/// Apply a single rule to a tag.
pub fn apply_rule(tag: &mut Tag, rule: &TransformRule) {
    match rule {
        // ── Whitespace / Unicode ─────────────────────────
        TransformRule::TrimWhitespace => apply_to_strings(tag, trim),
        TransformRule::NormalizeWhitespace => apply_to_strings(tag, collapse_ws),
        TransformRule::NormalizeUnicode => apply_to_strings(tag, nfkc),

        // ── Setters ─────────────────────────────────────
        TransformRule::SetTitle(v) => tag.title = Some(v.clone()),
        TransformRule::SetArtist(v) => tag.track_artist = Some(v.clone()),
        TransformRule::SetAlbum(v) => tag.album = Some(v.clone()),
        TransformRule::SetAlbumArtist(v) => tag.album_artist = Some(v.clone()),
        TransformRule::SetGenre(v) => tag.genre = Some(v.clone()),
        TransformRule::SetYear(y) => tag.year = Some(*y),
        TransformRule::SetTrackNumber(n) => tag.track_number = Some(*n),
        TransformRule::SetDiscNumber(n) => tag.disc_number = Some(*n),
        TransformRule::SetTrackTotal(n) => tag.track_total = Some(*n),
        TransformRule::SetDiscTotal(n) => tag.disc_total = Some(*n),
        TransformRule::SetBpm(b) => tag.bpm = Some(*b),
        TransformRule::SetComment(v) => tag.comment = Some(v.clone()),

        // ── Remove ──────────────────────────────────────
        TransformRule::RemoveLyrics => tag.lyrics = None,
        TransformRule::RemoveComment => tag.comment = None,
        TransformRule::RemovePictures => tag.pictures = vec![],
        TransformRule::RemoveBpm => tag.bpm = None,
        TransformRule::RemoveReplayGain => {
            tag.replay_gain_track_gain = None;
            tag.replay_gain_track_peak = None;
            tag.replay_gain_album_gain = None;
            tag.replay_gain_album_peak = None;
        }
        TransformRule::RemoveTitle => tag.title = None,
        TransformRule::RemoveArtist => tag.track_artist = None,
        TransformRule::RemoveAlbum => tag.album = None,
        TransformRule::RemoveAlbumArtist => tag.album_artist = None,
        TransformRule::RemoveGenre => tag.genre = None,
        TransformRule::RemoveYear => tag.year = None,
        TransformRule::RemoveTrackNumber => tag.track_number = None,
        TransformRule::RemoveDiscNumber => tag.disc_number = None,

        // ── Normalize numbers ───────────────────────────
        TransformRule::NormalizeTrackNumbers => {
            tag.track_number = tag.track_number.map(|n| n.clamp(0, 999));
        }
        TransformRule::NormalizeDiscNumbers => {
            tag.disc_number = tag.disc_number.map(|n| n.clamp(0, 99));
        }
        TransformRule::NormalizeYear => {
            tag.year = tag.year.map(normalize_year);
        }

        // ── Copy between fields ─────────────────────────
        TransformRule::CopyArtistToAlbumArtist => {
            if tag.album_artist.as_deref() == Some("") || tag.album_artist.is_none() {
                tag.album_artist = tag.track_artist.clone();
            }
        }
        TransformRule::CopyAlbumArtistToArtist => {
            if tag.track_artist.as_deref() == Some("") || tag.track_artist.is_none() {
                tag.track_artist = tag.album_artist.clone();
            }
        }
        TransformRule::CopyTitleToComment => {
            if tag.comment.as_deref() == Some("") || tag.comment.is_none() {
                tag.comment = tag.title.clone();
            }
        }

        // ── Prefix / Suffix ─────────────────────────────
        TransformRule::PrefixTitle(p) => {
            tag.title = tag.title.as_ref().map(|s| format!("{p}{s}"));
        }
        TransformRule::SuffixTitle(s) => {
            tag.title = tag.title.as_ref().map(|t| format!("{t}{s}"));
        }
        TransformRule::PrefixAlbum(p) => {
            tag.album = tag.album.as_ref().map(|a| format!("{p}{a}"));
        }
        TransformRule::SuffixAlbum(s) => {
            tag.album = tag.album.as_ref().map(|a| format!("{a}{s}"));
        }
        TransformRule::PrefixArtist(p) => {
            tag.track_artist = tag.track_artist.as_ref().map(|a| format!("{p}{a}"));
        }
        TransformRule::SuffixArtist(s) => {
            tag.track_artist = tag.track_artist.as_ref().map(|a| format!("{a}{s}"));
        }

        // ── Case transformations ────────────────────────
        TransformRule::TitleCaseTitle => {
            tag.title = tag.title.as_ref().map(|s| title_case(s));
        }
        TransformRule::TitleCaseArtist => {
            tag.track_artist = tag.track_artist.as_ref().map(|s| title_case(s));
        }
        TransformRule::TitleCaseAlbum => {
            tag.album = tag.album.as_ref().map(|s| title_case(s));
        }
        TransformRule::LowerCaseAll => apply_to_strings(tag, |s| s.to_lowercase()),
        TransformRule::UpperCaseAll => apply_to_strings(tag, |s| s.to_uppercase()),

        // ── Search / Replace ────────────────────────────
        TransformRule::ReplaceInTitle { find, replace } => {
            tag.title = tag.title.as_ref().map(|s| s.replace(find, replace));
        }
        TransformRule::ReplaceInArtist { find, replace } => {
            tag.track_artist = tag.track_artist.as_ref().map(|s| s.replace(find, replace));
        }
        TransformRule::ReplaceInAlbum { find, replace } => {
            tag.album = tag.album.as_ref().map(|s| s.replace(find, replace));
        }
        TransformRule::ReplaceInAll { find, replace } => {
            apply_to_strings(tag, |s| s.replace(find, replace));
        }

        // ── Conditional ─────────────────────────────────
        TransformRule::SetTitleIfEmpty(v) => {
            if tag.title.as_deref() == Some("") || tag.title.is_none() {
                tag.title = Some(v.clone());
            }
        }
        TransformRule::SetArtistIfEmpty(v) => {
            if tag.track_artist.as_deref() == Some("") || tag.track_artist.is_none() {
                tag.track_artist = Some(v.clone());
            }
        }
        TransformRule::SetAlbumIfEmpty(v) => {
            if tag.album.as_deref() == Some("") || tag.album.is_none() {
                tag.album = Some(v.clone());
            }
        }
        TransformRule::SetGenreIfEmpty(v) => {
            if tag.genre.as_deref() == Some("") || tag.genre.is_none() {
                tag.genre = Some(v.clone());
            }
        }
        TransformRule::SetAlbumArtistIfEmpty(v) => {
            if tag.album_artist.as_deref() == Some("") || tag.album_artist.is_none() {
                tag.album_artist = Some(v.clone());
            }
        }

        // ── Remove empty ────────────────────────────────
        TransformRule::RemoveEmptyFields => {
            tag.title = tag.title.as_ref().and_then(|s| {
                let t = s.trim();
                if t.is_empty() {
                    None
                } else {
                    Some(t.to_string())
                }
            });
            tag.track_artist = tag.track_artist.as_ref().and_then(|s| {
                let t = s.trim();
                if t.is_empty() {
                    None
                } else {
                    Some(t.to_string())
                }
            });
            tag.album = tag.album.as_ref().and_then(|s| {
                let t = s.trim();
                if t.is_empty() {
                    None
                } else {
                    Some(t.to_string())
                }
            });
            tag.album_artist = tag.album_artist.as_ref().and_then(|s| {
                let t = s.trim();
                if t.is_empty() {
                    None
                } else {
                    Some(t.to_string())
                }
            });
            tag.genre = tag.genre.as_ref().and_then(|s| {
                let t = s.trim();
                if t.is_empty() {
                    None
                } else {
                    Some(t.to_string())
                }
            });
            tag.lyrics = tag.lyrics.as_ref().and_then(|s| {
                let t = s.trim();
                if t.is_empty() {
                    None
                } else {
                    Some(t.to_string())
                }
            });
            tag.comment = tag.comment.as_ref().and_then(|s| {
                let t = s.trim();
                if t.is_empty() {
                    None
                } else {
                    Some(t.to_string())
                }
            });
        }

        // ── Pictures ────────────────────────────────────
        TransformRule::RemoveNonCoverPictures => {
            tag.pictures.retain(|p| {
                matches!(
                    p.picture_type,
                    super::picture::PictureType::CoverFront
                        | super::picture::PictureType::CoverBack
                )
            });
        }
    }
}

/// Apply a pipeline of rules to a tag.
pub fn apply_pipeline(tag: &Tag, pipeline: &TagPipeline) -> Tag {
    pipeline.apply(tag)
}
