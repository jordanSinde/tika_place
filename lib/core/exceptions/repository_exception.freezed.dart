// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repository_exception.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RepositoryException {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() notFound,
    required TResult Function() alreadyExists,
    required TResult Function() serverError,
    required TResult Function() networkError,
    required TResult Function(String error) unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? notFound,
    TResult? Function()? alreadyExists,
    TResult? Function()? serverError,
    TResult? Function()? networkError,
    TResult? Function(String error)? unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? notFound,
    TResult Function()? alreadyExists,
    TResult Function()? serverError,
    TResult Function()? networkError,
    TResult Function(String error)? unknown,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotFound value) notFound,
    required TResult Function(AlreadyExists value) alreadyExists,
    required TResult Function(ServerError value) serverError,
    required TResult Function(NetworkError value) networkError,
    required TResult Function(Unknown value) unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotFound value)? notFound,
    TResult? Function(AlreadyExists value)? alreadyExists,
    TResult? Function(ServerError value)? serverError,
    TResult? Function(NetworkError value)? networkError,
    TResult? Function(Unknown value)? unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotFound value)? notFound,
    TResult Function(AlreadyExists value)? alreadyExists,
    TResult Function(ServerError value)? serverError,
    TResult Function(NetworkError value)? networkError,
    TResult Function(Unknown value)? unknown,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RepositoryExceptionCopyWith<$Res> {
  factory $RepositoryExceptionCopyWith(
          RepositoryException value, $Res Function(RepositoryException) then) =
      _$RepositoryExceptionCopyWithImpl<$Res, RepositoryException>;
}

/// @nodoc
class _$RepositoryExceptionCopyWithImpl<$Res, $Val extends RepositoryException>
    implements $RepositoryExceptionCopyWith<$Res> {
  _$RepositoryExceptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$NotFoundImplCopyWith<$Res> {
  factory _$$NotFoundImplCopyWith(
          _$NotFoundImpl value, $Res Function(_$NotFoundImpl) then) =
      __$$NotFoundImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NotFoundImplCopyWithImpl<$Res>
    extends _$RepositoryExceptionCopyWithImpl<$Res, _$NotFoundImpl>
    implements _$$NotFoundImplCopyWith<$Res> {
  __$$NotFoundImplCopyWithImpl(
      _$NotFoundImpl _value, $Res Function(_$NotFoundImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$NotFoundImpl extends NotFound {
  const _$NotFoundImpl() : super._();

  @override
  String toString() {
    return 'RepositoryException.notFound()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$NotFoundImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() notFound,
    required TResult Function() alreadyExists,
    required TResult Function() serverError,
    required TResult Function() networkError,
    required TResult Function(String error) unknown,
  }) {
    return notFound();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? notFound,
    TResult? Function()? alreadyExists,
    TResult? Function()? serverError,
    TResult? Function()? networkError,
    TResult? Function(String error)? unknown,
  }) {
    return notFound?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? notFound,
    TResult Function()? alreadyExists,
    TResult Function()? serverError,
    TResult Function()? networkError,
    TResult Function(String error)? unknown,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotFound value) notFound,
    required TResult Function(AlreadyExists value) alreadyExists,
    required TResult Function(ServerError value) serverError,
    required TResult Function(NetworkError value) networkError,
    required TResult Function(Unknown value) unknown,
  }) {
    return notFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotFound value)? notFound,
    TResult? Function(AlreadyExists value)? alreadyExists,
    TResult? Function(ServerError value)? serverError,
    TResult? Function(NetworkError value)? networkError,
    TResult? Function(Unknown value)? unknown,
  }) {
    return notFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotFound value)? notFound,
    TResult Function(AlreadyExists value)? alreadyExists,
    TResult Function(ServerError value)? serverError,
    TResult Function(NetworkError value)? networkError,
    TResult Function(Unknown value)? unknown,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(this);
    }
    return orElse();
  }
}

abstract class NotFound extends RepositoryException {
  const factory NotFound() = _$NotFoundImpl;
  const NotFound._() : super._();
}

/// @nodoc
abstract class _$$AlreadyExistsImplCopyWith<$Res> {
  factory _$$AlreadyExistsImplCopyWith(
          _$AlreadyExistsImpl value, $Res Function(_$AlreadyExistsImpl) then) =
      __$$AlreadyExistsImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AlreadyExistsImplCopyWithImpl<$Res>
    extends _$RepositoryExceptionCopyWithImpl<$Res, _$AlreadyExistsImpl>
    implements _$$AlreadyExistsImplCopyWith<$Res> {
  __$$AlreadyExistsImplCopyWithImpl(
      _$AlreadyExistsImpl _value, $Res Function(_$AlreadyExistsImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AlreadyExistsImpl extends AlreadyExists {
  const _$AlreadyExistsImpl() : super._();

  @override
  String toString() {
    return 'RepositoryException.alreadyExists()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AlreadyExistsImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() notFound,
    required TResult Function() alreadyExists,
    required TResult Function() serverError,
    required TResult Function() networkError,
    required TResult Function(String error) unknown,
  }) {
    return alreadyExists();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? notFound,
    TResult? Function()? alreadyExists,
    TResult? Function()? serverError,
    TResult? Function()? networkError,
    TResult? Function(String error)? unknown,
  }) {
    return alreadyExists?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? notFound,
    TResult Function()? alreadyExists,
    TResult Function()? serverError,
    TResult Function()? networkError,
    TResult Function(String error)? unknown,
    required TResult orElse(),
  }) {
    if (alreadyExists != null) {
      return alreadyExists();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotFound value) notFound,
    required TResult Function(AlreadyExists value) alreadyExists,
    required TResult Function(ServerError value) serverError,
    required TResult Function(NetworkError value) networkError,
    required TResult Function(Unknown value) unknown,
  }) {
    return alreadyExists(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotFound value)? notFound,
    TResult? Function(AlreadyExists value)? alreadyExists,
    TResult? Function(ServerError value)? serverError,
    TResult? Function(NetworkError value)? networkError,
    TResult? Function(Unknown value)? unknown,
  }) {
    return alreadyExists?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotFound value)? notFound,
    TResult Function(AlreadyExists value)? alreadyExists,
    TResult Function(ServerError value)? serverError,
    TResult Function(NetworkError value)? networkError,
    TResult Function(Unknown value)? unknown,
    required TResult orElse(),
  }) {
    if (alreadyExists != null) {
      return alreadyExists(this);
    }
    return orElse();
  }
}

abstract class AlreadyExists extends RepositoryException {
  const factory AlreadyExists() = _$AlreadyExistsImpl;
  const AlreadyExists._() : super._();
}

/// @nodoc
abstract class _$$ServerErrorImplCopyWith<$Res> {
  factory _$$ServerErrorImplCopyWith(
          _$ServerErrorImpl value, $Res Function(_$ServerErrorImpl) then) =
      __$$ServerErrorImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ServerErrorImplCopyWithImpl<$Res>
    extends _$RepositoryExceptionCopyWithImpl<$Res, _$ServerErrorImpl>
    implements _$$ServerErrorImplCopyWith<$Res> {
  __$$ServerErrorImplCopyWithImpl(
      _$ServerErrorImpl _value, $Res Function(_$ServerErrorImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ServerErrorImpl extends ServerError {
  const _$ServerErrorImpl() : super._();

  @override
  String toString() {
    return 'RepositoryException.serverError()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ServerErrorImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() notFound,
    required TResult Function() alreadyExists,
    required TResult Function() serverError,
    required TResult Function() networkError,
    required TResult Function(String error) unknown,
  }) {
    return serverError();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? notFound,
    TResult? Function()? alreadyExists,
    TResult? Function()? serverError,
    TResult? Function()? networkError,
    TResult? Function(String error)? unknown,
  }) {
    return serverError?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? notFound,
    TResult Function()? alreadyExists,
    TResult Function()? serverError,
    TResult Function()? networkError,
    TResult Function(String error)? unknown,
    required TResult orElse(),
  }) {
    if (serverError != null) {
      return serverError();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotFound value) notFound,
    required TResult Function(AlreadyExists value) alreadyExists,
    required TResult Function(ServerError value) serverError,
    required TResult Function(NetworkError value) networkError,
    required TResult Function(Unknown value) unknown,
  }) {
    return serverError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotFound value)? notFound,
    TResult? Function(AlreadyExists value)? alreadyExists,
    TResult? Function(ServerError value)? serverError,
    TResult? Function(NetworkError value)? networkError,
    TResult? Function(Unknown value)? unknown,
  }) {
    return serverError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotFound value)? notFound,
    TResult Function(AlreadyExists value)? alreadyExists,
    TResult Function(ServerError value)? serverError,
    TResult Function(NetworkError value)? networkError,
    TResult Function(Unknown value)? unknown,
    required TResult orElse(),
  }) {
    if (serverError != null) {
      return serverError(this);
    }
    return orElse();
  }
}

abstract class ServerError extends RepositoryException {
  const factory ServerError() = _$ServerErrorImpl;
  const ServerError._() : super._();
}

/// @nodoc
abstract class _$$NetworkErrorImplCopyWith<$Res> {
  factory _$$NetworkErrorImplCopyWith(
          _$NetworkErrorImpl value, $Res Function(_$NetworkErrorImpl) then) =
      __$$NetworkErrorImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NetworkErrorImplCopyWithImpl<$Res>
    extends _$RepositoryExceptionCopyWithImpl<$Res, _$NetworkErrorImpl>
    implements _$$NetworkErrorImplCopyWith<$Res> {
  __$$NetworkErrorImplCopyWithImpl(
      _$NetworkErrorImpl _value, $Res Function(_$NetworkErrorImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$NetworkErrorImpl extends NetworkError {
  const _$NetworkErrorImpl() : super._();

  @override
  String toString() {
    return 'RepositoryException.networkError()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$NetworkErrorImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() notFound,
    required TResult Function() alreadyExists,
    required TResult Function() serverError,
    required TResult Function() networkError,
    required TResult Function(String error) unknown,
  }) {
    return networkError();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? notFound,
    TResult? Function()? alreadyExists,
    TResult? Function()? serverError,
    TResult? Function()? networkError,
    TResult? Function(String error)? unknown,
  }) {
    return networkError?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? notFound,
    TResult Function()? alreadyExists,
    TResult Function()? serverError,
    TResult Function()? networkError,
    TResult Function(String error)? unknown,
    required TResult orElse(),
  }) {
    if (networkError != null) {
      return networkError();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotFound value) notFound,
    required TResult Function(AlreadyExists value) alreadyExists,
    required TResult Function(ServerError value) serverError,
    required TResult Function(NetworkError value) networkError,
    required TResult Function(Unknown value) unknown,
  }) {
    return networkError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotFound value)? notFound,
    TResult? Function(AlreadyExists value)? alreadyExists,
    TResult? Function(ServerError value)? serverError,
    TResult? Function(NetworkError value)? networkError,
    TResult? Function(Unknown value)? unknown,
  }) {
    return networkError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotFound value)? notFound,
    TResult Function(AlreadyExists value)? alreadyExists,
    TResult Function(ServerError value)? serverError,
    TResult Function(NetworkError value)? networkError,
    TResult Function(Unknown value)? unknown,
    required TResult orElse(),
  }) {
    if (networkError != null) {
      return networkError(this);
    }
    return orElse();
  }
}

abstract class NetworkError extends RepositoryException {
  const factory NetworkError() = _$NetworkErrorImpl;
  const NetworkError._() : super._();
}

/// @nodoc
abstract class _$$UnknownImplCopyWith<$Res> {
  factory _$$UnknownImplCopyWith(
          _$UnknownImpl value, $Res Function(_$UnknownImpl) then) =
      __$$UnknownImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$UnknownImplCopyWithImpl<$Res>
    extends _$RepositoryExceptionCopyWithImpl<$Res, _$UnknownImpl>
    implements _$$UnknownImplCopyWith<$Res> {
  __$$UnknownImplCopyWithImpl(
      _$UnknownImpl _value, $Res Function(_$UnknownImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$UnknownImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UnknownImpl extends Unknown {
  const _$UnknownImpl(this.error) : super._();

  @override
  final String error;

  @override
  String toString() {
    return 'RepositoryException.unknown(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownImplCopyWith<_$UnknownImpl> get copyWith =>
      __$$UnknownImplCopyWithImpl<_$UnknownImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() notFound,
    required TResult Function() alreadyExists,
    required TResult Function() serverError,
    required TResult Function() networkError,
    required TResult Function(String error) unknown,
  }) {
    return unknown(error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? notFound,
    TResult? Function()? alreadyExists,
    TResult? Function()? serverError,
    TResult? Function()? networkError,
    TResult? Function(String error)? unknown,
  }) {
    return unknown?.call(error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? notFound,
    TResult Function()? alreadyExists,
    TResult Function()? serverError,
    TResult Function()? networkError,
    TResult Function(String error)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotFound value) notFound,
    required TResult Function(AlreadyExists value) alreadyExists,
    required TResult Function(ServerError value) serverError,
    required TResult Function(NetworkError value) networkError,
    required TResult Function(Unknown value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotFound value)? notFound,
    TResult? Function(AlreadyExists value)? alreadyExists,
    TResult? Function(ServerError value)? serverError,
    TResult? Function(NetworkError value)? networkError,
    TResult? Function(Unknown value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotFound value)? notFound,
    TResult Function(AlreadyExists value)? alreadyExists,
    TResult Function(ServerError value)? serverError,
    TResult Function(NetworkError value)? networkError,
    TResult Function(Unknown value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class Unknown extends RepositoryException {
  const factory Unknown(final String error) = _$UnknownImpl;
  const Unknown._() : super._();

  String get error;
  @JsonKey(ignore: true)
  _$$UnknownImplCopyWith<_$UnknownImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
