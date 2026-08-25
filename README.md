# hAudiotagger

![Haudiotagger](https://raw.githubusercontent.com/Hirdaya-Shrestha/haudiotagger/main/haudiotagger/cover.png?)

[![pub package](https://img.shields.io/pub/v/haudiotagger.svg)](https://pub.dev/packages/haudiotagger)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue.svg)](https://flutter.dev)

Read and write audio metadata in Flutter — powered by Rust. Fast, reliable, and supports every major format.

Built on [lofty](https://github.com/Serial-ATA/lofty-rs).

## Features

- **Read** metadata from audio files (title, artist, album, year, genre, cover art, lyrics, BPM, and more)
- **Write** metadata back to audio files
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

> **Web**: Uses a WASM-compiled Rust binary. No native compilation needed — just add the JS/WASM files to your `web/` directory. See [Web Setup](#web-setup) below.

## Supported Formats

| Format | Tags |
|--------|------|
| MP3 | ID3v1, ID3v2, APE |
| FLAC | Vorbis Comments |
| OGG (Vorbis / Opus / Speex) | Vorbis Comments |
| MP4 / M4A | iTunes-style ilst |
| WAV | ID3v2, RIFF INFO |
| AIFF | ID3v2, Text Chunks |
| APE | APE, ID3v2, ID3v1 |
| WavPack | APE, ID3v1 |
| Musepack | APE, ID3v2, ID3v1 |
| AAC (ADTS) | ID3v2, ID3v1 |

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  haudiotagger: ^1.0.4
```

Then run:

```bash
flutter pub get
```

### Web Setup

Add one line to `web/index.html` before `main.dart.js`:

```html
<script type="module" src="assets/packages/haudiotagger/web/wasm/haudiotagger.js"></script>
```

The WASM files are bundled automatically as Flutter assets — no files to copy. The JS glue loads the WASM from the asset path.

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

Add the WASM files and JS glue to your `web/` directory (see [Web Setup](#web-setup) above). The WASM binary is ~1.1 MB.

## API Reference

### `Haudiotagger`

| Method | Returns | Description |
|--------|---------|-------------|
| `read(String path)` | `Future<Tag?>` | Read metadata from a file path (native only). Returns `null` if no tags found. |
| `readFromBytes(Uint8List bytes)` | `Future<Tag?>` | Read metadata from in-memory bytes (web + native). Returns `null` if no tags found. |
| `write(String path, Tag tag)` | `Future<void>` | Write metadata to a file path. Replaces existing tags. |
| `writeToBytes(Uint8List bytes, Tag tag)` | `Future<Uint8List>` | Write metadata to in-memory bytes. Returns modified bytes. |

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
| `duration` | `int?` | Duration in seconds (read-only) |
| `bpm` | `double?` | Beats per minute |
| `pictures` | `List<Picture>` | Embedded images |

### `Picture`

| Field | Type | Description |
|-------|------|-------------|
| `pictureType` | `PictureType` | Image type (cover front, back, artist, etc.) |
| `mimeType` | `MimeType?` | Image format (JPEG, PNG, etc.) |
| `bytes` | `Uint8List` | Raw image data |

## Requirements

- Flutter >= 3.0.0
- Dart SDK >= 3.6.0

## License

MIT License - see [LICENSE](LICENSE) for details.
