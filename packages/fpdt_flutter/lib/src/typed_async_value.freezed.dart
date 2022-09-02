// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'typed_async_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$TypedAsyncValue<E, A> {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() none,
    required TResult Function(Option<A> data) loading,
    required TResult Function(E error) error,
    required TResult Function(A data) data,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? none,
    TResult Function(Option<A> data)? loading,
    TResult Function(E error)? error,
    TResult Function(A data)? data,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? none,
    TResult Function(Option<A> data)? loading,
    TResult Function(E error)? error,
    TResult Function(A data)? data,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TypedAsyncValueNone<E, A> value) none,
    required TResult Function(TypedAsyncValueLoading<E, A> value) loading,
    required TResult Function(TypedAsyncValueError<E, A> value) error,
    required TResult Function(TypedAsyncValueData<E, A> value) data,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TypedAsyncValueNone<E, A> value)? none,
    TResult Function(TypedAsyncValueLoading<E, A> value)? loading,
    TResult Function(TypedAsyncValueError<E, A> value)? error,
    TResult Function(TypedAsyncValueData<E, A> value)? data,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TypedAsyncValueNone<E, A> value)? none,
    TResult Function(TypedAsyncValueLoading<E, A> value)? loading,
    TResult Function(TypedAsyncValueError<E, A> value)? error,
    TResult Function(TypedAsyncValueData<E, A> value)? data,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TypedAsyncValueCopyWith<E, A, $Res> {
  factory $TypedAsyncValueCopyWith(TypedAsyncValue<E, A> value,
          $Res Function(TypedAsyncValue<E, A>) then) =
      _$TypedAsyncValueCopyWithImpl<E, A, $Res>;
}

/// @nodoc
class _$TypedAsyncValueCopyWithImpl<E, A, $Res>
    implements $TypedAsyncValueCopyWith<E, A, $Res> {
  _$TypedAsyncValueCopyWithImpl(this._value, this._then);

  final TypedAsyncValue<E, A> _value;
  // ignore: unused_field
  final $Res Function(TypedAsyncValue<E, A>) _then;
}

/// @nodoc
abstract class _$$TypedAsyncValueNoneCopyWith<E, A, $Res> {
  factory _$$TypedAsyncValueNoneCopyWith(_$TypedAsyncValueNone<E, A> value,
          $Res Function(_$TypedAsyncValueNone<E, A>) then) =
      __$$TypedAsyncValueNoneCopyWithImpl<E, A, $Res>;
}

/// @nodoc
class __$$TypedAsyncValueNoneCopyWithImpl<E, A, $Res>
    extends _$TypedAsyncValueCopyWithImpl<E, A, $Res>
    implements _$$TypedAsyncValueNoneCopyWith<E, A, $Res> {
  __$$TypedAsyncValueNoneCopyWithImpl(_$TypedAsyncValueNone<E, A> _value,
      $Res Function(_$TypedAsyncValueNone<E, A>) _then)
      : super(_value, (v) => _then(v as _$TypedAsyncValueNone<E, A>));

  @override
  _$TypedAsyncValueNone<E, A> get _value =>
      super._value as _$TypedAsyncValueNone<E, A>;
}

/// @nodoc

class _$TypedAsyncValueNone<E, A> extends TypedAsyncValueNone<E, A> {
  const _$TypedAsyncValueNone() : super._();

  @override
  String toString() {
    return 'TypedAsyncValue<$E, $A>.none()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TypedAsyncValueNone<E, A>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() none,
    required TResult Function(Option<A> data) loading,
    required TResult Function(E error) error,
    required TResult Function(A data) data,
  }) {
    return none();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? none,
    TResult Function(Option<A> data)? loading,
    TResult Function(E error)? error,
    TResult Function(A data)? data,
  }) {
    return none?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? none,
    TResult Function(Option<A> data)? loading,
    TResult Function(E error)? error,
    TResult Function(A data)? data,
    required TResult orElse(),
  }) {
    if (none != null) {
      return none();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TypedAsyncValueNone<E, A> value) none,
    required TResult Function(TypedAsyncValueLoading<E, A> value) loading,
    required TResult Function(TypedAsyncValueError<E, A> value) error,
    required TResult Function(TypedAsyncValueData<E, A> value) data,
  }) {
    return none(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TypedAsyncValueNone<E, A> value)? none,
    TResult Function(TypedAsyncValueLoading<E, A> value)? loading,
    TResult Function(TypedAsyncValueError<E, A> value)? error,
    TResult Function(TypedAsyncValueData<E, A> value)? data,
  }) {
    return none?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TypedAsyncValueNone<E, A> value)? none,
    TResult Function(TypedAsyncValueLoading<E, A> value)? loading,
    TResult Function(TypedAsyncValueError<E, A> value)? error,
    TResult Function(TypedAsyncValueData<E, A> value)? data,
    required TResult orElse(),
  }) {
    if (none != null) {
      return none(this);
    }
    return orElse();
  }
}

abstract class TypedAsyncValueNone<E, A> extends TypedAsyncValue<E, A> {
  const factory TypedAsyncValueNone() = _$TypedAsyncValueNone<E, A>;
  const TypedAsyncValueNone._() : super._();
}

/// @nodoc
abstract class _$$TypedAsyncValueLoadingCopyWith<E, A, $Res> {
  factory _$$TypedAsyncValueLoadingCopyWith(
          _$TypedAsyncValueLoading<E, A> value,
          $Res Function(_$TypedAsyncValueLoading<E, A>) then) =
      __$$TypedAsyncValueLoadingCopyWithImpl<E, A, $Res>;
  $Res call({Option<A> data});
}

/// @nodoc
class __$$TypedAsyncValueLoadingCopyWithImpl<E, A, $Res>
    extends _$TypedAsyncValueCopyWithImpl<E, A, $Res>
    implements _$$TypedAsyncValueLoadingCopyWith<E, A, $Res> {
  __$$TypedAsyncValueLoadingCopyWithImpl(_$TypedAsyncValueLoading<E, A> _value,
      $Res Function(_$TypedAsyncValueLoading<E, A>) _then)
      : super(_value, (v) => _then(v as _$TypedAsyncValueLoading<E, A>));

  @override
  _$TypedAsyncValueLoading<E, A> get _value =>
      super._value as _$TypedAsyncValueLoading<E, A>;

  @override
  $Res call({
    Object? data = freezed,
  }) {
    return _then(_$TypedAsyncValueLoading<E, A>(
      data: data == freezed
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Option<A>,
    ));
  }
}

/// @nodoc

class _$TypedAsyncValueLoading<E, A> extends TypedAsyncValueLoading<E, A> {
  const _$TypedAsyncValueLoading({this.data = kNone}) : super._();

  @override
  @JsonKey()
  final Option<A> data;

  @override
  String toString() {
    return 'TypedAsyncValue<$E, $A>.loading(data: $data)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TypedAsyncValueLoading<E, A> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  @JsonKey(ignore: true)
  @override
  _$$TypedAsyncValueLoadingCopyWith<E, A, _$TypedAsyncValueLoading<E, A>>
      get copyWith => __$$TypedAsyncValueLoadingCopyWithImpl<E, A,
          _$TypedAsyncValueLoading<E, A>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() none,
    required TResult Function(Option<A> data) loading,
    required TResult Function(E error) error,
    required TResult Function(A data) data,
  }) {
    return loading(this.data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? none,
    TResult Function(Option<A> data)? loading,
    TResult Function(E error)? error,
    TResult Function(A data)? data,
  }) {
    return loading?.call(this.data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? none,
    TResult Function(Option<A> data)? loading,
    TResult Function(E error)? error,
    TResult Function(A data)? data,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this.data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TypedAsyncValueNone<E, A> value) none,
    required TResult Function(TypedAsyncValueLoading<E, A> value) loading,
    required TResult Function(TypedAsyncValueError<E, A> value) error,
    required TResult Function(TypedAsyncValueData<E, A> value) data,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TypedAsyncValueNone<E, A> value)? none,
    TResult Function(TypedAsyncValueLoading<E, A> value)? loading,
    TResult Function(TypedAsyncValueError<E, A> value)? error,
    TResult Function(TypedAsyncValueData<E, A> value)? data,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TypedAsyncValueNone<E, A> value)? none,
    TResult Function(TypedAsyncValueLoading<E, A> value)? loading,
    TResult Function(TypedAsyncValueError<E, A> value)? error,
    TResult Function(TypedAsyncValueData<E, A> value)? data,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class TypedAsyncValueLoading<E, A> extends TypedAsyncValue<E, A> {
  const factory TypedAsyncValueLoading({final Option<A> data}) =
      _$TypedAsyncValueLoading<E, A>;
  const TypedAsyncValueLoading._() : super._();

  Option<A> get data;
  @JsonKey(ignore: true)
  _$$TypedAsyncValueLoadingCopyWith<E, A, _$TypedAsyncValueLoading<E, A>>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TypedAsyncValueErrorCopyWith<E, A, $Res> {
  factory _$$TypedAsyncValueErrorCopyWith(_$TypedAsyncValueError<E, A> value,
          $Res Function(_$TypedAsyncValueError<E, A>) then) =
      __$$TypedAsyncValueErrorCopyWithImpl<E, A, $Res>;
  $Res call({E error});
}

/// @nodoc
class __$$TypedAsyncValueErrorCopyWithImpl<E, A, $Res>
    extends _$TypedAsyncValueCopyWithImpl<E, A, $Res>
    implements _$$TypedAsyncValueErrorCopyWith<E, A, $Res> {
  __$$TypedAsyncValueErrorCopyWithImpl(_$TypedAsyncValueError<E, A> _value,
      $Res Function(_$TypedAsyncValueError<E, A>) _then)
      : super(_value, (v) => _then(v as _$TypedAsyncValueError<E, A>));

  @override
  _$TypedAsyncValueError<E, A> get _value =>
      super._value as _$TypedAsyncValueError<E, A>;

  @override
  $Res call({
    Object? error = freezed,
  }) {
    return _then(_$TypedAsyncValueError<E, A>(
      error == freezed
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as E,
    ));
  }
}

/// @nodoc

class _$TypedAsyncValueError<E, A> extends TypedAsyncValueError<E, A> {
  const _$TypedAsyncValueError(this.error) : super._();

  @override
  final E error;

  @override
  String toString() {
    return 'TypedAsyncValue<$E, $A>.error(error: $error)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TypedAsyncValueError<E, A> &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(error));

  @JsonKey(ignore: true)
  @override
  _$$TypedAsyncValueErrorCopyWith<E, A, _$TypedAsyncValueError<E, A>>
      get copyWith => __$$TypedAsyncValueErrorCopyWithImpl<E, A,
          _$TypedAsyncValueError<E, A>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() none,
    required TResult Function(Option<A> data) loading,
    required TResult Function(E error) error,
    required TResult Function(A data) data,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? none,
    TResult Function(Option<A> data)? loading,
    TResult Function(E error)? error,
    TResult Function(A data)? data,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? none,
    TResult Function(Option<A> data)? loading,
    TResult Function(E error)? error,
    TResult Function(A data)? data,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this.error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TypedAsyncValueNone<E, A> value) none,
    required TResult Function(TypedAsyncValueLoading<E, A> value) loading,
    required TResult Function(TypedAsyncValueError<E, A> value) error,
    required TResult Function(TypedAsyncValueData<E, A> value) data,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TypedAsyncValueNone<E, A> value)? none,
    TResult Function(TypedAsyncValueLoading<E, A> value)? loading,
    TResult Function(TypedAsyncValueError<E, A> value)? error,
    TResult Function(TypedAsyncValueData<E, A> value)? data,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TypedAsyncValueNone<E, A> value)? none,
    TResult Function(TypedAsyncValueLoading<E, A> value)? loading,
    TResult Function(TypedAsyncValueError<E, A> value)? error,
    TResult Function(TypedAsyncValueData<E, A> value)? data,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class TypedAsyncValueError<E, A> extends TypedAsyncValue<E, A> {
  const factory TypedAsyncValueError(final E error) =
      _$TypedAsyncValueError<E, A>;
  const TypedAsyncValueError._() : super._();

  E get error;
  @JsonKey(ignore: true)
  _$$TypedAsyncValueErrorCopyWith<E, A, _$TypedAsyncValueError<E, A>>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TypedAsyncValueDataCopyWith<E, A, $Res> {
  factory _$$TypedAsyncValueDataCopyWith(_$TypedAsyncValueData<E, A> value,
          $Res Function(_$TypedAsyncValueData<E, A>) then) =
      __$$TypedAsyncValueDataCopyWithImpl<E, A, $Res>;
  $Res call({A data});
}

/// @nodoc
class __$$TypedAsyncValueDataCopyWithImpl<E, A, $Res>
    extends _$TypedAsyncValueCopyWithImpl<E, A, $Res>
    implements _$$TypedAsyncValueDataCopyWith<E, A, $Res> {
  __$$TypedAsyncValueDataCopyWithImpl(_$TypedAsyncValueData<E, A> _value,
      $Res Function(_$TypedAsyncValueData<E, A>) _then)
      : super(_value, (v) => _then(v as _$TypedAsyncValueData<E, A>));

  @override
  _$TypedAsyncValueData<E, A> get _value =>
      super._value as _$TypedAsyncValueData<E, A>;

  @override
  $Res call({
    Object? data = freezed,
  }) {
    return _then(_$TypedAsyncValueData<E, A>(
      data == freezed
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as A,
    ));
  }
}

/// @nodoc

class _$TypedAsyncValueData<E, A> extends TypedAsyncValueData<E, A> {
  const _$TypedAsyncValueData(this.data) : super._();

  @override
  final A data;

  @override
  String toString() {
    return 'TypedAsyncValue<$E, $A>.data(data: $data)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TypedAsyncValueData<E, A> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  @JsonKey(ignore: true)
  @override
  _$$TypedAsyncValueDataCopyWith<E, A, _$TypedAsyncValueData<E, A>>
      get copyWith => __$$TypedAsyncValueDataCopyWithImpl<E, A,
          _$TypedAsyncValueData<E, A>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() none,
    required TResult Function(Option<A> data) loading,
    required TResult Function(E error) error,
    required TResult Function(A data) data,
  }) {
    return data(this.data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? none,
    TResult Function(Option<A> data)? loading,
    TResult Function(E error)? error,
    TResult Function(A data)? data,
  }) {
    return data?.call(this.data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? none,
    TResult Function(Option<A> data)? loading,
    TResult Function(E error)? error,
    TResult Function(A data)? data,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this.data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TypedAsyncValueNone<E, A> value) none,
    required TResult Function(TypedAsyncValueLoading<E, A> value) loading,
    required TResult Function(TypedAsyncValueError<E, A> value) error,
    required TResult Function(TypedAsyncValueData<E, A> value) data,
  }) {
    return data(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TypedAsyncValueNone<E, A> value)? none,
    TResult Function(TypedAsyncValueLoading<E, A> value)? loading,
    TResult Function(TypedAsyncValueError<E, A> value)? error,
    TResult Function(TypedAsyncValueData<E, A> value)? data,
  }) {
    return data?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TypedAsyncValueNone<E, A> value)? none,
    TResult Function(TypedAsyncValueLoading<E, A> value)? loading,
    TResult Function(TypedAsyncValueError<E, A> value)? error,
    TResult Function(TypedAsyncValueData<E, A> value)? data,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this);
    }
    return orElse();
  }
}

abstract class TypedAsyncValueData<E, A> extends TypedAsyncValue<E, A> {
  const factory TypedAsyncValueData(final A data) = _$TypedAsyncValueData<E, A>;
  const TypedAsyncValueData._() : super._();

  A get data;
  @JsonKey(ignore: true)
  _$$TypedAsyncValueDataCopyWith<E, A, _$TypedAsyncValueData<E, A>>
      get copyWith => throw _privateConstructorUsedError;
}
