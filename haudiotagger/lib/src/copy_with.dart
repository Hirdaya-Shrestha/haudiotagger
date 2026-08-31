import 'dart:typed_data';

import 'rust/api/picture.dart';
import 'rust/api/tag.dart';
import 'rust/api/tag_changes.dart';

extension TagCopyWith on Tag {
  Tag copyWith({
    String? title,
    String? trackArtist,
    String? album,
    String? albumArtist,
    int? year,
    String? genre,
    int? trackNumber,
    int? trackTotal,
    int? discNumber,
    int? discTotal,
    String? lyrics,
    String? comment,
    int? duration,
    List<Picture>? pictures,
    double? bpm,
  }) =>
      Tag(
        title: title ?? this.title,
        trackArtist: trackArtist ?? this.trackArtist,
        album: album ?? this.album,
        albumArtist: albumArtist ?? this.albumArtist,
        year: year ?? this.year,
        genre: genre ?? this.genre,
        trackNumber: trackNumber ?? this.trackNumber,
        trackTotal: trackTotal ?? this.trackTotal,
        discNumber: discNumber ?? this.discNumber,
        discTotal: discTotal ?? this.discTotal,
        lyrics: lyrics ?? this.lyrics,
        comment: comment ?? this.comment,
        duration: duration ?? this.duration,
        pictures: pictures ?? this.pictures,
        bpm: bpm ?? this.bpm,
      );
}

extension TagChangesCopyWith on TagChanges {
  TagChanges copyWith({
    String? title,
    String? trackArtist,
    String? album,
    String? albumArtist,
    int? year,
    String? genre,
    int? trackNumber,
    int? trackTotal,
    int? discNumber,
    int? discTotal,
    String? lyrics,
    String? comment,
    List<Picture>? pictures,
    double? bpm,
  }) =>
      TagChanges(
        title: title ?? this.title,
        trackArtist: trackArtist ?? this.trackArtist,
        album: album ?? this.album,
        albumArtist: albumArtist ?? this.albumArtist,
        year: year ?? this.year,
        genre: genre ?? this.genre,
        trackNumber: trackNumber ?? this.trackNumber,
        trackTotal: trackTotal ?? this.trackTotal,
        discNumber: discNumber ?? this.discNumber,
        discTotal: discTotal ?? this.discTotal,
        lyrics: lyrics ?? this.lyrics,
        comment: comment ?? this.comment,
        pictures: pictures ?? this.pictures,
        bpm: bpm ?? this.bpm,
      );
}

extension PictureCopyWith on Picture {
  Picture copyWith({
    PictureType? pictureType,
    MimeType? mimeType,
    Uint8List? bytes,
  }) =>
      Picture(
        pictureType: pictureType ?? this.pictureType,
        mimeType: mimeType ?? this.mimeType,
        bytes: bytes ?? this.bytes,
      );
}
