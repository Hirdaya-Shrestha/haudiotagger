import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:haudiotagger/haudiotagger.dart';

import 'fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Uint8List mp3Bytes;

  setUp(() {
    mp3Bytes = createTaggedMp3();
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
      final written =
          await Haudiotagger.writeToBytes(mp3Bytes, Tag(pictures: []));
      final readBack = await Haudiotagger.readFromBytes(written);
      expect(readBack, isNull);
    });
  });

  // ============================================================
  // UPDATE (partial)
  // ============================================================

  group('update', () {
    test('updateFromBytes changes only specified fields', () async {
      final changes = TagChanges(title: 'Updated Title');
      final written = await Haudiotagger.updateFromBytes(mp3Bytes, changes);
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
      final written = await Haudiotagger.updateFromBytes(mp3Bytes, changes);
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
      final written = await Haudiotagger.updateFromBytes(mp3Bytes, changes);
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
      expect(readBack, isNull);
    });
  });

  // ============================================================
  // BATCH OPERATIONS
  // ============================================================

  group('batch operations', () {
    test('batchWriteFromBytes writes to all byte arrays', () async {
      final arrays = [mp3Bytes, mp3Bytes, mp3Bytes];
      final tag =
          Tag(title: 'Batch Title', trackArtist: 'Batch Artist', pictures: []);

      final result = await Haudiotagger.batchWriteFromBytes(arrays, tag);

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
      final newTag =
          Tag(title: 'New Title', trackArtist: 'New Artist', pictures: []);

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
      final diff = Haudiotagger.diff(
          tag,
          Tag(
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
      final tagB = Tag(
          title: '', trackArtist: 'Artist B', album: 'Album B', pictures: []);

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
        pictures: [
          Picture(pictureType: PictureType.coverFront, bytes: Uint8List(1))
        ],
      );

      final result = await Haudiotagger.validateTag(tag);

      expect(await result.isValid(), true);
      expect(result.issues.where((i) => i.severity == ValidationSeverity.error),
          isEmpty);
    });

    test('validateTag detects track number > total', () async {
      final tag = Tag(trackNumber: 5, trackTotal: 3, pictures: []);

      final result = await Haudiotagger.validateTag(tag);

      expect(await result.isValid(), false);
      final errors =
          result.issues.where((i) => i.severity == ValidationSeverity.error);
      expect(errors.any((i) => i.field == 'track_number'), true);
    });

    test('validateTag detects disc number > total', () async {
      final tag = Tag(discNumber: 3, discTotal: 2, pictures: []);

      final result = await Haudiotagger.validateTag(tag);

      expect(await result.isValid(), false);
      final errors =
          result.issues.where((i) => i.severity == ValidationSeverity.error);
      expect(errors.any((i) => i.field == 'disc_number'), true);
    });

    test('validateTag warns on missing artist', () async {
      final tag = Tag(title: 'Title', pictures: []);

      final result = await Haudiotagger.validateTag(tag);

      final warnings =
          result.issues.where((i) => i.severity == ValidationSeverity.warning);
      expect(warnings.any((i) => i.field == 'track_artist'), true);
    });

    test('validateTag warns on missing album', () async {
      final tag = Tag(title: 'Title', trackArtist: 'Artist', pictures: []);

      final result = await Haudiotagger.validateTag(tag);

      final warnings =
          result.issues.where((i) => i.severity == ValidationSeverity.warning);
      expect(warnings.any((i) => i.field == 'album'), true);
    });

    test('validateTag warns on missing artwork', () async {
      final tag = Tag(
          title: 'Title', trackArtist: 'Artist', album: 'Album', pictures: []);

      final result = await Haudiotagger.validateTag(tag);

      final warnings =
          result.issues.where((i) => i.severity == ValidationSeverity.warning);
      expect(warnings.any((i) => i.field == 'pictures'), true);
    });

    test('validateTag warns on invalid BPM', () async {
      final tag = Tag(bpm: -5.0, pictures: []);

      final result = await Haudiotagger.validateTag(tag);

      final warnings =
          result.issues.where((i) => i.severity == ValidationSeverity.warning);
      expect(warnings.any((i) => i.field == 'bpm'), true);
    });

    test('validateTag warns on invalid year', () async {
      final tag = Tag(year: 0, pictures: []);

      final result = await Haudiotagger.validateTag(tag);

      final warnings =
          result.issues.where((i) => i.severity == ValidationSeverity.warning);
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
      final destBytes = createEmptyMp3();

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
      final destBytes = createEmptyMp3();

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

  // ============================================================
  // FORMAT FILENAME / RENAME
  // ============================================================

  group('formatFilename / rename', () {
    test('formatFilename with track and title', () {
      final tag = Tag(
        trackNumber: 1,
        title: 'My Song',
        pictures: [],
      );

      final result =
          Haudiotagger.formatFilename(tag, pattern: '{track}. {title}');
      expect(result, '01. My Song');
    });

    test('formatFilename with all placeholders', () {
      final tag = Tag(
        title: 'Song Title',
        trackArtist: 'Artist Name',
        album: 'Album Name',
        albumArtist: 'Album Artist',
        trackNumber: 5,
        trackTotal: 12,
        discNumber: 1,
        discTotal: 2,
        year: 2025,
        genre: 'Rock',
        pictures: [],
      );

      final result = Haudiotagger.formatFilename(
        tag,
        pattern: '{track}. {title} - {artist} [{album}]',
      );
      expect(result, '05. Song Title - Artist Name [Album Name]');
    });

    test('formatFilename handles missing fields gracefully', () {
      final tag = Tag(pictures: []);

      final result =
          Haudiotagger.formatFilename(tag, pattern: '{track}. {title}');
      expect(result, isEmpty);
    });

    test('formatFilename pads track number with zero', () {
      final tag = Tag(trackNumber: 3, title: 'Track', pictures: []);
      final result = Haudiotagger.formatFilename(tag, pattern: '{track}');
      expect(result, '03');
    });

    test('formatFilename cleans up trailing dots', () {
      final tag = Tag(title: 'Song', pictures: []);
      final result = Haudiotagger.formatFilename(tag, pattern: '{title}.');
      expect(result, 'Song');
    });

    test('formatFilename cleans up multiple spaces', () {
      final tag = Tag(title: 'Song', pictures: []);
      final result =
          Haudiotagger.formatFilename(tag, pattern: '{title}  {title}');
      expect(result, 'Song Song');
    });

    test('rename updates file path', () async {
      // This test requires a real file, so it's skipped by default
      // Uncomment to test with actual files:
      /*
      final tempDir = Directory.systemTemp.createTempSync('rename_test');
      final srcFile = File('${tempDir.path}/source.mp3');
      srcFile.writeAsBytesSync(mp3Bytes);

      final newPath = await Haudiotagger.rename(
        srcFile.path,
        pattern: '{track}. {title}',
      );

      expect(newPath, contains('01. My Song.mp3'));
      expect(File(newPath).existsSync(), true);
      expect(srcFile.existsSync(), false);

      tempDir.deleteSync(recursive: true);
      */
    });
  });

  // ============================================================
  // TAG PIPELINE
  // ============================================================

  group('TagPipeline', () {
    test('trimWhitespace trims all string fields', () async {
      final tag = Tag(
        title: '  Hello  ',
        trackArtist: '  Artist  ',
        album: '  Album  ',
        pictures: [],
      );

      final pipeline = TagPipeline()..trimWhitespace();
      final result = await pipeline.apply(tag);

      expect(result.title, 'Hello');
      expect(result.trackArtist, 'Artist');
      expect(result.album, 'Album');
    });

    test('setAlbumArtist sets album artist', () async {
      final tag = Tag(pictures: []);
      final pipeline = TagPipeline()..setAlbumArtist('Various Artists');
      final result = await pipeline.apply(tag);

      expect(result.albumArtist, 'Various Artists');
    });

    test('setGenre sets genre', () async {
      final tag = Tag(pictures: []);
      final pipeline = TagPipeline()..setGenre('Rock');
      final result = await pipeline.apply(tag);

      expect(result.genre, 'Rock');
    });

    test('removeLyrics clears lyrics', () async {
      final tag = Tag(lyrics: 'Some lyrics', pictures: []);
      final pipeline = TagPipeline()..removeLyrics();
      final result = await pipeline.apply(tag);

      expect(result.lyrics, isNull);
    });

    test('removeComment clears comment', () async {
      final tag = Tag(comment: 'Some comment', pictures: []);
      final pipeline = TagPipeline()..removeComment();
      final result = await pipeline.apply(tag);

      expect(result.comment, isNull);
    });

    test('removePictures clears pictures', () async {
      final pic = Picture(
        pictureType: PictureType.coverFront,
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      final tag = Tag(pictures: [pic]);
      final pipeline = TagPipeline()..removePictures();
      final result = await pipeline.apply(tag);

      expect(result.pictures, isEmpty);
    });

    test('chaining multiple rules', () async {
      final tag = Tag(
        title: '  Hello  ',
        genre: 'Pop',
        lyrics: 'Some lyrics',
        pictures: [],
      );

      final pipeline = TagPipeline()
        ..trimWhitespace()
        ..setGenre('Rock')
        ..removeLyrics();
      final result = await pipeline.apply(tag);

      expect(result.title, 'Hello');
      expect(result.genre, 'Rock');
      expect(result.lyrics, isNull);
    });

    test('pipeline tracks rules', () {
      final pipeline = TagPipeline()
        ..trimWhitespace()
        ..setGenre('Rock');

      expect(pipeline.length, 2);
      expect(pipeline.isEmpty, false);
    });

    test('empty pipeline returns original tag', () async {
      final tag = Tag(title: 'Title', pictures: []);
      final pipeline = TagPipeline();
      final result = await pipeline.apply(tag);

      expect(result.title, 'Title');
    });

    test('setTitle sets title', () async {
      final tag = Tag(pictures: []);
      final pipeline = TagPipeline()..setTitle('New Title');
      final result = await pipeline.apply(tag);
      expect(result.title, 'New Title');
    });

    test('setArtist sets artist', () async {
      final tag = Tag(pictures: []);
      final pipeline = TagPipeline()..setArtist('New Artist');
      final result = await pipeline.apply(tag);
      expect(result.trackArtist, 'New Artist');
    });

    test('setAlbum sets album', () async {
      final tag = Tag(pictures: []);
      final pipeline = TagPipeline()..setAlbum('New Album');
      final result = await pipeline.apply(tag);
      expect(result.album, 'New Album');
    });

    test('setYear sets year', () async {
      final tag = Tag(pictures: []);
      final pipeline = TagPipeline()..setYear(2025);
      final result = await pipeline.apply(tag);
      expect(result.year, 2025);
    });

    test('setTrackNumber sets track number', () async {
      final tag = Tag(pictures: []);
      final pipeline = TagPipeline()..setTrackNumber(5);
      final result = await pipeline.apply(tag);
      expect(result.trackNumber, 5);
    });

    test('setDiscNumber sets disc number', () async {
      final tag = Tag(pictures: []);
      final pipeline = TagPipeline()..setDiscNumber(2);
      final result = await pipeline.apply(tag);
      expect(result.discNumber, 2);
    });

    test('setBpm sets bpm', () async {
      final tag = Tag(pictures: []);
      final pipeline = TagPipeline()..setBpm(120.0);
      final result = await pipeline.apply(tag);
      expect(result.bpm, 120.0);
    });

    test('setComment sets comment', () async {
      final tag = Tag(pictures: []);
      final pipeline = TagPipeline()..setComment('My comment');
      final result = await pipeline.apply(tag);
      expect(result.comment, 'My comment');
    });

    test('removeTitle removes title', () async {
      final tag = Tag(title: 'Title', pictures: []);
      final pipeline = TagPipeline()..removeTitle();
      final result = await pipeline.apply(tag);
      expect(result.title, isNull);
    });

    test('removeArtist removes artist', () async {
      final tag = Tag(trackArtist: 'Artist', pictures: []);
      final pipeline = TagPipeline()..removeArtist();
      final result = await pipeline.apply(tag);
      expect(result.trackArtist, isNull);
    });

    test('removeAlbum removes album', () async {
      final tag = Tag(album: 'Album', pictures: []);
      final pipeline = TagPipeline()..removeAlbum();
      final result = await pipeline.apply(tag);
      expect(result.album, isNull);
    });

    test('removeBpm removes bpm', () async {
      final tag = Tag(bpm: 120.0, pictures: []);
      final pipeline = TagPipeline()..removeBpm();
      final result = await pipeline.apply(tag);
      expect(result.bpm, isNull);
    });

    test('removeYear removes year', () async {
      final tag = Tag(year: 2025, pictures: []);
      final pipeline = TagPipeline()..removeYear();
      final result = await pipeline.apply(tag);
      expect(result.year, isNull);
    });

    test('removeGenre removes genre', () async {
      final tag = Tag(genre: 'Rock', pictures: []);
      final pipeline = TagPipeline()..removeGenre();
      final result = await pipeline.apply(tag);
      expect(result.genre, isNull);
    });

    test('prefixTitle adds prefix', () async {
      final tag = Tag(title: 'Song', pictures: []);
      final pipeline = TagPipeline()..prefixTitle('prefix_');
      final result = await pipeline.apply(tag);
      expect(result.title, 'prefix_Song');
    });

    test('suffixTitle adds suffix', () async {
      final tag = Tag(title: 'Song', pictures: []);
      final pipeline = TagPipeline()..suffixTitle('_suffix');
      final result = await pipeline.apply(tag);
      expect(result.title, 'Song_suffix');
    });

    test('prefixAlbum adds prefix', () async {
      final tag = Tag(album: 'Album', pictures: []);
      final pipeline = TagPipeline()..prefixAlbum('prefix_');
      final result = await pipeline.apply(tag);
      expect(result.album, 'prefix_Album');
    });

    test('suffixAlbum adds suffix', () async {
      final tag = Tag(album: 'Album', pictures: []);
      final pipeline = TagPipeline()..suffixAlbum('_suffix');
      final result = await pipeline.apply(tag);
      expect(result.album, 'Album_suffix');
    });

    test('prefixArtist adds prefix', () async {
      final tag = Tag(trackArtist: 'Artist', pictures: []);
      final pipeline = TagPipeline()..prefixArtist('prefix_');
      final result = await pipeline.apply(tag);
      expect(result.trackArtist, 'prefix_Artist');
    });

    test('suffixArtist adds suffix', () async {
      final tag = Tag(trackArtist: 'Artist', pictures: []);
      final pipeline = TagPipeline()..suffixArtist('_suffix');
      final result = await pipeline.apply(tag);
      expect(result.trackArtist, 'Artist_suffix');
    });

    test('titleCaseTitle converts to title case', () async {
      final tag = Tag(title: 'hello world', pictures: []);
      final pipeline = TagPipeline()..titleCaseTitle();
      final result = await pipeline.apply(tag);
      expect(result.title, 'Hello World');
    });

    test('titleCaseArtist converts to title case', () async {
      final tag = Tag(trackArtist: 'hello world', pictures: []);
      final pipeline = TagPipeline()..titleCaseArtist();
      final result = await pipeline.apply(tag);
      expect(result.trackArtist, 'Hello World');
    });

    test('titleCaseAlbum converts to title case', () async {
      final tag = Tag(album: 'hello world', pictures: []);
      final pipeline = TagPipeline()..titleCaseAlbum();
      final result = await pipeline.apply(tag);
      expect(result.album, 'Hello World');
    });

    test('lowerCaseAll converts to lowercase', () async {
      final tag = Tag(title: 'TITLE', trackArtist: 'ARTIST', pictures: []);
      final pipeline = TagPipeline()..lowerCaseAll();
      final result = await pipeline.apply(tag);
      expect(result.title, 'title');
      expect(result.trackArtist, 'artist');
    });

    test('upperCaseAll converts to uppercase', () async {
      final tag = Tag(title: 'title', trackArtist: 'artist', pictures: []);
      final pipeline = TagPipeline()..upperCaseAll();
      final result = await pipeline.apply(tag);
      expect(result.title, 'TITLE');
      expect(result.trackArtist, 'ARTIST');
    });

    test('replaceInTitle replaces text', () async {
      final tag = Tag(title: 'Hello World', pictures: []);
      final pipeline = TagPipeline()..replaceInTitle('World', 'Dart');
      final result = await pipeline.apply(tag);
      expect(result.title, 'Hello Dart');
    });

    test('replaceInArtist replaces text', () async {
      final tag = Tag(trackArtist: 'Hello World', pictures: []);
      final pipeline = TagPipeline()..replaceInArtist('World', 'Dart');
      final result = await pipeline.apply(tag);
      expect(result.trackArtist, 'Hello Dart');
    });

    test('replaceInAlbum replaces text', () async {
      final tag = Tag(album: 'Hello World', pictures: []);
      final pipeline = TagPipeline()..replaceInAlbum('World', 'Dart');
      final result = await pipeline.apply(tag);
      expect(result.album, 'Hello Dart');
    });

    test('replaceInAll replaces in all fields', () async {
      final tag = Tag(
        title: 'Hello World',
        trackArtist: 'Hello World',
        album: 'Hello World',
        pictures: [],
      );
      final pipeline = TagPipeline()..replaceInAll('World', 'Dart');
      final result = await pipeline.apply(tag);
      expect(result.title, 'Hello Dart');
      expect(result.trackArtist, 'Hello Dart');
      expect(result.album, 'Hello Dart');
    });

    test('setTitleIfEmpty only sets if empty', () async {
      final tag1 = Tag(pictures: []);
      final tag2 = Tag(title: 'Existing', pictures: []);
      final pipeline = TagPipeline()..setTitleIfEmpty('Default Title');
      final result1 = await pipeline.apply(tag1);
      final result2 = await pipeline.apply(tag2);
      expect(result1.title, 'Default Title');
      expect(result2.title, 'Existing');
    });

    test('setArtistIfEmpty only sets if empty', () async {
      final tag1 = Tag(pictures: []);
      final tag2 = Tag(trackArtist: 'Existing', pictures: []);
      final pipeline = TagPipeline()..setArtistIfEmpty('Default Artist');
      final result1 = await pipeline.apply(tag1);
      final result2 = await pipeline.apply(tag2);
      expect(result1.trackArtist, 'Default Artist');
      expect(result2.trackArtist, 'Existing');
    });

    test('removeEmptyFields removes empty fields', () async {
      final tag = Tag(
        title: '',
        trackArtist: '  ',
        album: null,
        genre: '',
        pictures: [],
      );
      final pipeline = TagPipeline()..removeEmptyFields();
      final result = await pipeline.apply(tag);
      expect(result.title, isNull);
      expect(result.trackArtist, isNull);
      expect(result.album, isNull);
      expect(result.genre, isNull);
    });

    test('removeNonCoverPictures removes non-cover pictures', () async {
      final pic1 = Picture(
        pictureType: PictureType.coverFront,
        bytes: Uint8List.fromList([1]),
      );
      final pic2 = Picture(
        pictureType: PictureType.artist,
        bytes: Uint8List.fromList([2]),
      );
      final tag = Tag(pictures: [pic1, pic2]);
      final pipeline = TagPipeline()..removeNonCoverPictures();
      final result = await pipeline.apply(tag);
      expect(result.pictures.length, 1);
      expect(result.pictures.first.pictureType, PictureType.coverFront);
    });

    test('copyArtistToAlbumArtist copies if empty', () async {
      final tag1 = Tag(trackArtist: 'Artist', pictures: []);
      final tag2 = Tag(
        trackArtist: 'Artist',
        albumArtist: 'Existing',
        pictures: [],
      );
      final pipeline = TagPipeline()..copyArtistToAlbumArtist();
      final result1 = await pipeline.apply(tag1);
      final result2 = await pipeline.apply(tag2);
      expect(result1.albumArtist, 'Artist');
      expect(result2.albumArtist, 'Existing');
    });

    test('removeReplayGain removes all RG fields', () async {
      final tag = Tag(
        replayGainTrackGain: '-6.43',
        replayGainTrackPeak: '0.98',
        replayGainAlbumGain: '-7.00',
        replayGainAlbumPeak: '0.95',
        pictures: [],
      );
      final pipeline = TagPipeline()..removeReplayGain();
      final result = await pipeline.apply(tag);
      expect(result.replayGainTrackGain, isNull);
      expect(result.replayGainTrackPeak, isNull);
      expect(result.replayGainAlbumGain, isNull);
      expect(result.replayGainAlbumPeak, isNull);
    });

    test('normalizeYear normalizes 2-digit year', () async {
      final tag1 = Tag(year: 95, pictures: []);
      final tag2 = Tag(year: 25, pictures: []);
      final tag3 = Tag(year: 1995, pictures: []);
      final pipeline = TagPipeline()..normalizeYear();
      final result1 = await pipeline.apply(tag1);
      final result2 = await pipeline.apply(tag2);
      final result3 = await pipeline.apply(tag3);
      expect(result1.year, 1995);
      expect(result2.year, 2025);
      expect(result3.year, 1995);
    });
  });

  // ============================================================
  // CHAPTERS
  // ============================================================

  group('chapters', () {
    test('getChaptersFromBytes returns empty for no chapters', () async {
      final chapters = await Haudiotagger.getChaptersFromBytes(mp3Bytes);
      expect(chapters, isEmpty);
    });

    test('setChaptersFromBytes writes chapters that read back', () async {
      final chapters = [
        Chapter(
          title: 'Introduction',
          startMs: BigInt.from(0),
          endMs: BigInt.from(42000),
        ),
        Chapter(
          title: 'Main Content',
          startMs: BigInt.from(42000),
          endMs: BigInt.from(180000),
        ),
        Chapter(
          title: 'Conclusion',
          startMs: BigInt.from(180000),
          endMs: BigInt.from(240000),
        ),
      ];

      final written =
          await Haudiotagger.setChaptersFromBytes(mp3Bytes, chapters);
      final readBack = await Haudiotagger.getChaptersFromBytes(written);

      expect(readBack.length, 3);
      expect(readBack[0].title, 'Introduction');
      expect(readBack[0].startMs, BigInt.from(0));
      expect(readBack[0].endMs, BigInt.from(42000));
      expect(readBack[1].title, 'Main Content');
      expect(readBack[1].startMs, BigInt.from(42000));
      expect(readBack[1].endMs, BigInt.from(180000));
      expect(readBack[2].title, 'Conclusion');
      expect(readBack[2].startMs, BigInt.from(180000));
      expect(readBack[2].endMs, BigInt.from(240000));
    });

    test('setChaptersFromBytes replaces existing chapters', () async {
      final chapters1 = [
        Chapter(
          title: 'Chapter 1',
          startMs: BigInt.from(0),
          endMs: BigInt.from(60000),
        ),
      ];

      final written1 =
          await Haudiotagger.setChaptersFromBytes(mp3Bytes, chapters1);
      final read1 = await Haudiotagger.getChaptersFromBytes(written1);
      expect(read1.length, 1);
      expect(read1[0].title, 'Chapter 1');

      final chapters2 = [
        Chapter(
          title: 'New Chapter A',
          startMs: BigInt.from(0),
          endMs: BigInt.from(30000),
        ),
        Chapter(
          title: 'New Chapter B',
          startMs: BigInt.from(30000),
          endMs: BigInt.from(90000),
        ),
      ];

      final written2 =
          await Haudiotagger.setChaptersFromBytes(written1, chapters2);
      final read2 = await Haudiotagger.getChaptersFromBytes(written2);
      expect(read2.length, 2);
      expect(read2[0].title, 'New Chapter A');
      expect(read2[1].title, 'New Chapter B');
    });

    test('setChaptersFromBytes with empty chapters removes all', () async {
      final chapters = [
        Chapter(
          title: 'To Remove',
          startMs: BigInt.from(0),
          endMs: BigInt.from(60000),
        ),
      ];

      final written =
          await Haudiotagger.setChaptersFromBytes(mp3Bytes, chapters);
      final cleared = await Haudiotagger.setChaptersFromBytes(written, []);
      final readBack = await Haudiotagger.getChaptersFromBytes(cleared);
      expect(readBack, isEmpty);
    });

    test('chapters round-trip preserves metadata', () async {
      final tag = Tag(
        title: 'Chapter Test',
        trackArtist: 'Test Artist',
        album: 'Test Album',
        pictures: [],
      );

      var bytes = await Haudiotagger.writeToBytes(mp3Bytes, tag);
      final chapters = [
        Chapter(
          title: 'Intro',
          startMs: BigInt.from(0),
          endMs: BigInt.from(10000),
        ),
      ];

      bytes = await Haudiotagger.setChaptersFromBytes(bytes, chapters);
      final readTag = await Haudiotagger.readFromBytes(bytes);
      final readChapters = await Haudiotagger.getChaptersFromBytes(bytes);

      expect(readTag!.title, 'Chapter Test');
      expect(readTag.trackArtist, 'Test Artist');
      expect(readChapters.length, 1);
      expect(readChapters[0].title, 'Intro');
    });
  });

  // ============================================================
  // EXTENDED METADATA
  // ============================================================

  group('extended metadata', () {
    test(
        'getExtendedFromBytes returns empty default tag for no extended fields',
        () async {
      final ext = await Haudiotagger.getExtendedFromBytes(mp3Bytes);
      expect(ext.isrc, isNull);
      expect(ext.mood, isNull);
      expect(ext.catalogNumber, isNull);
      expect(ext.barcode, isNull);
    });

    test('setExtendedFromBytes writes fields that read back', () async {
      final data = ExtendedTag(
        isrc: 'US-S1Z-99-00001',
        mood: 'upbeat',
        catalogNumber: 'CAT-12345',
        barcode: '1234567890',
      );

      final written = await Haudiotagger.setExtendedFromBytes(mp3Bytes, data);
      final readBack = await Haudiotagger.getExtendedFromBytes(written);

      expect(readBack.isrc, 'US-S1Z-99-00001');
      expect(readBack.mood, 'upbeat');
      expect(readBack.catalogNumber, 'CAT-12345');
      expect(readBack.barcode, '1234567890');
    });

    test('setExtendedFromBytes replaces existing extended fields', () async {
      // Write initial extended tag
      final initial = ExtendedTag(
        isrc: 'ORIGINAL-ISRC',
        catalogNumber: 'CAT-000',
      );
      var bytes = await Haudiotagger.setExtendedFromBytes(mp3Bytes, initial);

      // Replace with new extended tag (only isrc, catalogNumber should be gone)
      final replacement = ExtendedTag(
        isrc: 'NEW-ISRC',
      );
      bytes = await Haudiotagger.setExtendedFromBytes(bytes, replacement);
      final readBack = await Haudiotagger.getExtendedFromBytes(bytes);

      expect(readBack.isrc, 'NEW-ISRC');
      expect(readBack.catalogNumber, isNull);
    });

    test('updateExtendedFromBytes merges correctly', () async {
      // Write initial extended tag with catalogNumber
      final initial = ExtendedTag(
        isrc: 'ORIGINAL-ISRC',
        catalogNumber: 'CAT-000',
      );
      var bytes = await Haudiotagger.setExtendedFromBytes(mp3Bytes, initial);

      // Update only isrc, catalogNumber should be preserved
      final changes = ExtendedChanges(
        isrc: 'UPDATED-ISRC',
      );
      bytes = await Haudiotagger.updateExtendedFromBytes(bytes, changes);
      final readBack = await Haudiotagger.getExtendedFromBytes(bytes);

      expect(readBack.isrc, 'UPDATED-ISRC');
      expect(readBack.catalogNumber, 'CAT-000');
    });

    test('removeExtendedFromBytes clears all extended fields', () async {
      // Write extended fields
      final data = ExtendedTag(
        isrc: 'something',
        mood: 'happy',
        catalogNumber: 'CAT-999',
      );
      var bytes = await Haudiotagger.setExtendedFromBytes(mp3Bytes, data);

      // Remove all extended fields
      bytes = await Haudiotagger.removeExtendedFromBytes(bytes);
      final readBack = await Haudiotagger.getExtendedFromBytes(bytes);

      expect(readBack.isrc, isNull);
      expect(readBack.mood, isNull);
      expect(readBack.catalogNumber, isNull);
    });

    test('extended tag roundtrip preserves standard tag', () async {
      // Write standard tag first
      final tag = Tag(
        title: 'Extended Test',
        trackArtist: 'Test Artist',
        pictures: [],
      );
      var bytes = await Haudiotagger.writeToBytes(mp3Bytes, tag);

      // Write extended fields
      final ext = ExtendedTag(
        isrc: 'US-XX-00-00001',
        mood: 'chill',
      );
      bytes = await Haudiotagger.setExtendedFromBytes(bytes, ext);

      // Both standard and extended tags should be readable
      final readTag = await Haudiotagger.readFromBytes(bytes);
      final readExt = await Haudiotagger.getExtendedFromBytes(bytes);

      expect(readTag!.title, 'Extended Test');
      expect(readTag.trackArtist, 'Test Artist');
      expect(readExt.isrc, 'US-XX-00-00001');
      expect(readExt.mood, 'chill');
    });

    test('file-based extended read/write roundtrip', () async {
      final tempDir = Directory.systemTemp.createTempSync('ext_test');
      final filePath = '${tempDir.path}/test.mp3';
      File(filePath).writeAsBytesSync(mp3Bytes);

      try {
        // Write extended fields
        final data = ExtendedTag(
          isrc: 'US-FILE-TEST',
          mood: 'energetic',
        );
        await Haudiotagger.setExtended(filePath, data);

        // Read back
        final readBack = await Haudiotagger.getExtended(filePath);
        expect(readBack.isrc, 'US-FILE-TEST');
        expect(readBack.mood, 'energetic');

        // Update only mood, isrc should persist
        final changes = ExtendedChanges(mood: 'calm');
        await Haudiotagger.updateExtended(filePath, changes);

        final afterUpdate = await Haudiotagger.getExtended(filePath);
        expect(afterUpdate.isrc, 'US-FILE-TEST');
        expect(afterUpdate.mood, 'calm');

        // Remove all extended
        await Haudiotagger.removeExtended(filePath);
        final afterRemove = await Haudiotagger.getExtended(filePath);
        expect(afterRemove.isrc, isNull);
        expect(afterRemove.mood, isNull);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });

  // ============================================================
  // FILE-BASED API (requires native lib)
  // ============================================================

  group('file-based read / write', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('haudiotagger_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('read returns tag from file', () async {
      final filePath = '${tempDir.path}/test.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      final tag = await Haudiotagger.read(filePath);
      expect(tag, isNotNull);
      expect(tag!.title, 'Original Title');
    });

    test('write creates tag on file', () async {
      final filePath = '${tempDir.path}/write.mp3';
      final mp3Header = mp3Bytes.sublist(0, 1024);
      await File(filePath).writeAsBytes(mp3Header);
      final tag = Tag(
        title: 'Written Title',
        trackArtist: 'Written Artist',
        album: 'Written Album',
        year: 2025,
        pictures: [],
      );
      await Haudiotagger.write(filePath, tag);
      final readBack = await Haudiotagger.read(filePath);
      expect(readBack, isNotNull);
      expect(readBack!.title, 'Written Title');
    });

    test('readProperties returns audio properties from file', () async {
      final filePath = '${tempDir.path}/props.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      final props = await Haudiotagger.readProperties(filePath);
      expect(props.durationMicros, isNotNull);
    });

    test('update applies changes to file', () async {
      final filePath = '${tempDir.path}/update.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      final changes = TagChanges(title: 'Updated Title');
      await Haudiotagger.update(filePath, changes);
      final tag = await Haudiotagger.read(filePath);
      expect(tag!.title, 'Updated Title');
      expect(tag.trackArtist, 'Original Artist');
    });

    test('remove clears specific fields from file', () async {
      final filePath = '${tempDir.path}/remove.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      await Haudiotagger.remove(filePath, [TagField.title]);
      final tag = await Haudiotagger.read(filePath);
      expect(tag!.title, isNull);
      expect(tag.trackArtist, 'Original Artist');
    });

    test('clear removes all metadata from file', () async {
      final filePath = '${tempDir.path}/clear.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      await Haudiotagger.clear(filePath);
      final tag = await Haudiotagger.read(filePath);
      expect(tag, isNull);
    });

    test('getTagFormats returns formats from file', () async {
      final filePath = '${tempDir.path}/formats.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      final formats = await Haudiotagger.getTagFormats(filePath);
      expect(formats, isNotEmpty);
    });

    test('getCustomTags and setCustomTag work on file', () async {
      final filePath = '${tempDir.path}/custom.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      await Haudiotagger.setCustomTag(filePath, 'MY_FIELD', 'my_value');
      final tags = await Haudiotagger.getCustomTags(filePath);
      expect(tags['MY_FIELD'], 'my_value');
    });

    test('removeCustomTag removes from file', () async {
      final filePath = '${tempDir.path}/rmcustom.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      await Haudiotagger.setCustomTag(filePath, 'MY_FIELD', 'my_value');
      await Haudiotagger.removeCustomTag(filePath, 'MY_FIELD');
      final tags = await Haudiotagger.getCustomTags(filePath);
      expect(tags.containsKey('MY_FIELD'), false);
    });

    test('getId3v2Version returns version from file', () async {
      final filePath = '${tempDir.path}/version.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      final version = await Haudiotagger.getId3v2Version(filePath);
      expect(version, isNotNull);
    });

    test('removeId3v1 removes ID3v1 from file', () async {
      final filePath = '${tempDir.path}/rmv1.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      await Haudiotagger.removeId3v1(filePath);
      final formats = await Haudiotagger.getTagFormats(filePath);
      expect(formats.any((f) => f.toLowerCase().contains('id3v1')), false);
    });

    test('inspect returns file info', () async {
      final filePath = '${tempDir.path}/inspect.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      final info = await Haudiotagger.inspect(filePath);
      expect(info, isNotNull);
    });

    test('validate returns validation result for file', () async {
      final filePath = '${tempDir.path}/validate.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      final result = await Haudiotagger.validate(filePath);
      expect(result, isNotNull);
    });

    test('normalize returns normalized tag from file', () async {
      final filePath = '${tempDir.path}/normalize.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      final tag = await Haudiotagger.normalize(filePath);
      expect(tag, isNotNull);
    });

    test('normalizeBytes returns normalized bytes', () async {
      final normalized = await Haudiotagger.normalizeBytes(mp3Bytes);
      expect(normalized, isNotEmpty);
    });

    test('copyMetadata copies between files', () async {
      final src = '${tempDir.path}/src.mp3';
      final dst = '${tempDir.path}/dst.mp3';
      await File(src).writeAsBytes(mp3Bytes);
      final mp3Header = mp3Bytes.sublist(0, 1024);
      await File(dst).writeAsBytes(mp3Header);
      await Haudiotagger.copyMetadata(src, dst);
      final tag = await Haudiotagger.read(dst);
      expect(tag, isNotNull);
      expect(tag!.title, 'Original Title');
    });

    test('rename renames file based on pattern', () async {
      final filePath = '${tempDir.path}/rename_me.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      final newPath = await Haudiotagger.rename(
        filePath,
        pattern: '{title}',
      );
      expect(File(newPath).existsSync(), true);
    });

    test('getChapters reads chapters from file', () async {
      final filePath = '${tempDir.path}/chapters.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      final chapters = await Haudiotagger.getChapters(filePath);
      expect(chapters, isA<List<Chapter>>());
    });

    test('setChapters writes chapters to file', () async {
      final filePath = '${tempDir.path}/setchapters.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      final chapters = [
        Chapter(title: 'Intro', startMs: BigInt.from(0), endMs: BigInt.from(30000)),
        Chapter(title: 'Main', startMs: BigInt.from(30000), endMs: BigInt.from(120000)),
      ];
      await Haudiotagger.setChapters(filePath, chapters);
      final readBack = await Haudiotagger.getChapters(filePath);
      expect(readBack.length, 2);
      expect(readBack[0].title, 'Intro');
    });

    test('getExtended reads extended metadata from file', () async {
      final filePath = '${tempDir.path}/extread.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      final ext = await Haudiotagger.getExtended(filePath);
      expect(ext, isA<ExtendedTag>());
    });

    test('setExtended writes extended metadata to file', () async {
      final filePath = '${tempDir.path}/extset.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      await Haudiotagger.setExtended(filePath, ExtendedTag(mood: 'happy'));
      final ext = await Haudiotagger.getExtended(filePath);
      expect(ext.mood, 'happy');
    });

    test('updateExtended updates extended metadata on file', () async {
      final filePath = '${tempDir.path}/extupd.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      await Haudiotagger.setExtended(filePath, ExtendedTag(
        mood: 'happy',
        isrc: 'US-TEST',
      ));
      await Haudiotagger.updateExtended(filePath, ExtendedChanges(mood: 'sad'));
      final ext = await Haudiotagger.getExtended(filePath);
      expect(ext.mood, 'sad');
      expect(ext.isrc, 'US-TEST');
    });

    test('removeExtended clears extended metadata from file', () async {
      final filePath = '${tempDir.path}/extrm.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      await Haudiotagger.setExtended(filePath, ExtendedTag(mood: 'happy'));
      await Haudiotagger.removeExtended(filePath);
      final ext = await Haudiotagger.getExtended(filePath);
      expect(ext.mood, isNull);
    });

    test('batchWrite writes to multiple files', () async {
      final paths = <String>[];
      for (var i = 0; i < 3; i++) {
        final p = '${tempDir.path}/batch_$i.mp3';
        await File(p).writeAsBytes(mp3Bytes);
        paths.add(p);
      }
      final tag = Tag(title: 'Batch', trackArtist: 'Test', pictures: []);
      final result = await Haudiotagger.batchWrite(paths, tag);
      expect(result.successes, 3);
      expect(result.failures, 0);
    });

    test('batchUpdateChanges applies changes to multiple files', () async {
      final paths = <String>[];
      for (var i = 0; i < 3; i++) {
        final p = '${tempDir.path}/batchupd_$i.mp3';
        await File(p).writeAsBytes(mp3Bytes);
        paths.add(p);
      }
      final changes = TagChanges(title: 'Batch Updated');
      final result = await Haudiotagger.batchUpdateChanges(paths, changes);
      expect(result.successes, 3);
    });

    test('batchUpdate uses callback for multiple files', () async {
      final paths = <String>[];
      for (var i = 0; i < 3; i++) {
        final p = '${tempDir.path}/batchcb_$i.mp3';
        await File(p).writeAsBytes(mp3Bytes);
        paths.add(p);
      }
      final result = await Haudiotagger.batchUpdate(
        paths,
        (path, current) => current.copyWith(title: 'Updated'),
      );
      expect(result.successes, 3);
    });

    test('getId3v2VersionFromBytes returns version', () async {
      final version = await Haudiotagger.getId3v2VersionFromBytes(mp3Bytes);
      expect(version, isNotNull);
    });

    test('removeId3v1FromBytes removes ID3v1', () async {
      final result = await Haudiotagger.removeId3v1FromBytes(mp3Bytes);
      expect(result, isNotEmpty);
    });

    test('convertId3v2FromBytes converts version', () async {
      final result = await Haudiotagger.convertId3v2FromBytes(
        mp3Bytes,
        Id3v2Version.v3,
      );
      expect(result, isNotEmpty);
    });

    test('readPropertiesFromBytes returns properties', () async {
      final props = await Haudiotagger.readPropertiesFromBytes(mp3Bytes);
      expect(props.durationMicros, isNotNull);
    });

    test('convertId3v2 converts file', () async {
      final filePath = '${tempDir.path}/convert.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      await Haudiotagger.convertId3v2(filePath, Id3v2Version.v4);
      final version = await Haudiotagger.getId3v2Version(filePath);
      expect(version, isNotNull);
    });

    test('validate file returns validation result', () async {
      final filePath = '${tempDir.path}/validate_file.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      final result = await Haudiotagger.validate(filePath);
      expect(result, isNotNull);
    });

    test('validateFromBytes returns validation result', () async {
      final result = await Haudiotagger.validateFromBytes(mp3Bytes);
      expect(result, isNotNull);
    });

    test('batchUpdate error handling', () async {
      final result = await Haudiotagger.batchUpdate(
        ['/nonexistent/path.mp3'],
        (path, current) => current.copyWith(title: 'X'),
      );
      expect(result.failures, 1);
      expect(result.errors, isNotEmpty);
    });

    test('batchUpdate generic exception handling', () async {
      final filePath = '${tempDir.path}/batcherr.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      final result = await Haudiotagger.batchUpdate(
        [filePath],
        (path, current) => throw Exception('generic error'),
      );
      expect(result.failures, 1);
    });

    test('batchUpdate with onProgress callback', () async {
      final filePath = '${tempDir.path}/batchprog.mp3';
      await File(filePath).writeAsBytes(mp3Bytes);
      final progresses = <BatchProgress>[];
      await Haudiotagger.batchUpdate(
        [filePath],
        (path, current) => current.copyWith(title: 'Progress'),
        onProgress: (p) => progresses.add(p),
      );
      expect(progresses.length, 1);
      expect(progresses.first.completed, 1);
    });

    test('batchUpdateFromBytes error handling', () async {
      final badBytes = [Uint8List(0)];
      final result = await Haudiotagger.batchUpdateFromBytes(
        badBytes,
        (index, current) => current.copyWith(title: 'X'),
      );
      expect(result.failures, 1);
    });

    test('batchUpdateFromBytes generic exception handling', () async {
      final result = await Haudiotagger.batchUpdateFromBytes(
        [mp3Bytes],
        (index, current) => throw Exception('generic error'),
      );
      expect(result.failures, 1);
    });

    test('batchUpdateFromBytes with onProgress callback', () async {
      final progresses = <BatchProgress>[];
      await Haudiotagger.batchUpdateFromBytes(
        [mp3Bytes],
        (index, current) => current.copyWith(title: 'Progress'),
        onProgress: (p) => progresses.add(p),
      );
      expect(progresses.length, 1);
    });
  });

  // ============================================================
  // AUDIO PROPERTIES / HELPERS
  // ============================================================

  group('helpers', () {
    test('AudioPropertiesX duration returns Duration', () async {
      final props = await Haudiotagger.readPropertiesFromBytes(mp3Bytes);
      final duration = props.duration;
      if (duration != null) {
        expect(duration, isA<Duration>());
        expect(duration.inMilliseconds, greaterThanOrEqualTo(0));
      }
    });

    test('BatchProgress percent works', () {
      final progress = BatchProgress(completed: 50, total: 100);
      expect(progress.percent, 0.5);
    });

    test('BatchProgress percent handles zero total', () {
      final progress = BatchProgress(completed: 0, total: 0);
      expect(progress.percent, 0.0);
    });

    test('MetadataDiff toString works', () {
      final tag = Tag(title: 'A', pictures: []);
      final diff = Haudiotagger.diff(tag, Tag(title: 'B', pictures: []));
      expect(diff.toString(), contains('change'));
    });

    test('MetadataDiff length works', () {
      final tag = Tag(title: 'A', pictures: []);
      final diff = Haudiotagger.diff(tag, Tag(title: 'B', pictures: []));
      expect(diff.length, diff.changes.length);
    });

    test('MetadataChange toString works', () {
      final change = MetadataChange(
        field: TagField.title,
        oldValue: 'Old',
        newValue: 'New',
        type: ChangeType.updated,
      );
      expect(change.toString(), contains('title'));
    });

    test('TagChanges copyWith with no args preserves all', () {
      final original = TagChanges(
        title: 'Title',
        trackArtist: 'Artist',
        year: 2025,
        bpm: 120.0,
      );
      final copy = original.copyWith();
      expect(copy.title, 'Title');
      expect(copy.trackArtist, 'Artist');
      expect(copy.year, 2025);
      expect(copy.bpm, 120.0);
    });

    test('Picture copyWith with no args preserves all', () {
      final original = Picture(
        pictureType: PictureType.coverFront,
        mimeType: MimeType.jpeg,
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      final copy = original.copyWith();
      expect(copy.pictureType, PictureType.coverFront);
      expect(copy.mimeType, MimeType.jpeg);
      expect(copy.bytes, [1, 2, 3]);
    });
  });

  // ============================================================
  // readField / readFieldFromBytes
  // ============================================================

  group('readField / readFieldFromBytes', () {
    test('readFieldFromBytes returns correct title', () async {
      final result = await Haudiotagger.readFieldFromBytes(
        mp3Bytes,
        TagField.title,
      );
      expect(result, 'Original Title');
    });

    test('readFieldFromBytes returns correct artist', () async {
      final result = await Haudiotagger.readFieldFromBytes(
        mp3Bytes,
        TagField.artist,
      );
      expect(result, 'Original Artist');
    });

    test('readFieldFromBytes returns correct album', () async {
      final result = await Haudiotagger.readFieldFromBytes(
        mp3Bytes,
        TagField.album,
      );
      expect(result, 'Original Album');
    });

    test('readFieldFromBytes returns null for missing field', () async {
      final result = await Haudiotagger.readFieldFromBytes(
        mp3Bytes,
        TagField.lyrics,
      );
      expect(result, isNull);
    });

    test('readFieldFromBytes throws on empty bytes', () async {
      expect(
        () => Haudiotagger.readFieldFromBytes(
          Uint8List(0),
          TagField.title,
        ),
        throwsA(isA<HaudiotaggerError>()),
      );
    });

    test('readField on file returns same value as read', () async {
      final dir = Directory.systemTemp.createTempSync('haudiotagger_rf_test_');
      final file = File('${dir.path}/test.mp3');
      file.writeAsBytesSync(mp3Bytes);

      final fullTag = await Haudiotagger.read(file.path);
      final titleFromField = await Haudiotagger.readField(
        file.path,
        TagField.title,
      );
      expect(titleFromField, fullTag!.title);

      final artistFromField = await Haudiotagger.readField(
        file.path,
        TagField.artist,
      );
      expect(artistFromField, fullTag.trackArtist);

      dir.deleteSync(recursive: true);
    });

    test('readField on file returns null for missing field', () async {
      final dir = Directory.systemTemp.createTempSync('haudiotagger_rf_test_');
      final file = File('${dir.path}/test.mp3');
      file.writeAsBytesSync(mp3Bytes);

      final result = await Haudiotagger.readField(
        file.path,
        TagField.lyrics,
      );
      expect(result, isNull);

      dir.deleteSync(recursive: true);
    });

    test('readFieldFromBytes is consistent with readFromBytes', () async {
      final tag = await Haudiotagger.readFromBytes(mp3Bytes);

      final title = await Haudiotagger.readFieldFromBytes(
        mp3Bytes,
        TagField.title,
      );
      expect(title, tag!.title);

      final artist = await Haudiotagger.readFieldFromBytes(
        mp3Bytes,
        TagField.artist,
      );
      expect(artist, tag.trackArtist);

      final album = await Haudiotagger.readFieldFromBytes(
        mp3Bytes,
        TagField.album,
      );
      expect(album, tag.album);
    });
  });

  // ============================================================
  // readPictures / readPictureByType
  // ============================================================

  group('readPictures / readPictureByType', () {
    test('readPicturesFromBytes returns list', () async {
      final pictures = await Haudiotagger.readPicturesFromBytes(mp3Bytes);
      expect(pictures, isA<List<Picture>>());
    });

    test('readPicturesFromBytes consistent with readFromBytes', () async {
      final tag = await Haudiotagger.readFromBytes(mp3Bytes);
      final pictures = await Haudiotagger.readPicturesFromBytes(mp3Bytes);
      expect(pictures.length, tag!.pictures.length);
    });

    test('readPictureByTypeFromBytes returns null when no match', () async {
      final result = await Haudiotagger.readPictureByTypeFromBytes(
        mp3Bytes,
        PictureType.coverBack,
      );
      expect(result, isNull);
    });

    test('readPictures on file returns list', () async {
      final dir = Directory.systemTemp.createTempSync('haudiotagger_pic_test_');
      final file = File('${dir.path}/test.mp3');
      file.writeAsBytesSync(mp3Bytes);

      final pictures = await Haudiotagger.readPictures(file.path);
      expect(pictures, isA<List<Picture>>());

      dir.deleteSync(recursive: true);
    });

    test('readPictureByType on file returns null when no match', () async {
      final dir = Directory.systemTemp.createTempSync('haudiotagger_pic_test_');
      final file = File('${dir.path}/test.mp3');
      file.writeAsBytesSync(mp3Bytes);

      final result = await Haudiotagger.readPictureByType(
        file.path,
        PictureType.coverBack,
      );
      expect(result, isNull);

      dir.deleteSync(recursive: true);
    });

    test('readPictureByTypeFromBytes matches type from full tag', () async {
      final tag = await Haudiotagger.readFromBytes(mp3Bytes);
      if (tag!.pictures.isNotEmpty) {
        final firstType = tag.pictures.first.pictureType;
        final result = await Haudiotagger.readPictureByTypeFromBytes(
          mp3Bytes,
          firstType,
        );
        expect(result, isNotNull);
        expect(result!.pictureType, firstType);
        expect(result.bytes, tag.pictures.first.bytes);
      }
    });
  });
}
