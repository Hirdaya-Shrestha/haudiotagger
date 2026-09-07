use lofty::file::{AudioFile, TaggedFileExt};
use lofty::tag::{Accessor, ItemKey, TagExt};

use crate::api::error::HaudiotaggerError;
use lofty::config::WriteOptions;
use lofty::tag::Tag as LoftyTag;

/// Extended metadata fields not covered by the basic `Tag`.
///
/// These fields are commonly used by music libraries (MusicBrainz, AcoustID),
/// professional audio tools, and metadata providers. They are kept separate
/// from the core `Tag` to maintain a clean separation between the metadata
/// engine and metadata providers.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct ExtendedTag {
    // ── MusicBrainz Identifiers ──
    pub music_brainz_recording_id: Option<String>,
    pub music_brainz_track_id: Option<String>,
    pub music_brainz_release_id: Option<String>,
    pub music_brainz_release_group_id: Option<String>,
    pub music_brainz_artist_id: Option<String>,
    pub music_brainz_release_artist_id: Option<String>,
    pub music_brainz_work_id: Option<String>,
    pub music_brainz_release_type: Option<String>,

    // ── AcoustID ──
    pub acoust_id: Option<String>,
    pub acoust_id_fingerprint: Option<String>,

    // ── Identifiers ──
    pub isrc: Option<String>,
    pub barcode: Option<String>,
    pub catalog_number: Option<String>,

    // ── People & Roles ──
    pub arranger: Option<String>,
    pub conductor: Option<String>,
    pub director: Option<String>,
    pub engineer: Option<String>,
    pub lyricist: Option<String>,
    pub mix_dj: Option<String>,
    pub mix_engineer: Option<String>,
    pub performer: Option<String>,
    pub producer: Option<String>,
    pub publisher: Option<String>,
    pub label: Option<String>,
    pub remixer: Option<String>,
    pub writer: Option<String>,
    pub composer: Option<String>,
    pub original_lyricist: Option<String>,

    // ── Dates ──
    pub recording_date: Option<String>,
    pub release_date: Option<String>,
    pub original_release_date: Option<String>,

    // ── Style ──
    pub initial_key: Option<String>,
    pub color: Option<String>,
    pub mood: Option<String>,

    // ── URLs ──
    pub audio_file_url: Option<String>,
    pub audio_source_url: Option<String>,
    pub commercial_information_url: Option<String>,
    pub copyright_url: Option<String>,
    pub track_artist_url: Option<String>,
    pub radio_station_url: Option<String>,
    pub payment_url: Option<String>,
    pub publisher_url: Option<String>,

    // ── Legal ──
    pub copyright_message: Option<String>,
    pub license: Option<String>,

    // ── Podcast ──
    pub podcast_description: Option<String>,
    pub podcast_series_category: Option<String>,
    pub podcast_url: Option<String>,
    pub podcast_global_unique_id: Option<String>,
    pub podcast_keywords: Option<String>,

    // ── Other ──
    pub set_subtitle: Option<String>,
    pub show_name: Option<String>,
    pub content_group: Option<String>,
    pub track_subtitle: Option<String>,
    pub language: Option<String>,
    pub script: Option<String>,
    pub parental_advisory: Option<String>,
    pub file_owner: Option<String>,
    pub original_file_name: Option<String>,
    pub original_media_type: Option<String>,
    pub encoded_by: Option<String>,
    pub encoder_software: Option<String>,
    pub encoder_settings: Option<String>,
}

impl ExtendedTag {
    pub fn is_empty(&self) -> bool {
        *self == Self::default()
    }
}

/// A partial set of extended tag fields for partial updates.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct ExtendedChanges {
    pub music_brainz_recording_id: Option<String>,
    pub music_brainz_track_id: Option<String>,
    pub music_brainz_release_id: Option<String>,
    pub music_brainz_release_group_id: Option<String>,
    pub music_brainz_artist_id: Option<String>,
    pub music_brainz_release_artist_id: Option<String>,
    pub music_brainz_work_id: Option<String>,
    pub music_brainz_release_type: Option<String>,
    pub acoust_id: Option<String>,
    pub acoust_id_fingerprint: Option<String>,
    pub isrc: Option<String>,
    pub barcode: Option<String>,
    pub catalog_number: Option<String>,
    pub arranger: Option<String>,
    pub conductor: Option<String>,
    pub director: Option<String>,
    pub engineer: Option<String>,
    pub lyricist: Option<String>,
    pub mix_dj: Option<String>,
    pub mix_engineer: Option<String>,
    pub performer: Option<String>,
    pub producer: Option<String>,
    pub publisher: Option<String>,
    pub label: Option<String>,
    pub remixer: Option<String>,
    pub writer: Option<String>,
    pub composer: Option<String>,
    pub original_lyricist: Option<String>,
    pub recording_date: Option<String>,
    pub release_date: Option<String>,
    pub original_release_date: Option<String>,
    pub initial_key: Option<String>,
    pub color: Option<String>,
    pub mood: Option<String>,
    pub audio_file_url: Option<String>,
    pub audio_source_url: Option<String>,
    pub commercial_information_url: Option<String>,
    pub copyright_url: Option<String>,
    pub track_artist_url: Option<String>,
    pub radio_station_url: Option<String>,
    pub payment_url: Option<String>,
    pub publisher_url: Option<String>,
    pub copyright_message: Option<String>,
    pub license: Option<String>,
    pub podcast_description: Option<String>,
    pub podcast_series_category: Option<String>,
    pub podcast_url: Option<String>,
    pub podcast_global_unique_id: Option<String>,
    pub podcast_keywords: Option<String>,
    pub set_subtitle: Option<String>,
    pub show_name: Option<String>,
    pub content_group: Option<String>,
    pub track_subtitle: Option<String>,
    pub language: Option<String>,
    pub script: Option<String>,
    pub parental_advisory: Option<String>,
    pub file_owner: Option<String>,
    pub original_file_name: Option<String>,
    pub original_media_type: Option<String>,
    pub encoded_by: Option<String>,
    pub encoder_software: Option<String>,
    pub encoder_settings: Option<String>,
}

impl ExtendedChanges {
    pub fn is_empty(&self) -> bool {
        *self == Self::default()
    }

    pub(crate) fn merge(&self, base: &ExtendedTag) -> ExtendedTag {
        macro_rules! or_clone {
            ($self:expr, $base:expr) => {
                $self.clone().or_else(|| $base.clone())
            };
        }
        ExtendedTag {
            music_brainz_recording_id: or_clone!(
                self.music_brainz_recording_id,
                base.music_brainz_recording_id
            ),
            music_brainz_track_id: or_clone!(
                self.music_brainz_track_id,
                base.music_brainz_track_id
            ),
            music_brainz_release_id: or_clone!(
                self.music_brainz_release_id,
                base.music_brainz_release_id
            ),
            music_brainz_release_group_id: or_clone!(
                self.music_brainz_release_group_id,
                base.music_brainz_release_group_id
            ),
            music_brainz_artist_id: or_clone!(
                self.music_brainz_artist_id,
                base.music_brainz_artist_id
            ),
            music_brainz_release_artist_id: or_clone!(
                self.music_brainz_release_artist_id,
                base.music_brainz_release_artist_id
            ),
            music_brainz_work_id: or_clone!(self.music_brainz_work_id, base.music_brainz_work_id),
            music_brainz_release_type: or_clone!(
                self.music_brainz_release_type,
                base.music_brainz_release_type
            ),
            acoust_id: or_clone!(self.acoust_id, base.acoust_id),
            acoust_id_fingerprint: or_clone!(
                self.acoust_id_fingerprint,
                base.acoust_id_fingerprint
            ),
            isrc: or_clone!(self.isrc, base.isrc),
            barcode: or_clone!(self.barcode, base.barcode),
            catalog_number: or_clone!(self.catalog_number, base.catalog_number),
            arranger: or_clone!(self.arranger, base.arranger),
            conductor: or_clone!(self.conductor, base.conductor),
            director: or_clone!(self.director, base.director),
            engineer: or_clone!(self.engineer, base.engineer),
            lyricist: or_clone!(self.lyricist, base.lyricist),
            mix_dj: or_clone!(self.mix_dj, base.mix_dj),
            mix_engineer: or_clone!(self.mix_engineer, base.mix_engineer),
            performer: or_clone!(self.performer, base.performer),
            producer: or_clone!(self.producer, base.producer),
            publisher: or_clone!(self.publisher, base.publisher),
            label: or_clone!(self.label, base.label),
            remixer: or_clone!(self.remixer, base.remixer),
            writer: or_clone!(self.writer, base.writer),
            composer: or_clone!(self.composer, base.composer),
            original_lyricist: or_clone!(self.original_lyricist, base.original_lyricist),
            recording_date: or_clone!(self.recording_date, base.recording_date),
            release_date: or_clone!(self.release_date, base.release_date),
            original_release_date: or_clone!(
                self.original_release_date,
                base.original_release_date
            ),
            initial_key: or_clone!(self.initial_key, base.initial_key),
            color: or_clone!(self.color, base.color),
            mood: or_clone!(self.mood, base.mood),
            audio_file_url: or_clone!(self.audio_file_url, base.audio_file_url),
            audio_source_url: or_clone!(self.audio_source_url, base.audio_source_url),
            commercial_information_url: or_clone!(
                self.commercial_information_url,
                base.commercial_information_url
            ),
            copyright_url: or_clone!(self.copyright_url, base.copyright_url),
            track_artist_url: or_clone!(self.track_artist_url, base.track_artist_url),
            radio_station_url: or_clone!(self.radio_station_url, base.radio_station_url),
            payment_url: or_clone!(self.payment_url, base.payment_url),
            publisher_url: or_clone!(self.publisher_url, base.publisher_url),
            copyright_message: or_clone!(self.copyright_message, base.copyright_message),
            license: or_clone!(self.license, base.license),
            podcast_description: or_clone!(self.podcast_description, base.podcast_description),
            podcast_series_category: or_clone!(
                self.podcast_series_category,
                base.podcast_series_category
            ),
            podcast_url: or_clone!(self.podcast_url, base.podcast_url),
            podcast_global_unique_id: or_clone!(
                self.podcast_global_unique_id,
                base.podcast_global_unique_id
            ),
            podcast_keywords: or_clone!(self.podcast_keywords, base.podcast_keywords),
            set_subtitle: or_clone!(self.set_subtitle, base.set_subtitle),
            show_name: or_clone!(self.show_name, base.show_name),
            content_group: or_clone!(self.content_group, base.content_group),
            track_subtitle: or_clone!(self.track_subtitle, base.track_subtitle),
            language: or_clone!(self.language, base.language),
            script: or_clone!(self.script, base.script),
            parental_advisory: or_clone!(self.parental_advisory, base.parental_advisory),
            file_owner: or_clone!(self.file_owner, base.file_owner),
            original_file_name: or_clone!(self.original_file_name, base.original_file_name),
            original_media_type: or_clone!(self.original_media_type, base.original_media_type),
            encoded_by: or_clone!(self.encoded_by, base.encoded_by),
            encoder_software: or_clone!(self.encoder_software, base.encoder_software),
            encoder_settings: or_clone!(self.encoder_settings, base.encoder_settings),
        }
    }
}

// ── Helpers ──

fn get_str(tag: &LoftyTag, key: ItemKey) -> Option<String> {
    tag.get_string(key).map(|s| s.to_string())
}

fn set_str(tag: &mut LoftyTag, key: ItemKey, val: &Option<String>) {
    match val {
        Some(v) => {
            tag.insert_text(key, v.clone());
        }
        None => {
            tag.remove_key(key);
        }
    }
}

fn from_lofty_tag(tag: &LoftyTag) -> ExtendedTag {
    ExtendedTag {
        music_brainz_recording_id: get_str(tag, ItemKey::MusicBrainzRecordingId),
        music_brainz_track_id: get_str(tag, ItemKey::MusicBrainzTrackId),
        music_brainz_release_id: get_str(tag, ItemKey::MusicBrainzReleaseId),
        music_brainz_release_group_id: get_str(tag, ItemKey::MusicBrainzReleaseGroupId),
        music_brainz_artist_id: get_str(tag, ItemKey::MusicBrainzArtistId),
        music_brainz_release_artist_id: get_str(tag, ItemKey::MusicBrainzReleaseArtistId),
        music_brainz_work_id: get_str(tag, ItemKey::MusicBrainzWorkId),
        music_brainz_release_type: get_str(tag, ItemKey::MusicBrainzReleaseType),
        acoust_id: get_str(tag, ItemKey::AcoustId),
        acoust_id_fingerprint: get_str(tag, ItemKey::AcoustIdFingerprint),
        isrc: get_str(tag, ItemKey::Isrc),
        barcode: get_str(tag, ItemKey::Barcode),
        catalog_number: get_str(tag, ItemKey::CatalogNumber),
        arranger: get_str(tag, ItemKey::Arranger),
        conductor: get_str(tag, ItemKey::Conductor),
        director: get_str(tag, ItemKey::Director),
        engineer: get_str(tag, ItemKey::Engineer),
        lyricist: get_str(tag, ItemKey::Lyricist),
        mix_dj: get_str(tag, ItemKey::MixDj),
        mix_engineer: get_str(tag, ItemKey::MixEngineer),
        performer: get_str(tag, ItemKey::Performer),
        producer: get_str(tag, ItemKey::Producer),
        publisher: get_str(tag, ItemKey::Publisher),
        label: get_str(tag, ItemKey::Label),
        remixer: get_str(tag, ItemKey::Remixer),
        writer: get_str(tag, ItemKey::Writer),
        composer: get_str(tag, ItemKey::Composer),
        original_lyricist: get_str(tag, ItemKey::OriginalLyricist),
        recording_date: get_str(tag, ItemKey::RecordingDate),
        release_date: get_str(tag, ItemKey::ReleaseDate),
        original_release_date: get_str(tag, ItemKey::OriginalReleaseDate),
        initial_key: get_str(tag, ItemKey::InitialKey),
        color: get_str(tag, ItemKey::Color),
        mood: get_str(tag, ItemKey::Mood),
        audio_file_url: get_str(tag, ItemKey::AudioFileUrl),
        audio_source_url: get_str(tag, ItemKey::AudioSourceUrl),
        commercial_information_url: get_str(tag, ItemKey::CommercialInformationUrl),
        copyright_url: get_str(tag, ItemKey::CopyrightUrl),
        track_artist_url: get_str(tag, ItemKey::TrackArtistUrl),
        radio_station_url: get_str(tag, ItemKey::RadioStationUrl),
        payment_url: get_str(tag, ItemKey::PaymentUrl),
        publisher_url: get_str(tag, ItemKey::PublisherUrl),
        copyright_message: get_str(tag, ItemKey::CopyrightMessage),
        license: get_str(tag, ItemKey::License),
        podcast_description: get_str(tag, ItemKey::PodcastDescription),
        podcast_series_category: get_str(tag, ItemKey::PodcastSeriesCategory),
        podcast_url: get_str(tag, ItemKey::PodcastUrl),
        podcast_global_unique_id: get_str(tag, ItemKey::PodcastGlobalUniqueId),
        podcast_keywords: get_str(tag, ItemKey::PodcastKeywords),
        set_subtitle: get_str(tag, ItemKey::SetSubtitle),
        show_name: get_str(tag, ItemKey::ShowName),
        content_group: get_str(tag, ItemKey::ContentGroup),
        track_subtitle: get_str(tag, ItemKey::TrackSubtitle),
        language: get_str(tag, ItemKey::Language),
        script: get_str(tag, ItemKey::Script),
        parental_advisory: get_str(tag, ItemKey::ParentalAdvisory),
        file_owner: get_str(tag, ItemKey::FileOwner),
        original_file_name: get_str(tag, ItemKey::OriginalFileName),
        original_media_type: get_str(tag, ItemKey::OriginalMediaType),
        encoded_by: get_str(tag, ItemKey::EncodedBy),
        encoder_software: get_str(tag, ItemKey::EncoderSoftware),
        encoder_settings: get_str(tag, ItemKey::EncoderSettings),
    }
}

fn apply_to_lofty_tag(tag: &ExtendedTag, lo_tag: &mut LoftyTag) {
    set_str(
        lo_tag,
        ItemKey::MusicBrainzRecordingId,
        &tag.music_brainz_recording_id,
    );
    set_str(
        lo_tag,
        ItemKey::MusicBrainzTrackId,
        &tag.music_brainz_track_id,
    );
    set_str(
        lo_tag,
        ItemKey::MusicBrainzReleaseId,
        &tag.music_brainz_release_id,
    );
    set_str(
        lo_tag,
        ItemKey::MusicBrainzReleaseGroupId,
        &tag.music_brainz_release_group_id,
    );
    set_str(
        lo_tag,
        ItemKey::MusicBrainzArtistId,
        &tag.music_brainz_artist_id,
    );
    set_str(
        lo_tag,
        ItemKey::MusicBrainzReleaseArtistId,
        &tag.music_brainz_release_artist_id,
    );
    set_str(
        lo_tag,
        ItemKey::MusicBrainzWorkId,
        &tag.music_brainz_work_id,
    );
    set_str(
        lo_tag,
        ItemKey::MusicBrainzReleaseType,
        &tag.music_brainz_release_type,
    );
    set_str(lo_tag, ItemKey::AcoustId, &tag.acoust_id);
    set_str(
        lo_tag,
        ItemKey::AcoustIdFingerprint,
        &tag.acoust_id_fingerprint,
    );
    set_str(lo_tag, ItemKey::Isrc, &tag.isrc);
    set_str(lo_tag, ItemKey::Barcode, &tag.barcode);
    set_str(lo_tag, ItemKey::CatalogNumber, &tag.catalog_number);
    set_str(lo_tag, ItemKey::Arranger, &tag.arranger);
    set_str(lo_tag, ItemKey::Conductor, &tag.conductor);
    set_str(lo_tag, ItemKey::Director, &tag.director);
    set_str(lo_tag, ItemKey::Engineer, &tag.engineer);
    set_str(lo_tag, ItemKey::Lyricist, &tag.lyricist);
    set_str(lo_tag, ItemKey::MixDj, &tag.mix_dj);
    set_str(lo_tag, ItemKey::MixEngineer, &tag.mix_engineer);
    set_str(lo_tag, ItemKey::Performer, &tag.performer);
    set_str(lo_tag, ItemKey::Producer, &tag.producer);
    set_str(lo_tag, ItemKey::Publisher, &tag.publisher);
    set_str(lo_tag, ItemKey::Label, &tag.label);
    set_str(lo_tag, ItemKey::Remixer, &tag.remixer);
    set_str(lo_tag, ItemKey::Writer, &tag.writer);
    set_str(lo_tag, ItemKey::Composer, &tag.composer);
    set_str(lo_tag, ItemKey::OriginalLyricist, &tag.original_lyricist);
    set_str(lo_tag, ItemKey::RecordingDate, &tag.recording_date);
    set_str(lo_tag, ItemKey::ReleaseDate, &tag.release_date);
    set_str(
        lo_tag,
        ItemKey::OriginalReleaseDate,
        &tag.original_release_date,
    );
    set_str(lo_tag, ItemKey::InitialKey, &tag.initial_key);
    set_str(lo_tag, ItemKey::Color, &tag.color);
    set_str(lo_tag, ItemKey::Mood, &tag.mood);
    set_str(lo_tag, ItemKey::AudioFileUrl, &tag.audio_file_url);
    set_str(lo_tag, ItemKey::AudioSourceUrl, &tag.audio_source_url);
    set_str(
        lo_tag,
        ItemKey::CommercialInformationUrl,
        &tag.commercial_information_url,
    );
    set_str(lo_tag, ItemKey::CopyrightUrl, &tag.copyright_url);
    set_str(lo_tag, ItemKey::TrackArtistUrl, &tag.track_artist_url);
    set_str(lo_tag, ItemKey::RadioStationUrl, &tag.radio_station_url);
    set_str(lo_tag, ItemKey::PaymentUrl, &tag.payment_url);
    set_str(lo_tag, ItemKey::PublisherUrl, &tag.publisher_url);
    set_str(lo_tag, ItemKey::CopyrightMessage, &tag.copyright_message);
    set_str(lo_tag, ItemKey::License, &tag.license);
    set_str(
        lo_tag,
        ItemKey::PodcastDescription,
        &tag.podcast_description,
    );
    set_str(
        lo_tag,
        ItemKey::PodcastSeriesCategory,
        &tag.podcast_series_category,
    );
    set_str(lo_tag, ItemKey::PodcastUrl, &tag.podcast_url);
    set_str(
        lo_tag,
        ItemKey::PodcastGlobalUniqueId,
        &tag.podcast_global_unique_id,
    );
    set_str(lo_tag, ItemKey::PodcastKeywords, &tag.podcast_keywords);
    set_str(lo_tag, ItemKey::SetSubtitle, &tag.set_subtitle);
    set_str(lo_tag, ItemKey::ShowName, &tag.show_name);
    set_str(lo_tag, ItemKey::ContentGroup, &tag.content_group);
    set_str(lo_tag, ItemKey::TrackSubtitle, &tag.track_subtitle);
    set_str(lo_tag, ItemKey::Language, &tag.language);
    set_str(lo_tag, ItemKey::Script, &tag.script);
    set_str(lo_tag, ItemKey::ParentalAdvisory, &tag.parental_advisory);
    set_str(lo_tag, ItemKey::FileOwner, &tag.file_owner);
    set_str(lo_tag, ItemKey::OriginalFileName, &tag.original_file_name);
    set_str(lo_tag, ItemKey::OriginalMediaType, &tag.original_media_type);
    set_str(lo_tag, ItemKey::EncodedBy, &tag.encoded_by);
    set_str(lo_tag, ItemKey::EncoderSoftware, &tag.encoder_software);
    set_str(lo_tag, ItemKey::EncoderSettings, &tag.encoder_settings);
}

// ── Read ──

/// Read extended metadata from a file path.
pub fn read_extended(path: String) -> Result<ExtendedTag, HaudiotaggerError> {
    let bytes = std::fs::read(&path).map_err(|e| HaudiotaggerError::OpenFile {
        message: format!("Could not read file: {e}"),
    })?;
    read_extended_from_bytes(bytes)
}

/// Read extended metadata from in-memory bytes.
pub fn read_extended_from_bytes(bytes: Vec<u8>) -> Result<ExtendedTag, HaudiotaggerError> {
    use std::io::Cursor;
    let mut cursor = Cursor::new(&bytes);
    let file = lofty::probe::Probe::new(&mut cursor)
        .guess_file_type()
        .map_err(|e| HaudiotaggerError::OpenFile {
            message: format!("Could not guess file type: {e}"),
        })?
        .read()
        .map_err(|e| HaudiotaggerError::OpenFile {
            message: format!("Could not read file: {e}"),
        })?;
    let lo_tag = file.primary_tag().ok_or(HaudiotaggerError::NoTags)?;
    Ok(from_lofty_tag(lo_tag))
}

// ── Write ──

/// Write extended metadata to a file, replacing the existing extended fields.
pub fn write_extended(path: String, data: ExtendedTag) -> Result<(), HaudiotaggerError> {
    let bytes = std::fs::read(&path).map_err(|e| HaudiotaggerError::OpenFile {
        message: format!("Could not read file: {e}"),
    })?;
    let out = write_extended_to_bytes_inner(&bytes, &data)?;
    std::fs::write(&path, out).map_err(|e| HaudiotaggerError::Write {
        message: format!("Could not write file: {e}"),
    })
}

/// Write extended metadata to bytes, returning the modified bytes.
pub fn write_extended_to_bytes(
    bytes: Vec<u8>,
    data: ExtendedTag,
) -> Result<Vec<u8>, HaudiotaggerError> {
    write_extended_to_bytes_inner(&bytes, &data)
}

fn write_extended_to_bytes_inner(
    bytes: &[u8],
    data: &ExtendedTag,
) -> Result<Vec<u8>, HaudiotaggerError> {
    use std::io::Cursor;

    // For MP3: strip tags, read existing tag, merge extended, dump, concatenate
    if crate::api::api::is_mp3("", bytes) {
        let audio = crate::api::api::strip_ape(crate::api::api::strip_id3v1(
            crate::api::api::strip_id3v2(bytes),
        ));

        // Read the existing tag via lofty to preserve all fields
        let mut cursor = Cursor::new(bytes);
        let mut lo_tag = lofty::probe::Probe::new(&mut cursor)
            .guess_file_type()
            .ok()
            .and_then(|p| p.read().ok())
            .and_then(|mut file| file.primary_tag().cloned())
            .unwrap_or_else(|| LoftyTag::new(lofty::tag::TagType::Id3v2));

        // Apply extended fields on top of existing tag
        apply_to_lofty_tag(data, &mut lo_tag);

        let mut tag_bytes = Vec::with_capacity(1024);
        lo_tag
            .dump_to(&mut tag_bytes, WriteOptions::new())
            .map_err(|e| HaudiotaggerError::Write {
                message: format!("Could not serialize tag: {e:?}"),
            })?;

        let mut out = Vec::with_capacity(tag_bytes.len() + audio.len());
        out.extend_from_slice(&tag_bytes);
        out.extend_from_slice(audio);
        return Ok(out);
    }

    // For non-MP3: use lofty's full read/write
    let mut cursor = Cursor::new(bytes);
    let mut file = lofty::probe::Probe::new(&mut cursor)
        .guess_file_type()
        .map_err(|e| HaudiotaggerError::OpenFile {
            message: format!("Could not guess file type: {e}"),
        })?
        .read()
        .map_err(|e| HaudiotaggerError::OpenFile {
            message: format!("Could not read file: {e}"),
        })?;
    let lo_tag = file.primary_tag_mut().ok_or(HaudiotaggerError::NoTags)?;
    apply_to_lofty_tag(data, lo_tag);

    let mut buf = Cursor::new(Vec::new());
    file.save_to(&mut buf, WriteOptions::new())
        .map_err(|e| HaudiotaggerError::Write {
            message: format!("Could not save file: {e:?}"),
        })?;
    Ok(buf.into_inner())
}

// ── Update ──

/// Apply partial changes to the extended tag at `path`.
pub fn update_extended(path: String, changes: ExtendedChanges) -> Result<(), HaudiotaggerError> {
    let base = read_extended_or_empty(&path)?;
    write_extended(path, changes.merge(&base))
}

/// Apply partial changes to extended tag bytes, returning modified bytes.
pub fn update_extended_from_bytes(
    bytes: Vec<u8>,
    changes: ExtendedChanges,
) -> Result<Vec<u8>, HaudiotaggerError> {
    let base = read_extended_from_bytes(bytes.clone()).unwrap_or_default();
    write_extended_to_bytes(bytes, changes.merge(&base))
}

fn read_extended_or_empty(path: &str) -> Result<ExtendedTag, HaudiotaggerError> {
    let bytes = std::fs::read(path).map_err(|e| HaudiotaggerError::OpenFile {
        message: format!("Could not read file: {e}"),
    })?;
    read_extended_from_bytes(bytes).or_else(|_| Ok(ExtendedTag::default()))
}

// ── Remove ──

/// Remove all extended fields from the file, preserving standard fields.
pub fn remove_extended(path: String) -> Result<(), HaudiotaggerError> {
    write_extended(path, ExtendedTag::default())
}

/// Remove all extended fields from bytes, returning modified bytes.
pub fn remove_extended_from_bytes(bytes: Vec<u8>) -> Result<Vec<u8>, HaudiotaggerError> {
    write_extended_to_bytes(bytes, ExtendedTag::default())
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Scratch-copy a real MP3 so concurrent tests don't clobber each other.
    fn scratch_test_mp3() -> String {
        let n = TEST_COUNTER.fetch_add(1, std::sync::atomic::Ordering::SeqCst);
        let dst =
            std::env::temp_dir().join(format!("haudiotagger_ext_{}_{}.mp3", std::process::id(), n));
        std::fs::copy("samples/test.mp3", &dst).expect("Could not copy test.mp3");
        dst.to_string_lossy().into_owned()
    }

    static TEST_COUNTER: std::sync::atomic::AtomicU64 = std::sync::atomic::AtomicU64::new(0);

    #[test]
    fn read_extended_roundtrip() {
        let path = scratch_test_mp3();

        let mut ext = ExtendedTag::default();
        ext.isrc = Some("US-S1Z-99-00001".to_string());
        ext.mood = Some("upbeat".to_string());
        ext.catalog_number = Some("CAT-12345".to_string());
        ext.barcode = Some("1234567890".to_string());

        write_extended(path.clone(), ext).unwrap();

        let read = read_extended(path).unwrap();
        assert_eq!(read.isrc.as_deref(), Some("US-S1Z-99-00001"));
        assert_eq!(read.mood.as_deref(), Some("upbeat"));
        assert_eq!(read.catalog_number.as_deref(), Some("CAT-12345"));
        assert_eq!(read.barcode.as_deref(), Some("1234567890"));
    }

    #[test]
    fn write_extended_roundtrip() {
        let path = scratch_test_mp3();

        let mut ext = ExtendedTag::default();
        ext.isrc = Some("NEW-ISRC-123".to_string());
        ext.mood = Some("chill".to_string());

        write_extended(path.clone(), ext).unwrap();
        let read_back = read_extended(path).unwrap();
        assert_eq!(read_back.isrc.as_deref(), Some("NEW-ISRC-123"));
        assert_eq!(read_back.mood.as_deref(), Some("chill"));
    }

    #[test]
    fn update_extended_merges() {
        let path = scratch_test_mp3();

        let mut initial = ExtendedTag::default();
        initial.isrc = Some("ORIGINAL-ISRC".to_string());
        initial.catalog_number = Some("CAT-000".to_string());
        write_extended(path.clone(), initial).unwrap();

        let mut changes = ExtendedChanges::default();
        changes.isrc = Some("UPDATED-ISRC".to_string());
        update_extended(path.clone(), changes).unwrap();

        let read_back = read_extended(path).unwrap();
        assert_eq!(read_back.isrc.as_deref(), Some("UPDATED-ISRC"));
        assert_eq!(read_back.catalog_number.as_deref(), Some("CAT-000"));
    }

    #[test]
    fn empty_extended_is_empty() {
        assert!(ExtendedTag::default().is_empty());
        let mut ext = ExtendedTag::default();
        ext.isrc = Some("something".to_string());
        assert!(!ext.is_empty());
    }

    #[test]
    fn remove_extended_clears_fields() {
        let path = scratch_test_mp3();

        let mut ext = ExtendedTag::default();
        ext.isrc = Some("something".to_string());
        ext.mood = Some("happy".to_string());
        write_extended(path.clone(), ext).unwrap();

        remove_extended(path.clone()).unwrap();
        let read_back = read_extended(path).unwrap();
        assert!(read_back.is_empty());
    }
}
