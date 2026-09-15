<p align="center">
  <img src="/haudiotagger/logo.png" alt="hAudiotagger" width="120">
</p>

<h1 align="center">hAudiotagger</h1>

<p align="center">
  <em>Rust-powered audio metadata for Flutter</em>
</p>

<p align="center">
  <a href="https://pub.dev/packages/haudiotagger"><img src="https://img.shields.io/pub/v/haudiotagger.svg?label=pub.dev&color=0175C2" alt="pub.dev"></a>
  <a href="https://github.com/Hirdaya-Shrestha/haudiotagger/actions"><img src="https://github.com/Hirdaya-Shrestha/haudiotagger/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-4285F4.svg" alt="MIT License"></a>
  <a href="https://pub.dev/packages/haudiotagger"><img src="https://img.shields.io/pub/dm/haudiotagger?label=Downloads&logo=dart" alt="Downloads"></a>
  <a href="https://haudiotagger.hirdaya-shrestha.com.np/"><img src="https://img.shields.io/badge/Web_Live-Demo-448cf3" alt="Live Demo"></a>
  <a href="https://gist.github.com/Hirdaya-Shrestha/66dd5d4e1fcfebe3f6ac0e744027b96b"><img src="https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/Hirdaya-Shrestha/66dd5d4e1fcfebe3f6ac0e744027b96b/raw/coverage.json" alt="Coverage"></a>
</p>

---

Read, write, and edit audio metadata across **Android, iOS, Linux, macOS, Windows, and Web**. Built on [lofty](https://github.com/Serial-ATA/lofty-rs) via [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge).

## Install

```yaml
dependencies:
  haudiotagger: ^1.3.5
```

## Quick Start

```dart
import 'package:haudiotagger/haudiotagger.dart';

// Read
final tag = await Haudiotagger.read('/path/to/song.mp3');
print(tag?.title);

// Write
await Haudiotagger.write('/path/to/song.mp3', Tag(
  title: 'My Song',
  artist: 'Artist',
  album: 'Album',
));

// Update (preserves other fields)
await Haudiotagger.update('/path/to/song.mp3', TagChanges(
  album: 'New Album',
));

// Batch
final result = await Haudiotagger.batchWrite(paths, tag);
```

## Features

| Feature | Platforms |
|---------|:-----------:|
| Read / write metadata (title, artist, album, art, lyrics...) | All |
| Partial updates — change one field without touching others | All |
| Batch operations with progress callbacks | All |
| Custom tags (TXXX, Vorbis) | All |
| ID3v2 version control (v2.3 / v2.4) | All |
| Audio properties (duration, bitrate, codec...) | All |
| Validate & normalize metadata | All |
| Copy / merge tags with configurable strategy | All |
| ReplayGain (track/album gain/peak) | All |
| **Chapters** (ID3v2 CHAP frames for MP3) | All |
| **Extended metadata** (MusicBrainz, AcoustID, ISRC, 60+ fields) | All |
| **Read single field** (`readField` — faster than full `read`) | All |
| **Read pictures** (all or by type, without full `read`) | All |
| TagPipeline — 56-rule transformation engine | All |
| Format & rename files from metadata | All |

## Supported Formats

| Format | Read | Write | Tags |
|--------|:----:|:-----:|------|
| **MP3** | Yes | Yes | ID3v2, ID3v1, APE |
| **FLAC** | Yes | Yes | Vorbis Comments, ID3v2* |
| **MP4 / M4A** | Yes | Yes | iTunes ilst |
| **Ogg Vorbis** | Yes | Yes | Vorbis Comments |
| **Opus** | Yes | Yes | Vorbis Comments |
| **AAC** | Yes | Yes | ID3v2, ID3v1 |
| **WAV** | Yes | Yes | ID3v2, RIFF INFO |
| **AIFF** | Yes | Yes | ID3v2, Text Chunks |
| **APE** | Yes | Yes | APE, ID3v2*, ID3v1 |
| **WavPack** | Yes | Yes | APE, ID3v1 |

\* Read only due to lack of official support

## Performance

| Operation | 1 File | 100 Files |
|-----------|--------|-----------|
| **Read** | 500 f/s | 1,282 f/s |
| **Batch Write** | 29 f/s | 197 f/s |
| **Batch Update** | 25 f/s | 197 f/s |

> [!NOTE]
> Native file-path API with rayon parallelism. Benchmarked on Linux with 100 distinct MP3 files (~8 MB each).

## Documentation

View Full **[Documentation &rarr;](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki)**

| Page | Description |
|------|-------------|
| [Getting Started](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/Getting-Started) | Installation, setup, web configuration |
| [Examples](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/Examples) | Real-world use cases with code |
| [API Reference](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/API-Reference) | Complete method & type documentation |
| [Extended Metadata](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/Extended-Metadata) | MusicBrainz, ISRC, 60+ fields |
| [Chapters](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/Chapters) | Podcast & audiobook chapter support |
| [TagPipeline](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/TagPipeline) | 56-rule transformation engine |
| [Web Setup](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/Web-Setup) | Cross-origin isolation & WASM config |
| [Platform Notes](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/Platform-Notes) | Platform-specific considerations |
| [FAQ](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/FAQ) | Common questions & troubleshooting |

## Live Demo

Try hAudiotagger in your browser — no install required:

**[hAudiotagger Web Demo](https://haudiotagger.hirdaya-shrestha.com.np/)**

> [!NOTE]
> On the web, use `*FromBytes` variants (e.g. `readFromBytes`, `writeToBytes`). See [Web Setup](https://github.com/Hirdaya-Shrestha/haudiotagger/wiki/Web-Setup) for details.

## Requirements

- Flutter >= 3.0.0
- Dart SDK >= 3.6.0

## License

hAudiotagger is open-source software licensed under the MIT License.

See the [LICENSE](LICENSE) file for more information.

## ❤️ Support
hAudiotagger is open-source software licensed under the [MIT License](LICENSE).

If hAudiotagger helps you build something cool, consider:

- ⭐ Starring the [repository](https://github.com/Hirdaya-Shrestha/haudiotagger)
- 🐛 Reporting bugs
- 💡 Suggesting improvements
- 🤝 Contributing code
- 📦 Sharing the package with other Flutter developers

Every bit of support helps keep the project moving forward.

---

<p align="center">
  Made with ❤️ and 🦀 by <a href="https://hirdaya-shrestha.com.np">Hirdaya Shrestha</a>
</p>
