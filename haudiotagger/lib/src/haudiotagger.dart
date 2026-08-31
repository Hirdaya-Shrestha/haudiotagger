import 'dart:typed_data';

import 'rust/frb_generated.dart';

import 'rust/api/api.dart' as api;
import 'rust/api/api.dart' show BatchResult, BatchBytesResult, Id3v2Version;
import 'rust/api/tag.dart';
import 'rust/api/error.dart';
import 'rust/api/audio_properties.dart' as ap;
import 'rust/api/tag_changes.dart' as tc;
import 'rust/api/tag_field.dart';

export 'rust/api/picture.dart';
export 'rust/api/tag.dart';
export 'rust/api/error.dart';
export 'rust/api/audio_properties.dart';
export 'rust/api/tag_changes.dart';
export 'rust/api/tag_field.dart';
export 'rust/api/api.dart' show BatchResult, BatchBytesResult, Id3v2Version;

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
  static Future<void> setCustomTag(String path, String key, String value) async {
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
    return await api.setCustomTagFromBytes(bytes: bytes, key: key, value: value);
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
