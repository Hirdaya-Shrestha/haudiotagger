// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pipeline.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransformRule {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is TransformRule);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule()';
  }
}

/// @nodoc
class $TransformRuleCopyWith<$Res> {
  $TransformRuleCopyWith(TransformRule _, $Res Function(TransformRule) __);
}

/// Adds pattern-matching-related methods to [TransformRule].
extension TransformRulePatterns on TransformRule {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TransformRule_TrimWhitespace value)? trimWhitespace,
    TResult Function(TransformRule_NormalizeWhitespace value)?
        normalizeWhitespace,
    TResult Function(TransformRule_NormalizeUnicode value)? normalizeUnicode,
    TResult Function(TransformRule_SetTitle value)? setTitle,
    TResult Function(TransformRule_SetArtist value)? setArtist,
    TResult Function(TransformRule_SetAlbum value)? setAlbum,
    TResult Function(TransformRule_SetAlbumArtist value)? setAlbumArtist,
    TResult Function(TransformRule_SetGenre value)? setGenre,
    TResult Function(TransformRule_SetYear value)? setYear,
    TResult Function(TransformRule_SetTrackNumber value)? setTrackNumber,
    TResult Function(TransformRule_SetDiscNumber value)? setDiscNumber,
    TResult Function(TransformRule_SetTrackTotal value)? setTrackTotal,
    TResult Function(TransformRule_SetDiscTotal value)? setDiscTotal,
    TResult Function(TransformRule_SetBpm value)? setBpm,
    TResult Function(TransformRule_SetComment value)? setComment,
    TResult Function(TransformRule_RemoveLyrics value)? removeLyrics,
    TResult Function(TransformRule_RemoveComment value)? removeComment,
    TResult Function(TransformRule_RemovePictures value)? removePictures,
    TResult Function(TransformRule_RemoveBpm value)? removeBpm,
    TResult Function(TransformRule_RemoveReplayGain value)? removeReplayGain,
    TResult Function(TransformRule_RemoveTitle value)? removeTitle,
    TResult Function(TransformRule_RemoveArtist value)? removeArtist,
    TResult Function(TransformRule_RemoveAlbum value)? removeAlbum,
    TResult Function(TransformRule_RemoveAlbumArtist value)? removeAlbumArtist,
    TResult Function(TransformRule_RemoveGenre value)? removeGenre,
    TResult Function(TransformRule_RemoveYear value)? removeYear,
    TResult Function(TransformRule_RemoveTrackNumber value)? removeTrackNumber,
    TResult Function(TransformRule_RemoveDiscNumber value)? removeDiscNumber,
    TResult Function(TransformRule_NormalizeTrackNumbers value)?
        normalizeTrackNumbers,
    TResult Function(TransformRule_NormalizeDiscNumbers value)?
        normalizeDiscNumbers,
    TResult Function(TransformRule_NormalizeYear value)? normalizeYear,
    TResult Function(TransformRule_CopyArtistToAlbumArtist value)?
        copyArtistToAlbumArtist,
    TResult Function(TransformRule_CopyAlbumArtistToArtist value)?
        copyAlbumArtistToArtist,
    TResult Function(TransformRule_CopyTitleToComment value)?
        copyTitleToComment,
    TResult Function(TransformRule_PrefixTitle value)? prefixTitle,
    TResult Function(TransformRule_SuffixTitle value)? suffixTitle,
    TResult Function(TransformRule_PrefixAlbum value)? prefixAlbum,
    TResult Function(TransformRule_SuffixAlbum value)? suffixAlbum,
    TResult Function(TransformRule_PrefixArtist value)? prefixArtist,
    TResult Function(TransformRule_SuffixArtist value)? suffixArtist,
    TResult Function(TransformRule_TitleCaseTitle value)? titleCaseTitle,
    TResult Function(TransformRule_TitleCaseArtist value)? titleCaseArtist,
    TResult Function(TransformRule_TitleCaseAlbum value)? titleCaseAlbum,
    TResult Function(TransformRule_LowerCaseAll value)? lowerCaseAll,
    TResult Function(TransformRule_UpperCaseAll value)? upperCaseAll,
    TResult Function(TransformRule_ReplaceInTitle value)? replaceInTitle,
    TResult Function(TransformRule_ReplaceInArtist value)? replaceInArtist,
    TResult Function(TransformRule_ReplaceInAlbum value)? replaceInAlbum,
    TResult Function(TransformRule_ReplaceInAll value)? replaceInAll,
    TResult Function(TransformRule_SetTitleIfEmpty value)? setTitleIfEmpty,
    TResult Function(TransformRule_SetArtistIfEmpty value)? setArtistIfEmpty,
    TResult Function(TransformRule_SetAlbumIfEmpty value)? setAlbumIfEmpty,
    TResult Function(TransformRule_SetGenreIfEmpty value)? setGenreIfEmpty,
    TResult Function(TransformRule_SetAlbumArtistIfEmpty value)?
        setAlbumArtistIfEmpty,
    TResult Function(TransformRule_RemoveEmptyFields value)? removeEmptyFields,
    TResult Function(TransformRule_RemoveNonCoverPictures value)?
        removeNonCoverPictures,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case TransformRule_TrimWhitespace() when trimWhitespace != null:
        return trimWhitespace(_that);
      case TransformRule_NormalizeWhitespace() when normalizeWhitespace != null:
        return normalizeWhitespace(_that);
      case TransformRule_NormalizeUnicode() when normalizeUnicode != null:
        return normalizeUnicode(_that);
      case TransformRule_SetTitle() when setTitle != null:
        return setTitle(_that);
      case TransformRule_SetArtist() when setArtist != null:
        return setArtist(_that);
      case TransformRule_SetAlbum() when setAlbum != null:
        return setAlbum(_that);
      case TransformRule_SetAlbumArtist() when setAlbumArtist != null:
        return setAlbumArtist(_that);
      case TransformRule_SetGenre() when setGenre != null:
        return setGenre(_that);
      case TransformRule_SetYear() when setYear != null:
        return setYear(_that);
      case TransformRule_SetTrackNumber() when setTrackNumber != null:
        return setTrackNumber(_that);
      case TransformRule_SetDiscNumber() when setDiscNumber != null:
        return setDiscNumber(_that);
      case TransformRule_SetTrackTotal() when setTrackTotal != null:
        return setTrackTotal(_that);
      case TransformRule_SetDiscTotal() when setDiscTotal != null:
        return setDiscTotal(_that);
      case TransformRule_SetBpm() when setBpm != null:
        return setBpm(_that);
      case TransformRule_SetComment() when setComment != null:
        return setComment(_that);
      case TransformRule_RemoveLyrics() when removeLyrics != null:
        return removeLyrics(_that);
      case TransformRule_RemoveComment() when removeComment != null:
        return removeComment(_that);
      case TransformRule_RemovePictures() when removePictures != null:
        return removePictures(_that);
      case TransformRule_RemoveBpm() when removeBpm != null:
        return removeBpm(_that);
      case TransformRule_RemoveReplayGain() when removeReplayGain != null:
        return removeReplayGain(_that);
      case TransformRule_RemoveTitle() when removeTitle != null:
        return removeTitle(_that);
      case TransformRule_RemoveArtist() when removeArtist != null:
        return removeArtist(_that);
      case TransformRule_RemoveAlbum() when removeAlbum != null:
        return removeAlbum(_that);
      case TransformRule_RemoveAlbumArtist() when removeAlbumArtist != null:
        return removeAlbumArtist(_that);
      case TransformRule_RemoveGenre() when removeGenre != null:
        return removeGenre(_that);
      case TransformRule_RemoveYear() when removeYear != null:
        return removeYear(_that);
      case TransformRule_RemoveTrackNumber() when removeTrackNumber != null:
        return removeTrackNumber(_that);
      case TransformRule_RemoveDiscNumber() when removeDiscNumber != null:
        return removeDiscNumber(_that);
      case TransformRule_NormalizeTrackNumbers()
          when normalizeTrackNumbers != null:
        return normalizeTrackNumbers(_that);
      case TransformRule_NormalizeDiscNumbers()
          when normalizeDiscNumbers != null:
        return normalizeDiscNumbers(_that);
      case TransformRule_NormalizeYear() when normalizeYear != null:
        return normalizeYear(_that);
      case TransformRule_CopyArtistToAlbumArtist()
          when copyArtistToAlbumArtist != null:
        return copyArtistToAlbumArtist(_that);
      case TransformRule_CopyAlbumArtistToArtist()
          when copyAlbumArtistToArtist != null:
        return copyAlbumArtistToArtist(_that);
      case TransformRule_CopyTitleToComment() when copyTitleToComment != null:
        return copyTitleToComment(_that);
      case TransformRule_PrefixTitle() when prefixTitle != null:
        return prefixTitle(_that);
      case TransformRule_SuffixTitle() when suffixTitle != null:
        return suffixTitle(_that);
      case TransformRule_PrefixAlbum() when prefixAlbum != null:
        return prefixAlbum(_that);
      case TransformRule_SuffixAlbum() when suffixAlbum != null:
        return suffixAlbum(_that);
      case TransformRule_PrefixArtist() when prefixArtist != null:
        return prefixArtist(_that);
      case TransformRule_SuffixArtist() when suffixArtist != null:
        return suffixArtist(_that);
      case TransformRule_TitleCaseTitle() when titleCaseTitle != null:
        return titleCaseTitle(_that);
      case TransformRule_TitleCaseArtist() when titleCaseArtist != null:
        return titleCaseArtist(_that);
      case TransformRule_TitleCaseAlbum() when titleCaseAlbum != null:
        return titleCaseAlbum(_that);
      case TransformRule_LowerCaseAll() when lowerCaseAll != null:
        return lowerCaseAll(_that);
      case TransformRule_UpperCaseAll() when upperCaseAll != null:
        return upperCaseAll(_that);
      case TransformRule_ReplaceInTitle() when replaceInTitle != null:
        return replaceInTitle(_that);
      case TransformRule_ReplaceInArtist() when replaceInArtist != null:
        return replaceInArtist(_that);
      case TransformRule_ReplaceInAlbum() when replaceInAlbum != null:
        return replaceInAlbum(_that);
      case TransformRule_ReplaceInAll() when replaceInAll != null:
        return replaceInAll(_that);
      case TransformRule_SetTitleIfEmpty() when setTitleIfEmpty != null:
        return setTitleIfEmpty(_that);
      case TransformRule_SetArtistIfEmpty() when setArtistIfEmpty != null:
        return setArtistIfEmpty(_that);
      case TransformRule_SetAlbumIfEmpty() when setAlbumIfEmpty != null:
        return setAlbumIfEmpty(_that);
      case TransformRule_SetGenreIfEmpty() when setGenreIfEmpty != null:
        return setGenreIfEmpty(_that);
      case TransformRule_SetAlbumArtistIfEmpty()
          when setAlbumArtistIfEmpty != null:
        return setAlbumArtistIfEmpty(_that);
      case TransformRule_RemoveEmptyFields() when removeEmptyFields != null:
        return removeEmptyFields(_that);
      case TransformRule_RemoveNonCoverPictures()
          when removeNonCoverPictures != null:
        return removeNonCoverPictures(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TransformRule_TrimWhitespace value)
        trimWhitespace,
    required TResult Function(TransformRule_NormalizeWhitespace value)
        normalizeWhitespace,
    required TResult Function(TransformRule_NormalizeUnicode value)
        normalizeUnicode,
    required TResult Function(TransformRule_SetTitle value) setTitle,
    required TResult Function(TransformRule_SetArtist value) setArtist,
    required TResult Function(TransformRule_SetAlbum value) setAlbum,
    required TResult Function(TransformRule_SetAlbumArtist value)
        setAlbumArtist,
    required TResult Function(TransformRule_SetGenre value) setGenre,
    required TResult Function(TransformRule_SetYear value) setYear,
    required TResult Function(TransformRule_SetTrackNumber value)
        setTrackNumber,
    required TResult Function(TransformRule_SetDiscNumber value) setDiscNumber,
    required TResult Function(TransformRule_SetTrackTotal value) setTrackTotal,
    required TResult Function(TransformRule_SetDiscTotal value) setDiscTotal,
    required TResult Function(TransformRule_SetBpm value) setBpm,
    required TResult Function(TransformRule_SetComment value) setComment,
    required TResult Function(TransformRule_RemoveLyrics value) removeLyrics,
    required TResult Function(TransformRule_RemoveComment value) removeComment,
    required TResult Function(TransformRule_RemovePictures value)
        removePictures,
    required TResult Function(TransformRule_RemoveBpm value) removeBpm,
    required TResult Function(TransformRule_RemoveReplayGain value)
        removeReplayGain,
    required TResult Function(TransformRule_RemoveTitle value) removeTitle,
    required TResult Function(TransformRule_RemoveArtist value) removeArtist,
    required TResult Function(TransformRule_RemoveAlbum value) removeAlbum,
    required TResult Function(TransformRule_RemoveAlbumArtist value)
        removeAlbumArtist,
    required TResult Function(TransformRule_RemoveGenre value) removeGenre,
    required TResult Function(TransformRule_RemoveYear value) removeYear,
    required TResult Function(TransformRule_RemoveTrackNumber value)
        removeTrackNumber,
    required TResult Function(TransformRule_RemoveDiscNumber value)
        removeDiscNumber,
    required TResult Function(TransformRule_NormalizeTrackNumbers value)
        normalizeTrackNumbers,
    required TResult Function(TransformRule_NormalizeDiscNumbers value)
        normalizeDiscNumbers,
    required TResult Function(TransformRule_NormalizeYear value) normalizeYear,
    required TResult Function(TransformRule_CopyArtistToAlbumArtist value)
        copyArtistToAlbumArtist,
    required TResult Function(TransformRule_CopyAlbumArtistToArtist value)
        copyAlbumArtistToArtist,
    required TResult Function(TransformRule_CopyTitleToComment value)
        copyTitleToComment,
    required TResult Function(TransformRule_PrefixTitle value) prefixTitle,
    required TResult Function(TransformRule_SuffixTitle value) suffixTitle,
    required TResult Function(TransformRule_PrefixAlbum value) prefixAlbum,
    required TResult Function(TransformRule_SuffixAlbum value) suffixAlbum,
    required TResult Function(TransformRule_PrefixArtist value) prefixArtist,
    required TResult Function(TransformRule_SuffixArtist value) suffixArtist,
    required TResult Function(TransformRule_TitleCaseTitle value)
        titleCaseTitle,
    required TResult Function(TransformRule_TitleCaseArtist value)
        titleCaseArtist,
    required TResult Function(TransformRule_TitleCaseAlbum value)
        titleCaseAlbum,
    required TResult Function(TransformRule_LowerCaseAll value) lowerCaseAll,
    required TResult Function(TransformRule_UpperCaseAll value) upperCaseAll,
    required TResult Function(TransformRule_ReplaceInTitle value)
        replaceInTitle,
    required TResult Function(TransformRule_ReplaceInArtist value)
        replaceInArtist,
    required TResult Function(TransformRule_ReplaceInAlbum value)
        replaceInAlbum,
    required TResult Function(TransformRule_ReplaceInAll value) replaceInAll,
    required TResult Function(TransformRule_SetTitleIfEmpty value)
        setTitleIfEmpty,
    required TResult Function(TransformRule_SetArtistIfEmpty value)
        setArtistIfEmpty,
    required TResult Function(TransformRule_SetAlbumIfEmpty value)
        setAlbumIfEmpty,
    required TResult Function(TransformRule_SetGenreIfEmpty value)
        setGenreIfEmpty,
    required TResult Function(TransformRule_SetAlbumArtistIfEmpty value)
        setAlbumArtistIfEmpty,
    required TResult Function(TransformRule_RemoveEmptyFields value)
        removeEmptyFields,
    required TResult Function(TransformRule_RemoveNonCoverPictures value)
        removeNonCoverPictures,
  }) {
    final _that = this;
    switch (_that) {
      case TransformRule_TrimWhitespace():
        return trimWhitespace(_that);
      case TransformRule_NormalizeWhitespace():
        return normalizeWhitespace(_that);
      case TransformRule_NormalizeUnicode():
        return normalizeUnicode(_that);
      case TransformRule_SetTitle():
        return setTitle(_that);
      case TransformRule_SetArtist():
        return setArtist(_that);
      case TransformRule_SetAlbum():
        return setAlbum(_that);
      case TransformRule_SetAlbumArtist():
        return setAlbumArtist(_that);
      case TransformRule_SetGenre():
        return setGenre(_that);
      case TransformRule_SetYear():
        return setYear(_that);
      case TransformRule_SetTrackNumber():
        return setTrackNumber(_that);
      case TransformRule_SetDiscNumber():
        return setDiscNumber(_that);
      case TransformRule_SetTrackTotal():
        return setTrackTotal(_that);
      case TransformRule_SetDiscTotal():
        return setDiscTotal(_that);
      case TransformRule_SetBpm():
        return setBpm(_that);
      case TransformRule_SetComment():
        return setComment(_that);
      case TransformRule_RemoveLyrics():
        return removeLyrics(_that);
      case TransformRule_RemoveComment():
        return removeComment(_that);
      case TransformRule_RemovePictures():
        return removePictures(_that);
      case TransformRule_RemoveBpm():
        return removeBpm(_that);
      case TransformRule_RemoveReplayGain():
        return removeReplayGain(_that);
      case TransformRule_RemoveTitle():
        return removeTitle(_that);
      case TransformRule_RemoveArtist():
        return removeArtist(_that);
      case TransformRule_RemoveAlbum():
        return removeAlbum(_that);
      case TransformRule_RemoveAlbumArtist():
        return removeAlbumArtist(_that);
      case TransformRule_RemoveGenre():
        return removeGenre(_that);
      case TransformRule_RemoveYear():
        return removeYear(_that);
      case TransformRule_RemoveTrackNumber():
        return removeTrackNumber(_that);
      case TransformRule_RemoveDiscNumber():
        return removeDiscNumber(_that);
      case TransformRule_NormalizeTrackNumbers():
        return normalizeTrackNumbers(_that);
      case TransformRule_NormalizeDiscNumbers():
        return normalizeDiscNumbers(_that);
      case TransformRule_NormalizeYear():
        return normalizeYear(_that);
      case TransformRule_CopyArtistToAlbumArtist():
        return copyArtistToAlbumArtist(_that);
      case TransformRule_CopyAlbumArtistToArtist():
        return copyAlbumArtistToArtist(_that);
      case TransformRule_CopyTitleToComment():
        return copyTitleToComment(_that);
      case TransformRule_PrefixTitle():
        return prefixTitle(_that);
      case TransformRule_SuffixTitle():
        return suffixTitle(_that);
      case TransformRule_PrefixAlbum():
        return prefixAlbum(_that);
      case TransformRule_SuffixAlbum():
        return suffixAlbum(_that);
      case TransformRule_PrefixArtist():
        return prefixArtist(_that);
      case TransformRule_SuffixArtist():
        return suffixArtist(_that);
      case TransformRule_TitleCaseTitle():
        return titleCaseTitle(_that);
      case TransformRule_TitleCaseArtist():
        return titleCaseArtist(_that);
      case TransformRule_TitleCaseAlbum():
        return titleCaseAlbum(_that);
      case TransformRule_LowerCaseAll():
        return lowerCaseAll(_that);
      case TransformRule_UpperCaseAll():
        return upperCaseAll(_that);
      case TransformRule_ReplaceInTitle():
        return replaceInTitle(_that);
      case TransformRule_ReplaceInArtist():
        return replaceInArtist(_that);
      case TransformRule_ReplaceInAlbum():
        return replaceInAlbum(_that);
      case TransformRule_ReplaceInAll():
        return replaceInAll(_that);
      case TransformRule_SetTitleIfEmpty():
        return setTitleIfEmpty(_that);
      case TransformRule_SetArtistIfEmpty():
        return setArtistIfEmpty(_that);
      case TransformRule_SetAlbumIfEmpty():
        return setAlbumIfEmpty(_that);
      case TransformRule_SetGenreIfEmpty():
        return setGenreIfEmpty(_that);
      case TransformRule_SetAlbumArtistIfEmpty():
        return setAlbumArtistIfEmpty(_that);
      case TransformRule_RemoveEmptyFields():
        return removeEmptyFields(_that);
      case TransformRule_RemoveNonCoverPictures():
        return removeNonCoverPictures(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TransformRule_TrimWhitespace value)? trimWhitespace,
    TResult? Function(TransformRule_NormalizeWhitespace value)?
        normalizeWhitespace,
    TResult? Function(TransformRule_NormalizeUnicode value)? normalizeUnicode,
    TResult? Function(TransformRule_SetTitle value)? setTitle,
    TResult? Function(TransformRule_SetArtist value)? setArtist,
    TResult? Function(TransformRule_SetAlbum value)? setAlbum,
    TResult? Function(TransformRule_SetAlbumArtist value)? setAlbumArtist,
    TResult? Function(TransformRule_SetGenre value)? setGenre,
    TResult? Function(TransformRule_SetYear value)? setYear,
    TResult? Function(TransformRule_SetTrackNumber value)? setTrackNumber,
    TResult? Function(TransformRule_SetDiscNumber value)? setDiscNumber,
    TResult? Function(TransformRule_SetTrackTotal value)? setTrackTotal,
    TResult? Function(TransformRule_SetDiscTotal value)? setDiscTotal,
    TResult? Function(TransformRule_SetBpm value)? setBpm,
    TResult? Function(TransformRule_SetComment value)? setComment,
    TResult? Function(TransformRule_RemoveLyrics value)? removeLyrics,
    TResult? Function(TransformRule_RemoveComment value)? removeComment,
    TResult? Function(TransformRule_RemovePictures value)? removePictures,
    TResult? Function(TransformRule_RemoveBpm value)? removeBpm,
    TResult? Function(TransformRule_RemoveReplayGain value)? removeReplayGain,
    TResult? Function(TransformRule_RemoveTitle value)? removeTitle,
    TResult? Function(TransformRule_RemoveArtist value)? removeArtist,
    TResult? Function(TransformRule_RemoveAlbum value)? removeAlbum,
    TResult? Function(TransformRule_RemoveAlbumArtist value)? removeAlbumArtist,
    TResult? Function(TransformRule_RemoveGenre value)? removeGenre,
    TResult? Function(TransformRule_RemoveYear value)? removeYear,
    TResult? Function(TransformRule_RemoveTrackNumber value)? removeTrackNumber,
    TResult? Function(TransformRule_RemoveDiscNumber value)? removeDiscNumber,
    TResult? Function(TransformRule_NormalizeTrackNumbers value)?
        normalizeTrackNumbers,
    TResult? Function(TransformRule_NormalizeDiscNumbers value)?
        normalizeDiscNumbers,
    TResult? Function(TransformRule_NormalizeYear value)? normalizeYear,
    TResult? Function(TransformRule_CopyArtistToAlbumArtist value)?
        copyArtistToAlbumArtist,
    TResult? Function(TransformRule_CopyAlbumArtistToArtist value)?
        copyAlbumArtistToArtist,
    TResult? Function(TransformRule_CopyTitleToComment value)?
        copyTitleToComment,
    TResult? Function(TransformRule_PrefixTitle value)? prefixTitle,
    TResult? Function(TransformRule_SuffixTitle value)? suffixTitle,
    TResult? Function(TransformRule_PrefixAlbum value)? prefixAlbum,
    TResult? Function(TransformRule_SuffixAlbum value)? suffixAlbum,
    TResult? Function(TransformRule_PrefixArtist value)? prefixArtist,
    TResult? Function(TransformRule_SuffixArtist value)? suffixArtist,
    TResult? Function(TransformRule_TitleCaseTitle value)? titleCaseTitle,
    TResult? Function(TransformRule_TitleCaseArtist value)? titleCaseArtist,
    TResult? Function(TransformRule_TitleCaseAlbum value)? titleCaseAlbum,
    TResult? Function(TransformRule_LowerCaseAll value)? lowerCaseAll,
    TResult? Function(TransformRule_UpperCaseAll value)? upperCaseAll,
    TResult? Function(TransformRule_ReplaceInTitle value)? replaceInTitle,
    TResult? Function(TransformRule_ReplaceInArtist value)? replaceInArtist,
    TResult? Function(TransformRule_ReplaceInAlbum value)? replaceInAlbum,
    TResult? Function(TransformRule_ReplaceInAll value)? replaceInAll,
    TResult? Function(TransformRule_SetTitleIfEmpty value)? setTitleIfEmpty,
    TResult? Function(TransformRule_SetArtistIfEmpty value)? setArtistIfEmpty,
    TResult? Function(TransformRule_SetAlbumIfEmpty value)? setAlbumIfEmpty,
    TResult? Function(TransformRule_SetGenreIfEmpty value)? setGenreIfEmpty,
    TResult? Function(TransformRule_SetAlbumArtistIfEmpty value)?
        setAlbumArtistIfEmpty,
    TResult? Function(TransformRule_RemoveEmptyFields value)? removeEmptyFields,
    TResult? Function(TransformRule_RemoveNonCoverPictures value)?
        removeNonCoverPictures,
  }) {
    final _that = this;
    switch (_that) {
      case TransformRule_TrimWhitespace() when trimWhitespace != null:
        return trimWhitespace(_that);
      case TransformRule_NormalizeWhitespace() when normalizeWhitespace != null:
        return normalizeWhitespace(_that);
      case TransformRule_NormalizeUnicode() when normalizeUnicode != null:
        return normalizeUnicode(_that);
      case TransformRule_SetTitle() when setTitle != null:
        return setTitle(_that);
      case TransformRule_SetArtist() when setArtist != null:
        return setArtist(_that);
      case TransformRule_SetAlbum() when setAlbum != null:
        return setAlbum(_that);
      case TransformRule_SetAlbumArtist() when setAlbumArtist != null:
        return setAlbumArtist(_that);
      case TransformRule_SetGenre() when setGenre != null:
        return setGenre(_that);
      case TransformRule_SetYear() when setYear != null:
        return setYear(_that);
      case TransformRule_SetTrackNumber() when setTrackNumber != null:
        return setTrackNumber(_that);
      case TransformRule_SetDiscNumber() when setDiscNumber != null:
        return setDiscNumber(_that);
      case TransformRule_SetTrackTotal() when setTrackTotal != null:
        return setTrackTotal(_that);
      case TransformRule_SetDiscTotal() when setDiscTotal != null:
        return setDiscTotal(_that);
      case TransformRule_SetBpm() when setBpm != null:
        return setBpm(_that);
      case TransformRule_SetComment() when setComment != null:
        return setComment(_that);
      case TransformRule_RemoveLyrics() when removeLyrics != null:
        return removeLyrics(_that);
      case TransformRule_RemoveComment() when removeComment != null:
        return removeComment(_that);
      case TransformRule_RemovePictures() when removePictures != null:
        return removePictures(_that);
      case TransformRule_RemoveBpm() when removeBpm != null:
        return removeBpm(_that);
      case TransformRule_RemoveReplayGain() when removeReplayGain != null:
        return removeReplayGain(_that);
      case TransformRule_RemoveTitle() when removeTitle != null:
        return removeTitle(_that);
      case TransformRule_RemoveArtist() when removeArtist != null:
        return removeArtist(_that);
      case TransformRule_RemoveAlbum() when removeAlbum != null:
        return removeAlbum(_that);
      case TransformRule_RemoveAlbumArtist() when removeAlbumArtist != null:
        return removeAlbumArtist(_that);
      case TransformRule_RemoveGenre() when removeGenre != null:
        return removeGenre(_that);
      case TransformRule_RemoveYear() when removeYear != null:
        return removeYear(_that);
      case TransformRule_RemoveTrackNumber() when removeTrackNumber != null:
        return removeTrackNumber(_that);
      case TransformRule_RemoveDiscNumber() when removeDiscNumber != null:
        return removeDiscNumber(_that);
      case TransformRule_NormalizeTrackNumbers()
          when normalizeTrackNumbers != null:
        return normalizeTrackNumbers(_that);
      case TransformRule_NormalizeDiscNumbers()
          when normalizeDiscNumbers != null:
        return normalizeDiscNumbers(_that);
      case TransformRule_NormalizeYear() when normalizeYear != null:
        return normalizeYear(_that);
      case TransformRule_CopyArtistToAlbumArtist()
          when copyArtistToAlbumArtist != null:
        return copyArtistToAlbumArtist(_that);
      case TransformRule_CopyAlbumArtistToArtist()
          when copyAlbumArtistToArtist != null:
        return copyAlbumArtistToArtist(_that);
      case TransformRule_CopyTitleToComment() when copyTitleToComment != null:
        return copyTitleToComment(_that);
      case TransformRule_PrefixTitle() when prefixTitle != null:
        return prefixTitle(_that);
      case TransformRule_SuffixTitle() when suffixTitle != null:
        return suffixTitle(_that);
      case TransformRule_PrefixAlbum() when prefixAlbum != null:
        return prefixAlbum(_that);
      case TransformRule_SuffixAlbum() when suffixAlbum != null:
        return suffixAlbum(_that);
      case TransformRule_PrefixArtist() when prefixArtist != null:
        return prefixArtist(_that);
      case TransformRule_SuffixArtist() when suffixArtist != null:
        return suffixArtist(_that);
      case TransformRule_TitleCaseTitle() when titleCaseTitle != null:
        return titleCaseTitle(_that);
      case TransformRule_TitleCaseArtist() when titleCaseArtist != null:
        return titleCaseArtist(_that);
      case TransformRule_TitleCaseAlbum() when titleCaseAlbum != null:
        return titleCaseAlbum(_that);
      case TransformRule_LowerCaseAll() when lowerCaseAll != null:
        return lowerCaseAll(_that);
      case TransformRule_UpperCaseAll() when upperCaseAll != null:
        return upperCaseAll(_that);
      case TransformRule_ReplaceInTitle() when replaceInTitle != null:
        return replaceInTitle(_that);
      case TransformRule_ReplaceInArtist() when replaceInArtist != null:
        return replaceInArtist(_that);
      case TransformRule_ReplaceInAlbum() when replaceInAlbum != null:
        return replaceInAlbum(_that);
      case TransformRule_ReplaceInAll() when replaceInAll != null:
        return replaceInAll(_that);
      case TransformRule_SetTitleIfEmpty() when setTitleIfEmpty != null:
        return setTitleIfEmpty(_that);
      case TransformRule_SetArtistIfEmpty() when setArtistIfEmpty != null:
        return setArtistIfEmpty(_that);
      case TransformRule_SetAlbumIfEmpty() when setAlbumIfEmpty != null:
        return setAlbumIfEmpty(_that);
      case TransformRule_SetGenreIfEmpty() when setGenreIfEmpty != null:
        return setGenreIfEmpty(_that);
      case TransformRule_SetAlbumArtistIfEmpty()
          when setAlbumArtistIfEmpty != null:
        return setAlbumArtistIfEmpty(_that);
      case TransformRule_RemoveEmptyFields() when removeEmptyFields != null:
        return removeEmptyFields(_that);
      case TransformRule_RemoveNonCoverPictures()
          when removeNonCoverPictures != null:
        return removeNonCoverPictures(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? trimWhitespace,
    TResult Function()? normalizeWhitespace,
    TResult Function()? normalizeUnicode,
    TResult Function(String field0)? setTitle,
    TResult Function(String field0)? setArtist,
    TResult Function(String field0)? setAlbum,
    TResult Function(String field0)? setAlbumArtist,
    TResult Function(String field0)? setGenre,
    TResult Function(int field0)? setYear,
    TResult Function(int field0)? setTrackNumber,
    TResult Function(int field0)? setDiscNumber,
    TResult Function(int field0)? setTrackTotal,
    TResult Function(int field0)? setDiscTotal,
    TResult Function(double field0)? setBpm,
    TResult Function(String field0)? setComment,
    TResult Function()? removeLyrics,
    TResult Function()? removeComment,
    TResult Function()? removePictures,
    TResult Function()? removeBpm,
    TResult Function()? removeReplayGain,
    TResult Function()? removeTitle,
    TResult Function()? removeArtist,
    TResult Function()? removeAlbum,
    TResult Function()? removeAlbumArtist,
    TResult Function()? removeGenre,
    TResult Function()? removeYear,
    TResult Function()? removeTrackNumber,
    TResult Function()? removeDiscNumber,
    TResult Function()? normalizeTrackNumbers,
    TResult Function()? normalizeDiscNumbers,
    TResult Function()? normalizeYear,
    TResult Function()? copyArtistToAlbumArtist,
    TResult Function()? copyAlbumArtistToArtist,
    TResult Function()? copyTitleToComment,
    TResult Function(String field0)? prefixTitle,
    TResult Function(String field0)? suffixTitle,
    TResult Function(String field0)? prefixAlbum,
    TResult Function(String field0)? suffixAlbum,
    TResult Function(String field0)? prefixArtist,
    TResult Function(String field0)? suffixArtist,
    TResult Function()? titleCaseTitle,
    TResult Function()? titleCaseArtist,
    TResult Function()? titleCaseAlbum,
    TResult Function()? lowerCaseAll,
    TResult Function()? upperCaseAll,
    TResult Function(String find, String replace)? replaceInTitle,
    TResult Function(String find, String replace)? replaceInArtist,
    TResult Function(String find, String replace)? replaceInAlbum,
    TResult Function(String find, String replace)? replaceInAll,
    TResult Function(String field0)? setTitleIfEmpty,
    TResult Function(String field0)? setArtistIfEmpty,
    TResult Function(String field0)? setAlbumIfEmpty,
    TResult Function(String field0)? setGenreIfEmpty,
    TResult Function(String field0)? setAlbumArtistIfEmpty,
    TResult Function()? removeEmptyFields,
    TResult Function()? removeNonCoverPictures,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case TransformRule_TrimWhitespace() when trimWhitespace != null:
        return trimWhitespace();
      case TransformRule_NormalizeWhitespace() when normalizeWhitespace != null:
        return normalizeWhitespace();
      case TransformRule_NormalizeUnicode() when normalizeUnicode != null:
        return normalizeUnicode();
      case TransformRule_SetTitle() when setTitle != null:
        return setTitle(_that.field0);
      case TransformRule_SetArtist() when setArtist != null:
        return setArtist(_that.field0);
      case TransformRule_SetAlbum() when setAlbum != null:
        return setAlbum(_that.field0);
      case TransformRule_SetAlbumArtist() when setAlbumArtist != null:
        return setAlbumArtist(_that.field0);
      case TransformRule_SetGenre() when setGenre != null:
        return setGenre(_that.field0);
      case TransformRule_SetYear() when setYear != null:
        return setYear(_that.field0);
      case TransformRule_SetTrackNumber() when setTrackNumber != null:
        return setTrackNumber(_that.field0);
      case TransformRule_SetDiscNumber() when setDiscNumber != null:
        return setDiscNumber(_that.field0);
      case TransformRule_SetTrackTotal() when setTrackTotal != null:
        return setTrackTotal(_that.field0);
      case TransformRule_SetDiscTotal() when setDiscTotal != null:
        return setDiscTotal(_that.field0);
      case TransformRule_SetBpm() when setBpm != null:
        return setBpm(_that.field0);
      case TransformRule_SetComment() when setComment != null:
        return setComment(_that.field0);
      case TransformRule_RemoveLyrics() when removeLyrics != null:
        return removeLyrics();
      case TransformRule_RemoveComment() when removeComment != null:
        return removeComment();
      case TransformRule_RemovePictures() when removePictures != null:
        return removePictures();
      case TransformRule_RemoveBpm() when removeBpm != null:
        return removeBpm();
      case TransformRule_RemoveReplayGain() when removeReplayGain != null:
        return removeReplayGain();
      case TransformRule_RemoveTitle() when removeTitle != null:
        return removeTitle();
      case TransformRule_RemoveArtist() when removeArtist != null:
        return removeArtist();
      case TransformRule_RemoveAlbum() when removeAlbum != null:
        return removeAlbum();
      case TransformRule_RemoveAlbumArtist() when removeAlbumArtist != null:
        return removeAlbumArtist();
      case TransformRule_RemoveGenre() when removeGenre != null:
        return removeGenre();
      case TransformRule_RemoveYear() when removeYear != null:
        return removeYear();
      case TransformRule_RemoveTrackNumber() when removeTrackNumber != null:
        return removeTrackNumber();
      case TransformRule_RemoveDiscNumber() when removeDiscNumber != null:
        return removeDiscNumber();
      case TransformRule_NormalizeTrackNumbers()
          when normalizeTrackNumbers != null:
        return normalizeTrackNumbers();
      case TransformRule_NormalizeDiscNumbers()
          when normalizeDiscNumbers != null:
        return normalizeDiscNumbers();
      case TransformRule_NormalizeYear() when normalizeYear != null:
        return normalizeYear();
      case TransformRule_CopyArtistToAlbumArtist()
          when copyArtistToAlbumArtist != null:
        return copyArtistToAlbumArtist();
      case TransformRule_CopyAlbumArtistToArtist()
          when copyAlbumArtistToArtist != null:
        return copyAlbumArtistToArtist();
      case TransformRule_CopyTitleToComment() when copyTitleToComment != null:
        return copyTitleToComment();
      case TransformRule_PrefixTitle() when prefixTitle != null:
        return prefixTitle(_that.field0);
      case TransformRule_SuffixTitle() when suffixTitle != null:
        return suffixTitle(_that.field0);
      case TransformRule_PrefixAlbum() when prefixAlbum != null:
        return prefixAlbum(_that.field0);
      case TransformRule_SuffixAlbum() when suffixAlbum != null:
        return suffixAlbum(_that.field0);
      case TransformRule_PrefixArtist() when prefixArtist != null:
        return prefixArtist(_that.field0);
      case TransformRule_SuffixArtist() when suffixArtist != null:
        return suffixArtist(_that.field0);
      case TransformRule_TitleCaseTitle() when titleCaseTitle != null:
        return titleCaseTitle();
      case TransformRule_TitleCaseArtist() when titleCaseArtist != null:
        return titleCaseArtist();
      case TransformRule_TitleCaseAlbum() when titleCaseAlbum != null:
        return titleCaseAlbum();
      case TransformRule_LowerCaseAll() when lowerCaseAll != null:
        return lowerCaseAll();
      case TransformRule_UpperCaseAll() when upperCaseAll != null:
        return upperCaseAll();
      case TransformRule_ReplaceInTitle() when replaceInTitle != null:
        return replaceInTitle(_that.find, _that.replace);
      case TransformRule_ReplaceInArtist() when replaceInArtist != null:
        return replaceInArtist(_that.find, _that.replace);
      case TransformRule_ReplaceInAlbum() when replaceInAlbum != null:
        return replaceInAlbum(_that.find, _that.replace);
      case TransformRule_ReplaceInAll() when replaceInAll != null:
        return replaceInAll(_that.find, _that.replace);
      case TransformRule_SetTitleIfEmpty() when setTitleIfEmpty != null:
        return setTitleIfEmpty(_that.field0);
      case TransformRule_SetArtistIfEmpty() when setArtistIfEmpty != null:
        return setArtistIfEmpty(_that.field0);
      case TransformRule_SetAlbumIfEmpty() when setAlbumIfEmpty != null:
        return setAlbumIfEmpty(_that.field0);
      case TransformRule_SetGenreIfEmpty() when setGenreIfEmpty != null:
        return setGenreIfEmpty(_that.field0);
      case TransformRule_SetAlbumArtistIfEmpty()
          when setAlbumArtistIfEmpty != null:
        return setAlbumArtistIfEmpty(_that.field0);
      case TransformRule_RemoveEmptyFields() when removeEmptyFields != null:
        return removeEmptyFields();
      case TransformRule_RemoveNonCoverPictures()
          when removeNonCoverPictures != null:
        return removeNonCoverPictures();
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() trimWhitespace,
    required TResult Function() normalizeWhitespace,
    required TResult Function() normalizeUnicode,
    required TResult Function(String field0) setTitle,
    required TResult Function(String field0) setArtist,
    required TResult Function(String field0) setAlbum,
    required TResult Function(String field0) setAlbumArtist,
    required TResult Function(String field0) setGenre,
    required TResult Function(int field0) setYear,
    required TResult Function(int field0) setTrackNumber,
    required TResult Function(int field0) setDiscNumber,
    required TResult Function(int field0) setTrackTotal,
    required TResult Function(int field0) setDiscTotal,
    required TResult Function(double field0) setBpm,
    required TResult Function(String field0) setComment,
    required TResult Function() removeLyrics,
    required TResult Function() removeComment,
    required TResult Function() removePictures,
    required TResult Function() removeBpm,
    required TResult Function() removeReplayGain,
    required TResult Function() removeTitle,
    required TResult Function() removeArtist,
    required TResult Function() removeAlbum,
    required TResult Function() removeAlbumArtist,
    required TResult Function() removeGenre,
    required TResult Function() removeYear,
    required TResult Function() removeTrackNumber,
    required TResult Function() removeDiscNumber,
    required TResult Function() normalizeTrackNumbers,
    required TResult Function() normalizeDiscNumbers,
    required TResult Function() normalizeYear,
    required TResult Function() copyArtistToAlbumArtist,
    required TResult Function() copyAlbumArtistToArtist,
    required TResult Function() copyTitleToComment,
    required TResult Function(String field0) prefixTitle,
    required TResult Function(String field0) suffixTitle,
    required TResult Function(String field0) prefixAlbum,
    required TResult Function(String field0) suffixAlbum,
    required TResult Function(String field0) prefixArtist,
    required TResult Function(String field0) suffixArtist,
    required TResult Function() titleCaseTitle,
    required TResult Function() titleCaseArtist,
    required TResult Function() titleCaseAlbum,
    required TResult Function() lowerCaseAll,
    required TResult Function() upperCaseAll,
    required TResult Function(String find, String replace) replaceInTitle,
    required TResult Function(String find, String replace) replaceInArtist,
    required TResult Function(String find, String replace) replaceInAlbum,
    required TResult Function(String find, String replace) replaceInAll,
    required TResult Function(String field0) setTitleIfEmpty,
    required TResult Function(String field0) setArtistIfEmpty,
    required TResult Function(String field0) setAlbumIfEmpty,
    required TResult Function(String field0) setGenreIfEmpty,
    required TResult Function(String field0) setAlbumArtistIfEmpty,
    required TResult Function() removeEmptyFields,
    required TResult Function() removeNonCoverPictures,
  }) {
    final _that = this;
    switch (_that) {
      case TransformRule_TrimWhitespace():
        return trimWhitespace();
      case TransformRule_NormalizeWhitespace():
        return normalizeWhitespace();
      case TransformRule_NormalizeUnicode():
        return normalizeUnicode();
      case TransformRule_SetTitle():
        return setTitle(_that.field0);
      case TransformRule_SetArtist():
        return setArtist(_that.field0);
      case TransformRule_SetAlbum():
        return setAlbum(_that.field0);
      case TransformRule_SetAlbumArtist():
        return setAlbumArtist(_that.field0);
      case TransformRule_SetGenre():
        return setGenre(_that.field0);
      case TransformRule_SetYear():
        return setYear(_that.field0);
      case TransformRule_SetTrackNumber():
        return setTrackNumber(_that.field0);
      case TransformRule_SetDiscNumber():
        return setDiscNumber(_that.field0);
      case TransformRule_SetTrackTotal():
        return setTrackTotal(_that.field0);
      case TransformRule_SetDiscTotal():
        return setDiscTotal(_that.field0);
      case TransformRule_SetBpm():
        return setBpm(_that.field0);
      case TransformRule_SetComment():
        return setComment(_that.field0);
      case TransformRule_RemoveLyrics():
        return removeLyrics();
      case TransformRule_RemoveComment():
        return removeComment();
      case TransformRule_RemovePictures():
        return removePictures();
      case TransformRule_RemoveBpm():
        return removeBpm();
      case TransformRule_RemoveReplayGain():
        return removeReplayGain();
      case TransformRule_RemoveTitle():
        return removeTitle();
      case TransformRule_RemoveArtist():
        return removeArtist();
      case TransformRule_RemoveAlbum():
        return removeAlbum();
      case TransformRule_RemoveAlbumArtist():
        return removeAlbumArtist();
      case TransformRule_RemoveGenre():
        return removeGenre();
      case TransformRule_RemoveYear():
        return removeYear();
      case TransformRule_RemoveTrackNumber():
        return removeTrackNumber();
      case TransformRule_RemoveDiscNumber():
        return removeDiscNumber();
      case TransformRule_NormalizeTrackNumbers():
        return normalizeTrackNumbers();
      case TransformRule_NormalizeDiscNumbers():
        return normalizeDiscNumbers();
      case TransformRule_NormalizeYear():
        return normalizeYear();
      case TransformRule_CopyArtistToAlbumArtist():
        return copyArtistToAlbumArtist();
      case TransformRule_CopyAlbumArtistToArtist():
        return copyAlbumArtistToArtist();
      case TransformRule_CopyTitleToComment():
        return copyTitleToComment();
      case TransformRule_PrefixTitle():
        return prefixTitle(_that.field0);
      case TransformRule_SuffixTitle():
        return suffixTitle(_that.field0);
      case TransformRule_PrefixAlbum():
        return prefixAlbum(_that.field0);
      case TransformRule_SuffixAlbum():
        return suffixAlbum(_that.field0);
      case TransformRule_PrefixArtist():
        return prefixArtist(_that.field0);
      case TransformRule_SuffixArtist():
        return suffixArtist(_that.field0);
      case TransformRule_TitleCaseTitle():
        return titleCaseTitle();
      case TransformRule_TitleCaseArtist():
        return titleCaseArtist();
      case TransformRule_TitleCaseAlbum():
        return titleCaseAlbum();
      case TransformRule_LowerCaseAll():
        return lowerCaseAll();
      case TransformRule_UpperCaseAll():
        return upperCaseAll();
      case TransformRule_ReplaceInTitle():
        return replaceInTitle(_that.find, _that.replace);
      case TransformRule_ReplaceInArtist():
        return replaceInArtist(_that.find, _that.replace);
      case TransformRule_ReplaceInAlbum():
        return replaceInAlbum(_that.find, _that.replace);
      case TransformRule_ReplaceInAll():
        return replaceInAll(_that.find, _that.replace);
      case TransformRule_SetTitleIfEmpty():
        return setTitleIfEmpty(_that.field0);
      case TransformRule_SetArtistIfEmpty():
        return setArtistIfEmpty(_that.field0);
      case TransformRule_SetAlbumIfEmpty():
        return setAlbumIfEmpty(_that.field0);
      case TransformRule_SetGenreIfEmpty():
        return setGenreIfEmpty(_that.field0);
      case TransformRule_SetAlbumArtistIfEmpty():
        return setAlbumArtistIfEmpty(_that.field0);
      case TransformRule_RemoveEmptyFields():
        return removeEmptyFields();
      case TransformRule_RemoveNonCoverPictures():
        return removeNonCoverPictures();
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? trimWhitespace,
    TResult? Function()? normalizeWhitespace,
    TResult? Function()? normalizeUnicode,
    TResult? Function(String field0)? setTitle,
    TResult? Function(String field0)? setArtist,
    TResult? Function(String field0)? setAlbum,
    TResult? Function(String field0)? setAlbumArtist,
    TResult? Function(String field0)? setGenre,
    TResult? Function(int field0)? setYear,
    TResult? Function(int field0)? setTrackNumber,
    TResult? Function(int field0)? setDiscNumber,
    TResult? Function(int field0)? setTrackTotal,
    TResult? Function(int field0)? setDiscTotal,
    TResult? Function(double field0)? setBpm,
    TResult? Function(String field0)? setComment,
    TResult? Function()? removeLyrics,
    TResult? Function()? removeComment,
    TResult? Function()? removePictures,
    TResult? Function()? removeBpm,
    TResult? Function()? removeReplayGain,
    TResult? Function()? removeTitle,
    TResult? Function()? removeArtist,
    TResult? Function()? removeAlbum,
    TResult? Function()? removeAlbumArtist,
    TResult? Function()? removeGenre,
    TResult? Function()? removeYear,
    TResult? Function()? removeTrackNumber,
    TResult? Function()? removeDiscNumber,
    TResult? Function()? normalizeTrackNumbers,
    TResult? Function()? normalizeDiscNumbers,
    TResult? Function()? normalizeYear,
    TResult? Function()? copyArtistToAlbumArtist,
    TResult? Function()? copyAlbumArtistToArtist,
    TResult? Function()? copyTitleToComment,
    TResult? Function(String field0)? prefixTitle,
    TResult? Function(String field0)? suffixTitle,
    TResult? Function(String field0)? prefixAlbum,
    TResult? Function(String field0)? suffixAlbum,
    TResult? Function(String field0)? prefixArtist,
    TResult? Function(String field0)? suffixArtist,
    TResult? Function()? titleCaseTitle,
    TResult? Function()? titleCaseArtist,
    TResult? Function()? titleCaseAlbum,
    TResult? Function()? lowerCaseAll,
    TResult? Function()? upperCaseAll,
    TResult? Function(String find, String replace)? replaceInTitle,
    TResult? Function(String find, String replace)? replaceInArtist,
    TResult? Function(String find, String replace)? replaceInAlbum,
    TResult? Function(String find, String replace)? replaceInAll,
    TResult? Function(String field0)? setTitleIfEmpty,
    TResult? Function(String field0)? setArtistIfEmpty,
    TResult? Function(String field0)? setAlbumIfEmpty,
    TResult? Function(String field0)? setGenreIfEmpty,
    TResult? Function(String field0)? setAlbumArtistIfEmpty,
    TResult? Function()? removeEmptyFields,
    TResult? Function()? removeNonCoverPictures,
  }) {
    final _that = this;
    switch (_that) {
      case TransformRule_TrimWhitespace() when trimWhitespace != null:
        return trimWhitespace();
      case TransformRule_NormalizeWhitespace() when normalizeWhitespace != null:
        return normalizeWhitespace();
      case TransformRule_NormalizeUnicode() when normalizeUnicode != null:
        return normalizeUnicode();
      case TransformRule_SetTitle() when setTitle != null:
        return setTitle(_that.field0);
      case TransformRule_SetArtist() when setArtist != null:
        return setArtist(_that.field0);
      case TransformRule_SetAlbum() when setAlbum != null:
        return setAlbum(_that.field0);
      case TransformRule_SetAlbumArtist() when setAlbumArtist != null:
        return setAlbumArtist(_that.field0);
      case TransformRule_SetGenre() when setGenre != null:
        return setGenre(_that.field0);
      case TransformRule_SetYear() when setYear != null:
        return setYear(_that.field0);
      case TransformRule_SetTrackNumber() when setTrackNumber != null:
        return setTrackNumber(_that.field0);
      case TransformRule_SetDiscNumber() when setDiscNumber != null:
        return setDiscNumber(_that.field0);
      case TransformRule_SetTrackTotal() when setTrackTotal != null:
        return setTrackTotal(_that.field0);
      case TransformRule_SetDiscTotal() when setDiscTotal != null:
        return setDiscTotal(_that.field0);
      case TransformRule_SetBpm() when setBpm != null:
        return setBpm(_that.field0);
      case TransformRule_SetComment() when setComment != null:
        return setComment(_that.field0);
      case TransformRule_RemoveLyrics() when removeLyrics != null:
        return removeLyrics();
      case TransformRule_RemoveComment() when removeComment != null:
        return removeComment();
      case TransformRule_RemovePictures() when removePictures != null:
        return removePictures();
      case TransformRule_RemoveBpm() when removeBpm != null:
        return removeBpm();
      case TransformRule_RemoveReplayGain() when removeReplayGain != null:
        return removeReplayGain();
      case TransformRule_RemoveTitle() when removeTitle != null:
        return removeTitle();
      case TransformRule_RemoveArtist() when removeArtist != null:
        return removeArtist();
      case TransformRule_RemoveAlbum() when removeAlbum != null:
        return removeAlbum();
      case TransformRule_RemoveAlbumArtist() when removeAlbumArtist != null:
        return removeAlbumArtist();
      case TransformRule_RemoveGenre() when removeGenre != null:
        return removeGenre();
      case TransformRule_RemoveYear() when removeYear != null:
        return removeYear();
      case TransformRule_RemoveTrackNumber() when removeTrackNumber != null:
        return removeTrackNumber();
      case TransformRule_RemoveDiscNumber() when removeDiscNumber != null:
        return removeDiscNumber();
      case TransformRule_NormalizeTrackNumbers()
          when normalizeTrackNumbers != null:
        return normalizeTrackNumbers();
      case TransformRule_NormalizeDiscNumbers()
          when normalizeDiscNumbers != null:
        return normalizeDiscNumbers();
      case TransformRule_NormalizeYear() when normalizeYear != null:
        return normalizeYear();
      case TransformRule_CopyArtistToAlbumArtist()
          when copyArtistToAlbumArtist != null:
        return copyArtistToAlbumArtist();
      case TransformRule_CopyAlbumArtistToArtist()
          when copyAlbumArtistToArtist != null:
        return copyAlbumArtistToArtist();
      case TransformRule_CopyTitleToComment() when copyTitleToComment != null:
        return copyTitleToComment();
      case TransformRule_PrefixTitle() when prefixTitle != null:
        return prefixTitle(_that.field0);
      case TransformRule_SuffixTitle() when suffixTitle != null:
        return suffixTitle(_that.field0);
      case TransformRule_PrefixAlbum() when prefixAlbum != null:
        return prefixAlbum(_that.field0);
      case TransformRule_SuffixAlbum() when suffixAlbum != null:
        return suffixAlbum(_that.field0);
      case TransformRule_PrefixArtist() when prefixArtist != null:
        return prefixArtist(_that.field0);
      case TransformRule_SuffixArtist() when suffixArtist != null:
        return suffixArtist(_that.field0);
      case TransformRule_TitleCaseTitle() when titleCaseTitle != null:
        return titleCaseTitle();
      case TransformRule_TitleCaseArtist() when titleCaseArtist != null:
        return titleCaseArtist();
      case TransformRule_TitleCaseAlbum() when titleCaseAlbum != null:
        return titleCaseAlbum();
      case TransformRule_LowerCaseAll() when lowerCaseAll != null:
        return lowerCaseAll();
      case TransformRule_UpperCaseAll() when upperCaseAll != null:
        return upperCaseAll();
      case TransformRule_ReplaceInTitle() when replaceInTitle != null:
        return replaceInTitle(_that.find, _that.replace);
      case TransformRule_ReplaceInArtist() when replaceInArtist != null:
        return replaceInArtist(_that.find, _that.replace);
      case TransformRule_ReplaceInAlbum() when replaceInAlbum != null:
        return replaceInAlbum(_that.find, _that.replace);
      case TransformRule_ReplaceInAll() when replaceInAll != null:
        return replaceInAll(_that.find, _that.replace);
      case TransformRule_SetTitleIfEmpty() when setTitleIfEmpty != null:
        return setTitleIfEmpty(_that.field0);
      case TransformRule_SetArtistIfEmpty() when setArtistIfEmpty != null:
        return setArtistIfEmpty(_that.field0);
      case TransformRule_SetAlbumIfEmpty() when setAlbumIfEmpty != null:
        return setAlbumIfEmpty(_that.field0);
      case TransformRule_SetGenreIfEmpty() when setGenreIfEmpty != null:
        return setGenreIfEmpty(_that.field0);
      case TransformRule_SetAlbumArtistIfEmpty()
          when setAlbumArtistIfEmpty != null:
        return setAlbumArtistIfEmpty(_that.field0);
      case TransformRule_RemoveEmptyFields() when removeEmptyFields != null:
        return removeEmptyFields();
      case TransformRule_RemoveNonCoverPictures()
          when removeNonCoverPictures != null:
        return removeNonCoverPictures();
      case _:
        return null;
    }
  }
}

/// @nodoc

class TransformRule_TrimWhitespace extends TransformRule {
  const TransformRule_TrimWhitespace() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_TrimWhitespace);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.trimWhitespace()';
  }
}

/// @nodoc

class TransformRule_NormalizeWhitespace extends TransformRule {
  const TransformRule_NormalizeWhitespace() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_NormalizeWhitespace);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.normalizeWhitespace()';
  }
}

/// @nodoc

class TransformRule_NormalizeUnicode extends TransformRule {
  const TransformRule_NormalizeUnicode() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_NormalizeUnicode);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.normalizeUnicode()';
  }
}

/// @nodoc

class TransformRule_SetTitle extends TransformRule {
  const TransformRule_SetTitle(this.field0) : super._();

  final String field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SetTitleCopyWith<TransformRule_SetTitle> get copyWith =>
      _$TransformRule_SetTitleCopyWithImpl<TransformRule_SetTitle>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SetTitle &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.setTitle(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SetTitleCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SetTitleCopyWith(TransformRule_SetTitle value,
          $Res Function(TransformRule_SetTitle) _then) =
      _$TransformRule_SetTitleCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$TransformRule_SetTitleCopyWithImpl<$Res>
    implements $TransformRule_SetTitleCopyWith<$Res> {
  _$TransformRule_SetTitleCopyWithImpl(this._self, this._then);

  final TransformRule_SetTitle _self;
  final $Res Function(TransformRule_SetTitle) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SetTitle(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_SetArtist extends TransformRule {
  const TransformRule_SetArtist(this.field0) : super._();

  final String field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SetArtistCopyWith<TransformRule_SetArtist> get copyWith =>
      _$TransformRule_SetArtistCopyWithImpl<TransformRule_SetArtist>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SetArtist &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.setArtist(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SetArtistCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SetArtistCopyWith(TransformRule_SetArtist value,
          $Res Function(TransformRule_SetArtist) _then) =
      _$TransformRule_SetArtistCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$TransformRule_SetArtistCopyWithImpl<$Res>
    implements $TransformRule_SetArtistCopyWith<$Res> {
  _$TransformRule_SetArtistCopyWithImpl(this._self, this._then);

  final TransformRule_SetArtist _self;
  final $Res Function(TransformRule_SetArtist) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SetArtist(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_SetAlbum extends TransformRule {
  const TransformRule_SetAlbum(this.field0) : super._();

  final String field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SetAlbumCopyWith<TransformRule_SetAlbum> get copyWith =>
      _$TransformRule_SetAlbumCopyWithImpl<TransformRule_SetAlbum>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SetAlbum &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.setAlbum(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SetAlbumCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SetAlbumCopyWith(TransformRule_SetAlbum value,
          $Res Function(TransformRule_SetAlbum) _then) =
      _$TransformRule_SetAlbumCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$TransformRule_SetAlbumCopyWithImpl<$Res>
    implements $TransformRule_SetAlbumCopyWith<$Res> {
  _$TransformRule_SetAlbumCopyWithImpl(this._self, this._then);

  final TransformRule_SetAlbum _self;
  final $Res Function(TransformRule_SetAlbum) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SetAlbum(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_SetAlbumArtist extends TransformRule {
  const TransformRule_SetAlbumArtist(this.field0) : super._();

  final String field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SetAlbumArtistCopyWith<TransformRule_SetAlbumArtist>
      get copyWith => _$TransformRule_SetAlbumArtistCopyWithImpl<
          TransformRule_SetAlbumArtist>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SetAlbumArtist &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.setAlbumArtist(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SetAlbumArtistCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SetAlbumArtistCopyWith(
          TransformRule_SetAlbumArtist value,
          $Res Function(TransformRule_SetAlbumArtist) _then) =
      _$TransformRule_SetAlbumArtistCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$TransformRule_SetAlbumArtistCopyWithImpl<$Res>
    implements $TransformRule_SetAlbumArtistCopyWith<$Res> {
  _$TransformRule_SetAlbumArtistCopyWithImpl(this._self, this._then);

  final TransformRule_SetAlbumArtist _self;
  final $Res Function(TransformRule_SetAlbumArtist) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SetAlbumArtist(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_SetGenre extends TransformRule {
  const TransformRule_SetGenre(this.field0) : super._();

  final String field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SetGenreCopyWith<TransformRule_SetGenre> get copyWith =>
      _$TransformRule_SetGenreCopyWithImpl<TransformRule_SetGenre>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SetGenre &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.setGenre(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SetGenreCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SetGenreCopyWith(TransformRule_SetGenre value,
          $Res Function(TransformRule_SetGenre) _then) =
      _$TransformRule_SetGenreCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$TransformRule_SetGenreCopyWithImpl<$Res>
    implements $TransformRule_SetGenreCopyWith<$Res> {
  _$TransformRule_SetGenreCopyWithImpl(this._self, this._then);

  final TransformRule_SetGenre _self;
  final $Res Function(TransformRule_SetGenre) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SetGenre(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_SetYear extends TransformRule {
  const TransformRule_SetYear(this.field0) : super._();

  final int field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SetYearCopyWith<TransformRule_SetYear> get copyWith =>
      _$TransformRule_SetYearCopyWithImpl<TransformRule_SetYear>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SetYear &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.setYear(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SetYearCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SetYearCopyWith(TransformRule_SetYear value,
          $Res Function(TransformRule_SetYear) _then) =
      _$TransformRule_SetYearCopyWithImpl;
  @useResult
  $Res call({int field0});
}

/// @nodoc
class _$TransformRule_SetYearCopyWithImpl<$Res>
    implements $TransformRule_SetYearCopyWith<$Res> {
  _$TransformRule_SetYearCopyWithImpl(this._self, this._then);

  final TransformRule_SetYear _self;
  final $Res Function(TransformRule_SetYear) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SetYear(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class TransformRule_SetTrackNumber extends TransformRule {
  const TransformRule_SetTrackNumber(this.field0) : super._();

  final int field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SetTrackNumberCopyWith<TransformRule_SetTrackNumber>
      get copyWith => _$TransformRule_SetTrackNumberCopyWithImpl<
          TransformRule_SetTrackNumber>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SetTrackNumber &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.setTrackNumber(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SetTrackNumberCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SetTrackNumberCopyWith(
          TransformRule_SetTrackNumber value,
          $Res Function(TransformRule_SetTrackNumber) _then) =
      _$TransformRule_SetTrackNumberCopyWithImpl;
  @useResult
  $Res call({int field0});
}

/// @nodoc
class _$TransformRule_SetTrackNumberCopyWithImpl<$Res>
    implements $TransformRule_SetTrackNumberCopyWith<$Res> {
  _$TransformRule_SetTrackNumberCopyWithImpl(this._self, this._then);

  final TransformRule_SetTrackNumber _self;
  final $Res Function(TransformRule_SetTrackNumber) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SetTrackNumber(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class TransformRule_SetDiscNumber extends TransformRule {
  const TransformRule_SetDiscNumber(this.field0) : super._();

  final int field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SetDiscNumberCopyWith<TransformRule_SetDiscNumber>
      get copyWith => _$TransformRule_SetDiscNumberCopyWithImpl<
          TransformRule_SetDiscNumber>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SetDiscNumber &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.setDiscNumber(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SetDiscNumberCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SetDiscNumberCopyWith(
          TransformRule_SetDiscNumber value,
          $Res Function(TransformRule_SetDiscNumber) _then) =
      _$TransformRule_SetDiscNumberCopyWithImpl;
  @useResult
  $Res call({int field0});
}

/// @nodoc
class _$TransformRule_SetDiscNumberCopyWithImpl<$Res>
    implements $TransformRule_SetDiscNumberCopyWith<$Res> {
  _$TransformRule_SetDiscNumberCopyWithImpl(this._self, this._then);

  final TransformRule_SetDiscNumber _self;
  final $Res Function(TransformRule_SetDiscNumber) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SetDiscNumber(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class TransformRule_SetTrackTotal extends TransformRule {
  const TransformRule_SetTrackTotal(this.field0) : super._();

  final int field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SetTrackTotalCopyWith<TransformRule_SetTrackTotal>
      get copyWith => _$TransformRule_SetTrackTotalCopyWithImpl<
          TransformRule_SetTrackTotal>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SetTrackTotal &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.setTrackTotal(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SetTrackTotalCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SetTrackTotalCopyWith(
          TransformRule_SetTrackTotal value,
          $Res Function(TransformRule_SetTrackTotal) _then) =
      _$TransformRule_SetTrackTotalCopyWithImpl;
  @useResult
  $Res call({int field0});
}

/// @nodoc
class _$TransformRule_SetTrackTotalCopyWithImpl<$Res>
    implements $TransformRule_SetTrackTotalCopyWith<$Res> {
  _$TransformRule_SetTrackTotalCopyWithImpl(this._self, this._then);

  final TransformRule_SetTrackTotal _self;
  final $Res Function(TransformRule_SetTrackTotal) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SetTrackTotal(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class TransformRule_SetDiscTotal extends TransformRule {
  const TransformRule_SetDiscTotal(this.field0) : super._();

  final int field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SetDiscTotalCopyWith<TransformRule_SetDiscTotal>
      get copyWith =>
          _$TransformRule_SetDiscTotalCopyWithImpl<TransformRule_SetDiscTotal>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SetDiscTotal &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.setDiscTotal(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SetDiscTotalCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SetDiscTotalCopyWith(TransformRule_SetDiscTotal value,
          $Res Function(TransformRule_SetDiscTotal) _then) =
      _$TransformRule_SetDiscTotalCopyWithImpl;
  @useResult
  $Res call({int field0});
}

/// @nodoc
class _$TransformRule_SetDiscTotalCopyWithImpl<$Res>
    implements $TransformRule_SetDiscTotalCopyWith<$Res> {
  _$TransformRule_SetDiscTotalCopyWithImpl(this._self, this._then);

  final TransformRule_SetDiscTotal _self;
  final $Res Function(TransformRule_SetDiscTotal) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SetDiscTotal(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class TransformRule_SetBpm extends TransformRule {
  const TransformRule_SetBpm(this.field0) : super._();

  final double field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SetBpmCopyWith<TransformRule_SetBpm> get copyWith =>
      _$TransformRule_SetBpmCopyWithImpl<TransformRule_SetBpm>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SetBpm &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.setBpm(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SetBpmCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SetBpmCopyWith(TransformRule_SetBpm value,
          $Res Function(TransformRule_SetBpm) _then) =
      _$TransformRule_SetBpmCopyWithImpl;
  @useResult
  $Res call({double field0});
}

/// @nodoc
class _$TransformRule_SetBpmCopyWithImpl<$Res>
    implements $TransformRule_SetBpmCopyWith<$Res> {
  _$TransformRule_SetBpmCopyWithImpl(this._self, this._then);

  final TransformRule_SetBpm _self;
  final $Res Function(TransformRule_SetBpm) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SetBpm(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class TransformRule_SetComment extends TransformRule {
  const TransformRule_SetComment(this.field0) : super._();

  final String field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SetCommentCopyWith<TransformRule_SetComment> get copyWith =>
      _$TransformRule_SetCommentCopyWithImpl<TransformRule_SetComment>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SetComment &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.setComment(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SetCommentCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SetCommentCopyWith(TransformRule_SetComment value,
          $Res Function(TransformRule_SetComment) _then) =
      _$TransformRule_SetCommentCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$TransformRule_SetCommentCopyWithImpl<$Res>
    implements $TransformRule_SetCommentCopyWith<$Res> {
  _$TransformRule_SetCommentCopyWithImpl(this._self, this._then);

  final TransformRule_SetComment _self;
  final $Res Function(TransformRule_SetComment) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SetComment(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_RemoveLyrics extends TransformRule {
  const TransformRule_RemoveLyrics() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_RemoveLyrics);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.removeLyrics()';
  }
}

/// @nodoc

class TransformRule_RemoveComment extends TransformRule {
  const TransformRule_RemoveComment() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_RemoveComment);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.removeComment()';
  }
}

/// @nodoc

class TransformRule_RemovePictures extends TransformRule {
  const TransformRule_RemovePictures() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_RemovePictures);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.removePictures()';
  }
}

/// @nodoc

class TransformRule_RemoveBpm extends TransformRule {
  const TransformRule_RemoveBpm() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is TransformRule_RemoveBpm);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.removeBpm()';
  }
}

/// @nodoc

class TransformRule_RemoveReplayGain extends TransformRule {
  const TransformRule_RemoveReplayGain() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_RemoveReplayGain);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.removeReplayGain()';
  }
}

/// @nodoc

class TransformRule_RemoveTitle extends TransformRule {
  const TransformRule_RemoveTitle() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_RemoveTitle);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.removeTitle()';
  }
}

/// @nodoc

class TransformRule_RemoveArtist extends TransformRule {
  const TransformRule_RemoveArtist() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_RemoveArtist);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.removeArtist()';
  }
}

/// @nodoc

class TransformRule_RemoveAlbum extends TransformRule {
  const TransformRule_RemoveAlbum() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_RemoveAlbum);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.removeAlbum()';
  }
}

/// @nodoc

class TransformRule_RemoveAlbumArtist extends TransformRule {
  const TransformRule_RemoveAlbumArtist() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_RemoveAlbumArtist);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.removeAlbumArtist()';
  }
}

/// @nodoc

class TransformRule_RemoveGenre extends TransformRule {
  const TransformRule_RemoveGenre() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_RemoveGenre);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.removeGenre()';
  }
}

/// @nodoc

class TransformRule_RemoveYear extends TransformRule {
  const TransformRule_RemoveYear() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is TransformRule_RemoveYear);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.removeYear()';
  }
}

/// @nodoc

class TransformRule_RemoveTrackNumber extends TransformRule {
  const TransformRule_RemoveTrackNumber() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_RemoveTrackNumber);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.removeTrackNumber()';
  }
}

/// @nodoc

class TransformRule_RemoveDiscNumber extends TransformRule {
  const TransformRule_RemoveDiscNumber() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_RemoveDiscNumber);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.removeDiscNumber()';
  }
}

/// @nodoc

class TransformRule_NormalizeTrackNumbers extends TransformRule {
  const TransformRule_NormalizeTrackNumbers() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_NormalizeTrackNumbers);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.normalizeTrackNumbers()';
  }
}

/// @nodoc

class TransformRule_NormalizeDiscNumbers extends TransformRule {
  const TransformRule_NormalizeDiscNumbers() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_NormalizeDiscNumbers);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.normalizeDiscNumbers()';
  }
}

/// @nodoc

class TransformRule_NormalizeYear extends TransformRule {
  const TransformRule_NormalizeYear() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_NormalizeYear);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.normalizeYear()';
  }
}

/// @nodoc

class TransformRule_CopyArtistToAlbumArtist extends TransformRule {
  const TransformRule_CopyArtistToAlbumArtist() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_CopyArtistToAlbumArtist);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.copyArtistToAlbumArtist()';
  }
}

/// @nodoc

class TransformRule_CopyAlbumArtistToArtist extends TransformRule {
  const TransformRule_CopyAlbumArtistToArtist() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_CopyAlbumArtistToArtist);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.copyAlbumArtistToArtist()';
  }
}

/// @nodoc

class TransformRule_CopyTitleToComment extends TransformRule {
  const TransformRule_CopyTitleToComment() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_CopyTitleToComment);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.copyTitleToComment()';
  }
}

/// @nodoc

class TransformRule_PrefixTitle extends TransformRule {
  const TransformRule_PrefixTitle(this.field0) : super._();

  final String field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_PrefixTitleCopyWith<TransformRule_PrefixTitle> get copyWith =>
      _$TransformRule_PrefixTitleCopyWithImpl<TransformRule_PrefixTitle>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_PrefixTitle &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.prefixTitle(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_PrefixTitleCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_PrefixTitleCopyWith(TransformRule_PrefixTitle value,
          $Res Function(TransformRule_PrefixTitle) _then) =
      _$TransformRule_PrefixTitleCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$TransformRule_PrefixTitleCopyWithImpl<$Res>
    implements $TransformRule_PrefixTitleCopyWith<$Res> {
  _$TransformRule_PrefixTitleCopyWithImpl(this._self, this._then);

  final TransformRule_PrefixTitle _self;
  final $Res Function(TransformRule_PrefixTitle) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_PrefixTitle(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_SuffixTitle extends TransformRule {
  const TransformRule_SuffixTitle(this.field0) : super._();

  final String field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SuffixTitleCopyWith<TransformRule_SuffixTitle> get copyWith =>
      _$TransformRule_SuffixTitleCopyWithImpl<TransformRule_SuffixTitle>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SuffixTitle &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.suffixTitle(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SuffixTitleCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SuffixTitleCopyWith(TransformRule_SuffixTitle value,
          $Res Function(TransformRule_SuffixTitle) _then) =
      _$TransformRule_SuffixTitleCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$TransformRule_SuffixTitleCopyWithImpl<$Res>
    implements $TransformRule_SuffixTitleCopyWith<$Res> {
  _$TransformRule_SuffixTitleCopyWithImpl(this._self, this._then);

  final TransformRule_SuffixTitle _self;
  final $Res Function(TransformRule_SuffixTitle) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SuffixTitle(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_PrefixAlbum extends TransformRule {
  const TransformRule_PrefixAlbum(this.field0) : super._();

  final String field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_PrefixAlbumCopyWith<TransformRule_PrefixAlbum> get copyWith =>
      _$TransformRule_PrefixAlbumCopyWithImpl<TransformRule_PrefixAlbum>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_PrefixAlbum &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.prefixAlbum(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_PrefixAlbumCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_PrefixAlbumCopyWith(TransformRule_PrefixAlbum value,
          $Res Function(TransformRule_PrefixAlbum) _then) =
      _$TransformRule_PrefixAlbumCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$TransformRule_PrefixAlbumCopyWithImpl<$Res>
    implements $TransformRule_PrefixAlbumCopyWith<$Res> {
  _$TransformRule_PrefixAlbumCopyWithImpl(this._self, this._then);

  final TransformRule_PrefixAlbum _self;
  final $Res Function(TransformRule_PrefixAlbum) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_PrefixAlbum(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_SuffixAlbum extends TransformRule {
  const TransformRule_SuffixAlbum(this.field0) : super._();

  final String field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SuffixAlbumCopyWith<TransformRule_SuffixAlbum> get copyWith =>
      _$TransformRule_SuffixAlbumCopyWithImpl<TransformRule_SuffixAlbum>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SuffixAlbum &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.suffixAlbum(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SuffixAlbumCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SuffixAlbumCopyWith(TransformRule_SuffixAlbum value,
          $Res Function(TransformRule_SuffixAlbum) _then) =
      _$TransformRule_SuffixAlbumCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$TransformRule_SuffixAlbumCopyWithImpl<$Res>
    implements $TransformRule_SuffixAlbumCopyWith<$Res> {
  _$TransformRule_SuffixAlbumCopyWithImpl(this._self, this._then);

  final TransformRule_SuffixAlbum _self;
  final $Res Function(TransformRule_SuffixAlbum) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SuffixAlbum(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_PrefixArtist extends TransformRule {
  const TransformRule_PrefixArtist(this.field0) : super._();

  final String field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_PrefixArtistCopyWith<TransformRule_PrefixArtist>
      get copyWith =>
          _$TransformRule_PrefixArtistCopyWithImpl<TransformRule_PrefixArtist>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_PrefixArtist &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.prefixArtist(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_PrefixArtistCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_PrefixArtistCopyWith(TransformRule_PrefixArtist value,
          $Res Function(TransformRule_PrefixArtist) _then) =
      _$TransformRule_PrefixArtistCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$TransformRule_PrefixArtistCopyWithImpl<$Res>
    implements $TransformRule_PrefixArtistCopyWith<$Res> {
  _$TransformRule_PrefixArtistCopyWithImpl(this._self, this._then);

  final TransformRule_PrefixArtist _self;
  final $Res Function(TransformRule_PrefixArtist) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_PrefixArtist(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_SuffixArtist extends TransformRule {
  const TransformRule_SuffixArtist(this.field0) : super._();

  final String field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SuffixArtistCopyWith<TransformRule_SuffixArtist>
      get copyWith =>
          _$TransformRule_SuffixArtistCopyWithImpl<TransformRule_SuffixArtist>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SuffixArtist &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.suffixArtist(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SuffixArtistCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SuffixArtistCopyWith(TransformRule_SuffixArtist value,
          $Res Function(TransformRule_SuffixArtist) _then) =
      _$TransformRule_SuffixArtistCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$TransformRule_SuffixArtistCopyWithImpl<$Res>
    implements $TransformRule_SuffixArtistCopyWith<$Res> {
  _$TransformRule_SuffixArtistCopyWithImpl(this._self, this._then);

  final TransformRule_SuffixArtist _self;
  final $Res Function(TransformRule_SuffixArtist) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SuffixArtist(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_TitleCaseTitle extends TransformRule {
  const TransformRule_TitleCaseTitle() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_TitleCaseTitle);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.titleCaseTitle()';
  }
}

/// @nodoc

class TransformRule_TitleCaseArtist extends TransformRule {
  const TransformRule_TitleCaseArtist() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_TitleCaseArtist);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.titleCaseArtist()';
  }
}

/// @nodoc

class TransformRule_TitleCaseAlbum extends TransformRule {
  const TransformRule_TitleCaseAlbum() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_TitleCaseAlbum);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.titleCaseAlbum()';
  }
}

/// @nodoc

class TransformRule_LowerCaseAll extends TransformRule {
  const TransformRule_LowerCaseAll() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_LowerCaseAll);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.lowerCaseAll()';
  }
}

/// @nodoc

class TransformRule_UpperCaseAll extends TransformRule {
  const TransformRule_UpperCaseAll() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_UpperCaseAll);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.upperCaseAll()';
  }
}

/// @nodoc

class TransformRule_ReplaceInTitle extends TransformRule {
  const TransformRule_ReplaceInTitle(
      {required this.find, required this.replace})
      : super._();

  final String find;
  final String replace;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_ReplaceInTitleCopyWith<TransformRule_ReplaceInTitle>
      get copyWith => _$TransformRule_ReplaceInTitleCopyWithImpl<
          TransformRule_ReplaceInTitle>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_ReplaceInTitle &&
            (identical(other.find, find) || other.find == find) &&
            (identical(other.replace, replace) || other.replace == replace));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, find, replace);
  }

  @override
  String toString() {
    return 'TransformRule.replaceInTitle(find: $find, replace: $replace)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_ReplaceInTitleCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_ReplaceInTitleCopyWith(
          TransformRule_ReplaceInTitle value,
          $Res Function(TransformRule_ReplaceInTitle) _then) =
      _$TransformRule_ReplaceInTitleCopyWithImpl;
  @useResult
  $Res call({String find, String replace});
}

/// @nodoc
class _$TransformRule_ReplaceInTitleCopyWithImpl<$Res>
    implements $TransformRule_ReplaceInTitleCopyWith<$Res> {
  _$TransformRule_ReplaceInTitleCopyWithImpl(this._self, this._then);

  final TransformRule_ReplaceInTitle _self;
  final $Res Function(TransformRule_ReplaceInTitle) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? find = null,
    Object? replace = null,
  }) {
    return _then(TransformRule_ReplaceInTitle(
      find: null == find
          ? _self.find
          : find // ignore: cast_nullable_to_non_nullable
              as String,
      replace: null == replace
          ? _self.replace
          : replace // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_ReplaceInArtist extends TransformRule {
  const TransformRule_ReplaceInArtist(
      {required this.find, required this.replace})
      : super._();

  final String find;
  final String replace;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_ReplaceInArtistCopyWith<TransformRule_ReplaceInArtist>
      get copyWith => _$TransformRule_ReplaceInArtistCopyWithImpl<
          TransformRule_ReplaceInArtist>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_ReplaceInArtist &&
            (identical(other.find, find) || other.find == find) &&
            (identical(other.replace, replace) || other.replace == replace));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, find, replace);
  }

  @override
  String toString() {
    return 'TransformRule.replaceInArtist(find: $find, replace: $replace)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_ReplaceInArtistCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_ReplaceInArtistCopyWith(
          TransformRule_ReplaceInArtist value,
          $Res Function(TransformRule_ReplaceInArtist) _then) =
      _$TransformRule_ReplaceInArtistCopyWithImpl;
  @useResult
  $Res call({String find, String replace});
}

/// @nodoc
class _$TransformRule_ReplaceInArtistCopyWithImpl<$Res>
    implements $TransformRule_ReplaceInArtistCopyWith<$Res> {
  _$TransformRule_ReplaceInArtistCopyWithImpl(this._self, this._then);

  final TransformRule_ReplaceInArtist _self;
  final $Res Function(TransformRule_ReplaceInArtist) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? find = null,
    Object? replace = null,
  }) {
    return _then(TransformRule_ReplaceInArtist(
      find: null == find
          ? _self.find
          : find // ignore: cast_nullable_to_non_nullable
              as String,
      replace: null == replace
          ? _self.replace
          : replace // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_ReplaceInAlbum extends TransformRule {
  const TransformRule_ReplaceInAlbum(
      {required this.find, required this.replace})
      : super._();

  final String find;
  final String replace;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_ReplaceInAlbumCopyWith<TransformRule_ReplaceInAlbum>
      get copyWith => _$TransformRule_ReplaceInAlbumCopyWithImpl<
          TransformRule_ReplaceInAlbum>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_ReplaceInAlbum &&
            (identical(other.find, find) || other.find == find) &&
            (identical(other.replace, replace) || other.replace == replace));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, find, replace);
  }

  @override
  String toString() {
    return 'TransformRule.replaceInAlbum(find: $find, replace: $replace)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_ReplaceInAlbumCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_ReplaceInAlbumCopyWith(
          TransformRule_ReplaceInAlbum value,
          $Res Function(TransformRule_ReplaceInAlbum) _then) =
      _$TransformRule_ReplaceInAlbumCopyWithImpl;
  @useResult
  $Res call({String find, String replace});
}

/// @nodoc
class _$TransformRule_ReplaceInAlbumCopyWithImpl<$Res>
    implements $TransformRule_ReplaceInAlbumCopyWith<$Res> {
  _$TransformRule_ReplaceInAlbumCopyWithImpl(this._self, this._then);

  final TransformRule_ReplaceInAlbum _self;
  final $Res Function(TransformRule_ReplaceInAlbum) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? find = null,
    Object? replace = null,
  }) {
    return _then(TransformRule_ReplaceInAlbum(
      find: null == find
          ? _self.find
          : find // ignore: cast_nullable_to_non_nullable
              as String,
      replace: null == replace
          ? _self.replace
          : replace // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_ReplaceInAll extends TransformRule {
  const TransformRule_ReplaceInAll({required this.find, required this.replace})
      : super._();

  final String find;
  final String replace;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_ReplaceInAllCopyWith<TransformRule_ReplaceInAll>
      get copyWith =>
          _$TransformRule_ReplaceInAllCopyWithImpl<TransformRule_ReplaceInAll>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_ReplaceInAll &&
            (identical(other.find, find) || other.find == find) &&
            (identical(other.replace, replace) || other.replace == replace));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, find, replace);
  }

  @override
  String toString() {
    return 'TransformRule.replaceInAll(find: $find, replace: $replace)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_ReplaceInAllCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_ReplaceInAllCopyWith(TransformRule_ReplaceInAll value,
          $Res Function(TransformRule_ReplaceInAll) _then) =
      _$TransformRule_ReplaceInAllCopyWithImpl;
  @useResult
  $Res call({String find, String replace});
}

/// @nodoc
class _$TransformRule_ReplaceInAllCopyWithImpl<$Res>
    implements $TransformRule_ReplaceInAllCopyWith<$Res> {
  _$TransformRule_ReplaceInAllCopyWithImpl(this._self, this._then);

  final TransformRule_ReplaceInAll _self;
  final $Res Function(TransformRule_ReplaceInAll) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? find = null,
    Object? replace = null,
  }) {
    return _then(TransformRule_ReplaceInAll(
      find: null == find
          ? _self.find
          : find // ignore: cast_nullable_to_non_nullable
              as String,
      replace: null == replace
          ? _self.replace
          : replace // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_SetTitleIfEmpty extends TransformRule {
  const TransformRule_SetTitleIfEmpty(this.field0) : super._();

  final String field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SetTitleIfEmptyCopyWith<TransformRule_SetTitleIfEmpty>
      get copyWith => _$TransformRule_SetTitleIfEmptyCopyWithImpl<
          TransformRule_SetTitleIfEmpty>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SetTitleIfEmpty &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.setTitleIfEmpty(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SetTitleIfEmptyCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SetTitleIfEmptyCopyWith(
          TransformRule_SetTitleIfEmpty value,
          $Res Function(TransformRule_SetTitleIfEmpty) _then) =
      _$TransformRule_SetTitleIfEmptyCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$TransformRule_SetTitleIfEmptyCopyWithImpl<$Res>
    implements $TransformRule_SetTitleIfEmptyCopyWith<$Res> {
  _$TransformRule_SetTitleIfEmptyCopyWithImpl(this._self, this._then);

  final TransformRule_SetTitleIfEmpty _self;
  final $Res Function(TransformRule_SetTitleIfEmpty) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SetTitleIfEmpty(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_SetArtistIfEmpty extends TransformRule {
  const TransformRule_SetArtistIfEmpty(this.field0) : super._();

  final String field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SetArtistIfEmptyCopyWith<TransformRule_SetArtistIfEmpty>
      get copyWith => _$TransformRule_SetArtistIfEmptyCopyWithImpl<
          TransformRule_SetArtistIfEmpty>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SetArtistIfEmpty &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.setArtistIfEmpty(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SetArtistIfEmptyCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SetArtistIfEmptyCopyWith(
          TransformRule_SetArtistIfEmpty value,
          $Res Function(TransformRule_SetArtistIfEmpty) _then) =
      _$TransformRule_SetArtistIfEmptyCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$TransformRule_SetArtistIfEmptyCopyWithImpl<$Res>
    implements $TransformRule_SetArtistIfEmptyCopyWith<$Res> {
  _$TransformRule_SetArtistIfEmptyCopyWithImpl(this._self, this._then);

  final TransformRule_SetArtistIfEmpty _self;
  final $Res Function(TransformRule_SetArtistIfEmpty) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SetArtistIfEmpty(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_SetAlbumIfEmpty extends TransformRule {
  const TransformRule_SetAlbumIfEmpty(this.field0) : super._();

  final String field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SetAlbumIfEmptyCopyWith<TransformRule_SetAlbumIfEmpty>
      get copyWith => _$TransformRule_SetAlbumIfEmptyCopyWithImpl<
          TransformRule_SetAlbumIfEmpty>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SetAlbumIfEmpty &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.setAlbumIfEmpty(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SetAlbumIfEmptyCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SetAlbumIfEmptyCopyWith(
          TransformRule_SetAlbumIfEmpty value,
          $Res Function(TransformRule_SetAlbumIfEmpty) _then) =
      _$TransformRule_SetAlbumIfEmptyCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$TransformRule_SetAlbumIfEmptyCopyWithImpl<$Res>
    implements $TransformRule_SetAlbumIfEmptyCopyWith<$Res> {
  _$TransformRule_SetAlbumIfEmptyCopyWithImpl(this._self, this._then);

  final TransformRule_SetAlbumIfEmpty _self;
  final $Res Function(TransformRule_SetAlbumIfEmpty) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SetAlbumIfEmpty(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_SetGenreIfEmpty extends TransformRule {
  const TransformRule_SetGenreIfEmpty(this.field0) : super._();

  final String field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SetGenreIfEmptyCopyWith<TransformRule_SetGenreIfEmpty>
      get copyWith => _$TransformRule_SetGenreIfEmptyCopyWithImpl<
          TransformRule_SetGenreIfEmpty>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SetGenreIfEmpty &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.setGenreIfEmpty(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SetGenreIfEmptyCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SetGenreIfEmptyCopyWith(
          TransformRule_SetGenreIfEmpty value,
          $Res Function(TransformRule_SetGenreIfEmpty) _then) =
      _$TransformRule_SetGenreIfEmptyCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$TransformRule_SetGenreIfEmptyCopyWithImpl<$Res>
    implements $TransformRule_SetGenreIfEmptyCopyWith<$Res> {
  _$TransformRule_SetGenreIfEmptyCopyWithImpl(this._self, this._then);

  final TransformRule_SetGenreIfEmpty _self;
  final $Res Function(TransformRule_SetGenreIfEmpty) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SetGenreIfEmpty(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_SetAlbumArtistIfEmpty extends TransformRule {
  const TransformRule_SetAlbumArtistIfEmpty(this.field0) : super._();

  final String field0;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransformRule_SetAlbumArtistIfEmptyCopyWith<
          TransformRule_SetAlbumArtistIfEmpty>
      get copyWith => _$TransformRule_SetAlbumArtistIfEmptyCopyWithImpl<
          TransformRule_SetAlbumArtistIfEmpty>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_SetAlbumArtistIfEmpty &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, field0);
  }

  @override
  String toString() {
    return 'TransformRule.setAlbumArtistIfEmpty(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $TransformRule_SetAlbumArtistIfEmptyCopyWith<$Res>
    implements $TransformRuleCopyWith<$Res> {
  factory $TransformRule_SetAlbumArtistIfEmptyCopyWith(
          TransformRule_SetAlbumArtistIfEmpty value,
          $Res Function(TransformRule_SetAlbumArtistIfEmpty) _then) =
      _$TransformRule_SetAlbumArtistIfEmptyCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$TransformRule_SetAlbumArtistIfEmptyCopyWithImpl<$Res>
    implements $TransformRule_SetAlbumArtistIfEmptyCopyWith<$Res> {
  _$TransformRule_SetAlbumArtistIfEmptyCopyWithImpl(this._self, this._then);

  final TransformRule_SetAlbumArtistIfEmpty _self;
  final $Res Function(TransformRule_SetAlbumArtistIfEmpty) _then;

  /// Create a copy of TransformRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(TransformRule_SetAlbumArtistIfEmpty(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class TransformRule_RemoveEmptyFields extends TransformRule {
  const TransformRule_RemoveEmptyFields() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_RemoveEmptyFields);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.removeEmptyFields()';
  }
}

/// @nodoc

class TransformRule_RemoveNonCoverPictures extends TransformRule {
  const TransformRule_RemoveNonCoverPictures() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransformRule_RemoveNonCoverPictures);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TransformRule.removeNonCoverPictures()';
  }
}

// dart format on
