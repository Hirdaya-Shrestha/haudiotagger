<p align="center">
  <img src="/haudiotagger/logo.png" alt="hAudiotagger Logo" width="140">
</p>

<h1 align="center">hAudiotagger</h1>

<p align="center">
  Powerful audio metadata editing for Flutter
</p>

<p align="center">
  <a href="https://pub.dev/packages/haudiotagger"><img src="https://img.shields.io/pub/v/haudiotagger.svg" alt="pub package"></a>
  <a href="https://github.com/Hirdaya-Shrestha/haudiotagger/actions"><img src="https://github.com/Hirdaya-Shrestha/haudiotagger/actions/workflows/ci.yml/badge.svg" alt="build"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
</p>   

Read and write audio metadata in Flutter — powered by Rust. Supports every major format on **Android, iOS, Linux, macOS, Windows, and Web**.

Built on [lofty](https://github.com/Serial-ATA/lofty-rs).

![hAudiotagger](/haudiotagger/cover.png)

## Quick Start

```yaml
dependencies:
  haudiotagger: ^1.2.2
```

```dart
import 'package:haudiotagger/haudiotagger.dart';

// Read
final tag = await Haudiotagger.read('/path/to/song.mp3');
print(tag?.title);

// Write
await Haudiotagger.write('/path/to/song.mp3', Tag(title: 'My Song', artist: 'Artist'));

// Update (preserves other fields)
await Haudiotagger.update('/path/to/song.mp3', TagChanges(album: 'New Album'));

// Batch
final result = await Haudiotagger.batchWrite(paths, tag);
```

## Supported Formats

| Format | Metadata |
|--------|----------|
| MP3 | `ID3v2`, `ID3v1`, `APE` |
| FLAC | `Vorbis Comments`, `ID3v2`* |
| MP4 / M4A | `iTunes ilst` |
| Ogg Vorbis | `Vorbis Comments` |
| Opus | `Vorbis Comments` |
| AAC | `ID3v2`, `ID3v1` |
| WAV | `ID3v2`, `RIFF INFO` |
| AIFF | `ID3v2`, `Text Chunks` |
| APE | `APE`, `ID3v2`*, `ID3v1` |
| WavPack | `APE`, `ID3v1` |

\* Read-only due to lack of official support.

## Web Setup

The host page must be **cross-origin isolated** for WASM shared memory. Add these headers when serving:

```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

For local development:

```bash
flutter run -d chrome \
  --web-header=Cross-Origin-Opener-Policy=same-origin \
  --web-header=Cross-Origin-Embedder-Policy=require-corp
```

The WASM binary (~1.1 MB) is bundled automatically as a plugin asset.

## Usage

<details>
<summary><b>Read Metadata</b></summary>

**From file path (native only):**

```dart
final tag = await Haudiotagger.read('/path/to/song.mp3');
// tag?.title, tag?.trackArtist, tag?.album, tag?.year, tag?.genre, etc.
```

**From bytes (web + native):**

```dart
final tag = await Haudiotagger.readFromBytes(fileBytes);
```

</details>

<details>
<summary><b>Write Metadata</b></summary>

**To file path (native only):**

```dart
await Haudiotagger.write('/path/to/song.mp3', Tag(
  title: 'Song Title',
  trackArtist: 'Artist',
  album: 'Album',
  year: 2024,
));
```

**To bytes (web + native):**

```dart
final modified = await Haudiotagger.writeToBytes(fileBytes, tag);
```

</details>

<details>
<summary><b>Update Metadata</b></summary>

`update` changes only the fields you pass, preserving everything else:

```dart
await Haudiotagger.update('/path/to/song.mp3', TagChanges(
  title: 'New Title',
  trackArtist: 'New Artist',
));
```

**Bytes variant (web + native):**

```dart
final modified = await Haudiotagger.updateFromBytes(fileBytes, TagChanges(genre: 'Jazz'));
```

</details>

<details>
<summary><b>Remove / Clear</b></summary>

```dart
// Remove specific fields
await Haudiotagger.remove(path, [TagField.lyrics, TagField.comment]);

// Clear all metadata
await Haudiotagger.clear(path);
```

Bytes variants: `removeFromBytes`, `clearFromBytes`.

</details>

<details>
<summary><b>Batch Operations</b></summary>

Process multiple files at once. Rust handles the heavy lifting.

**Write same tag to multiple files:**

```dart
final result = await Haudiotagger.batchWrite(paths, tag);
print('${result.successes} updated, ${result.failures} failed');
```

**Apply same changes to multiple files:**

```dart
final result = await Haudiotagger.batchUpdateChanges(paths, TagChanges(album: 'New Album'));
```

**Per-file callback with progress:**

```dart
final result = await Haudiotagger.batchUpdate(
  paths,
  onProgress: (p) => print('${(p.percent * 100).round()}%'),
  (path, currentTag) => currentTag.copyWith(trackNumber: paths.indexOf(path) + 1),
);
```

**Web/bytes variants:**

```dart
await Haudiotagger.batchWriteFromBytes(byteArrays, tag);
await Haudiotagger.batchUpdateChangesFromBytes(byteArrays, changes);
await Haudiotagger.batchUpdateFromBytes(byteArrays, (i, tag) => tag.copyWith(...));
```

`BatchResult` / `BatchBytesResult` include `successes`, `failures`, and `errors`.

</details>

<details>
<summary><b>Audio Properties</b></summary>

Read-only technical info (duration, bitrate, sample rate, codec, etc.):

```dart
final props = await Haudiotagger.readProperties('/path/to/song.mp3');
// props.duration, props.bitrate, props.sampleRate, props.codec, etc.
```

Bytes variant: `readPropertiesFromBytes`.

</details>

<details>
<summary><b>Detect Tag Formats</b></summary>

```dart
final formats = await Haudiotagger.getTagFormats('/path/to/song.mp3');
// ['ID3v2', 'ID3v1']
```

Returns: `ID3v1`, `ID3v2`, `APE`, `iTunes`, `VorbisComments`, `RiffInfo`, `AiffText`.

Bytes variant: `getTagFormatsFromBytes`.

</details>

<details>
<summary><b>Custom Tags</b></summary>

Read, write, and remove format-specific custom tags. Supported for **ID3v2** (TXXX frames) and **Vorbis Comments** (non-standard keys).

**Read custom tags:**

```dart
final custom = await Haudiotagger.getCustomTags('/path/to/song.mp3');
// {'MY_FIELD': 'some value', 'RATING': '5'}
```

**Write a custom tag:**

```dart
await Haudiotagger.setCustomTag('/path/to/song.mp3', 'MY_FIELD', 'some value');
```

**Remove a custom tag:**

```dart
await Haudiotagger.removeCustomTag('/path/to/song.mp3', 'MY_FIELD');
```

Bytes variants: `getCustomTagsFromBytes`, `setCustomTagFromBytes`, `removeCustomTagFromBytes`.

</details>

<details>
<summary><b>ID3v2 Version Control</b></summary>

Detect and convert the ID3v2 version of MP3/AAC files.

**Get current version:**

```dart
final version = await Haudiotagger.getId3v2Version('/path/to/song.mp3');
// Id3v2Version.v3 or Id3v2Version.v4
```

**Convert to a specific version:**

```dart
// Convert to ID3v2.3 (widely compatible)
await Haudiotagger.convertId3v2('/path/to/song.mp3', Id3v2Version.v3);

// Convert to ID3v2.4 (latest spec)
await Haudiotagger.convertId3v2('/path/to/song.mp3', Id3v2Version.v4);
```

Bytes variants: `getId3v2VersionFromBytes`, `convertId3v2FromBytes`.

</details>

<details>
<summary><b>Remove ID3v1</b></summary>

Strip ID3v1 tags from files or bytes.

```dart
await Haudiotagger.removeId3v1('/path/to/song.mp3');
final cleaned = await Haudiotagger.removeId3v1FromBytes(bytes);
```

</details>

<details>
<summary><b>Error Handling</b></summary>

```dart
try {
  final tag = await Haudiotagger.read('/path/to/song.mp3');
} on HaudiotaggerError catch (e) {
  // file not found, unsupported format, etc.
}
```

</details>

<details>
<summary><b>API Reference</b></summary>

### Methods

| Method | Returns | Platform |
|--------|---------|----------|
| `read(path)` | `Tag?` | native |
| `readFromBytes(bytes)` | `Tag?` | all |
| `write(path, tag)` | `void` | native |
| `writeToBytes(bytes, tag)` | `Uint8List` | all |
| `update(path, changes)` | `void` | native |
| `updateFromBytes(bytes, changes)` | `Uint8List` | all |
| `remove(path, fields)` | `void` | native |
| `removeFromBytes(bytes, fields)` | `Uint8List` | all |
| `clear(path)` | `void` | native |
| `clearFromBytes(bytes)` | `Uint8List` | all |
| `readProperties(path)` | `AudioProperties` | native |
| `readPropertiesFromBytes(bytes)` | `AudioProperties` | all |
| `getTagFormats(path)` | `List<String>` | native |
| `getTagFormatsFromBytes(bytes)` | `List<String>` | all |
| `getCustomTags(path)` | `Map<String, String>` | native |
| `getCustomTagsFromBytes(bytes)` | `Map<String, String>` | all |
| `setCustomTag(path, key, value)` | `void` | native |
| `setCustomTagFromBytes(bytes, key, value)` | `Uint8List` | all |
| `removeCustomTag(path, key)` | `void` | native |
| `removeCustomTagFromBytes(bytes, key)` | `Uint8List` | all |
| `getId3v2Version(path)` | `Id3v2Version?` | all |
| `getId3v2VersionFromBytes(bytes)` | `Id3v2Version?` | all |
| `convertId3v2(path, version)` | `void` | all |
| `convertId3v2FromBytes(bytes, version)` | `Uint8List` | all |
| `removeId3v1(path)` | `void` | all |
| `removeId3v1FromBytes(bytes)` | `Uint8List` | all |
| `batchWrite(paths, tag)` | `BatchResult` | native |
| `batchUpdateChanges(paths, changes)` | `BatchResult` | native |
| `batchUpdate(paths, updater, {onProgress})` | `BatchResult` | native |
| `batchWriteFromBytes(bytes, tag)` | `BatchBytesResult` | all |
| `batchUpdateChangesFromBytes(bytes, changes)` | `BatchBytesResult` | all |
| `batchUpdateFromBytes(bytes, updater, {onProgress})` | `BatchBytesResult` | all |

### `Tag`

| Field | Type | Notes |
|-------|------|-------|
| `title` | `String?` | |
| `trackArtist` | `String?` | |
| `album` | `String?` | |
| `albumArtist` | `String?` | |
| `year` | `int?` | |
| `genre` | `String?` | |
| `trackNumber` | `int?` | |
| `trackTotal` | `int?` | |
| `discNumber` | `int?` | |
| `discTotal` | `int?` | |
| `lyrics` | `String?` | |
| `comment` | `String?` | |
| `bpm` | `double?` | |
| `duration` | `int?` | Read-only (seconds) |
| `pictures` | `List<Picture>` | |

### `TagChanges`

Same fields as `Tag`, all optional. Only set fields are applied; rest preserved.

### `Picture`

| Field | Type |
|-------|------|
| `pictureType` | `PictureType` |
| `mimeType` | `MimeType?` |
| `bytes` | `Uint8List` |

### `AudioProperties`

| Field | Type |
|-------|------|
| `duration` | `Duration?` |
| `durationMicros` | `int?` |
| `bitrate` | `int?` |
| `sampleRate` | `int?` |
| `channels` | `int?` |
| `bitsPerSample` | `int?` |
| `codec` | `String` |
| `containerFormat` | `String` |
| `lossless` | `bool` |
| `bitrateMode` | `BitrateMode` |
| `fileSize` | `BigInt?` |

### `BatchResult`

| Field | Type |
|-------|------|
| `successes` | `int` |
| `failures` | `int` |
| `errors` | `List<(String, String)>` |

### `BatchBytesResult`

| Field | Type |
|-------|------|
| `results` | `List<Uint8List>` |
| `failures` | `int` |
| `errors` | `List<(int, String)>` |

### `BatchProgress`

| Field | Type |
|-------|------|
| `completed` | `int` |
| `total` | `int` |
| `percent` | `double` |

</details>

## Requirements

- Flutter >= 3.0.0
- Dart SDK >= 3.6.0

## License

MIT License - see [LICENSE](LICENSE) for details.
