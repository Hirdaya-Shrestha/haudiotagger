## 1.0.2

- Fixed `write()` failing to replace/remove existing tags (`lofty`'s `remove_from_path` opened a probe without guessing the file type and aborted with `format: None`). Tags are now properly removed from disk before the new tag is written, and clearing a tag fully strips it.
- Fixed reading/writing files by path regardless of file extension — format is now detected from file content instead of the path extension.
- Fixed `writeToBytes()` now correctly removes existing tags before applying the new ones (byte-based I/O on all platforms including web).
- Tests now run against isolated per-test scratch copies of the samples, eliminating the parallel-execution race on shared fixture files.
- Added the `samples/` directory to `.gitignore`/`.pubignore`.

## 1.0.1

- Add web/WASM support — read and write metadata in the browser
- Add `readFromBytes()` and `writeToBytes()` for byte-based I/O (works on all platforms including web)
- Fixed BPM and tag field unwrap panics in Rust
- Fixed Dart init race condition (concurrent `RustLib.init()` calls)
- Improved error messages (human-readable `HaudiotaggerError` display)
- Added `Clone` derive to `PictureType` and `MimeType`
- Example app rewritten as cross-platform metadata editor

## 1.0.0

- Initial release
- Read audio metadata (title, artist, album, year, genre, cover art, lyrics, BPM, and more)
- Write audio metadata back to files
- Support for MP3, FLAC, OGG, MP4/M4A, WAV, AIFF, APE, WavPack, Musepack, AAC
- Cross-platform: Android, iOS, Linux, macOS, Windows
- Powered by Rust (lofty) via flutter_rust_bridge
