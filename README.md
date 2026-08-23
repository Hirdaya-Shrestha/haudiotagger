# Haudiotagger

A Flutter plugin for reading and writing audio metadata, powered by Rust.

Built on [lofty](https://github.com/Serial-ATA/lofty-rs) — supports MP3, FLAC, OGG, MP4, WAV, AIFF, WavPack, Musepack, and more.

## Setup

Add to your `pubspec.yaml`:

```yaml
dependencies:
  haudiotagger:
    git:
      url: https://github.com/Hirdaya-Shrestha/haudiotagger.git
      ref: main
      path: haudiotagger
```

## Usage

### Read metadata

```dart
import 'package:haudiotagger/haudiotagger.dart';

Tag? tag = await Haudiotagger.read('/path/to/song.mp3');

print(tag?.title);
print(tag?.trackArtist);
print(tag?.album);
print(tag?.albumArtist);
print(tag?.genre);
print(tag?.year);
print(tag?.trackNumber);
print(tag?.trackTotal);
print(tag?.discNumber);
print(tag?.discTotal);
print(tag?.duration);
print(tag?.pictures);
```

### Write metadata

```dart
import 'dart:typed_data';
import 'package:haudiotagger/haudiotagger.dart';

Tag tag = Tag(
  title: 'Song Title',
  trackArtist: 'Artist Name',
  album: 'Album Name',
  albumArtist: 'Album Artist',
  genre: 'Rock',
  year: 2024,
  trackNumber: 1,
  trackTotal: 12,
  discNumber: 1,
  discTotal: 1,
  pictures: [
    Picture(
      bytes: Uint8List.fromList([/* image bytes */]),
      mimeType: MimeType.jpeg,
      pictureType: PictureType.coverFront,
    ),
  ],
);

await Haudiotagger.write('/path/to/song.mp3', tag);
```

## Supported Formats

| Format | Metadata |
|--------|----------|
| MP3 | ID3v1, ID3v2, APE |
| FLAC | Vorbis Comments |
| OGG Vorbis / Opus / Speex | Vorbis Comments |
| MP4 / M4A | iTunes-style ilst |
| WAV | ID3v2, RIFF INFO |
| AIFF | ID3v2, Text Chunks |
| APE | APE, ID3v2, ID3v1 |
| WavPack | APE, ID3v1 |
| Musepack | APE, ID3v2, ID3v1 |
| AAC (ADTS) | ID3v2, ID3v1 |

## Building from Source

The Rust native library is compiled via [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge). To rebuild:

```bash
cd haudiotagger/rust
cargo build --release

cd ../..
flutter_rust_bridge_codegen generate
```

## License

MIT OR Apache-2.0
