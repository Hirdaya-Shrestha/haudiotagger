use super::error::HaudiotaggerError;

/// Represents a chapter marker in an audio file.
#[derive(Debug, Clone, PartialEq)]
pub struct Chapter {
    /// Chapter title.
    pub title: String,
    /// Start time in milliseconds.
    pub start_ms: u64,
    /// End time in milliseconds.
    pub end_ms: u64,
}

/// Decode a 4-byte syncsafe integer (7 bits per byte).
#[inline]
fn decode_syncsafe(b0: u8, b1: u8, b2: u8, b3: u8) -> usize {
    ((b0 as usize & 0x7F) << 21)
        | ((b1 as usize & 0x7F) << 14)
        | ((b2 as usize & 0x7F) << 7)
        | (b3 as usize & 0x7F)
}

/// Encode a usize as a 4-byte syncsafe integer.
#[inline]
fn encode_syncsafe(size: usize) -> [u8; 4] {
    [
        ((size >> 21) & 0x7F) as u8,
        ((size >> 14) & 0x7F) as u8,
        ((size >> 7) & 0x7F) as u8,
        (size & 0x7F) as u8,
    ]
}

/// Read ID3v2 CHAP frames from MP3 bytes.
pub fn read_chapters_from_mp3_bytes(bytes: &[u8]) -> Result<Vec<Chapter>, HaudiotaggerError> {
    if bytes.len() < 10 || &bytes[0..3] != b"ID3" {
        return Ok(Vec::new());
    }

    let version = bytes[3];
    let tag_size = decode_syncsafe(bytes[6], bytes[7], bytes[8], bytes[9]);
    let tag_end = 10 + tag_size;
    if tag_end > bytes.len() {
        return Ok(Vec::new());
    }

    let tag_data = &bytes[10..tag_end];
    let mut chapters = Vec::new();

    let mut offset = 0;
    while offset + 10 <= tag_data.len() {
        let frame_id = &tag_data[offset..offset + 4];

        // Skip ID3v2 padding (null bytes) — may appear between frames
        if frame_id == &[0, 0, 0, 0] {
            // Skip to end of padding block
            while offset < tag_data.len() && tag_data[offset] == 0 {
                offset += 1;
            }
            continue;
        }

        let frame_size = if version >= 4 {
            decode_syncsafe(
                tag_data[offset + 4],
                tag_data[offset + 5],
                tag_data[offset + 6],
                tag_data[offset + 7],
            )
        } else {
            ((tag_data[offset + 4] as usize) << 24)
                | ((tag_data[offset + 5] as usize) << 16)
                | ((tag_data[offset + 6] as usize) << 8)
                | (tag_data[offset + 7] as usize)
        };

        if frame_size == 0 || offset + 10 + frame_size > tag_data.len() {
            break;
        }

        if frame_id == b"CHAP" {
            let frame_body = &tag_data[offset + 10..offset + 10 + frame_size];
            if let Some(chap) = parse_chap_frame(frame_body) {
                chapters.push(chap);
            }
        }

        offset += 10 + frame_size;
    }

    Ok(chapters)
}

/// Parse a single CHAP frame body.
fn parse_chap_frame(body: &[u8]) -> Option<Chapter> {
    let null_pos = body.iter().position(|&b| b == 0)?;
    let element_id = String::from_utf8_lossy(&body[..null_pos]).to_string();

    let time_start = null_pos + 1;
    if time_start + 8 > body.len() {
        return None;
    }

    let start_ms = u32::from_be_bytes([
        body[time_start],
        body[time_start + 1],
        body[time_start + 2],
        body[time_start + 3],
    ]) as u64;

    let end_ms = u32::from_be_bytes([
        body[time_start + 4],
        body[time_start + 5],
        body[time_start + 6],
        body[time_start + 7],
    ]) as u64;

    Some(Chapter {
        title: element_id,
        start_ms,
        end_ms,
    })
}

/// Strip existing CHAP and CTOC frames from tag content bytes,
/// returning only non-chapter frames (including trailing padding).
fn strip_chapter_frames(tag_data: &[u8], version: u8) -> Vec<u8> {
    let mut out = Vec::with_capacity(tag_data.len());
    let mut offset = 0;
    while offset + 10 <= tag_data.len() {
        let frame_id = &tag_data[offset..offset + 4];

        // Skip padding (null bytes) — may appear between frames or at end
        if frame_id == &[0, 0, 0, 0] {
            // If we've only seen padding so far, preserve it at the end
            // (it's the original tag's trailing padding)
            break;
        }

        let frame_size = if version >= 4 {
            decode_syncsafe(
                tag_data[offset + 4],
                tag_data[offset + 5],
                tag_data[offset + 6],
                tag_data[offset + 7],
            )
        } else {
            ((tag_data[offset + 4] as usize) << 24)
                | ((tag_data[offset + 5] as usize) << 16)
                | ((tag_data[offset + 6] as usize) << 8)
                | (tag_data[offset + 7] as usize)
        };

        if frame_size == 0 || offset + 10 + frame_size > tag_data.len() {
            break;
        }

        // Keep all frames EXCEPT CHAP and CTOC
        if frame_id != b"CHAP" && frame_id != b"CTOC" {
            out.extend_from_slice(&tag_data[offset..offset + 10 + frame_size]);
        }

        offset += 10 + frame_size;
    }

    // Append trailing padding (everything from offset to end that's all zeros)
    // to preserve tag size semantics
    while offset < tag_data.len() && tag_data[offset] == 0 {
        out.push(0);
        offset += 1;
    }

    out
}

/// Write chapters as ID3v2 CHAP frames to MP3 bytes.
/// Strips existing CHAP/CTOC frames, then appends new ones.
pub fn write_chapters_to_mp3_bytes(
    bytes: &[u8],
    chapters: &[Chapter],
) -> Result<Vec<u8>, HaudiotaggerError> {
    let is_v24 = bytes.len() >= 4 && bytes[3] >= 4;

    if bytes.len() < 10 || &bytes[0..3] != b"ID3" {
        if chapters.is_empty() {
            return Ok(bytes.to_vec());
        }
        let chap_bytes = serialize_chap_frames(&chapters, is_v24);
        let header = create_id3v2_header(chap_bytes.len());
        let mut out = Vec::with_capacity(header.len() + chap_bytes.len() + bytes.len());
        out.extend_from_slice(&header);
        out.extend_from_slice(&chap_bytes);
        out.extend_from_slice(bytes);
        return Ok(out);
    }

    let version = bytes[3];
    let tag_size = decode_syncsafe(bytes[6], bytes[7], bytes[8], bytes[9]);
    let tag_end = 10 + tag_size;
    if tag_end > bytes.len() {
        return Err(HaudiotaggerError::Write {
            message: "ID3v2 tag size exceeds file".to_string(),
        });
    }

    let audio = &bytes[tag_end..];

    // Strip existing chapter frames from tag content
    let clean_frames = strip_chapter_frames(&bytes[10..tag_end], version);
    let chap_bytes = serialize_chap_frames(&chapters, is_v24);
    let new_content_size = clean_frames.len() + chap_bytes.len();

    let mut out = Vec::with_capacity(10 + new_content_size + audio.len());
    out.extend_from_slice(&bytes[..6]);
    out.extend_from_slice(&encode_syncsafe(new_content_size));
    out.extend_from_slice(&clean_frames);
    if !chap_bytes.is_empty() {
        out.extend_from_slice(&chap_bytes);
    }
    out.extend_from_slice(audio);

    Ok(out)
}

/// Serialize chapters as CHAP frames.
/// `is_v24`: if true, use syncsafe frame sizes (ID3v2.4); otherwise big-endian (ID3v2.3).
fn serialize_chap_frames(chapters: &[Chapter], is_v24: bool) -> Vec<u8> {
    let mut out = Vec::new();
    for chapter in chapters {
        let id_bytes = chapter.title.as_bytes();
        let body_size = id_bytes.len() + 1 + 8;
        let start_ms = chapter.start_ms as u32;
        let end_ms = chapter.end_ms as u32;

        out.extend_from_slice(b"CHAP");
        if is_v24 {
            out.extend_from_slice(&encode_syncsafe(body_size));
        } else {
            out.extend_from_slice(&(body_size as u32).to_be_bytes());
        }
        out.extend_from_slice(&[0, 0]); // flags
        out.extend_from_slice(id_bytes);
        out.push(0); // null terminator
        out.extend_from_slice(&start_ms.to_be_bytes());
        out.extend_from_slice(&end_ms.to_be_bytes());
    }
    out
}

/// Create an ID3v2.4 header with syncsafe size.
fn create_id3v2_header(tag_size: usize) -> [u8; 10] {
    let mut header = [0u8; 10];
    header[0] = b'I';
    header[1] = b'D';
    header[2] = b'3';
    header[3] = 4; // version 2.4
    header[4] = 0; // revision
    header[5] = 0; // flags
    header[6..10].copy_from_slice(&encode_syncsafe(tag_size));
    header
}

/// Read chapters from in-memory bytes (for web/WASM).
pub fn read_chapters_from_bytes(bytes: Vec<u8>) -> Result<Vec<Chapter>, HaudiotaggerError> {
    if crate::api::api::is_mp3("", &bytes) {
        return read_chapters_from_mp3_bytes(&bytes);
    }
    Ok(Vec::new())
}

/// Write chapters to in-memory bytes, returning modified bytes.
pub fn write_chapters_to_bytes(
    bytes: Vec<u8>,
    chapters: Vec<Chapter>,
) -> Result<Vec<u8>, HaudiotaggerError> {
    if crate::api::api::is_mp3("", &bytes) {
        return write_chapters_to_mp3_bytes(&bytes, &chapters);
    }
    Ok(bytes)
}

/// Read chapters from the file at `path`.
pub fn get_chapters(path: String) -> Result<Vec<Chapter>, HaudiotaggerError> {
    let bytes = std::fs::read(&path).map_err(|e| HaudiotaggerError::OpenFile {
        message: format!("Could not read file: {e}"),
    })?;
    read_chapters_from_mp3_bytes(&bytes)
}

/// Write chapters to the file at `path`.
pub fn set_chapters(path: String, chapters: Vec<Chapter>) -> Result<(), HaudiotaggerError> {
    let bytes = std::fs::read(&path).map_err(|e| HaudiotaggerError::OpenFile {
        message: format!("Could not read file: {e}"),
    })?;
    let out = write_chapters_to_mp3_bytes(&bytes, &chapters)?;
    std::fs::write(&path, out).map_err(|e| HaudiotaggerError::Write {
        message: format!("Could not write file: {e}"),
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use lofty::config::WriteOptions;
    use lofty::tag::{ItemKey, Tag as LoftyTag, TagExt, TagType};

    fn make_test_mp3() -> Vec<u8> {
        let mut lo_tag = LoftyTag::new(TagType::Id3v2);
        lo_tag.insert_text(ItemKey::TrackTitle, "Test".to_string());
        let mut tag_bytes = Vec::new();
        lo_tag.dump_to(&mut tag_bytes, WriteOptions::new()).unwrap();
        let mut mp3 = tag_bytes;
        mp3.extend_from_slice(&[0xFFu8; 200]); // fake audio
        mp3
    }

    #[test]
    fn chapter_roundtrip() {
        let mp3 = make_test_mp3();
        let chapters = vec![
            Chapter { title: "Intro".into(), start_ms: 0, end_ms: 60000 },
            Chapter { title: "Verse".into(), start_ms: 60000, end_ms: 120000 },
        ];
        let written = write_chapters_to_mp3_bytes(&mp3, &chapters).unwrap();
        let read_back = read_chapters_from_mp3_bytes(&written).unwrap();
        assert_eq!(read_back.len(), 2);
        assert_eq!(read_back[0].title, "Intro");
        assert_eq!(read_back[0].start_ms, 0);
        assert_eq!(read_back[1].title, "Verse");
        assert_eq!(read_back[1].end_ms, 120000);
    }

    #[test]
    fn write_overwrites_chapters() {
        let mp3 = make_test_mp3();
        let ch1 = vec![Chapter { title: "A".into(), start_ms: 0, end_ms: 100 }];
        let written = write_chapters_to_mp3_bytes(&mp3, &ch1).unwrap();
        let ch2 = vec![
            Chapter { title: "X".into(), start_ms: 0, end_ms: 50 },
            Chapter { title: "Y".into(), start_ms: 50, end_ms: 100 },
            Chapter { title: "Z".into(), start_ms: 100, end_ms: 200 },
        ];
        let written2 = write_chapters_to_mp3_bytes(&written, &ch2).unwrap();
        let read_back = read_chapters_from_mp3_bytes(&written2).unwrap();
        assert_eq!(read_back.len(), 3);
        assert_eq!(read_back[0].title, "X");
        assert_eq!(read_back[2].title, "Z");
    }

    #[test]
    fn no_chapters_returns_input() {
        let mp3 = make_test_mp3();
        let result = write_chapters_to_mp3_bytes(&mp3, &[]).unwrap();
        assert_eq!(result, mp3);
    }
}
