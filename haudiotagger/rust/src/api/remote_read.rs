use super::error::HaudiotaggerError;
use crate::remote;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum UrlReadStrategy {
    Auto,
    Full,
    Progressive,
    RandomAccess,
}

impl Default for UrlReadStrategy {
    fn default() -> Self {
        Self::Auto
    }
}

/// Read audio metadata from a remote URL.
///
/// Downloads the file (or relevant portions via HTTP range requests) and
/// parses the metadata tag. Supports MP3, FLAC, OGG, Opus, MP4, WAV, AIFF,
/// APE, and WavPack.
///
/// Use [UrlReadStrategy] to control how the file is fetched:
/// - `Auto` (default): picks the best strategy based on file size and format.
/// - `Full`: downloads the entire file before parsing.
/// - `Progressive`: fetches only the header + tag progressively.
/// - `RandomAccess`: uses HTTP range-backed seekable reader.
///
/// On WASM, all strategies fall back to Full download (Progressive and
/// RandomAccess are not yet implemented for async range fetching).
pub async fn read_from_url(
    url: String,
    strategy: UrlReadStrategy,
) -> Result<super::tag::Tag, HaudiotaggerError> {
    remote::read_from_url(url, strategy).await
}
