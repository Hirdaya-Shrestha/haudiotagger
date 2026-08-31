import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:haudiotagger/haudiotagger.dart';

import 'fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Uint8List mp3Bytes;

  setUp(() {
    mp3Bytes = createMinimalMp3(
      title: 'Original Title',
      artist: 'Original Artist',
      album: 'Original Album',
    );
  });

  // ============================================================
  // READ / WRITE
  // ============================================================

  group('read / write', () {
    test('readFromBytes returns tag with correct fields', () async {
      final tag = await Haudiotagger.readFromBytes(mp3Bytes);
      expect(tag, isNotNull);
      expect(tag!.title, 'Original Title');
      expect(tag.trackArtist, 'Original Artist');
      expect(tag.album, 'Original Album');
    });

    test('writeToBytes produces bytes that read back correctly', () async {
      final tag = Tag(
        title: 'New Title',
        trackArtist: 'New Artist',
        album: 'New Album',
        year: 2025,
        genre: 'Rock',
        pictures: [],
      );

      final written = await Haudiotagger.writeToBytes(mp3Bytes, tag);
      final readBack = await Haudiotagger.readFromBytes(written);
      expect(readBack, isNotNull);
      expect(readBack!.title, 'New Title');
      expect(readBack.trackArtist, 'New Artist');
      expect(readBack.album, 'New Album');
      expect(readBack.year, 2025);
      expect(readBack.genre, 'Rock');
    });

    test('write with empty tag clears metadata', () async {
      final written = await Haudiotagger.writeToBytes(mp3Bytes, Tag(pictures: []));
      final readBack = await Haudiotagger.readFromBytes(written);
      expect(readBack, isNotNull);
      expect(readBack!.title, isNull);
      expect(readBack.trackArtist, isNull);
      expect(readBack.album, isNull);
    });
  });

  // ============================================================
  // UPDATE (partial)
  // ============================================================

  group('update', () {
    test('updateFromBytes changes only specified fields', () async {
      final changes = TagChanges(title: 'Updated Title');
      final written =
          await Haudiotagger.updateFromBytes(mp3Bytes, changes);
      final readBack = await Haudiotagger.readFromBytes(written);
      expect(readBack, isNotNull);
      expect(readBack!.title, 'Updated Title');
      expect(readBack.trackArtist, 'Original Artist');
      expect(readBack.album, 'Original Album');
    });

    test('update preserves all other fields', () async {
      final changes = TagChanges(
        year: 2030,
        genre: 'Jazz',
      );
      final written =
          await Haudiotagger.updateFromBytes(mp3Bytes, changes);
      final readBack = await Haudiotagger.readFromBytes(written);
      expect(readBack, isNotNull);
      expect(readBack!.title, 'Original Title');
      expect(readBack.trackArtist, 'Original Artist');
      expect(readBack.album, 'Original Album');
      expect(readBack.year, 2030);
      expect(readBack.genre, 'Jazz');
    });

    test('multiple fields updated at once', () async {
      final changes = TagChanges(
        title: 'New Title',
        trackArtist: 'New Artist',
        album: 'New Album',
      );
      final written =
          await Haudiotagger.updateFromBytes(mp3Bytes, changes);
      final readBack = await Haudiotagger.readFromBytes(written);
      expect(readBack, isNotNull);
      expect(readBack!.title, 'New Title');
      expect(readBack.trackArtist, 'New Artist');
      expect(readBack.album, 'New Album');
    });
  });

  // ============================================================
  // REMOVE / CLEAR
  // ============================================================

  group('remove / clear', () {
    test('removeFromBytes clears specific fields', () async {
      final written = await Haudiotagger.removeFromBytes(
        mp3Bytes,
        [TagField.title, TagField.artist],
      );
      final readBack = await Haudiotagger.readFromBytes(written);
      expect(readBack, isNotNull);
      expect(readBack!.title, isNull);
      expect(readBack.trackArtist, isNull);
      expect(readBack.album, 'Original Album');
    });

    test('clearFromBytes removes all metadata', () async {
      final written = await Haudiotagger.clearFromBytes(mp3Bytes);
      final readBack = await Haudiotagger.readFromBytes(written);
      expect(readBack, isNotNull);
      expect(readBack!.title, isNull);
      expect(readBack.trackArtist, isNull);
      expect(readBack.album, isNull);
      expect(await readBack.isEmpty(), true);
    });
  });

  // ============================================================
  // BATCH OPERATIONS
  // ============================================================

  group('batch operations', () {
    test('batchWriteFromBytes writes to all byte arrays', () async {
      final arrays = [mp3Bytes, mp3Bytes, mp3Bytes];
      final tag = Tag(title: 'Batch Title', trackArtist: 'Batch Artist', pictures: []);

      final result =
          await Haudiotagger.batchWriteFromBytes(arrays, tag);

      expect(result.failures, 0);
      expect(result.results.length, 3);

      for (final bytes in result.results) {
        final readBack = await Haudiotagger.readFromBytes(bytes);
        expect(readBack, isNotNull);
        expect(readBack!.title, 'Batch Title');
        expect(readBack.trackArtist, 'Batch Artist');
      }
    });

    test('batchUpdateChangesFromBytes applies changes to all', () async {
      final arrays = [mp3Bytes, mp3Bytes];
      final changes = TagChanges(title: 'Updated');

      final result =
          await Haudiotagger.batchUpdateChangesFromBytes(arrays, changes);

      expect(result.failures, 0);
      expect(result.results.length, 2);

      for (final bytes in result.results) {
        final readBack = await Haudiotagger.readFromBytes(bytes);
        expect(readBack, isNotNull);
        expect(readBack!.title, 'Updated');
        expect(readBack.trackArtist, 'Original Artist');
      }
    });

    test('batchUpdateFromBytes with callback', () async {
      final arrays = [mp3Bytes, mp3Bytes, mp3Bytes];

      final result = await Haudiotagger.batchUpdateFromBytes(
        arrays,
        (index, current) => current.copyWith(
          title: 'Track $index',
        ),
      );

      expect(result.failures, 0);
      expect(result.results.length, 3);

      final tag0 = await Haudiotagger.readFromBytes(result.results[0]);
      final tag1 = await Haudiotagger.readFromBytes(result.results[1]);
      final tag2 = await Haudiotagger.readFromBytes(result.results[2]);

      expect(tag0?.title, 'Track 0');
      expect(tag1?.title, 'Track 1');
      expect(tag2?.title, 'Track 2');
    });
  });

  // ============================================================
  // CUSTOM TAGS
  // ============================================================

  group('custom tags', () {
    test('setCustomTagFromBytes and getCustomTagsFromBytes', () async {
      var bytes = await Haudiotagger.setCustomTagFromBytes(
        mp3Bytes,
        'MY_FIELD',
        'my_value',
      );

      final customTags = await Haudiotagger.getCustomTagsFromBytes(bytes);
      expect(customTags['MY_FIELD'], 'my_value');
    });

    test('removeCustomTagFromBytes removes custom tag', () async {
      var bytes = await Haudiotagger.setCustomTagFromBytes(
        mp3Bytes,
        'MY_FIELD',
        'my_value',
      );

      bytes = await Haudiotagger.removeCustomTagFromBytes(bytes, 'MY_FIELD');

      final customTags = await Haudiotagger.getCustomTagsFromBytes(bytes);
      expect(customTags.containsKey('MY_FIELD'), false);
    });
  });

  // ============================================================
  // INSPECT
  // ============================================================

  group('inspect', () {
    test('inspectFromBytes returns file info', () async {
      final info = await Haudiotagger.inspectFromBytes(mp3Bytes);

      expect(info.format, 'MP3');
      expect(info.tagFormat, 'ID3v2');
      expect(info.metadata, isNotNull);
      expect(info.metadata!.title, 'Original Title');
    });
  });

  // ============================================================
  // TAG FORMATS
  // ============================================================

  group('tag formats', () {
    test('getTagFormatsFromBytes returns formats', () async {
      final formats = await Haudiotagger.getTagFormatsFromBytes(mp3Bytes);
      expect(formats, contains('ID3v2'));
    });
  });

  // ============================================================
  // DIFF
  // ============================================================

  group('diff', () {
    test('diff detects added fields', () {
      final oldTag = Tag(pictures: []);
      final newTag = Tag(title: 'New Title', trackArtist: 'New Artist', pictures: []);

      final diff = Haudiotagger.diff(oldTag, newTag);

      expect(diff.isNotEmpty, true);
      expect(diff.changes.length, 2);

      final titleChange =
          diff.changes.firstWhere((c) => c.field == TagField.title);
      expect(titleChange.type, ChangeType.added);
      expect(titleChange.oldValue, isNull);
      expect(titleChange.newValue, 'New Title');
    });

    test('diff detects updated fields', () {
      final oldTag = Tag(title: 'Old Title', year: 2020, pictures: []);
      final newTag = Tag(title: 'New Title', year: 2020, pictures: []);

      final diff = Haudiotagger.diff(oldTag, newTag);

      expect(diff.changes.length, 1);
      expect(diff.changes.first.type, ChangeType.updated);
      expect(diff.changes.first.oldValue, 'Old Title');
      expect(diff.changes.first.newValue, 'New Title');
    });

    test('diff detects removed fields', () {
      final oldTag = Tag(title: 'Title', trackArtist: 'Artist', pictures: []);
      final newTag = Tag(title: 'Title', pictures: []);

      final diff = Haudiotagger.diff(oldTag, newTag);

      expect(diff.changes.length, 1);
      expect(diff.changes.first.type, ChangeType.removed);
      expect(diff.changes.first.field, TagField.artist);
    });

    test('diff returns empty for identical tags', () {
      final tag = Tag(title: 'Title', year: 2025, pictures: []);
      final diff = Haudiotagger.diff(tag, Tag(
        title: 'Title',
        year: 2025,
        pictures: [],
      ));

      expect(diff.isEmpty, true);
    });
  });

  // ============================================================
  // MERGE TAGS
  // ============================================================

  group('mergeTags', () {
    test('preferFirstNonEmpty uses first tag unless empty', () {
      final tagA = Tag(title: 'Title A', trackArtist: 'Artist A', pictures: []);
      final tagB = Tag(title: '', trackArtist: 'Artist B', album: 'Album B', pictures: []);

      final merged = Haudiotagger.mergeTags(tagA, tagB);

      expect(merged.title, 'Title A');
      expect(merged.trackArtist, 'Artist A');
      expect(merged.album, 'Album B');
    });

    test('preferFirst always uses first tag', () {
      final tagA = Tag(title: 'Title A', pictures: []);
      final tagB = Tag(title: 'Title B', pictures: []);

      final merged = Haudiotagger.mergeTags(
        tagA,
        tagB,
        strategy: MergeStrategy.preferFirst,
      );

      expect(merged.title, 'Title A');
    });

    test('preferSecond always uses second tag', () {
      final tagA = Tag(title: 'Title A', pictures: []);
      final tagB = Tag(title: 'Title B', pictures: []);

      final merged = Haudiotagger.mergeTags(
        tagA,
        tagB,
        strategy: MergeStrategy.preferSecond,
      );

      expect(merged.title, 'Title B');
    });

    test('preferSecondNonEmpty uses second unless empty', () {
      final tagA = Tag(title: 'Title A', album: 'Album A', pictures: []);
      final tagB = Tag(title: 'Title B', album: '', pictures: []);

      final merged = Haudiotagger.mergeTags(
        tagA,
        tagB,
        strategy: MergeStrategy.preferSecondNonEmpty,
      );

      expect(merged.title, 'Title B');
      expect(merged.album, 'Album A');
    });

    test('merge concatenates pictures', () async {
      final pic1 = Picture(
        pictureType: PictureType.coverFront,
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      final pic2 = Picture(
        pictureType: PictureType.coverBack,
        bytes: Uint8List.fromList([4, 5, 6]),
      );

      final tagA = Tag(pictures: [pic1]);
      final tagB = Tag(pictures: [pic2]);

      final merged = Haudiotagger.mergeTags(tagA, tagB);

      expect(merged.pictures.length, 2);
    });

    test('merge does not modify originals', () {
      final tagA = Tag(title: 'A', pictures: []);
      final tagB = Tag(title: 'B', pictures: []);

      Haudiotagger.mergeTags(tagA, tagB);

      expect(tagA.title, 'A');
      expect(tagB.title, 'B');
    });
  });

  // ============================================================
  // VALIDATE
  // ============================================================

  group('validate', () {
    test('validateTag returns no errors for valid tag', () async {
      final tag = Tag(
        title: 'Title',
        trackArtist: 'Artist',
        album: 'Album',
        trackNumber: 1,
        trackTotal: 10,
        pictures: [Picture(pictureType: PictureType.coverFront, bytes: Uint8List(1))],
      );

      final result = await Haudiotagger.validateTag(tag);

      expect(result.isValid, true);
      expect(result.issues.where((i) => i.severity == ValidationSeverity.error), isEmpty);
    });

    test('validateTag detects track number > total', () async {
      final tag = Tag(trackNumber: 5, trackTotal: 3, pictures: []);

      final result = await Haudiotagger.validateTag(tag);

      expect(result.isValid, false);
      final errors = result.issues.where((i) => i.severity == ValidationSeverity.error);
      expect(errors.any((i) => i.field == 'track_number'), true);
    });

    test('validateTag detects disc number > total', () async {
      final tag = Tag(discNumber: 3, discTotal: 2, pictures: []);

      final result = await Haudiotagger.validateTag(tag);

      expect(result.isValid, false);
      final errors = result.issues.where((i) => i.severity == ValidationSeverity.error);
      expect(errors.any((i) => i.field == 'disc_number'), true);
    });

    test('validateTag warns on missing artist', () async {
      final tag = Tag(title: 'Title', pictures: []);

      final result = await Haudiotagger.validateTag(tag);

      final warnings = result.issues.where((i) => i.severity == ValidationSeverity.warning);
      expect(warnings.any((i) => i.field == 'track_artist'), true);
    });

    test('validateTag warns on missing album', () async {
      final tag = Tag(title: 'Title', trackArtist: 'Artist', pictures: []);

      final result = await Haudiotagger.validateTag(tag);

      final warnings = result.issues.where((i) => i.severity == ValidationSeverity.warning);
      expect(warnings.any((i) => i.field == 'album'), true);
    });

    test('validateTag warns on missing artwork', () async {
      final tag = Tag(title: 'Title', trackArtist: 'Artist', album: 'Album', pictures: []);

      final result = await Haudiotagger.validateTag(tag);

      final warnings = result.issues.where((i) => i.severity == ValidationSeverity.warning);
      expect(warnings.any((i) => i.field == 'pictures'), true);
    });

    test('validateTag warns on invalid BPM', () async {
      final tag = Tag(bpm: -5.0, pictures: []);

      final result = await Haudiotagger.validateTag(tag);

      final warnings = result.issues.where((i) => i.severity == ValidationSeverity.warning);
      expect(warnings.any((i) => i.field == 'bpm'), true);
    });

    test('validateTag warns on invalid year', () async {
      final tag = Tag(year: 0, pictures: []);

      final result = await Haudiotagger.validateTag(tag);

      final warnings = result.issues.where((i) => i.severity == ValidationSeverity.warning);
      expect(warnings.any((i) => i.field == 'year'), true);
    });
  });

  // ============================================================
  // NORMALIZE
  // ============================================================

  group('normalize', () {
    test('normalizeTag trims whitespace', () async {
      final tag = Tag(
        title: '  My Song  ',
        trackArtist: '  The Artist  ',
        pictures: [],
      );

      final normalized = await Haudiotagger.normalizeTag(tag);

      expect(normalized.title, 'My Song');
      expect(normalized.trackArtist, 'The Artist');
    });

    test('normalizeTag collapses whitespace', () async {
      final tag = Tag(
        title: 'The   Artist',
        album: '  Some   Album  ',
        pictures: [],
      );

      final normalized = await Haudiotagger.normalizeTag(tag);

      expect(normalized.title, 'The Artist');
      expect(normalized.album, 'Some Album');
    });

    test('normalizeTag removes empty values when removeEmptyValues is true',
        () async {
      final tag = Tag(
        title: '  ', // only whitespace → empty after trim
        trackArtist: 'Artist',
        pictures: [],
      );

      final normalized = await Haudiotagger.normalizeTag(tag);

      expect(normalized.title, isNull);
      expect(normalized.trackArtist, 'Artist');
    });

    test('normalizeTag with custom options', () async {
      final tag = Tag(title: '  My Song  ', pictures: []);

      final normalized = await Haudiotagger.normalizeTag(
        tag,
        options: NormalizeOptions(
          trimValues: false,
          normalizeWhitespace: false,
          normalizeUnicode: false,
          removeEmptyValues: false,
        ),
      );

      // No normalization applied
      expect(normalized.title, '  My Song  ');
    });

    test('normalizeTag preserves non-string fields', () async {
      final tag = Tag(
        title: 'Title',
        year: 2025,
        trackNumber: 1,
        bpm: 120.0,
        pictures: [],
      );

      final normalized = await Haudiotagger.normalizeTag(tag);

      expect(normalized.year, 2025);
      expect(normalized.trackNumber, 1);
      expect(normalized.bpm, 120.0);
    });
  });

  // ============================================================
  // COPY METADATA
  // ============================================================

  group('copyMetadata', () {
    test('copyMetadataFromBytes copies all metadata', () async {
      final destBytes = createMinimalMp3();

      final result = await Haudiotagger.copyMetadataFromBytes(
        mp3Bytes,
        destBytes,
      );

      final readBack = await Haudiotagger.readFromBytes(result);
      expect(readBack, isNotNull);
      expect(readBack!.title, 'Original Title');
      expect(readBack.trackArtist, 'Original Artist');
      expect(readBack.album, 'Original Album');
    });

    test('copyMetadataFromBytes without artwork excludes pictures', () async {
      final destBytes = createMinimalMp3();

      final result = await Haudiotagger.copyMetadataFromBytes(
        mp3Bytes,
        destBytes,
        includeArtwork: false,
      );

      final readBack = await Haudiotagger.readFromBytes(result);
      expect(readBack, isNotNull);
      expect(readBack!.pictures, isEmpty);
    });
  });

  // ============================================================
  // REPLAYGAIN
  // ============================================================

  group('ReplayGain', () {
    test('write and read ReplayGain fields', () async {
      final tag = Tag(
        title: 'Song',
        pictures: [],
        replayGainTrackGain: '-6.43',
        replayGainTrackPeak: '0.981201',
        replayGainAlbumGain: '-7.12',
        replayGainAlbumPeak: '0.995000',
      );

      final written = await Haudiotagger.writeToBytes(mp3Bytes, tag);
      final readBack = await Haudiotagger.readFromBytes(written);
      expect(readBack, isNotNull);

      expect(readBack!.replayGainTrackGain, '-6.43');
      expect(readBack.replayGainTrackPeak, '0.981201');
      expect(readBack.replayGainAlbumGain, '-7.12');
      expect(readBack.replayGainAlbumPeak, '0.995000');
    });

    test('update preserves ReplayGain when not modified', () async {
      // Write ReplayGain first
      var tag = Tag(
        title: 'Song',
        pictures: [],
        replayGainTrackGain: '-6.43',
      );
      var bytes = await Haudiotagger.writeToBytes(mp3Bytes, tag);

      // Now update only title
      final changes = TagChanges(title: 'Updated Title');
      bytes = await Haudiotagger.updateFromBytes(bytes, changes);

      final readBack = await Haudiotagger.readFromBytes(bytes);
      expect(readBack, isNotNull);
      expect(readBack!.title, 'Updated Title');
      expect(readBack.replayGainTrackGain, '-6.43');
    });
  });

  // ============================================================
  // COPYWITH
  // ============================================================

  group('copyWith', () {
    test('copyWith preserves unspecified fields', () {
      final original = Tag(
        title: 'Title',
        trackArtist: 'Artist',
        album: 'Album',
        year: 2025,
        pictures: [],
      );

      final copy = original.copyWith(title: 'New Title');

      expect(copy.title, 'New Title');
      expect(copy.trackArtist, 'Artist');
      expect(copy.album, 'Album');
      expect(copy.year, 2025);
    });

    test('copyWith replaces pictures', () async {
      final pic1 = Picture(
        pictureType: PictureType.coverFront,
        bytes: Uint8List.fromList([1]),
      );
      final pic2 = Picture(
        pictureType: PictureType.coverBack,
        bytes: Uint8List.fromList([2]),
      );

      final original = Tag(pictures: [pic1]);
      final copy = original.copyWith(pictures: [pic2]);

      expect(copy.pictures.length, 1);
      expect(copy.pictures.first.pictureType, PictureType.coverBack);
    });

    test('copyWith returns independent instance', () {
      final original = Tag(title: 'Title', pictures: []);
      final copy = original.copyWith(title: 'New Title');

      expect(original.title, 'Title');
      expect(copy.title, 'New Title');
    });
  });
}
