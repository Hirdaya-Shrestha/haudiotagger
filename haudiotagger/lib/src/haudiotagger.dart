import 'dart:typed_data';

import 'rust/frb_generated.dart';

import 'rust/api/api.dart' as api;
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
