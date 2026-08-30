## 1.2.1

- Added batch operations for processing multiple files at once:
  - `batchWrite` / `batchWriteFromBytes`: write the same tag to multiple files
  - `batchUpdateChanges` / `batchUpdateChangesFromBytes`: apply the same `TagChanges` to multiple files
  - `batchUpdate` / `batchUpdateFromBytes`: per-file callback-based update with progress tracking
- Added `BatchResult`, `BatchBytesResult`, and `BatchProgress` types for batch operation results
- All batch operations work on both native (file paths) and web (byte arrays)

## 1.2.0

- Added `getTagFormats()` and `getTagFormatsFromBytes()` to detect which tag formats are present in an audio file (ID3v1, ID3v2, APE, iTunes, VorbisComments, RiffInfo, AiffText).
- Updated README with correct supported formats table.

## 1.1.9

- Minor changes and binary version updates

## 1.1.8

- Fixed a native (and all platform) runtime crash where calls such as `readFromBytes`/`writeToBytes` aborted inside `TagField::sse_decode` with `internal error: entered unreachable code`. The published package was shipping **stale committed prebuilt native binaries** (built from the old `TagField`-based API signatures) against newly generated Dart bindings, so the native binary decoded arguments using the wrong types. The `publish` CI job now overwrites the committed prebuilt native artifacts with the freshly-built ones from `build_and_upload` before publishing, guaranteeing the native binary matches the published Dart/FFI contract. Also rebuilt the committed Linux prebuilt and re-scoped `panic=abort` to the WASM build only.

## 1.1.7

- Fixed a native (Android/iOS/Linux/macOS/Windows) runtime crash where the async FFI dispatcher aborted with `panic cannot unwind`. The threaded web build previously relied on a committed `rust/.cargo/config.toml` with `build-std = ["std","panic_abort"]`, which also rebuilt the *native* `std` with `panic=abort` and broke `flutter_rust_bridge`'s `catch_unwind`-based async dispatcher. The build-std/panic_abort configuration is now scoped to the WASM build only (CI `build_web` job + local build via `CARGO_UNSTABLE_BUILD_STD`/`build-std`), so native builds use the default unwinding `std` again. Web behaviour (threaded shared-memory WASM + cross-origin isolation) is unchanged.

## 1.1.6

- Minor changes with updated logs and docs.

## 1.1.5

- Reverted the 1.1.4 synchronous workaround. Web now runs calls asynchronously through `flutter_rust_bridge` 2.13's Web Worker pool (non-blocking on the main thread), which requires **shared (threaded) WASM memory** plus cross-origin isolation.
- Rebuilt the web WASM with `+atomics,+bulk-memory,+mutable-globals`, a shared/imported memory (`--shared-memory --import-memory`), and the wasm-threads TLS/heap symbols explicitly exported (`--export=__wasm_init_tls --export=__tls_size --export=__tls_align --export=__tls_base --export=__heap_base --export=__stack_pointer`). This is built with `RUSTUP_TOOLCHAIN=nightly` and `-Z build-std=std,panic_abort` so std provides the threads runtime. The exported symbols let wasm-bindgen's threading transform succeed (previously it failed with `failed to find __wasm_init_tls`).
- **Web hosts must be cross-origin isolated**: serve the page with `Cross-Origin-Opener-Policy: same-origin` and `Cross-Origin-Embedder-Policy: require-corp` (e.g. `flutter run -d chrome --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp`). Without these headers, `RustLib.init()` fails with a `WorkerPool` / shared-memory error.
- Native platforms are unaffected in API and now run async on the thread pool again (no main-thread blocking, unlike 1.1.4).

## 1.1.4

- Fixed a web runtime crash (`fail to create WorkerPool: ... #<Memory> could not be cloned`). `flutter_rust_bridge` 2.13 dispatches async calls through a Web Worker pool that requires *shared* WASM memory plus cross-origin isolation (COOP/COEP headers), which the example host did not provide. Generated all API functions synchronously (`default_dart_async: false`) so web calls run on the main thread with no Worker pool, no shared memory, and no special server headers. The public `Future<T>` API is unchanged; native calls now execute synchronously on the calling isolate instead of via an async worker pool.

## 1.1.3

- Fixed the web platform: the WASM was previously built with `wasm-pack --target web`, producing an ES module that `flutter_rust_bridge` 2.13's classic-script loader could not initialize (the example hung at `RustLib.init()`). Rebuilt with `wasm-pack -t no-modules`, pointed the plugin/example assets and frb's `webPrefix` to `pkg/`, and removed the manual `<script>` tag so frb loads the glue automatically. No API changes.

## 1.1.2

- Added partial-tag editing that preserves existing metadata:
  - `Haudiotagger.update(path, TagChanges(...))` applies only the fields you specify, leaving the rest untouched (plus `updateFromBytes` for web/native).
  - `Haudiotagger.remove(path, [TagField.lyrics, TagField.comment, ...])` clears specific fields while keeping the rest (plus `removeFromBytes`).
  - `Haudiotagger.clear(path)` removes all metadata (plus `clearFromBytes`).
- Added `comment` field to `Tag` (read/write supported).

## 1.1.1

- Added read-only `AudioProperties` model exposing technical audio properties (duration, bitrate, sample rate, channels, bits per sample, codec, container format, lossless flag, bitrate mode, file size). Available via `Haudiotagger.readProperties(path)` (native) and `Haudiotagger.readPropertiesFromBytes(bytes)` (web + native). Does not affect existing read/write behavior.

## 1.1.0

- Pointed every platform's prebuilt download at the fixed release. The Android, Linux and Windows `CMakeLists.txt` and the iOS/macOS podspecs all hardcoded `v1.0.1`, so every version still shipped the old buggy native binary. All now download from `v1.1.0`. Also fixed the macOS podscript condition so it actually re-downloads (it previously skipped the download because the committed framework already existed).
- MP3 write fix (byte-level ID3v2 path, robust `.mp3`/ID3 detection) and MP3 lyrics fix included.

## 1.0.9

- Fixed Android never picking up native fixes: `android/CMakeLists.txt` pinned the prebuilt `.so` download to `v1.0.1`, so every version still shipped the old buggy binary. Pointed it at the `v1.0.8` release (which contains the fixed `android.tar.gz`). NOTE: the CMake `Version` must be bumped alongside future releases, or Android will keep using an outdated prebuilt.

## 1.0.8

- Hardened MP3 write detection. `write` previously gated the byte-level ID3v2 path on lofty's content probe (`file.file_type() == Mpeg`), which mis-identifies some real MP3s and routed them through lofty's writer, producing `FileEncodingError { format: None }`. Detection now keys off the `.mp3` extension and a leading `ID3` marker (matching `write_to_bytes`), so MP3s never reach lofty's `save_to_path`/`remove_from`. Added a regression test for an unsniffable-but-`.mp3` file.

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
