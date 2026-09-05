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
  <a href="https://pub.dev/packages/haudiotagger"><img src="https://img.shields.io/pub/dm/haudiotagger?label=Downloads&logo=dart" alt="pub.dev downloads"></a>
  <a href="https://haudiotagger.hirdaya-shrestha.com.np/"><img src="https://img.shields.io/badge/Web_Live-Demo-448cf3" alt="Live Demo"></a>
</p>

---

Read, write, and edit audio metadata across **Android, iOS, Linux, macOS, Windows, and Web**. Built on [lofty](https://github.com/Serial-ATA/lofty-rs) via [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge).

![hAudiotagger](/haudiotagger/cover.png)

### 🌐 Live Web Demo

Try hAudiotagger working demo directly in your browser - no install required:

**[hAudiotagger Live Web Demo](https://haudiotagger.hirdaya-shrestha.com.np/)**

## Features

| Feature | Platforms |
|---------|:-----------:|
| Read / write metadata (title, artist, album, art, lyrics...) | All |
| Partial updates — change one field without touching others | All |
| Batch operations with progress callbacks | All |
| Custom tags (TXXX, Vorbis) | All |
| ID3v2 version control (v2.3 / v2.4) | All |
| Strip ID3v1 tags | All |
| Audio properties (duration, bitrate, codec...) | All |
| Tag format detection | All |
| Validate metadata (missing fields, invalid values) | All |
| Normalize metadata (trim, Unicode, whitespace) | All |
| Copy metadata between files | All |
| Merge tags with configurable strategy | All |
| ReplayGain support (track/album gain/peak) | All |
| TagPipeline — 56-rule metadata transformation engine | All |
| Format filenames from tag metadata | All |
| Rename files based on metadata patterns | All |

> [!NOTE]
> On the web, browsers cannot access arbitrary local files via file paths due to security sandboxing. Use the `*FromBytes` variants (e.g. `readFromBytes`, `writeToBytes`) which accept and return raw byte arrays. On native platforms (Android, iOS, Linux, macOS, Windows), both file path and bytes APIs are available. Also see [Web Setup](#web-setup).

## Install

```yaml
dependencies:
  haudiotagger: ^1.3.0
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

## Supported Formats

| Format | Tags |
|--------|------|
| **MP3** | ID3v2, ID3v1, APE |
| **FLAC** | Vorbis Comments, ID3v2\* |
| **MP4 / M4A** | iTunes ilst |
| **Ogg Vorbis** | Vorbis Comments |
| **Opus** | Vorbis Comments |
| **AAC** | ID3v2, ID3v1 |
| **WAV** | ID3v2, RIFF INFO |
| **AIFF** | ID3v2, Text Chunks |
| **APE** | APE, ID3v2\*, ID3v1 |
| **WavPack** | APE, ID3v1 |

\* The tag will be **read only**, due to lack of official support

---

## Usage

### Read Metadata

```dart
// From file path (native)
final tag = await Haudiotagger.read('/path/to/song.mp3');

// From bytes (web + native)
final tag = await Haudiotagger.readFromBytes(fileBytes);
```

### Write Metadata

```dart
// To file path (native)
await Haudiotagger.write('/path/to/song.mp3', Tag(
  title: 'Song Title',
  trackArtist: 'Artist',
  album: 'Album',
  year: 2024,
));

// To bytes (web + native)
final modified = await Haudiotagger.writeToBytes(fileBytes, tag);
```

### Update Metadata

Only the fields you pass are changed — everything else stays intact.

```dart
await Haudiotagger.update('/path/to/song.mp3', TagChanges(
  title: 'New Title',
  genre: 'Jazz',
));

// Bytes variant
final modified = await Haudiotagger.updateFromBytes(fileBytes, changes);
```

### Batch Operations

```dart
// Write same tag to multiple files
final result = await Haudiotagger.batchWrite(paths, tag);

// Apply same changes to multiple files
await Haudiotagger.batchUpdateChanges(paths, TagChanges(album: 'New Album'));

// Per-file callback with progress
await Haudiotagger.batchUpdate(
  paths,
  onProgress: (p) => print('${(p.percent * 100).round()}%'),
  (path, current) => current.copyWith(trackNumber: paths.indexOf(path) + 1),
);

// Web/bytes variants available
await Haudiotagger.batchWriteFromBytes(byteArrays, tag);
```

### Custom Tags

Read, write, and remove format-specific custom tags (ID3v2 TXXX frames, Vorbis non-standard keys).

```dart
// Read
final custom = await Haudiotagger.getCustomTags('/path/to/song.mp3');
// {'MY_FIELD': 'some value'}

// Write
await Haudiotagger.setCustomTag('/path/to/song.mp3', 'MY_FIELD', 'some value');

// Remove
await Haudiotagger.removeCustomTag('/path/to/song.mp3', 'MY_FIELD');

// Bytes variants: getCustomTagsFromBytes, setCustomTagFromBytes, removeCustomTagFromBytes
```

### ID3v2 Version Control

```dart
// Detect version
final version = await Haudiotagger.getId3v2Version('/path/to/song.mp3');
// Id3v2Version.v3 or Id3v2Version.v4

// Convert to ID3v2.3 (widely compatible)
await Haudiotagger.convertId3v2('/path/to/song.mp3', Id3v2Version.v3);

// Convert to ID3v2.4 (latest spec)
await Haudiotagger.convertId3v2('/path/to/song.mp3', Id3v2Version.v4);

// Bytes variants: getId3v2VersionFromBytes, convertId3v2FromBytes
```

### Remove ID3v1

```dart
await Haudiotagger.removeId3v1('/path/to/song.mp3');
final cleaned = await Haudiotagger.removeId3v1FromBytes(bytes);
```

### Audio Properties

```dart
final props = await Haudiotagger.readProperties('/path/to/song.mp3');
// props.duration, props.bitrate, props.sampleRate, props.codec, ...

// Bytes variant
await Haudiotagger.readPropertiesFromBytes(bytes);
```

### Diff Tags

Compare two tags to see exactly what changed — useful for confirmation dialogs and undo previews.

```dart
final oldTag = await Haudiotagger.read('/path/to/song.mp3');
final newTag = oldTag?.copyWith(title: 'New Title', year: 2025);

final diff = Haudiotagger.diff(oldTag!, newTag!);

print(diff.length);     // 2
print(diff.changes[0]); // title: Old Title → New Title

for (final change in diff.changes) {
  switch (change.type) {
    case ChangeType.added:
      print('Added ${change.field.name}');
    case ChangeType.updated:
      print('Updated ${change.field.name}');
    case ChangeType.removed:
      print('Removed ${change.field.name}');
  }
}
```

### Detect Tag Formats

```dart
final formats = await Haudiotagger.getTagFormats('/path/to/song.mp3');
// ['ID3v2', 'ID3v1']
```

### Inspect File

One call to get everything: format, tag format, properties, metadata, pictures, and file size.

```dart
final info = await Haudiotagger.inspect('/path/to/song.mp3');

print(info.format);      // 'MP3'
print(info.tagFormat);   // 'ID3v2'
print(info.size);        // 4812345
print(info.metadata?.title);
print(info.properties.duration);
print(info.pictures.length);

// Bytes variant
final info = await Haudiotagger.inspectFromBytes(bytes);
```

### Validate Metadata

Detect issues before publishing: missing fields, invalid track/disc numbers, bad BPM or year values.

```dart
final result = await Haudiotagger.validate('/path/to/song.mp3');

print(result.isValid);  // false if any errors

for (final issue in result.issues) {
  print('${issue.severity.name}: ${issue.field} — ${issue.message}');
}
// Error: track_number — Track number (5) exceeds total (3)
// Warning: pictures — Missing artwork

// Bytes variant
final result = await Haudiotagger.validateFromBytes(bytes);

// Validate a Tag directly
final result = await Haudiotagger.validateTag(tag);
```

### Normalize Metadata

Clean up whitespace, normalize Unicode, and remove empty values.

```dart
// Default options (trim, normalize whitespace, NFKC, remove empty)
final tag = await Haudiotagger.normalize('/path/to/song.mp3');
await Haudiotagger.write('/path/to/song.mp3', tag);

// Custom options
final tag = await Haudiotagger.normalizeTag(
  currentTag,
  options: NormalizeOptions(
    trimValues: true,
    normalizeWhitespace: true,
    normalizeUnicode: false,  // keep original Unicode
    removeEmptyValues: true,
  ),
);

// Bytes variant
final bytes = await Haudiotagger.normalizeBytes(fileBytes);
```

### Copy Metadata

Copy metadata between files with fine-grained control.

```dart
// Copy all metadata from FLAC to MP3
await Haudiotagger.copyMetadata('album.flac', 'album.mp3');

// Copy without artwork
await Haudiotagger.copyMetadata(
  'source.mp3',
  'dest.mp3',
  includeArtwork: false,
);

// Copy without lyrics or custom tags
await Haudiotagger.copyMetadata(
  'source.flac',
  'dest.mp3',
  includeLyrics: false,
  includeCustomTags: false,
);

// Bytes variant (web + native)
final result = await Haudiotagger.copyMetadataFromBytes(
  sourceBytes,
  destBytes,
  includeArtwork: true,
);
```

### Merge Tags

Combine two tags with configurable priority strategy.

```dart
final tagA = await Haudiotagger.read('song_a.mp3');
final tagB = await Haudiotagger.read('song_b.mp3');

// Default: preferFirstNonEmpty (tagA wins unless empty)
final merged = Haudiotagger.mergeTags(tagA, tagB);

// Explicit strategy
final merged = Haudiotagger.mergeTags(
  tagA,
  tagB,
  strategy: MergeStrategy.preferSecond,
);

await Haudiotagger.write('merged.mp3', merged);
```

**Strategies**: `preferFirst`, `preferSecond`, `preferFirstNonEmpty`, `preferSecondNonEmpty`

### ReplayGain

Read and write ReplayGain tags for volume normalization.

```dart
final tag = await Haudiotagger.read('song.mp3');

// Read
print(tag.replayGainTrackGain);  // "-6.43"
print(tag.replayGainAlbumPeak);  // "0.981201"

// Write
await Haudiotagger.write('song.mp3', tag.copyWith(
  replayGainTrackGain: '-6.43',
  replayGainTrackPeak: '0.981201',
  replayGainAlbumGain: '-7.12',
  replayGainAlbumPeak: '0.995000',
));

// Partial update
await Haudiotagger.update('song.mp3', TagChanges(
  replayGainTrackGain: '-6.43',
));
```

### Format Filename

Format a filename from tag metadata using placeholders.

```dart
final name = Haudiotagger.formatFilename(
  tag,
  pattern: '{track}. {title}',
);
// "01. My Song"
```

**Placeholders**: `{title}`, `{artist}`, `{album}`, `{albumArtist}`, `{track}`, `{trackTotal}`, `{disc}`, `{discTotal}`, `{year}`, `{genre}`

### Rename Files

Rename a file based on its metadata.

```dart
final newPath = await Haudiotagger.rename(
  '/path/to/song.mp3',
  pattern: '{track} - {title}',
);
// Renames to "/path/to/01 - My Song.mp3"
```

### TagPipeline — Transformation Engine

Apply batch transformations to metadata with a reusable pipeline.

```dart
final pipeline = TagPipeline()
  ..trimWhitespace()
  ..normalizeUnicode()
  ..setAlbumArtist('Various Artists')
  ..removeLyrics()
  ..setGenre('Rock');

// Preview changes before writing
final result = await pipeline.preview('/path/to/song.mp3');
final resultFromBytes = await pipeline.previewFromBytes(fileBytes);
print(result.changes);
// [title: "  Hello  " → "Hello", genre: null → "Rock"]

// Process multiple files
await pipeline.process(files);

// Process byte arrays (web + native)
final modifiedBytes = await pipeline.processFromBytes(fileBytes);
final modifiedList = await pipeline.processBatchFromBytes([bytes1, bytes2]);
```

#### Available Rules (56)

| Category | Rules |
|----------|-------|
| **Setters** | `setTitle`, `setArtist`, `setAlbum`, `setAlbumArtist`, `setGenre`, `setYear`, `setTrackNumber`, `setDiscNumber`, `setTrackTotal`, `setDiscTotal`, `setBpm`, `setComment` |
| **Remove** | `removeTitle`, `removeArtist`, `removeAlbum`, `removeAlbumArtist`, `removeGenre`, `removeYear`, `removeTrackNumber`, `removeDiscNumber`, `removeLyrics`, `removeComment`, `removePictures`, `removeBpm`, `removeReplayGain` |
| **Normalize** | `trimWhitespace`, `normalizeWhitespace`, `normalizeUnicode`, `normalizeTrackNumbers`, `normalizeDiscNumbers`, `normalizeYear` |
| **Copy** | `copyArtistToAlbumArtist`, `copyAlbumArtistToArtist`, `copyTitleToComment` |
| **Prefix/Suffix** | `prefixTitle`, `suffixTitle`, `prefixAlbum`, `suffixAlbum`, `prefixArtist`, `suffixArtist` |
| **Case** | `titleCaseTitle`, `titleCaseArtist`, `titleCaseAlbum`, `lowerCaseAll`, `upperCaseAll` |
| **Search/Replace** | `replaceInTitle`, `replaceInArtist`, `replaceInAlbum`, `replaceInAll` |
| **Conditional** | `setTitleIfEmpty`, `setArtistIfEmpty`, `setAlbumIfEmpty`, `setGenreIfEmpty`, `setAlbumArtistIfEmpty` |
| **Cleanup** | `removeEmptyFields`, `removeNonCoverPictures` |

---

## ⚡ Performance Benchmarks

Benchmarks were performed using **hAudiotagger 1.3.0** on a Linux system with 500 MP3 files (~8 MB each).

### Benchmark Environment

| Property | Value |
|---|---|
| **hAudiotagger** | `1.3.0` |
| **OS** | Linux (Arch) |
| **CPU** | AMD Ryzen 5 4500U |
| **RAM** | 16 GB DDR4 |
| **Storage** | 256 GB NVMe SSD |
| **Dart** | `v3.13.2` |
| **Rust** | `v1.98.0` |
| **lofty** | `v0.25.1` |
| **flutter_rust_bridge** | `v2.13.0` |

### Bytes API (Web + Native)

| Operation | 1 File | 10 Files | 50 Files | 100 Files |
|:---|---:|---:|---:|---:|
| **Read** | 59 f/s | 63 f/s | 78 f/s | 77 f/s |
| **Update** | 28 f/s | 22 f/s | 20 f/s | 20 f/s |
| **Batch Write** | 19 f/s | 26 f/s | 30 f/s | 30 f/s |
| **Custom Tag** | 24 f/s | 18 f/s | 22 f/s | 23 f/s |

### File-Path API (Native, Rayon Parallel)

| Operation | 1 File | 10 Files | 50 Files | 100 Files |
|:---|---:|---:|---:|---:|
| **Read** | 500 f/s | 1,003 f/s | 1,064 f/s | 1,282 f/s |
| **Update** | 26 f/s | 30 f/s | 63 f/s | 71 f/s |
| **Batch Write** | 29 f/s | 36 f/s | 198 f/s | 197 f/s |
| **Batch Update** | 25 f/s | 36 f/s | 202 f/s | 197 f/s |

> [!NOTE]
> All values in files per second (f/s). File-path APIs are significantly faster because Rust reads files directly without FFI data transfer. Bytes APIs require serializing/deserializing all data across the Dart↔Rust boundary, which becomes the bottleneck at scale. Use file-path APIs on native for maximum throughput; bytes APIs are designed for web where file paths are unavailable.

---

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

---

## API Reference

<details>
<summary>All methods</summary>

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
| `inspect(path)` | `AudioFileInfo` | native |
| `inspectFromBytes(bytes)` | `AudioFileInfo` | all |
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
| `validate(path)` | `ValidationResult` | native |
| `validateFromBytes(bytes)` | `ValidationResult` | all |
| `validateTag(tag)` | `ValidationResult` | all |
| `normalize(path)` | `Tag` | native |
| `normalizeBytes(bytes)` | `Uint8List` | all |
| `normalizeTag(tag, {options})` | `Tag` | all |
| `copyMetadata(src, dst, {includeArtwork, includeLyrics, includeCustomTags})` | `void` | native |
| `copyMetadataFromBytes(srcBytes, dstBytes, {includeArtwork, includeLyrics, includeCustomTags})` | `Uint8List` | all |
| `mergeTags(tagA, tagB, {strategy})` | `Tag` | all |
| `batchWrite(paths, tag)` | `BatchResult` | native |
| `batchUpdateChanges(paths, changes)` | `BatchResult` | native |
| `batchUpdate(paths, updater, {onProgress})` | `BatchResult` | native |
| `batchWriteFromBytes(bytes, tag)` | `BatchBytesResult` | all |
| `batchUpdateChangesFromBytes(bytes, changes)` | `BatchBytesResult` | all |
| `batchUpdateFromBytes(bytes, updater, {onProgress})` | `BatchBytesResult` | all |

</details>

<details>
<summary>Data types</summary>

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
| `duration` | `int?` | Read-only |
| `pictures` | `List<Picture>` | |
| `replayGainTrackGain` | `String?` | e.g. `"-6.43"` |
| `replayGainTrackPeak` | `String?` | e.g. `"0.981201"` |
| `replayGainAlbumGain` | `String?` | e.g. `"-7.12"` |
| `replayGainAlbumPeak` | `String?` | e.g. `"0.995000"` |

### `TagChanges`

Same fields as `Tag`, all optional. Only set fields are applied.

### `Picture`

| Field | Type |
|-------|------|
| `pictureType` | `PictureType` |
| `mimeType` | `MimeType?` |
| `bytes` | `Uint8List` |

### `AudioFileInfo`

| Field | Type | Notes |
|-------|------|-------|
| `format` | `String` | e.g. `MP3`, `FLAC` |
| `tagFormat` | `String` | e.g. `ID3v2`, `VorbisComments` |
| `properties` | `AudioProperties` | Technical details |
| `metadata` | `Tag?` | All metadata fields |
| `pictures` | `List<Picture>` | Embedded artwork |
| `size` | `BigInt` | File size in bytes |

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

### `Id3v2Version`

`v2` (not supported for writing), `v3`, `v4`

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

### `MetadataDiff`

| Field | Type |
|-------|------|
| `changes` | `List<MetadataChange>` |
| `length` | `int` |
| `isEmpty` | `bool` |

### `MetadataChange<T>`

| Field | Type |
|-------|------|
| `field` | `TagField` |
| `oldValue` | `T?` |
| `newValue` | `T?` |
| `type` | `ChangeType` |

### `ChangeType`

`added`, `updated`, `removed`

### `ValidationResult`

| Field | Type |
|-------|------|
| `issues` | `List<ValidationIssue>` |
| `isValid` | `bool` (getter) |

### `ValidationIssue`

| Field | Type |
|-------|------|
| `field` | `String` |
| `message` | `String` |
| `severity` | `ValidationSeverity` |

### `ValidationSeverity`

`error`, `warning`

### `NormalizeOptions`

| Field | Type | Default |
|-------|------|---------|
| `trimValues` | `bool` | `true` |
| `normalizeWhitespace` | `bool` | `true` |
| `normalizeUnicode` | `bool` | `true` |
| `removeEmptyValues` | `bool` | `true` |

### `MergeStrategy`

| Value | Behavior |
|-------|----------|
| `preferFirst` | tagA wins for all fields |
| `preferSecond` | tagB wins for all fields |
| `preferFirstNonEmpty` | tagA wins unless empty, then tagB |
| `preferSecondNonEmpty` | tagB wins unless empty, then tagA |

</details>

---

## Requirements

- Flutter >= 3.0.0
- Dart SDK >= 3.6.0

## License

hAudiotagger is open-source software licensed under the MIT License.

See the [LICENSE](LICENSE) file for more information.

## ❤️ Support

If hAudiotagger helps you build something cool, consider:

- ⭐ Starring the [repository](https://github.com/Hirdaya-Shrestha/haudiotagger)
- 🐛 Reporting bugs
- 💡 Suggesting improvements
- 🤝 Contributing code
- 📦 Sharing the package with other Flutter developers

Every bit of support helps keep the project moving forward.

<p align="center">
Made with ❤️ and 🦀
</p>
