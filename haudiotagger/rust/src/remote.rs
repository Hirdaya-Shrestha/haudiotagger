use std::collections::HashMap;
use std::io::{Read, Seek, SeekFrom};
use std::sync::{Arc, Mutex};

use crate::api::error::HaudiotaggerError;
use crate::api::remote_read::UrlReadStrategy;

// ── Shared data types ───────────────────────────────────────────────────────

pub struct RemoteFileInfo {
    pub size: Option<u64>,
    pub accept_ranges: bool,
    pub content_type: Option<String>,
}

pub struct HttpResponse {
    pub status: u16,
    pub body: Vec<u8>,
}

// ── Format detection ────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
#[allow(dead_code)]
pub(crate) enum DetectedFormat {
    Mp3,
    Flac,
    Ogg,
    Opus,
    Mp4,
    Wav,
    Aiff,
    Ape,
    WavPack,
    Unknown,
}

fn detect_from_bytes(data: &[u8]) -> DetectedFormat {
    if data.len() >= 3 && &data[0..3] == b"ID3" {
        return DetectedFormat::Mp3;
    }
    if data.len() >= 4 && &data[0..4] == b"fLaC" {
        return DetectedFormat::Flac;
    }
    if data.len() >= 4 && &data[0..4] == b"OggS" {
        return DetectedFormat::Ogg;
    }
    if data.len() >= 12 && &data[0..4] == b"RIFF" && &data[8..12] == b"WAVE" {
        return DetectedFormat::Wav;
    }
    if data.len() >= 4 && &data[0..4] == b"ftyp" {
        return DetectedFormat::Mp4;
    }
    if data.len() >= 4 {
        let tag = &data[0..4];
        if tag == b"FORM" || tag == b"AIFF" {
            return DetectedFormat::Aiff;
        }
    }
    DetectedFormat::Unknown
}

const SMALL_FILE_THRESHOLD: u64 = 5 * 1024 * 1024;
const PROGRESSIVE_THRESHOLD: u64 = 50 * 1024 * 1024;

fn select_strategy(info: &RemoteFileInfo, format: DetectedFormat) -> UrlReadStrategy {
    if !info.accept_ranges {
        return UrlReadStrategy::Full;
    }
    let size = info.size.unwrap_or(0);

    match format {
        DetectedFormat::Mp3 => {
            if size < SMALL_FILE_THRESHOLD {
                UrlReadStrategy::Full
            } else if size < PROGRESSIVE_THRESHOLD {
                UrlReadStrategy::Progressive
            } else {
                UrlReadStrategy::RandomAccess
            }
        }
        DetectedFormat::Flac | DetectedFormat::Ogg | DetectedFormat::Opus => {
            UrlReadStrategy::Progressive
        }
        _ => {
            if size < SMALL_FILE_THRESHOLD {
                UrlReadStrategy::Full
            } else {
                UrlReadStrategy::RandomAccess
            }
        }
    }
}

// ── Block cache ─────────────────────────────────────────────────────────────

const MAX_CACHE_BYTES: u64 = 16 * 1024 * 1024;

struct RangeCache {
    blocks: HashMap<u64, Vec<u8>>,
    block_size: u64,
    total_bytes: u64,
}

impl RangeCache {
    fn new(block_size: u64) -> Self {
        Self {
            blocks: HashMap::new(),
            block_size: block_size.max(1),
            total_bytes: 0,
        }
    }

    fn get(&self, offset: u64, length: u64) -> Option<Vec<u8>> {
        let start_block = offset / self.block_size;
        let end_block = (offset + length + self.block_size - 1) / self.block_size;

        let mut result = Vec::with_capacity(length as usize);
        for idx in start_block..end_block {
            let block_start = idx * self.block_size;
            let data = self.blocks.get(&block_start)?;
            let block_end = block_start + data.len() as u64;

            let s = if offset > block_start {
                (offset - block_start) as usize
            } else {
                0
            };
            let e = if offset + length < block_end {
                ((offset + length) - block_start) as usize
            } else {
                data.len()
            };

            if s > e || s > data.len() {
                return None;
            }
            result.extend_from_slice(&data[s..e]);
        }
        Some(result)
    }

    fn insert(&mut self, offset: u64, data: Vec<u8>) {
        let block_start = (offset / self.block_size) * self.block_size;
        let entry = self.blocks.entry(block_start).or_default();

        let block_offset = offset - block_start;
        let end = block_offset as usize + data.len();
        if end > entry.len() {
            entry.resize(end, 0);
        }
        entry[block_offset as usize..end].copy_from_slice(&data);

        self.total_bytes = self.blocks.values().map(|v| v.len() as u64).sum();
        if self.total_bytes > MAX_CACHE_BYTES {
            self.evict();
        }
    }

    fn evict(&mut self) {
        let target = MAX_CACHE_BYTES / 2;
        let mut total = self.total_bytes;
        while total > target && !self.blocks.is_empty() {
            if let Some(key) = self.blocks.keys().min().copied() {
                if let Some(data) = self.blocks.remove(&key) {
                    total -= data.len() as u64;
                }
            } else {
                break;
            }
        }
        self.total_bytes = total;
    }
}

// ── Native: blocking HTTP + RemoteReader (Read + Seek over HTTP Range) ──────
//
// Uses reqwest::blocking::Client for synchronous HTTP Range requests inside
// RemoteReader's Read::read() impl. Lofty parses metadata via std::io::Read
// + Seek without async plumbing.

#[cfg(not(target_arch = "wasm32"))]
mod native_http {
    use super::*;
    use reqwest::blocking::Client;

    pub struct BlockingHttpClient {
        client: Client,
        request_timeout_ms: u64,
        max_retries: u32,
    }

    impl BlockingHttpClient {
        pub fn new() -> Self {
            let client = Client::builder()
                .gzip(true)
                .brotli(true)
                .deflate(true)
                .build()
                .unwrap_or_else(|e| panic!("Failed to build HTTP client: {e}"));
            Self {
                client,
                request_timeout_ms: 30_000,
                max_retries: 3,
            }
        }

        pub fn head(&self, url: &str) -> Result<RemoteFileInfo, HaudiotaggerError> {
            let response = self.retry(|| {
                self.client
                    .head(url)
                    .timeout(std::time::Duration::from_millis(self.request_timeout_ms))
                    .send()
                    .map_err(|e| HaudiotaggerError::Remote {
                        message: format!("Network error: {e}"),
                    })
            })?;

            let status = response.status().as_u16();
            if status >= 400 {
                return Err(HaudiotaggerError::Remote {
                    message: format!("HEAD request failed with status {status}"),
                });
            }

            let headers = response.headers().clone();
            let size = headers
                .get("content-length")
                .and_then(|v| v.to_str().ok())
                .and_then(|v| v.parse::<u64>().ok());

            let accept_ranges = headers
                .get("accept-ranges")
                .and_then(|v| v.to_str().ok())
                .map(|v| v.contains("bytes"))
                .unwrap_or(false);

            let content_type = headers
                .get("content-type")
                .and_then(|v| v.to_str().ok())
                .map(|v| v.to_string());

            Ok(RemoteFileInfo {
                size,
                accept_ranges,
                content_type,
            })
        }

        pub fn get_range(
            &self,
            url: &str,
            start: u64,
            end: u64,
        ) -> Result<HttpResponse, HaudiotaggerError> {
            let response = self.retry(|| {
                self.client
                    .get(url)
                    .header("Range", format!("bytes={start}-{end}"))
                    .timeout(std::time::Duration::from_millis(self.request_timeout_ms))
                    .send()
                    .map_err(|e| HaudiotaggerError::Remote {
                        message: format!("Network error: {e}"),
                    })
            })?;

            let status = response.status().as_u16();
            let body = response
                .bytes()
                .map_err(|e| HaudiotaggerError::Remote {
                    message: format!("Failed to read response body: {e}"),
                })?
                .to_vec();

            Ok(HttpResponse { status, body })
        }

        pub fn get_all(&self, url: &str) -> Result<HttpResponse, HaudiotaggerError> {
            let response = self.retry(|| {
                self.client
                    .get(url)
                    .timeout(std::time::Duration::from_millis(self.request_timeout_ms))
                    .send()
                    .map_err(|e| HaudiotaggerError::Remote {
                        message: format!("Network error: {e}"),
                    })
            })?;

            let status = response.status().as_u16();
            let body = response
                .bytes()
                .map_err(|e| HaudiotaggerError::Remote {
                    message: format!("Failed to read response body: {e}"),
                })?
                .to_vec();

            Ok(HttpResponse { status, body })
        }

        fn retry(
            &self,
            mut op: impl FnMut() -> Result<reqwest::blocking::Response, HaudiotaggerError>,
        ) -> Result<reqwest::blocking::Response, HaudiotaggerError> {
            let mut last_err = None;
            for attempt in 0..=self.max_retries {
                match op() {
                    Ok(resp) => {
                        let status = resp.status().as_u16();
                        if status >= 500 && attempt < self.max_retries {
                            std::thread::sleep(std::time::Duration::from_millis(
                                500 * (attempt as u64 + 1),
                            ));
                            continue;
                        }
                        return Ok(resp);
                    }
                    Err(e) => {
                        if attempt < self.max_retries {
                            std::thread::sleep(std::time::Duration::from_millis(
                                500 * (attempt as u64 + 1),
                            ));
                            last_err = Some(e);
                            continue;
                        }
                        return Err(e);
                    }
                }
            }
            Err(last_err.unwrap_or_else(|| HaudiotaggerError::Remote {
                message: "Request failed".to_string(),
            }))
        }
    }

    pub fn detect_from_url(url: &str, http: &BlockingHttpClient) -> DetectedFormat {
        if let Ok(info) = http.head(url) {
            if let Some(ct) = &info.content_type {
                let ct = ct.to_lowercase();
                if ct.contains("mpeg") || ct.contains("mp3") {
                    return DetectedFormat::Mp3;
                }
                if ct.contains("flac") {
                    return DetectedFormat::Flac;
                }
                if ct.contains("ogg") {
                    return DetectedFormat::Ogg;
                }
                if ct.contains("opus") {
                    return DetectedFormat::Opus;
                }
                if ct.contains("mp4") || ct.contains("mp4a") {
                    return DetectedFormat::Mp4;
                }
                if ct.contains("wav") {
                    return DetectedFormat::Wav;
                }
                if ct.contains("aiff") {
                    return DetectedFormat::Aiff;
                }
            }
        }
        if let Ok(resp) = http.get_range(url, 0, 15) {
            if resp.status == 206 || resp.status == 200 {
                return detect_from_bytes(&resp.body);
            }
        }
        DetectedFormat::Unknown
    }

    pub struct RemoteReader {
        url: String,
        size: Option<u64>,
        accept_ranges: bool,
        http: Arc<BlockingHttpClient>,
        cache: Mutex<RangeCache>,
        fetch_size: u64,
        fetched_bytes: Mutex<u64>,
        request_count: Mutex<u32>,
        seek_pos: Mutex<u64>,
    }

    impl RemoteReader {
        pub fn new(url: String, info: RemoteFileInfo, http: Arc<BlockingHttpClient>) -> Self {
            let fetch_size = match info.size {
                Some(s) if s < SMALL_FILE_THRESHOLD => s,
                Some(s) if s < PROGRESSIVE_THRESHOLD => 256 * 1024,
                Some(_) => 1024 * 1024,
                None => 256 * 1024,
            };
            Self {
                url,
                size: info.size,
                accept_ranges: info.accept_ranges,
                http,
                cache: Mutex::new(RangeCache::new(fetch_size)),
                fetch_size,
                fetched_bytes: Mutex::new(0),
                request_count: Mutex::new(0),
                seek_pos: Mutex::new(0),
            }
        }

        pub fn read_at(&self, offset: u64, length: u64) -> Result<Vec<u8>, HaudiotaggerError> {
            if length == 0 {
                return Ok(Vec::new());
            }

            {
                let cache = self.cache.lock().unwrap();
                if let Some(data) = cache.get(offset, length) {
                    return Ok(data);
                }
            }

            if !self.accept_ranges {
                let resp = self.http.get_all(&self.url)?;
                if resp.status != 200 {
                    return Err(HaudiotaggerError::Remote {
                        message: format!("HTTP {} when downloading file", resp.status),
                    });
                }
                *self.request_count.lock().unwrap() += 1;
                *self.fetched_bytes.lock().unwrap() += resp.body.len() as u64;
                self.cache.lock().unwrap().insert(0, resp.body);

                let cache = self.cache.lock().unwrap();
                return cache
                    .get(offset, length)
                    .ok_or_else(|| HaudiotaggerError::Remote {
                        message: "Requested range exceeds downloaded data".to_string(),
                    });
            }

            let start_block = offset / self.fetch_size;
            let end_block = (offset + length + self.fetch_size - 1) / self.fetch_size;

            for idx in start_block..=end_block {
                let block_start = idx * self.fetch_size;
                let block_end = block_start + self.fetch_size - 1;

                let resp = self.http.get_range(&self.url, block_start, block_end)?;
                match resp.status {
                    206 | 200 => {
                        *self.request_count.lock().unwrap() += 1;
                        *self.fetched_bytes.lock().unwrap() += resp.body.len() as u64;
                        self.cache.lock().unwrap().insert(block_start, resp.body);
                    }
                    status => {
                        return Err(HaudiotaggerError::Remote {
                            message: format!("Unexpected HTTP status {status}"),
                        });
                    }
                }
            }

            let cache = self.cache.lock().unwrap();
            cache
                .get(offset, length)
                .ok_or_else(|| HaudiotaggerError::Remote {
                    message: "Failed to read from cache after fetch".to_string(),
                })
        }
    }

    impl Read for RemoteReader {
        fn read(&mut self, buf: &mut [u8]) -> std::io::Result<usize> {
            let pos = *self.seek_pos.lock().unwrap();
            let data = self
                .read_at(pos, buf.len() as u64)
                .map_err(|e| std::io::Error::new(std::io::ErrorKind::Other, e))?;
            let n = data.len().min(buf.len());
            buf[..n].copy_from_slice(&data[..n]);
            *self.seek_pos.lock().unwrap() = pos + n as u64;
            Ok(n)
        }
    }

    impl Seek for RemoteReader {
        fn seek(&mut self, pos: SeekFrom) -> std::io::Result<u64> {
            let current = *self.seek_pos.lock().unwrap();
            let new = match pos {
                SeekFrom::Start(o) => o,
                SeekFrom::Current(d) => current.checked_add_signed(d).ok_or_else(|| {
                    std::io::Error::new(std::io::ErrorKind::InvalidInput, "overflow")
                })?,
                SeekFrom::End(d) => {
                    let size = self.size.ok_or_else(|| {
                        std::io::Error::new(std::io::ErrorKind::UnexpectedEof, "unknown size")
                    })?;
                    size.checked_add_signed(d).ok_or_else(|| {
                        std::io::Error::new(std::io::ErrorKind::InvalidInput, "overflow")
                    })?
                }
            };
            *self.seek_pos.lock().unwrap() = new;
            Ok(new)
        }
    }
}

// ── WASM: async full-download fallback ──────────────────────────────────────
//
// On WASM, std::io::Read + Seek cannot call async HTTP. Downloads the entire
// file via web-sys fetch and parses metadata from the in-memory buffer.
// Progressive/RandomAccess strategies fall back to Full here.
//
// TODO: Replace with async Range + cache when wasm32 async seekable I/O is
//       available, without changing the public API.

#[cfg(target_arch = "wasm32")]
mod wasm_http {
    use super::*;
    use wasm_bindgen::JsCast;
    use wasm_bindgen::prelude::*;
    use wasm_bindgen_futures::JsFuture;

    async fn js_fetch(url: &str, method: &str) -> Result<(u16, Vec<u8>), HaudiotaggerError> {
        let window = web_sys::window().ok_or_else(|| HaudiotaggerError::Remote {
            message: "No window object".to_string(),
        })?;

        let mut opts = web_sys::RequestInit::new();
        opts.method(method);
        opts.mode(web_sys::RequestMode::Cors);

        let request = web_sys::Request::new_with_str_and_init(url, &opts).map_err(|e| {
            HaudiotaggerError::Remote {
                message: format!("Failed to create request: {e:?}"),
            }
        })?;

        let resp_value = JsFuture::from(window.fetch_with_request(&request))
            .await
            .map_err(|e| HaudiotaggerError::Remote {
                message: format!("Fetch failed: {e:?}"),
            })?;

        let resp: web_sys::Response =
            resp_value
                .dyn_into()
                .map_err(|_| HaudiotaggerError::Remote {
                    message: "Response cast failed".to_string(),
                })?;

        let status = resp.status() as u16;

        let array_buffer =
            JsFuture::from(resp.array_buffer().map_err(|e| HaudiotaggerError::Remote {
                message: format!("array_buffer failed: {e:?}"),
            })?)
            .await
            .map_err(|e| HaudiotaggerError::Remote {
                message: format!("Failed to read body: {e:?}"),
            })?;

        let uint8_array = js_sys::Uint8Array::new(&array_buffer);
        let body = uint8_array.to_vec();

        Ok((status, body))
    }

    async fn http_head(url: &str) -> Result<RemoteFileInfo, HaudiotaggerError> {
        let (status, _) = js_fetch(url, "HEAD").await?;
        if status >= 400 {
            return Err(HaudiotaggerError::Remote {
                message: format!("HEAD request failed with status {status}"),
            });
        }

        // Re-fetch with GET and HEAD to get headers — web-sys HEAD doesn't expose headers well
        // For simplicity, do a GET with Range: 0-0 to probe size + accept-ranges
        let window = web_sys::window().ok_or_else(|| HaudiotaggerError::Remote {
            message: "No window object".to_string(),
        })?;
        let mut opts = web_sys::RequestInit::new();
        opts.method("GET");
        opts.mode(web_sys::RequestMode::Cors);
        let request = web_sys::Request::new_with_str_and_init(url, &opts).map_err(|e| {
            HaudiotaggerError::Remote {
                message: format!("Failed to create request: {e:?}"),
            }
        })?;
        let resp_value = JsFuture::from(window.fetch_with_request(&request))
            .await
            .map_err(|e| HaudiotaggerError::Remote {
                message: format!("Fetch failed: {e:?}"),
            })?;
        let resp: web_sys::Response =
            resp_value
                .dyn_into()
                .map_err(|_| HaudiotaggerError::Remote {
                    message: "Response cast failed".to_string(),
                })?;
        let headers = resp.headers();
        let get_header = |name: &str| -> Option<String> { headers.get(name).ok().flatten() };
        let size = get_header("content-length").and_then(|v| v.parse::<u64>().ok());
        let accept_ranges = get_header("accept-ranges")
            .map(|v| v.contains("bytes"))
            .unwrap_or(false);
        let content_type = get_header("content-type");

        Ok(RemoteFileInfo {
            size,
            accept_ranges,
            content_type,
        })
    }

    async fn http_get_all(url: &str) -> Result<HttpResponse, HaudiotaggerError> {
        let (status, body) = js_fetch(url, "GET").await?;
        Ok(HttpResponse { status, body })
    }

    pub async fn read_from_url_inner(
        url: String,
        strategy: UrlReadStrategy,
    ) -> Result<Tag, HaudiotaggerError> {
        let info = http_head(&url).await?;

        let _effective = match strategy {
            UrlReadStrategy::Auto => {
                let fmt = if let Some(ct) = &info.content_type {
                    let ct = ct.to_lowercase();
                    if ct.contains("mpeg") || ct.contains("mp3") {
                        DetectedFormat::Mp3
                    } else if ct.contains("flac") {
                        DetectedFormat::Flac
                    } else if ct.contains("ogg") {
                        DetectedFormat::Ogg
                    } else if ct.contains("opus") {
                        DetectedFormat::Opus
                    } else if ct.contains("mp4") || ct.contains("mp4a") {
                        DetectedFormat::Mp4
                    } else if ct.contains("wav") {
                        DetectedFormat::Wav
                    } else if ct.contains("aiff") {
                        DetectedFormat::Aiff
                    } else {
                        DetectedFormat::Unknown
                    }
                } else {
                    DetectedFormat::Unknown
                };
                select_strategy(&info, fmt)
            }
            other => other,
        };

        // WASM always downloads full file.
        let resp = http_get_all(&url).await?;
        if resp.status != 200 {
            return Err(HaudiotaggerError::Remote {
                message: format!("HTTP {} when downloading file", resp.status),
            });
        }

        let mut cursor = std::io::Cursor::new(resp.body);
        let file = Probe::new(&mut cursor)
            .guess_file_type()
            .map_err(|e| HaudiotaggerError::OpenFile {
                message: e.to_string(),
            })?
            .read()
            .map_err(|e| HaudiotaggerError::OpenFile {
                message: e.to_string(),
            })?;
        tag_from_lofty_file(&file)
    }
}

// ── Tag extraction (shared) ─────────────────────────────────────────────────

use lofty::probe::Probe;

use crate::api::tag::Tag;

fn tag_from_lofty_file(file: &lofty::file::TaggedFile) -> Result<Tag, HaudiotaggerError> {
    use lofty::file::{AudioFile, TaggedFileExt};

    let tag = file
        .primary_tag()
        .or_else(|| file.first_tag())
        .ok_or(HaudiotaggerError::NoTags)?;

    let mut tag = Tag::from(tag);
    tag.duration = Some(file.properties().duration().as_secs() as u32);
    Ok(tag)
}

// ── Public API ──────────────────────────────────────────────────────────────

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
) -> Result<Tag, HaudiotaggerError> {
    let parsed = url::Url::parse(&url).map_err(|e| HaudiotaggerError::Remote {
        message: format!("Invalid URL: {e}"),
    })?;
    if parsed.scheme() != "http" && parsed.scheme() != "https" {
        return Err(HaudiotaggerError::Remote {
            message: "Only HTTP and HTTPS URLs are supported".to_string(),
        });
    }

    #[cfg(not(target_arch = "wasm32"))]
    {
        tokio::task::spawn_blocking(move || read_from_url_native(url, strategy))
            .await
            .map_err(|e| HaudiotaggerError::Remote {
                message: format!("Task failed: {e}"),
            })?
    }

    #[cfg(target_arch = "wasm32")]
    {
        wasm_http::read_from_url_inner(url, strategy).await
    }
}

/// Native sync implementation — runs inside spawn_blocking.
#[cfg(not(target_arch = "wasm32"))]
fn read_from_url_native(url: String, strategy: UrlReadStrategy) -> Result<Tag, HaudiotaggerError> {
    use native_http::*;

    let http = Arc::new(BlockingHttpClient::new());
    let info = http.head(&url)?;

    let effective = match strategy {
        UrlReadStrategy::Auto => {
            let format = detect_from_url(&url, &http);
            select_strategy(&info, format)
        }
        other => other,
    };

    match effective {
        UrlReadStrategy::Auto | UrlReadStrategy::Full => {
            let resp = http.get_all(&url)?;
            if resp.status != 200 {
                return Err(HaudiotaggerError::Remote {
                    message: format!("HTTP {} when downloading file", resp.status),
                });
            }
            let mut cursor = std::io::Cursor::new(resp.body);
            let file = Probe::new(&mut cursor)
                .guess_file_type()
                .map_err(|e| HaudiotaggerError::OpenFile {
                    message: e.to_string(),
                })?
                .read()
                .map_err(|e| HaudiotaggerError::OpenFile {
                    message: e.to_string(),
                })?;
            tag_from_lofty_file(&file)
        }
        UrlReadStrategy::Progressive | UrlReadStrategy::RandomAccess => {
            let reader = RemoteReader::new(url, info, http);
            let mut reader = std::io::BufReader::new(reader);
            let file = Probe::new(&mut reader)
                .guess_file_type()
                .map_err(|e| HaudiotaggerError::OpenFile {
                    message: e.to_string(),
                })?
                .read()
                .map_err(|e| HaudiotaggerError::OpenFile {
                    message: e.to_string(),
                })?;
            tag_from_lofty_file(&file)
        }
    }
}

// ── Tests ───────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    // ── detect_from_bytes ────────────────────────────────────────────────

    #[test]
    fn detect_mp3_id3v2() {
        let mut data = b"ID3".to_vec();
        data.extend_from_slice(&[0; 100]);
        assert_eq!(detect_from_bytes(&data), DetectedFormat::Mp3);
    }

    #[test]
    fn detect_flac() {
        let mut data = b"fLaC".to_vec();
        data.extend_from_slice(&[0; 100]);
        assert_eq!(detect_from_bytes(&data), DetectedFormat::Flac);
    }

    #[test]
    fn detect_ogg() {
        let mut data = b"OggS".to_vec();
        data.extend_from_slice(&[0; 100]);
        assert_eq!(detect_from_bytes(&data), DetectedFormat::Ogg);
    }

    #[test]
    fn detect_wav() {
        let mut data = b"RIFF".to_vec();
        data.extend_from_slice(&[0; 4]);
        data.extend_from_slice(b"WAVE");
        data.extend_from_slice(&[0; 100]);
        assert_eq!(detect_from_bytes(&data), DetectedFormat::Wav);
    }

    #[test]
    fn detect_mp4_ftyp() {
        let mut data = b"ftyp".to_vec();
        data.extend_from_slice(&[0; 100]);
        assert_eq!(detect_from_bytes(&data), DetectedFormat::Mp4);
    }

    #[test]
    fn detect_aiff_form() {
        let mut data = b"FORM".to_vec();
        data.extend_from_slice(&[0; 100]);
        assert_eq!(detect_from_bytes(&data), DetectedFormat::Aiff);
    }

    #[test]
    fn detect_unknown() {
        let data = [0u8; 100];
        assert_eq!(detect_from_bytes(&data), DetectedFormat::Unknown);
    }

    #[test]
    fn detect_empty() {
        assert_eq!(detect_from_bytes(&[]), DetectedFormat::Unknown);
    }

    #[test]
    fn detect_too_short_for_id3() {
        assert_eq!(detect_from_bytes(&[0x49, 0x44]), DetectedFormat::Unknown);
    }

    // ── RangeCache ───────────────────────────────────────────────────────

    #[test]
    fn cache_insert_and_get() {
        let mut cache = RangeCache::new(10);
        cache.insert(0, vec![1, 2, 3, 4, 5]);
        assert_eq!(cache.get(0, 5), Some(vec![1, 2, 3, 4, 5]));
    }

    #[test]
    fn cache_get_partial() {
        let mut cache = RangeCache::new(10);
        cache.insert(0, vec![1, 2, 3, 4, 5]);
        assert_eq!(cache.get(1, 3), Some(vec![2, 3, 4]));
    }

    #[test]
    fn cache_get_miss() {
        let cache = RangeCache::new(10);
        assert_eq!(cache.get(0, 5), None);
    }

    #[test]
    fn cache_get_cross_block() {
        let mut cache = RangeCache::new(4);
        cache.insert(0, vec![1, 2, 3, 4]);
        cache.insert(4, vec![5, 6, 7, 8]);
        assert_eq!(cache.get(2, 4), Some(vec![3, 4, 5, 6]));
    }

    #[test]
    fn cache_insert_offset_not_aligned() {
        let mut cache = RangeCache::new(10);
        cache.insert(3, vec![10, 20, 30]);
        assert_eq!(cache.get(3, 3), Some(vec![10, 20, 30]));
    }

    #[test]
    fn cache_eviction() {
        let mut cache = RangeCache::new(1024);
        for i in 0..2000 {
            cache.insert(i * 1024, vec![0u8; 1024]);
        }
        assert!(cache.total_bytes <= MAX_CACHE_BYTES);
    }

    #[test]
    fn cache_get_zero_length() {
        let mut cache = RangeCache::new(10);
        cache.insert(0, vec![1, 2, 3]);
        assert_eq!(cache.get(0, 0), Some(vec![]));
    }

    // ── select_strategy ──────────────────────────────────────────────────

    fn make_info(size: Option<u64>, accept_ranges: bool) -> RemoteFileInfo {
        RemoteFileInfo {
            size,
            accept_ranges,
            content_type: None,
        }
    }

    #[test]
    fn strategy_no_range_support() {
        let info = make_info(Some(1_000_000), false);
        assert_eq!(
            select_strategy(&info, DetectedFormat::Mp3),
            UrlReadStrategy::Full
        );
    }

    #[test]
    fn strategy_mp3_small() {
        let info = make_info(Some(1_000_000), true);
        assert_eq!(
            select_strategy(&info, DetectedFormat::Mp3),
            UrlReadStrategy::Full
        );
    }

    #[test]
    fn strategy_mp3_medium() {
        let info = make_info(Some(10_000_000), true);
        assert_eq!(
            select_strategy(&info, DetectedFormat::Mp3),
            UrlReadStrategy::Progressive
        );
    }

    #[test]
    fn strategy_mp3_large() {
        let info = make_info(Some(100_000_000), true);
        assert_eq!(
            select_strategy(&info, DetectedFormat::Mp3),
            UrlReadStrategy::RandomAccess
        );
    }

    #[test]
    fn strategy_flac() {
        let info = make_info(Some(10_000_000), true);
        assert_eq!(
            select_strategy(&info, DetectedFormat::Flac),
            UrlReadStrategy::Progressive
        );
    }

    #[test]
    fn strategy_unknown_small() {
        let info = make_info(Some(1_000_000), true);
        assert_eq!(
            select_strategy(&info, DetectedFormat::Unknown),
            UrlReadStrategy::Full
        );
    }

    #[test]
    fn strategy_unknown_large() {
        let info = make_info(Some(100_000_000), true);
        assert_eq!(
            select_strategy(&info, DetectedFormat::Unknown),
            UrlReadStrategy::RandomAccess
        );
    }

    #[test]
    fn strategy_unknown_size_none() {
        let info = make_info(None, true);
        assert_eq!(
            select_strategy(&info, DetectedFormat::Unknown),
            UrlReadStrategy::Full
        );
    }

    // ── UrlReadStrategy ──────────────────────────────────────────────────

    #[test]
    fn url_read_strategy_default() {
        assert_eq!(UrlReadStrategy::default(), UrlReadStrategy::Auto);
    }

    // ── URL validation ───────────────────────────────────────────────────

    #[tokio::test]
    async fn read_from_url_invalid_url() {
        let result = read_from_url("not-a-url".to_string(), UrlReadStrategy::Full).await;
        assert!(result.is_err());
        match result.unwrap_err() {
            HaudiotaggerError::Remote { message } => assert!(message.contains("Invalid URL")),
            other => panic!("expected Remote error, got {other:?}"),
        }
    }

    #[tokio::test]
    async fn read_from_url_ftp_scheme() {
        let result = read_from_url(
            "ftp://example.com/file.mp3".to_string(),
            UrlReadStrategy::Full,
        )
        .await;
        assert!(result.is_err());
        match result.unwrap_err() {
            HaudiotaggerError::Remote { message } => {
                assert!(message.contains("Only HTTP and HTTPS"))
            }
            other => panic!("expected Remote error, got {other:?}"),
        }
    }

    #[tokio::test]
    async fn read_from_url_rejects_non_http() {
        let err = read_from_url(
            "ftp://example.com/file.mp3".to_string(),
            UrlReadStrategy::Full,
        )
        .await;
        assert!(err.is_err());
    }

    // ── RemoteReader seek (native only) ──────────────────────────────────

    #[cfg(not(target_arch = "wasm32"))]
    mod native_tests {
        use super::*;
        use native_http::*;

        #[test]
        fn remote_reader_seek_start() {
            let info = make_info(Some(1000), true);
            let http = Arc::new(BlockingHttpClient::new());
            let mut reader = RemoteReader::new("https://example.com/test.mp3".into(), info, http);
            let pos = reader.seek(SeekFrom::Start(42)).unwrap();
            assert_eq!(pos, 42);
        }

        #[test]
        fn remote_reader_seek_current() {
            let info = make_info(Some(1000), true);
            let http = Arc::new(BlockingHttpClient::new());
            let mut reader = RemoteReader::new("https://example.com/test.mp3".into(), info, http);
            reader.seek(SeekFrom::Start(10)).unwrap();
            let pos = reader.seek(SeekFrom::Current(5)).unwrap();
            assert_eq!(pos, 15);
        }

        #[test]
        fn remote_reader_seek_end() {
            let info = make_info(Some(1000), true);
            let http = Arc::new(BlockingHttpClient::new());
            let mut reader = RemoteReader::new("https://example.com/test.mp3".into(), info, http);
            let pos = reader.seek(SeekFrom::End(-10)).unwrap();
            assert_eq!(pos, 990);
        }

        #[test]
        fn remote_reader_seek_end_no_size() {
            let info = make_info(None, true);
            let http = Arc::new(BlockingHttpClient::new());
            let mut reader = RemoteReader::new("https://example.com/test.mp3".into(), info, http);
            let result = reader.seek(SeekFrom::End(-10));
            assert!(result.is_err());
        }
    }
}
