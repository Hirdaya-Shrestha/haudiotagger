import 'dart:typed_data';
import 'haudiotagger.dart';
import 'rust/api/api.dart' as api;
import 'rust/api/pipeline.dart' as rpc;

/// Result of previewing a pipeline transformation.
class PreviewResult {
  /// The original tag before transformation.
  final Tag original;

  /// The transformed tag after applying rules.
  final Tag transformed;

  /// The list of field changes.
  final List<FieldChange> changes;

  const PreviewResult({
    required this.original,
    required this.transformed,
    required this.changes,
  });

  /// Whether any changes were made.
  bool get hasChanges => changes.isNotEmpty;

  @override
  String toString() => 'PreviewResult(${changes.length} changes)';
}

/// A single field change between original and transformed tags.
class FieldChange {
  final String field;
  final String? oldValue;
  final String? newValue;

  const FieldChange({
    required this.field,
    this.oldValue,
    this.newValue,
  });

  @override
  String toString() => '$field: $oldValue → $newValue';
}

/// A pipeline of transformation rules to apply to audio metadata.
///
/// Example:
/// ```dart
/// final pipeline = TagPipeline()
///   ..trimWhitespace()
///   ..normalizeUnicode()
///   ..setAlbumArtist('Various Artists')
///   ..removeLyrics();
///
/// // Process multiple files
/// await pipeline.process(files);
///
/// // Preview changes on a single file
/// final result = await pipeline.preview('/path/to/song.mp3');
/// print(result.changes);
/// ```
class TagPipeline {
  final List<rpc.TransformRule> _rules;

  TagPipeline() : _rules = [];

  /// Create a pipeline from existing rules.
  factory TagPipeline.fromRules(List<rpc.TransformRule> rules) {
    return TagPipeline._(List.of(rules));
  }

  TagPipeline._(this._rules);

  // ── Whitespace / Unicode ──────────────────────────────

  /// Trim leading/trailing whitespace from all string fields.
  TagPipeline trimWhitespace() {
    _rules.add(const rpc.TransformRule.trimWhitespace());
    return this;
  }

  /// Collapse multiple whitespace characters into a single space.
  TagPipeline normalizeWhitespace() {
    _rules.add(const rpc.TransformRule.normalizeWhitespace());
    return this;
  }

  /// Apply Unicode NFKC normalization.
  TagPipeline normalizeUnicode() {
    _rules.add(const rpc.TransformRule.normalizeUnicode());
    return this;
  }

  // ── Setters ──────────────────────────────────────────

  /// Set the title.
  TagPipeline setTitle(String value) {
    _rules.add(rpc.TransformRule.setTitle(value));
    return this;
  }

  /// Set the artist.
  TagPipeline setArtist(String value) {
    _rules.add(rpc.TransformRule.setArtist(value));
    return this;
  }

  /// Set the album.
  TagPipeline setAlbum(String value) {
    _rules.add(rpc.TransformRule.setAlbum(value));
    return this;
  }

  /// Set the album artist.
  TagPipeline setAlbumArtist(String value) {
    _rules.add(rpc.TransformRule.setAlbumArtist(value));
    return this;
  }

  /// Set the genre.
  TagPipeline setGenre(String value) {
    _rules.add(rpc.TransformRule.setGenre(value));
    return this;
  }

  /// Set the year.
  TagPipeline setYear(int year) {
    _rules.add(rpc.TransformRule.setYear(year));
    return this;
  }

  /// Set the track number.
  TagPipeline setTrackNumber(int n) {
    _rules.add(rpc.TransformRule.setTrackNumber(n));
    return this;
  }

  /// Set the disc number.
  TagPipeline setDiscNumber(int n) {
    _rules.add(rpc.TransformRule.setDiscNumber(n));
    return this;
  }

  /// Set the track total.
  TagPipeline setTrackTotal(int n) {
    _rules.add(rpc.TransformRule.setTrackTotal(n));
    return this;
  }

  /// Set the disc total.
  TagPipeline setDiscTotal(int n) {
    _rules.add(rpc.TransformRule.setDiscTotal(n));
    return this;
  }

  /// Set the BPM.
  TagPipeline setBpm(double bpm) {
    _rules.add(rpc.TransformRule.setBpm(bpm));
    return this;
  }

  /// Set the comment.
  TagPipeline setComment(String value) {
    _rules.add(rpc.TransformRule.setComment(value));
    return this;
  }

  // ── Remove ───────────────────────────────────────────

  /// Remove lyrics.
  TagPipeline removeLyrics() {
    _rules.add(const rpc.TransformRule.removeLyrics());
    return this;
  }

  /// Remove comments.
  TagPipeline removeComment() {
    _rules.add(const rpc.TransformRule.removeComment());
    return this;
  }

  /// Remove all pictures.
  TagPipeline removePictures() {
    _rules.add(const rpc.TransformRule.removePictures());
    return this;
  }

  /// Remove BPM.
  TagPipeline removeBpm() {
    _rules.add(const rpc.TransformRule.removeBpm());
    return this;
  }

  /// Remove all ReplayGain fields.
  TagPipeline removeReplayGain() {
    _rules.add(const rpc.TransformRule.removeReplayGain());
    return this;
  }

  /// Remove title.
  TagPipeline removeTitle() {
    _rules.add(const rpc.TransformRule.removeTitle());
    return this;
  }

  /// Remove artist.
  TagPipeline removeArtist() {
    _rules.add(const rpc.TransformRule.removeArtist());
    return this;
  }

  /// Remove album.
  TagPipeline removeAlbum() {
    _rules.add(const rpc.TransformRule.removeAlbum());
    return this;
  }

  /// Remove album artist.
  TagPipeline removeAlbumArtist() {
    _rules.add(const rpc.TransformRule.removeAlbumArtist());
    return this;
  }

  /// Remove genre.
  TagPipeline removeGenre() {
    _rules.add(const rpc.TransformRule.removeGenre());
    return this;
  }

  /// Remove year.
  TagPipeline removeYear() {
    _rules.add(const rpc.TransformRule.removeYear());
    return this;
  }

  /// Remove track number.
  TagPipeline removeTrackNumber() {
    _rules.add(const rpc.TransformRule.removeTrackNumber());
    return this;
  }

  /// Remove disc number.
  TagPipeline removeDiscNumber() {
    _rules.add(const rpc.TransformRule.removeDiscNumber());
    return this;
  }

  // ── Normalize numbers ────────────────────────────────

  /// Normalize track numbers (clamp to valid range).
  TagPipeline normalizeTrackNumbers() {
    _rules.add(const rpc.TransformRule.normalizeTrackNumbers());
    return this;
  }

  /// Normalize disc numbers (clamp to valid range).
  TagPipeline normalizeDiscNumbers() {
    _rules.add(const rpc.TransformRule.normalizeDiscNumbers());
    return this;
  }

  /// Normalize year (2-digit to 4-digit).
  TagPipeline normalizeYear() {
    _rules.add(const rpc.TransformRule.normalizeYear());
    return this;
  }

  // ── Copy between fields ──────────────────────────────

  /// Copy artist to album artist (if album artist is empty).
  TagPipeline copyArtistToAlbumArtist() {
    _rules.add(const rpc.TransformRule.copyArtistToAlbumArtist());
    return this;
  }

  /// Copy album artist to artist (if artist is empty).
  TagPipeline copyAlbumArtistToArtist() {
    _rules.add(const rpc.TransformRule.copyAlbumArtistToArtist());
    return this;
  }

  /// Copy title to comment (if comment is empty).
  TagPipeline copyTitleToComment() {
    _rules.add(const rpc.TransformRule.copyTitleToComment());
    return this;
  }

  // ── Prefix / Suffix ──────────────────────────────────

  /// Add a prefix to the title.
  TagPipeline prefixTitle(String prefix) {
    _rules.add(rpc.TransformRule.prefixTitle(prefix));
    return this;
  }

  /// Add a suffix to the title.
  TagPipeline suffixTitle(String suffix) {
    _rules.add(rpc.TransformRule.suffixTitle(suffix));
    return this;
  }

  /// Add a prefix to the album.
  TagPipeline prefixAlbum(String prefix) {
    _rules.add(rpc.TransformRule.prefixAlbum(prefix));
    return this;
  }

  /// Add a suffix to the album.
  TagPipeline suffixAlbum(String suffix) {
    _rules.add(rpc.TransformRule.suffixAlbum(suffix));
    return this;
  }

  /// Add a prefix to the artist.
  TagPipeline prefixArtist(String prefix) {
    _rules.add(rpc.TransformRule.prefixArtist(prefix));
    return this;
  }

  /// Add a suffix to the artist.
  TagPipeline suffixArtist(String suffix) {
    _rules.add(rpc.TransformRule.suffixArtist(suffix));
    return this;
  }

  // ── Case transformations ─────────────────────────────

  /// Convert title to Title Case.
  TagPipeline titleCaseTitle() {
    _rules.add(const rpc.TransformRule.titleCaseTitle());
    return this;
  }

  /// Convert artist to Title Case.
  TagPipeline titleCaseArtist() {
    _rules.add(const rpc.TransformRule.titleCaseArtist());
    return this;
  }

  /// Convert album to Title Case.
  TagPipeline titleCaseAlbum() {
    _rules.add(const rpc.TransformRule.titleCaseAlbum());
    return this;
  }

  /// Convert all string fields to lowercase.
  TagPipeline lowerCaseAll() {
    _rules.add(const rpc.TransformRule.lowerCaseAll());
    return this;
  }

  /// Convert all string fields to uppercase.
  TagPipeline upperCaseAll() {
    _rules.add(const rpc.TransformRule.upperCaseAll());
    return this;
  }

  // ── Search / Replace ─────────────────────────────────

  /// Replace text in title.
  TagPipeline replaceInTitle(String find, String replace) {
    _rules.add(rpc.TransformRule.replaceInTitle(find: find, replace: replace));
    return this;
  }

  /// Replace text in artist.
  TagPipeline replaceInArtist(String find, String replace) {
    _rules.add(rpc.TransformRule.replaceInArtist(find: find, replace: replace));
    return this;
  }

  /// Replace text in album.
  TagPipeline replaceInAlbum(String find, String replace) {
    _rules.add(rpc.TransformRule.replaceInAlbum(find: find, replace: replace));
    return this;
  }

  /// Replace text in all string fields.
  TagPipeline replaceInAll(String find, String replace) {
    _rules.add(rpc.TransformRule.replaceInAll(find: find, replace: replace));
    return this;
  }

  // ── Conditional ──────────────────────────────────────

  /// Set title only if it is currently empty.
  TagPipeline setTitleIfEmpty(String value) {
    _rules.add(rpc.TransformRule.setTitleIfEmpty(value));
    return this;
  }

  /// Set artist only if it is currently empty.
  TagPipeline setArtistIfEmpty(String value) {
    _rules.add(rpc.TransformRule.setArtistIfEmpty(value));
    return this;
  }

  /// Set album only if it is currently empty.
  TagPipeline setAlbumIfEmpty(String value) {
    _rules.add(rpc.TransformRule.setAlbumIfEmpty(value));
    return this;
  }

  /// Set genre only if it is currently empty.
  TagPipeline setGenreIfEmpty(String value) {
    _rules.add(rpc.TransformRule.setGenreIfEmpty(value));
    return this;
  }

  /// Set album artist only if it is currently empty.
  TagPipeline setAlbumArtistIfEmpty(String value) {
    _rules.add(rpc.TransformRule.setAlbumArtistIfEmpty(value));
    return this;
  }

  // ── Remove empty ─────────────────────────────────────

  /// Remove all fields that are empty strings or null.
  TagPipeline removeEmptyFields() {
    _rules.add(const rpc.TransformRule.removeEmptyFields());
    return this;
  }

  // ── Pictures ─────────────────────────────────────────

  /// Remove all pictures except cover art.
  TagPipeline removeNonCoverPictures() {
    _rules.add(const rpc.TransformRule.removeNonCoverPictures());
    return this;
  }

  // ── Execution ────────────────────────────────────────

  /// Apply all rules to a tag and return the transformed tag.
  Future<Tag> apply(Tag tag) async {
    final pipeline = await rpc.TagPipeline.fromRules(rules: _rules);
    return pipeline.apply(tag: tag);
  }

  /// Preview the changes that would be made to a file.
  ///
  /// Returns a [PreviewResult] with the original tag, transformed tag,
  /// and a list of [FieldChange]s.
  Future<PreviewResult> preview(String path) async {
    final original = await Haudiotagger.read(path);
    if (original == null) {
      throw Exception('No metadata found at $path');
    }
    final transformed = await apply(original);
    final changes = _diffTags(original, transformed);
    return PreviewResult(
      original: original,
      transformed: transformed,
      changes: changes,
    );
  }

  /// Preview the changes that would be made to a byte array.
  Future<PreviewResult> previewFromBytes(Uint8List bytes) async {
    final original = await Haudiotagger.readFromBytes(bytes);
    if (original == null) {
      throw Exception('No metadata found in bytes');
    }
    final transformed = await apply(original);
    final changes = _diffTags(original, transformed);
    return PreviewResult(
      original: original,
      transformed: transformed,
      changes: changes,
    );
  }

  /// Apply the pipeline to a single file and write the result.
  Future<void> processFile(String path) async {
    await api.processFile(path: path, rules: _rules);
  }

  /// Apply the pipeline to a byte array and return the modified bytes.
  Future<Uint8List> processFromBytes(Uint8List bytes) async {
    final result = await api.processBytes(bytes: bytes, rules: _rules);
    return result;
  }

  /// Apply the pipeline to multiple files.
  ///
  /// Returns the number of files successfully processed.
  Future<int> process(List<String> files) async {
    final result = await api.processBatch(paths: files, rules: _rules);
    return result.successes;
  }

  /// Apply the pipeline to multiple byte arrays.
  ///
  /// Returns the list of modified byte arrays (same length as input).
  Future<List<Uint8List>> processBatchFromBytes(
    List<Uint8List> byteArrays,
  ) async {
    final result = await api.processBatchBytes(
      byteArrays: byteArrays,
      rules: _rules,
    );
    return result.results.toList();
  }

  /// Get the list of rules in this pipeline.
  List<rpc.TransformRule> get rules => List.unmodifiable(_rules);

  /// Get the number of rules in this pipeline.
  int get length => _rules.length;

  /// Check if the pipeline has no rules.
  bool get isEmpty => _rules.isEmpty;

  List<FieldChange> _diffTags(Tag a, Tag b) {
    final changes = <FieldChange>[];

    void check(String name, String? av, String? bv) {
      if (av != bv) {
        changes.add(FieldChange(field: name, oldValue: av, newValue: bv));
      }
    }

    check('title', a.title, b.title);
    check('artist', a.trackArtist, b.trackArtist);
    check('album', a.album, b.album);
    check('albumArtist', a.albumArtist, b.albumArtist);
    check('genre', a.genre, b.genre);
    check('lyrics', a.lyrics, b.lyrics);
    check('comment', a.comment, b.comment);
    check('year', a.year?.toString(), b.year?.toString());
    check('trackNumber', a.trackNumber?.toString(), b.trackNumber?.toString());
    check('trackTotal', a.trackTotal?.toString(), b.trackTotal?.toString());
    check('discNumber', a.discNumber?.toString(), b.discNumber?.toString());
    check('discTotal', a.discTotal?.toString(), b.discTotal?.toString());
    check('bpm', a.bpm?.toString(), b.bpm?.toString());

    if (a.pictures.length != b.pictures.length) {
      changes.add(FieldChange(
        field: 'pictures',
        oldValue: '${a.pictures.length} pictures',
        newValue: '${b.pictures.length} pictures',
      ));
    }

    return changes;
  }
}
