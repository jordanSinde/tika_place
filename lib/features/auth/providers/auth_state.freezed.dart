// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthState {
  User? get user => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get redirectPath =>
      throw _privateConstructorUsedError; // Nouveaux champs
  bool get isPhoneVerificationInProgress => throw _privateConstructorUsedError;
  Map<String, dynamic>? get pendingUserData =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AuthStateCopyWith<AuthState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
  @useResult
  $Res call(
      {User? user,
      bool isLoading,
      String? error,
      String? redirectPath,
      bool isPhoneVerificationInProgress,
      Map<String, dynamic>? pendingUserData});

  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? isLoading = null,
    Object? error = freezed,
    Object? redirectPath = freezed,
    Object? isPhoneVerificationInProgress = null,
    Object? pendingUserData = freezed,
  }) {
    return _then(_value.copyWith(
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      redirectPath: freezed == redirectPath
          ? _value.redirectPath
          : redirectPath // ignore: cast_nullable_to_non_nullable
              as String?,
      isPhoneVerificationInProgress: null == isPhoneVerificationInProgress
          ? _value.isPhoneVerificationInProgress
          : isPhoneVerificationInProgress // ignore: cast_nullable_to_non_nullable
              as bool,
      pendingUserData: freezed == pendingUserData
          ? _value.pendingUserData
          : pendingUserData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthStateImplCopyWith<$Res>
    implements $AuthStateCopyWith<$Res> {
  factory _$$AuthStateImplCopyWith(
          _$AuthStateImpl value, $Res Function(_$AuthStateImpl) then) =
      __$$AuthStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {User? user,
      bool isLoading,
      String? error,
      String? redirectPath,
      bool isPhoneVerificationInProgress,
      Map<String, dynamic>? pendingUserData});

  @override
  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$AuthStateImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthStateImpl>
    implements _$$AuthStateImplCopyWith<$Res> {
  __$$AuthStateImplCopyWithImpl(
      _$AuthStateImpl _value, $Res Function(_$AuthStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? isLoading = null,
    Object? error = freezed,
    Object? redirectPath = freezed,
    Object? isPhoneVerificationInProgress = null,
    Object? pendingUserData = freezed,
  }) {
    return _then(_$AuthStateImpl(
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      redirectPath: freezed == redirectPath
          ? _value.redirectPath
          : redirectPath // ignore: cast_nullable_to_non_nullable
              as String?,
      isPhoneVerificationInProgress: null == isPhoneVerificationInProgress
          ? _value.isPhoneVerificationInProgress
          : isPhoneVerificationInProgress // ignore: cast_nullable_to_non_nullable
              as bool,
      pendingUserData: freezed == pendingUserData
          ? _value._pendingUserData
          : pendingUserData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$AuthStateImpl extends _AuthState {
  const _$AuthStateImpl(
      {this.user,
      this.isLoading = false,
      this.error,
      this.redirectPath,
      this.isPhoneVerificationInProgress = false,
      final Map<String, dynamic>? pendingUserData})
      : _pendingUserData = pendingUserData,
        super._();

  @override
  final User? user;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  final String? redirectPath;
// Nouveaux champs
  @override
  @JsonKey()
  final bool isPhoneVerificationInProgress;
  final Map<String, dynamic>? _pendingUserData;
  @override
  Map<String, dynamic>? get pendingUserData {
    final value = _pendingUserData;
    if (value == null) return null;
    if (_pendingUserData is EqualUnmodifiableMapView) return _pendingUserData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AuthState(user: $user, isLoading: $isLoading, error: $error, redirectPath: $redirectPath, isPhoneVerificationInProgress: $isPhoneVerificationInProgress, pendingUserData: $pendingUserData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthStateImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.redirectPath, redirectPath) ||
                other.redirectPath == redirectPath) &&
            (identical(other.isPhoneVerificationInProgress,
                    isPhoneVerificationInProgress) ||
                other.isPhoneVerificationInProgress ==
                    isPhoneVerificationInProgress) &&
            const DeepCollectionEquality()
                .equals(other._pendingUserData, _pendingUserData));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      user,
      isLoading,
      error,
      redirectPath,
      isPhoneVerificationInProgress,
      const DeepCollectionEquality().hash(_pendingUserData));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthStateImplCopyWith<_$AuthStateImpl> get copyWith =>
      __$$AuthStateImplCopyWithImpl<_$AuthStateImpl>(this, _$identity);
}

abstract class _AuthState extends AuthState {
  const factory _AuthState(
      {final User? user,
      final bool isLoading,
      final String? error,
      final String? redirectPath,
      final bool isPhoneVerificationInProgress,
      final Map<String, dynamic>? pendingUserData}) = _$AuthStateImpl;
  const _AuthState._() : super._();

  @override
  User? get user;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  String? get redirectPath;
  @override // Nouveaux champs
  bool get isPhoneVerificationInProgress;
  @override
  Map<String, dynamic>? get pendingUserData;
  @override
  @JsonKey(ignore: true)
  _$$AuthStateImplCopyWith<_$AuthStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
