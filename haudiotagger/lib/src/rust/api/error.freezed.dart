// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HaudiotaggerError {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is HaudiotaggerError);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HaudiotaggerError()';
  }
}

/// @nodoc
class $HaudiotaggerErrorCopyWith<$Res> {
  $HaudiotaggerErrorCopyWith(
      HaudiotaggerError _, $Res Function(HaudiotaggerError) __);
}

/// Adds pattern-matching-related methods to [HaudiotaggerError].
extension HaudiotaggerErrorPatterns on HaudiotaggerError {
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
    TResult Function(HaudiotaggerError_InvalidPath value)? invalidPath,
    TResult Function(HaudiotaggerError_NoTags value)? noTags,
    TResult Function(HaudiotaggerError_OpenFile value)? openFile,
    TResult Function(HaudiotaggerError_Write value)? write,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case HaudiotaggerError_InvalidPath() when invalidPath != null:
        return invalidPath(_that);
      case HaudiotaggerError_NoTags() when noTags != null:
        return noTags(_that);
      case HaudiotaggerError_OpenFile() when openFile != null:
        return openFile(_that);
      case HaudiotaggerError_Write() when write != null:
        return write(_that);
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
    required TResult Function(HaudiotaggerError_InvalidPath value) invalidPath,
    required TResult Function(HaudiotaggerError_NoTags value) noTags,
    required TResult Function(HaudiotaggerError_OpenFile value) openFile,
    required TResult Function(HaudiotaggerError_Write value) write,
  }) {
    final _that = this;
    switch (_that) {
      case HaudiotaggerError_InvalidPath():
        return invalidPath(_that);
      case HaudiotaggerError_NoTags():
        return noTags(_that);
      case HaudiotaggerError_OpenFile():
        return openFile(_that);
      case HaudiotaggerError_Write():
        return write(_that);
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
    TResult? Function(HaudiotaggerError_InvalidPath value)? invalidPath,
    TResult? Function(HaudiotaggerError_NoTags value)? noTags,
    TResult? Function(HaudiotaggerError_OpenFile value)? openFile,
    TResult? Function(HaudiotaggerError_Write value)? write,
  }) {
    final _that = this;
    switch (_that) {
      case HaudiotaggerError_InvalidPath() when invalidPath != null:
        return invalidPath(_that);
      case HaudiotaggerError_NoTags() when noTags != null:
        return noTags(_that);
      case HaudiotaggerError_OpenFile() when openFile != null:
        return openFile(_that);
      case HaudiotaggerError_Write() when write != null:
        return write(_that);
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
    TResult Function()? invalidPath,
    TResult Function()? noTags,
    TResult Function(String message)? openFile,
    TResult Function(String message)? write,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case HaudiotaggerError_InvalidPath() when invalidPath != null:
        return invalidPath();
      case HaudiotaggerError_NoTags() when noTags != null:
        return noTags();
      case HaudiotaggerError_OpenFile() when openFile != null:
        return openFile(_that.message);
      case HaudiotaggerError_Write() when write != null:
        return write(_that.message);
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
    required TResult Function() invalidPath,
    required TResult Function() noTags,
    required TResult Function(String message) openFile,
    required TResult Function(String message) write,
  }) {
    final _that = this;
    switch (_that) {
      case HaudiotaggerError_InvalidPath():
        return invalidPath();
      case HaudiotaggerError_NoTags():
        return noTags();
      case HaudiotaggerError_OpenFile():
        return openFile(_that.message);
      case HaudiotaggerError_Write():
        return write(_that.message);
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
    TResult? Function()? invalidPath,
    TResult? Function()? noTags,
    TResult? Function(String message)? openFile,
    TResult? Function(String message)? write,
  }) {
    final _that = this;
    switch (_that) {
      case HaudiotaggerError_InvalidPath() when invalidPath != null:
        return invalidPath();
      case HaudiotaggerError_NoTags() when noTags != null:
        return noTags();
      case HaudiotaggerError_OpenFile() when openFile != null:
        return openFile(_that.message);
      case HaudiotaggerError_Write() when write != null:
        return write(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class HaudiotaggerError_InvalidPath extends HaudiotaggerError {
  const HaudiotaggerError_InvalidPath() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HaudiotaggerError_InvalidPath);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HaudiotaggerError.invalidPath()';
  }
}

/// @nodoc

class HaudiotaggerError_NoTags extends HaudiotaggerError {
  const HaudiotaggerError_NoTags() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is HaudiotaggerError_NoTags);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HaudiotaggerError.noTags()';
  }
}

/// @nodoc

class HaudiotaggerError_OpenFile extends HaudiotaggerError {
  const HaudiotaggerError_OpenFile({required this.message}) : super._();

  final String message;

  /// Create a copy of HaudiotaggerError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HaudiotaggerError_OpenFileCopyWith<HaudiotaggerError_OpenFile>
      get copyWith =>
          _$HaudiotaggerError_OpenFileCopyWithImpl<HaudiotaggerError_OpenFile>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HaudiotaggerError_OpenFile &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'HaudiotaggerError.openFile(message: $message)';
  }
}

/// @nodoc
abstract mixin class $HaudiotaggerError_OpenFileCopyWith<$Res>
    implements $HaudiotaggerErrorCopyWith<$Res> {
  factory $HaudiotaggerError_OpenFileCopyWith(HaudiotaggerError_OpenFile value,
          $Res Function(HaudiotaggerError_OpenFile) _then) =
      _$HaudiotaggerError_OpenFileCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$HaudiotaggerError_OpenFileCopyWithImpl<$Res>
    implements $HaudiotaggerError_OpenFileCopyWith<$Res> {
  _$HaudiotaggerError_OpenFileCopyWithImpl(this._self, this._then);

  final HaudiotaggerError_OpenFile _self;
  final $Res Function(HaudiotaggerError_OpenFile) _then;

  /// Create a copy of HaudiotaggerError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(HaudiotaggerError_OpenFile(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class HaudiotaggerError_Write extends HaudiotaggerError {
  const HaudiotaggerError_Write({required this.message}) : super._();

  final String message;

  /// Create a copy of HaudiotaggerError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HaudiotaggerError_WriteCopyWith<HaudiotaggerError_Write> get copyWith =>
      _$HaudiotaggerError_WriteCopyWithImpl<HaudiotaggerError_Write>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HaudiotaggerError_Write &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'HaudiotaggerError.write(message: $message)';
  }
}

/// @nodoc
abstract mixin class $HaudiotaggerError_WriteCopyWith<$Res>
    implements $HaudiotaggerErrorCopyWith<$Res> {
  factory $HaudiotaggerError_WriteCopyWith(HaudiotaggerError_Write value,
          $Res Function(HaudiotaggerError_Write) _then) =
      _$HaudiotaggerError_WriteCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$HaudiotaggerError_WriteCopyWithImpl<$Res>
    implements $HaudiotaggerError_WriteCopyWith<$Res> {
  _$HaudiotaggerError_WriteCopyWithImpl(this._self, this._then);

  final HaudiotaggerError_Write _self;
  final $Res Function(HaudiotaggerError_Write) _then;

  /// Create a copy of HaudiotaggerError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(HaudiotaggerError_Write(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
