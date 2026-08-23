# Haudiotagger

![Haudiotagger](https://raw.githubusercontent.com/Hirdaya-Shrestha/haudiotagger/main/haudiotagger/cover.png)

[![pub package](https://img.shields.io/pub/v/haudiotagger.svg)](https://pub.dev/packages/haudiotagger)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue.svg)](https://flutter.dev)

Read and write audio metadata in Flutter — powered by Rust. Fast, reliable, and supports every major format.

Built on [lofty](https://github.com/Serial-ATA/lofty-rs).

## Features

- **Read** metadata from audio files (title, artist, album, year, genre, cover art, lyrics, BPM, and more)
- **Write** metadata back to audio files
- **Cover art** support — read and write embedded images
- **Cross-platform** — Android, iOS, Linux, macOS, Windows
- **Blazing fast** — Rust-powered native library via [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge)

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
  haudiotagger: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Read Metadata

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

await Haudiotagger.write('/path/to/song.mp3', tag);
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

## API Reference

### `Haudiotagger`

| Method | Returns | Description |
|--------|---------|-------------|
| `read(String path)` | `Future<Tag?>` | Read metadata from a file. Returns `null` if no tags found. |
| `write(String path, Tag tag)` | `Future<void>` | Write metadata to a file. Replaces existing tags. |

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
