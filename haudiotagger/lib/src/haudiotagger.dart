import 'dart:typed_data';

import 'rust/frb_generated.dart';

import 'rust/api/api.dart' as api;
import 'rust/api/tag.dart';
import 'rust/api/error.dart';

export 'rust/api/picture.dart';
export 'rust/api/tag.dart';
export 'rust/api/error.dart';

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
}
