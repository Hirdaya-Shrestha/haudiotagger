use lofty::file::{AudioFile, FileType, TaggedFileExt};

use super::api::get_file;
use super::api::get_file_from_bytes;
use super::error::HaudiotaggerError;

/// Bitrate encoding mode, when known.
#[derive(Debug, Clone, Copy)]
pub enum BitrateMode {
    /// Could not be determined.
    Unknown,
    /// Constant bitrate.
    Cbr,
    /// Variable bitrate.
    Vbr,
}

/// Immutable, read-only technical audio properties of a file.
#[derive(Debug, Clone)]
pub struct AudioProperties {
    /// Duration of the audio, in microseconds.
    pub duration_micros: Option<i64>,
    /// Overall bitrate (kbps).
    pub bitrate: Option<u32>,
    /// Sample rate (Hz).
    pub sample_rate: Option<u32>,
    /// Number of channels.
    pub channels: Option<u32>,
    /// Bits per sample.
    pub bits_per_sample: Option<u32>,
    /// The audio codec (ex. `MP3`, `FLAC`, `AAC`).
    pub codec: String,
    /// The container format (ex. `MP3`, `MP4`, `Ogg`).
    pub container_format: String,
    /// Whether the audio is lossless.
    pub lossless: bool,
    /// Bitrate encoding mode, when known.
    pub bitrate_mode: BitrateMode,
    /// File size in bytes.
    pub file_size: Option<u64>,
}

/// Returns the (codec, container, lossless) triple for a `FileType`.
pub(crate) fn type_info(ft: FileType) -> (String, String, bool) {
    match ft {
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
        FileType::Custom(s) => (s.into(), s.into(), false),
        _ => ("Unknown".into(), "Unknown".into(), false),
    }
}

impl AudioProperties {
    /// Builds [`AudioProperties`] from a parsed file.
    fn from_file(file: &lofty::file::TaggedFile, file_size: Option<u64>) -> Self {
        let props = file.properties();
        let (codec, container_format, lossless) = type_info(file.file_type());

        AudioProperties {
            duration_micros: Some(props.duration().as_micros() as i64),
            bitrate: props.overall_bitrate().or_else(|| props.audio_bitrate()),
            sample_rate: props.sample_rate(),
            channels: props.channels().map(u32::from),
            bits_per_sample: props.bit_depth().map(u32::from),
            codec,
            container_format,
            lossless,
            // ponytail: lofty's generic FileProperties does not expose bitrate
            // mode; left Unknown until a format-specific probe is wired in.
            bitrate_mode: BitrateMode::Unknown,
            file_size,
        }
    }
}

/// Read the technical audio properties of the file at `path`.
pub fn read_properties(path: String) -> Result<AudioProperties, HaudiotaggerError> {
    let file = get_file(&path)?;
    let file_size = std::fs::metadata(&path).map(|m| m.len()).ok();
    Ok(AudioProperties::from_file(&file, file_size))
}

/// Read the technical audio properties from in-memory bytes (for web/WASM).
pub fn read_properties_from_bytes(bytes: Vec<u8>) -> Result<AudioProperties, HaudiotaggerError> {
    let file = get_file_from_bytes(&bytes)?;
    Ok(AudioProperties::from_file(&file, Some(bytes.len() as u64)))
}
