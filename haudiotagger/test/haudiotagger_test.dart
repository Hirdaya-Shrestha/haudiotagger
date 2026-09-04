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
}
