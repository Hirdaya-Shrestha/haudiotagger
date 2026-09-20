<p align="center">
  <img src="/haudiotagger/logo.png" alt="hAudiotagger" width="140">
</p>

<h1 align="center">hAudiotagger</h1>

<p align="center">
  <strong>Powerful, cross-platform audio metadata for Flutter.</strong>
</p>

<p align="center">
  Read · Write · Edit · Analyze · Transform
</p>

<p align="center">
  <a href="https://pub.dev/packages/haudiotagger"><img src="https://img.shields.io/pub/v/haudiotagger.svg?label=pub.dev&color=0175C2" alt="pub.dev"></a>
  <a href="https://github.com/Hirdaya-Shrestha/haudiotagger/actions"><img src="https://github.com/Hirdaya-Shrestha/haudiotagger/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-4285F4.svg" alt="MIT License"></a>
  <a href="https://pub.dev/packages/haudiotagger"><img src="https://img.shields.io/pub/dm/haudiotagger?label=Downloads&logo=dart" alt="Downloads"></a>
  <a href="https://haudiotagger.hirdaya-shrestha.com.np/"><img src="https://img.shields.io/badge/Web-Demo-448cf3" alt="Live Demo"></a>
  <a href="https://gist.github.com/Hirdaya-Shrestha/66dd5d4e1fcfebe3f6ac0e744027b96b"><img src="https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/Hirdaya-Shrestha/66dd5d4e1fcfebe3f6ac0e744027b96b/raw/coverage.json" alt="Coverage"></a>
</p>

<p align="center">
  <a href="https://haudiotagger.hirdaya-shrestha.com.np/docs"><strong>Documentation</strong></a>
  ·
  <a href="https://haudiotagger.hirdaya-shrestha.com.np/"><strong>Live Demo</strong></a>
  ·
  <a href="https://pub.dev/packages/haudiotagger"><strong>pub.dev</strong></a>
</p>

---

## Why hAudiotagger?

**hAudiotagger** is a Rust-powered Flutter library for reading, writing, updating, and transforming audio metadata.

It supports **Android, iOS, Linux, macOS, Windows, and Web**, with native performance powered by [lofty](https://github.com/Serial-ATA/lofty-rs) and [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge).

Built for everything from **music players and tag editors to media managers, audio libraries, podcast apps, and file organizers**.

### Highlights

- 🚀 Rust-powered metadata processing
- 🌍 Android, iOS, Linux, macOS, Windows & Web
- 🎵 MP3, FLAC, M4A, OGG, Opus, WAV, AIFF, APE & WavPack
- 🏷️ Read, write & partially update metadata
- 🖼️ Artwork and picture management
- 📚 Extended metadata with 60+ fields
- ⚡ Parallel batch processing
- 🔧 Custom tags and ID3 control
- 🔄 Metadata diff, merge & transformation
- 🎧 ReplayGain support
- 📖 MP3 chapter support
- 🌐 WebAssembly support

---

## Live Demo

Try hAudiotagger directly in your browser.

**No installation. No server-side processing. Everything runs locally in your browser.**

<p>
  <a href="https://haudiotagger.hirdaya-shrestha.com.np/">
    <img src="https://img.shields.io/badge/▶_Try_the_Live_Demo-448cf3?style=for-the-badge" alt="Try Live Demo">
  </a>
</p>

> [!NOTE]
> Web applications should use the `*FromBytes` APIs such as `readFromBytes` and `writeToBytes`.
> See the [Web Setup Guide](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/Web-Setup).

---

## Installation

Add hAudiotagger to your `pubspec.yaml`:

```yaml
dependencies:
  haudiotagger: ^2.0.5
```

Or install it from the command line:

```bash
flutter pub add haudiotagger
```

---

## Quick Start

### Read metadata

```dart
import 'package:haudiotagger/haudiotagger.dart';

final tag = await Haudiotagger.read('/path/to/song.mp3');

print(tag?.title);
print(tag?.artist);
print(tag?.album);
```

### Write metadata

```dart
await Haudiotagger.write(
  '/path/to/song.mp3',
  Tag(
    title: 'My Song',
    artist: 'Artist',
    album: 'Album',
  ),
);
```

### Update specific fields

Change only what you need while preserving the rest of the existing metadata:

```dart
await Haudiotagger.update(
  '/path/to/song.mp3',
  TagChanges(
    album: 'New Album',
  ),
);
```

### Batch processing

Process multiple files with a single API:

```dart
final result = await Haudiotagger.batchWrite(
  paths,
  tag,
);
```

---

## Supported Formats

| Format | Read | Write | Metadata |
|:------:|:----:|:-----:|----------|
| **MP3** | ✅ | ✅ | ID3v2, ID3v1, APE |
| **FLAC** | ✅ | ✅ | Vorbis Comments, ID3v2* |
| **MP4 / M4A** | ✅ | ✅ | iTunes `ilst` |
| **Ogg Vorbis** | ✅ | ✅ | Vorbis Comments |
| **Opus** | ✅ | ✅ | Vorbis Comments |
| **AAC** | ✅ | ✅ | ID3v2, ID3v1 |
| **WAV** | ✅ | ✅ | ID3v2, RIFF INFO |
| **AIFF** | ✅ | ✅ | ID3v2, Text Chunks |
| **APE** | ✅ | ✅ | APE, ID3v2*, ID3v1 |
| **WavPack** | ✅ | ✅ | APE, ID3v1 |

<sub>* Read-only where writing is not supported by the underlying format implementation.</sub>

---

## Features

### Metadata

- Title, artist, album, album artist
- Genre, year, track & disc numbers
- Composer, conductor, grouping
- Comment and description
- Lyrics
- Artwork / embedded pictures
- Custom tags
- Extended metadata
- MusicBrainz identifiers
- AcoustID
- ISRC
- ReplayGain

### Advanced Operations

- Partial metadata updates
- Batch read/write/update
- Progress callbacks
- Metadata diff
- Configurable merge strategies
- Metadata validation & normalization
- ID3v2.3 / ID3v2.4 control
- ID3v1 removal
- MP3 chapters
- Individual field reads
- Individual picture reads
- Metadata-driven file renaming
- TagPipeline transformation engine

---

## TagPipeline

Need to transform metadata across thousands of files?

The **TagPipeline** provides a rule-based transformation engine for building repeatable metadata workflows.

```dart
final pipeline = TagPipeline([
  // transformation rules
]);

await pipeline.process(paths);
```

Use it to build workflows such as:

```text
Read metadata
     ↓
Normalize fields
     ↓
Apply transformation rules
     ↓
Validate metadata
     ↓
Write changes
```

Perfect for music library managers, tag editors, and automated organization tools.

---

## Performance

Native file-path operations use Rust with parallel processing where applicable.

Benchmarked on Linux using **100 distinct MP3 files (~8 MB each)**:

| Operation | 1 File | 100 Files |
|-----------|-------:|----------:|
| **Read** | 500 f/s | 1,282 f/s |
| **Batch Write** | 29 f/s | 197 f/s |
| **Batch Update** | 25 f/s | 197 f/s |

> [!NOTE]
> Performance depends heavily on storage, file size, metadata complexity, filesystem, and hardware. These numbers are provided as a reference rather than a guaranteed throughput.

---

## Platform Support

| Platform | Support |
|:--------:|:-------:|
| Android | ✅ |
| iOS | ✅ |
| Linux | ✅ |
| macOS | ✅ |
| Windows | ✅ |
| Web | ✅ |

The Web implementation uses **WebAssembly** and provides byte-based APIs for browser environments.

---

## Documentation

### Guides

- [Getting Started](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/Getting-Started)
- [Examples](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/Examples)
- [Web Setup](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/Web-Setup)
- [Platform Notes](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/Platform-Notes)
- [FAQ](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/FAQ)

### Reference

- [API Reference](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/API-Reference)
- [Extended Metadata](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/Extended-Metadata)
- [Chapters](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/Chapters)
- [TagPipeline](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/TagPipeline)

**→ [Read the full documentation](https://haudiotagger.hirdaya-shrestha.com.np/docs)**

---

## Requirements

- Flutter `>= 3.0.0`
- Dart SDK `>= 3.6.0`

---

## Contributing

Contributions are welcome! 🎉

If you find a bug, have an idea, or want to improve hAudiotagger:

- ⭐ [Star the repository](https://github.com/Hirdaya-Shrestha/haudiotagger)
- 🐛 [Report a bug](https://github.com/Hirdaya-Shrestha/haudiotagger/issues)
- 💡 [Request a feature](https://github.com/Hirdaya-Shrestha/haudiotagger/issues)
- 🤝 Submit a pull request
- 📢 Share hAudiotagger with other Flutter developers

---

## License

hAudiotagger is open-source software licensed under the [MIT License](LICENSE).

---

<p align="center">
  Made with ❤️ and 🦀 by
  <a href="https://hirdaya-shrestha.com.np">Hirdaya Shrestha</a>
</p>
