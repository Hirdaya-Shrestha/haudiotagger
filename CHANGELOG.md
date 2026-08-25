## 1.0.7

- Fixed `write` crashing on MP3/ID3v2 files with `FileEncodingError { format: None }`. lofty's `TagType::remove_from` re-probes the file on write and fails for any file it cannot content-sniff (common on Android). MP3 writes now strip the existing tag at the byte level (ID3v2/ID3v1/APE markers) and prepend a freshly serialized ID3v2, so the new tag fully replaces the old one. Other formats replace the in-memory primary tag and let `save_to_path` rewrite the file (also stripping it when the new tag is empty). Add `pictures: []` to `Tag` when clearing all fields.

## 1.0.6

- Fixed lyrics not persisting for MP3 (ID3v2) files. `ItemKey::Lyrics` is unsupported by ID3v2 (lyrics live in the `USLT` frame, addressed by `ItemKey::UnsyncLyrics`). `write` now uses the ID3v2-correct key and `read` falls back to both keys, so lyrics round-trip on MP3 as well as MP4.

## 1.0.5

- Fixed Android build failure (`Inconsistent JVM Target Compatibility`): replaced the removed legacy `kotlinOptions` with a Kotlin JVM toolchain (`jvmToolchain(17)`), aligning the Kotlin and Java compile targets so `flutter build apk` succeeds.

## 1.0.4

- Added Swift Package Manager support for iOS and macOS: committed `ios/haudiotagger/Package.swift`, `macos/haudiotagger/Package.swift`, and the prebuilt `haudiotagger.xcframework`, clearing the pub.dev SPM warning.
- Removed the legacy `kotlinOptions { jvmTarget = '17' }` block from `android/build.gradle`, clearing the pub.dev legacy Kotlin configuration warning.

## 1.0.3

- Declared `web` platform support in `pubspec.yaml` (added the `web:` entry under `flutter.plugin.platforms` and `lib/haudiotagger_web.dart` registration shim). pub.dev now lists Web support for the package.

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
