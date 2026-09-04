import 'dart:typed_data';

import 'rust/frb_generated.dart';

import 'rust/api/api.dart' as api;
import 'rust/api/api.dart'
    show BatchResult, BatchBytesResult, Id3v2Version, AudioFileInfo;
import 'rust/api/tag.dart';
import 'rust/api/error.dart';
import 'rust/api/audio_properties.dart' as ap;
import 'rust/api/tag_changes.dart' as tc;
import 'rust/api/tag_field.dart';
import 'rust/api/validation.dart' show ValidationResult;
import 'rust/api/normalization.dart' show NormalizeOptions;
import 'copy_with.dart';

export 'rust/api/picture.dart';
export 'rust/api/tag.dart';
export 'rust/api/error.dart';
export 'rust/api/audio_properties.dart';
export 'rust/api/tag_changes.dart';
export 'rust/api/tag_field.dart';
export 'rust/api/api.dart'
    show BatchResult, BatchBytesResult, Id3v2Version, AudioFileInfo;
export 'rust/api/validation.dart'
    show ValidationResult, ValidationIssue, ValidationSeverity;
export 'rust/api/normalization.dart' show NormalizeOptions;
export 'copy_with.dart';
export 'pipeline.dart' show TagPipeline, PreviewResult, FieldChange;

/// Progress information for batch operations.
class BatchProgress {
  /// Number of files processed so far.
  final int completed;

  /// Total number of files to process.
  final int total;

  const BatchProgress({required this.completed, required this.total});

  /// Progress as a percentage (0.0 to 1.0).
  double get percent => total > 0 ? completed / total : 0.0;
}

class Haudiotagger {
  static Future<void>? _initFuture;

  static Future<void> _ensureInit() => _initFuture ??= RustLib.init();

  /// Read the metadata at the given path. Returns
  /// a [Tag] or null if there is no metadata.
  static Future<Tag?> read(String path) async {
    await _ensureInit();

    try {
      return await api.read(path: path);
    } on HaudiotaggerError catch (e) {
      switch (e) {
        case HaudiotaggerError_NoTags():
          return null;
        default:
          rethrow;
      }
    }
  }

  /// Read metadata from in-memory bytes. Works on web and native.
  static Future<Tag?> readFromBytes(Uint8List bytes) async {
    await _ensureInit();

    try {
      return await api.readFromBytes(bytes: bytes);
    } on HaudiotaggerError catch (e) {
      switch (e) {
        case HaudiotaggerError_NoTags():
          return null;
        default:
          rethrow;
      }
    }
  }

  /// Write the metadata at the given path. Previous metadata will
  /// be cleared and the metadata in [tag] will be written.
  ///
  /// Can throw a [HaudiotaggerError].
  static Future<void> write(String path, Tag tag) async {
    await _ensureInit();
    return await api.write(path: path, data: tag);
  }

  /// Write metadata to in-memory bytes. Returns the modified bytes.
  /// Works on web and native.
  static Future<Uint8List> writeToBytes(Uint8List bytes, Tag tag) async {
    await _ensureInit();
    return await api.writeToBytes(bytes: bytes, data: tag);
  }

  /// Read the technical audio properties of the file at [path].
  /// Read-only; works on native.
  static Future<ap.AudioProperties> readProperties(String path) async {
    await _ensureInit();
    return await ap.readProperties(path: path);
  }

  /// Read the technical audio properties from in-memory [bytes].
  /// Read-only; works on web and native.
  static Future<ap.AudioProperties> readPropertiesFromBytes(
      Uint8List bytes) async {
    await _ensureInit();
    return await ap.readPropertiesFromBytes(bytes: bytes);
  }

  /// Apply [changes] to the metadata at [path], preserving any fields not
  /// mentioned in [changes]. Works on native.
  static Future<void> update(String path, tc.TagChanges changes) async {
    await _ensureInit();
    return await tc.update(path: path, changes: changes);
  }

  /// Apply [changes] to metadata held in [bytes], returning the modified bytes.
  /// Works on web and native.
  static Future<Uint8List> updateFromBytes(
      Uint8List bytes, tc.TagChanges changes) async {
    await _ensureInit();
    return await tc.updateFromBytes(bytes: bytes, changes: changes);
  }

  /// Remove the given [fields] from the metadata at [path], keeping everything
  /// else. Works on native.
  static Future<void> remove(String path, List<TagField> fields) async {
    await _ensureInit();
    return await api.remove(path: path, fields: fields);
  }

  /// Remove the given [fields] from metadata held in [bytes], returning the
  /// modified bytes. Works on web and native.
  static Future<Uint8List> removeFromBytes(
      Uint8List bytes, List<TagField> fields) async {
    await _ensureInit();
    return await api.removeFromBytes(bytes: bytes, fields: fields);
  }

  /// Remove all metadata from the file at [path]. Works on native.
  static Future<void> clear(String path) async {
    await _ensureInit();
    return await api.clear(path: path);
  }

  /// Remove all metadata from the data held in [bytes], returning the modified
  /// bytes. Works on web and native.
  static Future<Uint8List> clearFromBytes(Uint8List bytes) async {
    await _ensureInit();
    return await api.clearFromBytes(bytes: bytes);
  }

  /// Write the same [tag] to multiple files at [paths].
  ///
  /// Returns a [BatchResult] with counts of successes/failures.
  /// Works on native only.
  static Future<BatchResult> batchWrite(
    List<String> paths,
    Tag tag,
  ) async {
    await _ensureInit();
    return await api.batchWrite(paths: paths, data: tag);
  }

  /// Apply the same [TagChanges] to multiple files at [paths].
  ///
  /// Returns a [BatchResult] with counts of successes/failures.
  /// Works on native only.
  static Future<BatchResult> batchUpdateChanges(
    List<String> paths,
    tc.TagChanges changes,
  ) async {
    await _ensureInit();
    return await api.batchUpdateChanges(paths: paths, changes: changes);
  }

  /// Update tags for multiple files using a callback.
  ///
  /// For each file, reads the current tag, calls [updater] to get the new tag,
  /// and writes it back. Use [onProgress] to track progress.
  ///
  /// Returns a [BatchResult] with counts of successes/failures.
  /// Works on native only.
  static Future<BatchResult> batchUpdate(
    List<String> paths,
    Tag Function(String path, Tag currentTag) updater, {
    void Function(BatchProgress progress)? onProgress,
  }) async {
    await _ensureInit();
    final total = paths.length;
    var completed = 0;
    var successes = 0;
    var failures = 0;
    final errors = <(String, String)>[];

    for (final path in paths) {
      try {
        final currentTag = await api.read(path: path);
        final newTag = updater(path, currentTag);
        await api.write(path: path, data: newTag);
        successes++;
      } on HaudiotaggerError catch (e) {
        failures++;
        errors.add((path, e.toString()));
      } catch (e) {
        failures++;
        errors.add((path, e.toString()));
      }
      completed++;
      onProgress?.call(BatchProgress(
        completed: completed,
        total: total,
      ));
    }

    return BatchResult(
      successes: successes,
      failures: failures,
      errors: errors,
    );
  }

  /// Write the same tag to multiple in-memory byte arrays.
  ///
  /// Returns a [BatchBytesResult] with the modified bytes and any errors.
  /// Works on web and native.
  static Future<BatchBytesResult> batchWriteFromBytes(
    List<Uint8List> byteArrays,
    Tag tag,
  ) async {
    await _ensureInit();
    return await api.batchWriteFromBytes(byteArrays: byteArrays, data: tag);
  }

  /// Apply the same [TagChanges] to multiple in-memory byte arrays.
  ///
  /// Returns a [BatchBytesResult] with the modified bytes and any errors.
  /// Works on web and native.
  static Future<BatchBytesResult> batchUpdateChangesFromBytes(
    List<Uint8List> byteArrays,
    tc.TagChanges changes,
  ) async {
    await _ensureInit();
    return await api.batchUpdateChangesFromBytes(
      byteArrays: byteArrays,
      changes: changes,
    );
  }

  /// Update tags for multiple in-memory byte arrays using a callback.
  ///
  /// For each byte array, reads the current tag, calls [updater] to get the
  /// new tag, and writes it back. Use [onProgress] to track progress.
  ///
  /// Returns a [BatchBytesResult] with the modified bytes and any errors.
  /// Works on web and native.
  static Future<BatchBytesResult> batchUpdateFromBytes(
    List<Uint8List> byteArrays,
    Tag Function(int index, Tag currentTag) updater, {
    void Function(BatchProgress progress)? onProgress,
  }) async {
    await _ensureInit();
    final total = byteArrays.length;
    var completed = 0;
    final results = <Uint8List>[];
    var failures = 0;
    final errors = <(int, String)>[];

    for (var i = 0; i < byteArrays.length; i++) {
      try {
        final currentTag = await api.readFromBytes(bytes: byteArrays[i]);
        final newTag = updater(i, currentTag);
        final modified =
            await api.writeToBytes(bytes: byteArrays[i], data: newTag);
        results.add(modified);
      } on HaudiotaggerError catch (e) {
        failures++;
        errors.add((i, e.toString()));
      } catch (e) {
        failures++;
        errors.add((i, e.toString()));
      }
      completed++;
      onProgress?.call(BatchProgress(
        completed: completed,
        total: total,
      ));
    }

    return BatchBytesResult(
      results: results,
      failures: failures,
      errors: errors,
    );
  }

  /// Get the list of tag formats present in the file at [path].
  /// Works on native only.
  static Future<List<String>> getTagFormats(String path) async {
    await _ensureInit();
    return await api.getTagFormats(path: path);
  }

  /// Get the list of tag formats present in the in-memory [bytes].
  /// Works on web and native.
  static Future<List<String>> getTagFormatsFromBytes(Uint8List bytes) async {
    await _ensureInit();
    return await api.getTagFormatsFromBytes(bytes: bytes);
  }

  /// Get all custom tags from the file at [path].
  /// Returns a map of key -> value for format-specific custom tags.
  /// For ID3v2: TXXX frames (user-defined text).
  /// For Vorbis Comments: non-standard keys.
  /// Works on native only.
  static Future<Map<String, String>> getCustomTags(String path) async {
    await _ensureInit();
    return await api.getCustomTags(path: path);
  }

  /// Get all custom tags from in-memory [bytes].
  /// Works on web and native.
  static Future<Map<String, String>> getCustomTagsFromBytes(
      Uint8List bytes) async {
    await _ensureInit();
    return await api.getCustomTagsFromBytes(bytes: bytes);
  }

  /// Set a custom tag on the file at [path].
  /// For ID3v2: creates a TXXX frame with the key as description.
  /// For Vorbis Comments: inserts with the key directly.
  /// Works on native only.
  static Future<void> setCustomTag(
      String path, String key, String value) async {
    await _ensureInit();
    return await api.setCustomTag(path: path, key: key, value: value);
  }

  /// Set a custom tag on in-memory [bytes], returning the modified bytes.
  /// Works on web and native.
  static Future<Uint8List> setCustomTagFromBytes(
    Uint8List bytes,
    String key,
    String value,
  ) async {
    await _ensureInit();
    return await api.setCustomTagFromBytes(
        bytes: bytes, key: key, value: value);
  }

  /// Remove a custom tag from the file at [path].
  /// Works on native only.
  static Future<void> removeCustomTag(String path, String key) async {
    await _ensureInit();
    return await api.removeCustomTag(path: path, key: key);
  }

  /// Remove a custom tag from in-memory [bytes], returning the modified bytes.
  /// Works on web and native.
  static Future<Uint8List> removeCustomTagFromBytes(
      Uint8List bytes, String key) async {
    await _ensureInit();
    return await api.removeCustomTagFromBytes(bytes: bytes, key: key);
  }

  /// Get the ID3v2 version of the tag in the file at [path].
  /// Returns null if the file has no ID3v2 tag.
  /// Works on native only.
  static Future<Id3v2Version?> getId3v2Version(String path) async {
    await _ensureInit();
    return await api.getId3V2Version(path: path);
  }

  /// Get the ID3v2 version of the tag in in-memory [bytes].
  /// Returns null if the bytes have no ID3v2 tag.
  /// Works on web and native.
  static Future<Id3v2Version?> getId3v2VersionFromBytes(Uint8List bytes) async {
    await _ensureInit();
    return await api.getId3V2VersionFromBytes(bytes: bytes);
  }

  /// Convert the ID3v2 tag in the file at [path] to the specified [version].
  ///
  /// - [Id3v2Version.v2] is not supported for writing (returns error).
  /// - [Id3v2Version.v3] writes ID3v2.3 (widely compatible).
  /// - [Id3v2Version.v4] writes ID3v2.4 (latest spec).
  ///
  /// Works on native only.
  static Future<void> convertId3v2(String path, Id3v2Version version) async {
    await _ensureInit();
    return await api.convertId3V2(path: path, version: version);
  }

  /// Convert the ID3v2 tag in in-memory [bytes] to the specified [version],
  /// returning the modified bytes.
  ///
  /// - [Id3v2Version.v2] is not supported for writing (returns error).
  /// - [Id3v2Version.v3] writes ID3v2.3 (widely compatible).
  /// - [Id3v2Version.v4] writes ID3v2.4 (latest spec).
  ///
  /// Works on web and native.
  static Future<Uint8List> convertId3v2FromBytes(
      Uint8List bytes, Id3v2Version version) async {
    await _ensureInit();
    return await api.convertId3V2FromBytes(bytes: bytes, version: version);
  }

  /// Remove the ID3v1 tag from the file at [path].
  /// Works on native only.
  static Future<void> removeId3v1(String path) async {
    await _ensureInit();
    return await api.removeId3V1(path: path);
  }

  /// Remove the ID3v1 tag from in-memory [bytes], returning the modified bytes.
  /// Works on web and native.
  static Future<Uint8List> removeId3v1FromBytes(Uint8List bytes) async {
    await _ensureInit();
    return await api.removeId3V1FromBytes(bytes: bytes);
  }

  /// Inspect an audio file, returning all available information in one call.
  /// Works on native only.
  static Future<AudioFileInfo> inspect(String path) async {
    await _ensureInit();
    return await api.inspect(path: path);
  }

  /// Inspect audio data from in-memory bytes, returning all available
  /// information in one call. Works on web and native.
  static Future<AudioFileInfo> inspectFromBytes(Uint8List bytes) async {
    await _ensureInit();
    return await api.inspectFromBytes(bytes: bytes);
  }

  /// Validate the tag at [path] and return any issues found.
  /// Works on native only.
  static Future<ValidationResult> validate(String path) async {
    await _ensureInit();
    return await api.validate(path: path);
  }

  /// Validate in-memory [bytes] and return any issues found.
  /// Works on web and native.
  static Future<ValidationResult> validateFromBytes(Uint8List bytes) async {
    await _ensureInit();
    return await api.validateFromBytes(bytes: bytes);
  }

  /// Validate a [Tag] directly (for use after manual edits).
  static Future<ValidationResult> validateTag(Tag tag) async {
    await _ensureInit();
    return await api.validateTag(tag: tag);
  }

  /// Normalize the tag at [path] using default options, returning the cleaned tag.
  /// Does NOT write to disk — use [write] to persist the result.
  /// Works on native only.
  static Future<Tag> normalize(String path) async {
    await _ensureInit();
    return await api.normalize(path: path);
  }

  /// Normalize in-memory [bytes] using default options, returning the modified bytes.
  /// Works on web and native.
  static Future<Uint8List> normalizeBytes(Uint8List bytes) async {
    await _ensureInit();
    return await api.normalizeBytes(bytes: bytes);
  }

  /// Normalize a [Tag] directly with custom [options].
  static Future<Tag> normalizeTag(Tag tag, {NormalizeOptions? options}) async {
    await _ensureInit();
    final opts = options ?? await NormalizeOptions.default_();
    return await api.normalizeTag(tag: tag, options: opts);
  }

  /// Copy metadata from [source] file to [destination] file.
  ///
  /// By default copies all metadata. Use options to exclude specific fields:
  /// - [includeArtwork]: copy embedded pictures (default: true)
  /// - [includeLyrics]: copy lyrics (default: true)
  /// - [includeCustomTags]: copy format-specific custom tags (default: true)
  ///
  /// Works on native only.
  static Future<void> copyMetadata(
    String source,
    String destination, {
    bool includeArtwork = true,
    bool includeLyrics = true,
    bool includeCustomTags = true,
  }) async {
    await _ensureInit();
    var tag = await api.read(path: source);

    if (!includeArtwork) {
      tag = tag.copyWith(pictures: []);
    }
    if (!includeLyrics) {
      tag = tag.copyWith(lyrics: null);
    }

    await api.write(path: destination, data: tag);

    if (includeCustomTags) {
      final customTags = await api.getCustomTags(path: source);
      for (final entry in customTags.entries) {
        await api.setCustomTag(
            path: destination, key: entry.key, value: entry.value);
      }
    }
  }

  /// Copy metadata from [sourceBytes] to [destinationBytes], returning modified bytes.
  ///
  /// By default copies all metadata. Use options to exclude specific fields.
  /// Works on web and native.
  static Future<Uint8List> copyMetadataFromBytes(
    Uint8List sourceBytes,
    Uint8List destinationBytes, {
    bool includeArtwork = true,
    bool includeLyrics = true,
    bool includeCustomTags = true,
  }) async {
    await _ensureInit();
    var tag = await api.readFromBytes(bytes: sourceBytes);

    if (!includeArtwork) {
      tag = tag.copyWith(pictures: []);
    }
    if (!includeLyrics) {
      tag = tag.copyWith(lyrics: null);
    }

    var result = await api.writeToBytes(bytes: destinationBytes, data: tag);

    if (includeCustomTags) {
      final customTags = await api.getCustomTagsFromBytes(bytes: sourceBytes);
      if (customTags.isNotEmpty) {
        for (final entry in customTags.entries) {
          result = await api.setCustomTagFromBytes(
              bytes: result, key: entry.key, value: entry.value);
        }
      }
    }

    return result;
  }

  /// Compare two tags and return a [MetadataDiff] describing every field
  /// that changed between [oldTag] and [newTag].
  static MetadataDiff diff(Tag oldTag, Tag newTag) {
    final changes = <MetadataChange>[];

    void check<T>(TagField field, T? oldVal, T? newVal) {
      if (oldVal == newVal) return;
      if (oldVal == null) {
        changes.add(MetadataChange(
            field: field,
            oldValue: null,
            newValue: newVal,
            type: ChangeType.added));
      } else if (newVal == null) {
        changes.add(MetadataChange(
            field: field,
            oldValue: oldVal,
            newValue: null,
            type: ChangeType.removed));
      } else {
        changes.add(MetadataChange(
            field: field,
            oldValue: oldVal,
            newValue: newVal,
            type: ChangeType.updated));
      }
    }

    check<String>(TagField.title, oldTag.title, newTag.title);
    check<String>(TagField.artist, oldTag.trackArtist, newTag.trackArtist);
    check<String>(TagField.album, oldTag.album, newTag.album);
    check<String>(TagField.albumArtist, oldTag.albumArtist, newTag.albumArtist);
    check<int>(TagField.year, oldTag.year, newTag.year);
    check<String>(TagField.genre, oldTag.genre, newTag.genre);
    check<int>(TagField.trackNumber, oldTag.trackNumber, newTag.trackNumber);
    check<int>(TagField.trackTotal, oldTag.trackTotal, newTag.trackTotal);
    check<int>(TagField.discNumber, oldTag.discNumber, newTag.discNumber);
    check<int>(TagField.discTotal, oldTag.discTotal, newTag.discTotal);
    check<String>(TagField.lyrics, oldTag.lyrics, newTag.lyrics);
    check<String>(TagField.comment, oldTag.comment, newTag.comment);
    check<double>(TagField.bpm, oldTag.bpm, newTag.bpm);

    return MetadataDiff(changes: changes);
  }

  /// Merge two tags using the given [strategy].
  ///
  /// - [MergeStrategy.preferFirst]: [tagA] wins for all fields.
  /// - [MergeStrategy.preferSecond]: [tagB] wins for all fields.
  /// - [MergeStrategy.preferFirstNonEmpty]: [tagA] wins unless empty, then [tagB].
  /// - [MergeStrategy.preferSecondNonEmpty]: [tagB] wins unless empty, then [tagA].
  ///
  /// Pictures are concatenated (both sources kept).
  /// Returns a new [Tag] without modifying the originals.
  static Tag mergeTags(
    Tag tagA,
    Tag tagB, {
    MergeStrategy strategy = MergeStrategy.preferFirstNonEmpty,
  }) {
    T pick<T>(T? a, T? b) {
      return switch (strategy) {
        MergeStrategy.preferFirst => a ?? b as T,
        MergeStrategy.preferSecond => b ?? a as T,
        MergeStrategy.preferFirstNonEmpty =>
          (a != null && a != '' && a != 0) ? a : b as T,
        MergeStrategy.preferSecondNonEmpty =>
          (b != null && b != '' && b != 0) ? b : a as T,
      };
    }

    return Tag(
      title: pick<String?>(tagA.title, tagB.title),
      trackArtist: pick<String?>(tagA.trackArtist, tagB.trackArtist),
      album: pick<String?>(tagA.album, tagB.album),
      albumArtist: pick<String?>(tagA.albumArtist, tagB.albumArtist),
      year: pick<int?>(tagA.year, tagB.year),
      genre: pick<String?>(tagA.genre, tagB.genre),
      trackNumber: pick<int?>(tagA.trackNumber, tagB.trackNumber),
      trackTotal: pick<int?>(tagA.trackTotal, tagB.trackTotal),
      discNumber: pick<int?>(tagA.discNumber, tagB.discNumber),
      discTotal: pick<int?>(tagA.discTotal, tagB.discTotal),
      lyrics: pick<String?>(tagA.lyrics, tagB.lyrics),
      comment: pick<String?>(tagA.comment, tagB.comment),
      bpm: pick<double?>(tagA.bpm, tagB.bpm),
      duration: tagA.duration ?? tagB.duration,
      pictures: [...tagA.pictures, ...tagB.pictures],
    );
  }

  /// Format a filename from a tag using a pattern string.
  ///
  /// Supported placeholders:
  /// `{title}`, `{artist}`, `{album}`, `{albumArtist}`, `{track}`,
  /// `{trackTotal}`, `{disc}`, `{discTotal}`, `{year}`, `{genre}`
  ///
  /// Example:
  /// ```dart
  /// final name = Haudiotagger.formatFilename(
  ///   tag,
  ///   pattern: '{track}. {title}',
  /// );
  /// // Result: "01. My Song"
  /// ```
  static String formatFilename(Tag tag, {required String pattern}) {
    final replacements = <String, String>{
      '{title}': tag.title ?? '',
      '{artist}': tag.trackArtist ?? '',
      '{album}': tag.album ?? '',
      '{albumArtist}': tag.albumArtist ?? '',
      '{track}': tag.trackNumber != null
          ? tag.trackNumber.toString().padLeft(2, '0')
          : '',
      '{trackTotal}': tag.trackTotal?.toString() ?? '',
      '{disc}': tag.discNumber?.toString() ?? '',
      '{discTotal}': tag.discTotal?.toString() ?? '',
      '{year}': tag.year?.toString() ?? '',
      '{genre}': tag.genre ?? '',
    };

    var result = pattern;
    for (final entry in replacements.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }

    // Clean up multiple spaces and trim
    result = result.replaceAll(RegExp(r' {2,}'), ' ').trim();

    // Remove trailing dots, dashes, or spaces
    result = result.replaceAll(RegExp(r'[\.\-\s]+$'), '');

    return result;
  }

  /// Rename a file based on its metadata using a pattern.
  ///
  /// Returns the new file path on success.
  ///
  /// Example:
  /// ```dart
  /// final newPath = await Haudiotagger.rename(
  ///   '/path/to/song.mp3',
  ///   pattern: '{track} - {title}',
  /// );
  /// // Renames to "/path/to/01 - My Song.mp3"
  /// ```
  static Future<String> rename(String path, {required String pattern}) async {
    await _ensureInit();
    return api.renameFile(path: path, pattern: pattern);
  }
}

/// The type of change for a single field.
enum ChangeType { added, updated, removed }

/// A single field change between two tags.
class MetadataChange<T> {
  final TagField field;
  final T? oldValue;
  final T? newValue;
  final ChangeType type;

  const MetadataChange({
    required this.field,
    required this.oldValue,
    required this.newValue,
    required this.type,
  });

  @override
  String toString() => '${field.name}: $oldValue → $newValue';
}

/// Result of comparing two tags.
class MetadataDiff {
  final List<MetadataChange> changes;

  const MetadataDiff({required this.changes});

  /// Number of fields that changed.
  int get length => changes.length;

  /// True if no fields changed.
  bool get isEmpty => changes.isEmpty;

  /// True if at least one field changed.
  bool get isNotEmpty => changes.isNotEmpty;

  @override
  String toString() => changes.isEmpty
      ? 'No changes'
      : '${changes.length} change${changes.length == 1 ? '' : 's'}';
}

/// Strategy for merging two tags.
enum MergeStrategy {
  /// [tagA] wins for all fields.
  preferFirst,

  /// [tagB] wins for all fields.
  preferSecond,

  /// [tagA] wins unless empty, then [tagB].
  preferFirstNonEmpty,

  /// [tagB] wins unless empty, then [tagA].
  preferSecondNonEmpty,
}

/// Convenience accessors for [ap.AudioProperties].
extension AudioPropertiesX on ap.AudioProperties {
  /// The audio duration, derived from [ap.AudioProperties.durationMicros].
  Duration? get duration {
    final micros = durationMicros;
    if (micros == null) return null;
    return Duration(microseconds: _microsToInt(micros));
  }
}

int _microsToInt(dynamic micros) =>
    micros is BigInt ? micros.toInt() : micros as int;
