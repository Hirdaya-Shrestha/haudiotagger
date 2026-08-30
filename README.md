<p align="center">
  <img src="/haudiotagger/logo.png" alt="hAudiotagger Logo" width="140">
</p>

<h1 align="center">hAudiotagger</h1>

<p align="center">
  Powerful audio metadata editing for Flutter
</p>

**Disclaimer:** This project is not affiliated with, endorsed by, or officially connected to the Rust Foundation or Rust Project.   

<br/>

[![pub package](https://img.shields.io/pub/v/haudiotagger.svg)](https://pub.dev/packages/haudiotagger)
[![build](https://github.com/Hirdaya-Shrestha/haudiotagger/actions/workflows/ci.yml/badge.svg)](https://github.com/Hirdaya-Shrestha/haudiotagger/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue.svg)](https://flutter.dev)

Read and write audio metadata in Flutter — powered by Rust. Fast, reliable, and supports every major format.

Built on [lofty](https://github.com/Serial-ATA/lofty-rs).

![hAudiotagger](/haudiotagger/cover.png)

## Features

- **Read** metadata from audio files (title, artist, album, year, genre, cover art, lyrics, BPM, and more)
- **Write** metadata back to audio files
- **Read technical audio properties** — duration, bitrate, sample rate, channels, bits per sample, codec, container, lossless flag, and more (read-only, cross-platform)
- **Cover art** support — read and write embedded images
- **Cross-platform** — Android, iOS, Linux, macOS, Windows, and **Web**
- **Blazing fast** — Rust-powered native library via [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge)

## Supported Platforms

| Platform | Native Binary | WASM |
|----------|:---:|:---:|
| Android | ✅ | — |
| iOS | ✅ | — |
| Linux | ✅ | — |
| macOS | ✅ | — |
| Windows | ✅ | — |
| Web | — | ✅ |

> **Web**: Uses a WASM-compiled Rust binary with a Web Worker pool for non-blocking calls. No native compilation needed — the JS/WASM files are bundled automatically as plugin assets. See [Web Setup](#web-setup) below. The host page must be cross-origin isolated (served with `Cross-Origin-Opener-Policy: same-origin` and `Cross-Origin-Embedder-Policy: require-corp`) so the WASM can use shared memory.

## Supported Formats

| File Format | Metadata Format(s) |
|-------------|---------------------|
| AAC (ADTS) | `ID3v2`, `ID3v1` |
| APE | `APE`, `ID3v2`\*, `ID3v1` |
| AIFF | `ID3v2`, `Text Chunks` |
| FLAC | `Vorbis Comments`, `ID3v2`\* |
| MP3 | `ID3v2`, `ID3v1`, `APE` |
| MP4 / M4A | `iTunes-style ilst` |
| MPC | `APE`, `ID3v2`\*, `ID3v1`\* |
| Opus | `Vorbis Comments` |
| Ogg Vorbis | `Vorbis Comments` |
| Speex | `Vorbis Comments` |
| WAV | `ID3v2`, `RIFF INFO` |
| WavPack | `APE`, `ID3v1` |

\* The tag will be **read only**, due to lack of official support.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  haudiotagger: ^1.1.9
```

Then run:

```bash
flutter pub get
```

### Web Setup

No extra setup is required to bundle the plugin, but the **host page must be
cross-origin isolated** for the web build to run. `flutter_rust_bridge` 2.13
dispatches async calls through a Web Worker pool that needs shared WASM memory,
which the browser only allows when the page is served with:

```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

The WASM binary and JS glue are bundled automatically as Flutter plugin assets
(under `assets/packages/haudiotagger/pkg/`) and are loaded at runtime by
`flutter_rust_bridge`. Nothing needs to be added to your `web/index.html`.

When running locally, pass the headers to `flutter run`:

```bash
flutter run -d chrome --web-header=Cross-Origin-Opener-Policy=same-origin \
  --web-header=Cross-Origin-Embedder-Policy=require-corp
```

If you serve the built `web/` folder yourself, configure your static server /
reverse proxy to send the two headers above. Without them the app fails at
`RustLib.init()` with a `WorkerPool` / shared-memory error.

## Usage

### Read Metadata (file path — native only)

```dart
import 'package:haudiotagger/haudiotagger.dart';

final tag = await Haudiotagger.read('/path/to/song.mp3');

if (tag != null) {
  print(tag.title);        // 'My Song'
  print(tag.trackArtist);  // 'Artist Name'
  print(tag.album);        // 'Album Name'
  print(tag.year);         // 2024
  print(tag.genre);        // 'Rock'
  print(tag.duration);     // 240 (seconds)
  print(tag.bpm);          // 120.0

  // Cover art
  for (final picture in tag.pictures) {
    print(picture.pictureType); // PictureType.coverFront
    print(picture.bytes);       // Uint8List
  }
}
```

### Read Metadata from Bytes (works on web + native)

```dart
import 'dart:typed_data';
import 'package:haudiotagger/haudiotagger.dart';

// From a file loaded as bytes (e.g., via FilePicker)
final Uint8List fileBytes = /* ... */;
final tag = await Haudiotagger.readFromBytes(fileBytes);
```

### Read Audio Properties (technical — read-only)

```dart
import 'package:haudiotagger/haudiotagger.dart';

// Native: from a file path
final props = await Haudiotagger.readProperties('/path/to/song.mp3');

// Web + native: from in-memory bytes
// final props = await Haudiotagger.readPropertiesFromBytes(fileBytes);

print(props.duration);       // Duration(seconds: 240)
print(props.bitrate);        // 320 (kbps)
print(props.sampleRate);     // 44100 (Hz)
print(props.channels);       // 2
print(props.bitsPerSample);  // 16
print(props.codec);          // 'MP3'
print(props.containerFormat); // 'MP3'
print(props.lossless);       // false
print(props.bitrateMode);    // BitrateMode.unknown
print(props.fileSize);       // 8234567 (bytes)
```

> **Note:** Audio properties are read-only and never affect tags or writing.

### Update Metadata (preserve the rest)

`write` replaces the whole tag. `update` changes only the fields you pass and keeps everything else:

```dart
await Haudiotagger.update(
  '/path/to/song.mp3',
  TagChanges(
    title: 'New Title',
    trackArtist: 'New Artist',
  ),
);
```

`TagChanges` mirrors `Tag` (all fields optional). Fields you omit are left untouched. On web + native, use the bytes variant:

```dart
final modified = await Haudiotagger.updateFromBytes(
  fileBytes,
  TagChanges(genre: 'Jazz'),
);
```

If the file has no existing tag, `update` simply creates one from the given fields.

### Remove Specific Fields

```dart
await Haudiotagger.remove(
  '/path/to/song.mp3',
  [TagField.lyrics, TagField.comment],
);
```

This clears only `lyrics` and `comment`, leaving all other metadata intact. Bytes variant:

```dart
final modified = await Haudiotagger.removeFromBytes(
  fileBytes,
  [TagField.pictures],
);
```

### Clear All Metadata

```dart
await Haudiotagger.clear('/path/to/song.mp3');
```

Removes every tag from the file. Bytes variant `clearFromBytes(bytes)` returns the stripped bytes.

### Write Metadata

```dart
import 'dart:typed_data';
import 'package:haudiotagger/haudiotagger.dart';

final tag = Tag(
  title: 'Song Title',
  trackArtist: 'Artist Name',
  album: 'Album Name',
  genre: 'Rock',
  year: 2024,
  trackNumber: 1,
  trackTotal: 12,
  pictures: [
    Picture(
      pictureType: PictureType.coverFront,
      mimeType: MimeType.jpeg,
      bytes: Uint8List.fromList(imageBytes),
    ),
  ],
);

// Native: write to file path
await Haudiotagger.write('/path/to/song.mp3', tag);
```

### Write Metadata from Bytes (works on web + native)

```dart
final Uint8List modifiedBytes = await Haudiotagger.writeToBytes(fileBytes, tag);
```

### Error Handling

```dart
try {
  final tag = await Haudiotagger.read('/path/to/song.mp3');
} on HaudiotaggerError catch (e) {
  // Handle errors (file not found, unsupported format, etc.)
}
```

## Platform Setup

### Android

No additional setup required. Min SDK 24+.

### iOS

No additional setup required. iOS 12.0+.

### Linux

No additional setup required.

### macOS

No additional setup required.

### Windows

No additional setup required.

### Web

No extra files are needed — the WASM binary and JS glue are bundled automatically as plugin assets (see [Web Setup](#web-setup) above). The WASM binary is ~1.1 MB.

## API Reference

### `hAudiotagger`

| Method | Returns | Description |
|--------|---------|-------------|
| `read(String path)` | `Future<Tag?>` | Read metadata from a file path (native only). Returns `null` if no tags found. |
| `readFromBytes(Uint8List bytes)` | `Future<Tag?>` | Read metadata from in-memory bytes (web + native). Returns `null` if no tags found. |
| `write(String path, Tag tag)` | `Future<void>` | Write metadata to a file path. Replaces existing tags. |
| `writeToBytes(Uint8List bytes, Tag tag)` | `Future<Uint8List>` | Write metadata to in-memory bytes. Returns modified bytes. |
| `update(String path, TagChanges changes)` | `Future<void>` | Apply partial changes, preserving all other fields (native only). |
| `updateFromBytes(Uint8List bytes, TagChanges changes)` | `Future<Uint8List>` | Apply partial changes to bytes. Returns modified bytes. |
| `remove(String path, List<TagField> fields)` | `Future<void>` | Remove the given fields, keeping the rest (native only). |
| `removeFromBytes(Uint8List bytes, List<TagField> fields)` | `Future<Uint8List>` | Remove the given fields from bytes. Returns modified bytes. |
| `clear(String path)` | `Future<void>` | Remove all metadata from the file (native only). |
| `clearFromBytes(Uint8List bytes)` | `Future<Uint8List>` | Remove all metadata from bytes. Returns modified bytes. |
| `readProperties(String path)` | `Future<AudioProperties>` | Read technical audio properties from a file path (native only). |
| `readPropertiesFromBytes(Uint8List bytes)` | `Future<AudioProperties>` | Read technical audio properties from in-memory bytes (web + native). |
| `getTagFormats(String path)` | `Future<List<String>>` | Get the list of tag formats present in a file (native only). |
| `getTagFormatsFromBytes(Uint8List bytes)` | `Future<List<String>>` | Get the list of tag formats present in in-memory bytes (web + native). |

### `Tag`

| Field | Type | Description |
|-------|------|-------------|
| `title` | `String?` | Song title |
| `trackArtist` | `String?` | Artist name |
| `album` | `String?` | Album name |
| `albumArtist` | `String?` | Album artist |
| `year` | `int?` | Release year |
| `genre` | `String?` | Genre |
| `trackNumber` | `int?` | Track position |
| `trackTotal` | `int?` | Total tracks |
| `discNumber` | `int?` | Disc position |
| `discTotal` | `int?` | Total discs |
| `lyrics` | `String?` | Song lyrics |
| `comment` | `String?` | Comment |
| `duration` | `int?` | Duration in seconds (read-only) |
| `bpm` | `double?` | Beats per minute |
| `pictures` | `List<Picture>` | Embedded images |

### `Picture`

| Field | Type | Description |
|-------|------|-------------|
| `pictureType` | `PictureType` | Image type (cover front, back, artist, etc.) |
| `mimeType` | `MimeType?` | Image format (JPEG, PNG, etc.) |
| `bytes` | `Uint8List` | Raw image data |

### `AudioProperties`

| Field | Type | Description |
|-------|------|-------------|
| `duration` | `Duration?` | Audio duration (convenience getter over `durationMicros`) |
| `durationMicros` | `int?` | Audio duration in microseconds |
| `bitrate` | `int?` | Overall bitrate (kbps) |
| `sampleRate` | `int?` | Sample rate (Hz) |
| `channels` | `int?` | Number of channels |
| `bitsPerSample` | `int?` | Bits per sample |
| `codec` | `String` | Audio codec (ex. `MP3`, `FLAC`, `AAC`) |
| `containerFormat` | `String` | Container format (ex. `MP3`, `MP4`, `Ogg`) |
| `lossless` | `bool` | Whether the audio is lossless |
| `bitrateMode` | `BitrateMode` | `BitrateMode.unknown` / `cbr` / `vbr` |
| `fileSize` | `BigInt?` | File size in bytes |

### `TagChanges`

A partial tag. All fields are optional — only the ones you set are applied by `update`/`updateFromBytes`; the rest of the existing tag is preserved.

| Field | Type | Description |
|-------|------|-------------|
| `title` | `String?` | Song title |
| `trackArtist` | `String?` | Artist name |
| `album` | `String?` | Album name |
| `albumArtist` | `String?` | Album artist |
| `year` | `int?` | Release year |
| `genre` | `String?` | Genre |
| `trackNumber` | `int?` | Track position |
| `trackTotal` | `int?` | Total tracks |
| `discNumber` | `int?` | Disc position |
| `discTotal` | `int?` | Total discs |
| `lyrics` | `String?` | Song lyrics |
| `comment` | `String?` | Comment |
| `pictures` | `List<Picture>?` | Embedded images (replaces existing when set) |
| `bpm` | `double?` | Beats per minute |

### `TagField`

Enum used by `remove`/`removeFromBytes` to name a specific field to clear.

`TagField.title`, `TagField.artist`, `TagField.album`, `TagField.albumArtist`, `TagField.year`, `TagField.genre`, `TagField.trackNumber`, `TagField.trackTotal`, `TagField.discNumber`, `TagField.discTotal`, `TagField.lyrics`, `TagField.comment`, `TagField.bpm`, `TagField.pictures`

### Tag Formats

The `getTagFormats` method returns a list of tag format strings present in the file. Possible values:

| Format | Description |
|--------|-------------|
| `ID3v1` | ID3v1 tag (128-byte tail tag) |
| `ID3v2` | ID3v2 tag (header tag, all versions upgraded to 2.4) |
| `APE` | APEv1/APEv2 tag |
| `iTunes` | MP4 ilst atom |
| `VorbisComments` | Vorbis Comments (FLAC, OGG, Opus, Speex) |
| `RiffInfo` | RIFF INFO LIST (WAV) |
| `AiffText` | AIFF text chunks |

```dart
final formats = await Haudiotagger.getTagFormats('/path/to/song.mp3');
print(formats); // ['ID3v2', 'ID3v1']
```

## Requirements

- Flutter >= 3.0.0
- Dart SDK >= 3.6.0

## License

MIT License - see [LICENSE](LICENSE) for details.

## ❤️ Support

If hAudiotagger helps you build something cool, consider:

- ⭐ Starring the [repository](https://github.com/Hirdaya-Shrestha/haudiotagger)
- 🐛 [Reporting](https://github.com/Hirdaya-Shrestha/haudiotagger/issues) bugs
- 💡 Suggesting improvements
- 🤝 Contributing code
- 📦 Sharing the package with other Flutter developers

Every bit of support helps keep the project moving forward.

<p align="center">
Made with ❤️ and Rust 🦀.
</p>
