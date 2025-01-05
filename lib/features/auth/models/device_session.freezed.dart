// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DeviceSession _$DeviceSessionFromJson(Map<String, dynamic> json) {
  return _DeviceSession.fromJson(json);
}

/// @nodoc
mixin _$DeviceSession {
  String get id => throw _privateConstructorUsedError;
  String get deviceName => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get lastActivityAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DeviceSessionCopyWith<DeviceSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceSessionCopyWith<$Res> {
  factory $DeviceSessionCopyWith(
          DeviceSession value, $Res Function(DeviceSession) then) =
      _$DeviceSessionCopyWithImpl<$Res, DeviceSession>;
  @useResult
  $Res call(
      {String id,
      String deviceName,
      DateTime createdAt,
      DateTime lastActivityAt});
}

/// @nodoc
class _$DeviceSessionCopyWithImpl<$Res, $Val extends DeviceSession>
    implements $DeviceSessionCopyWith<$Res> {
  _$DeviceSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceName = null,
    Object? createdAt = null,
    Object? lastActivityAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deviceName: null == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastActivityAt: null == lastActivityAt
          ? _value.lastActivityAt
          : lastActivityAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeviceSessionImplCopyWith<$Res>
    implements $DeviceSessionCopyWith<$Res> {
  factory _$$DeviceSessionImplCopyWith(
          _$DeviceSessionImpl value, $Res Function(_$DeviceSessionImpl) then) =
      __$$DeviceSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String deviceName,
      DateTime createdAt,
      DateTime lastActivityAt});
}

/// @nodoc
class __$$DeviceSessionImplCopyWithImpl<$Res>
    extends _$DeviceSessionCopyWithImpl<$Res, _$DeviceSessionImpl>
    implements _$$DeviceSessionImplCopyWith<$Res> {
  __$$DeviceSessionImplCopyWithImpl(
      _$DeviceSessionImpl _value, $Res Function(_$DeviceSessionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceName = null,
    Object? createdAt = null,
    Object? lastActivityAt = null,
  }) {
    return _then(_$DeviceSessionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deviceName: null == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastActivityAt: null == lastActivityAt
          ? _value.lastActivityAt
          : lastActivityAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceSessionImpl implements _DeviceSession {
  const _$DeviceSessionImpl(
      {required this.id,
      required this.deviceName,
      required this.createdAt,
      required this.lastActivityAt});

  factory _$DeviceSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String deviceName;
  @override
  final DateTime createdAt;
  @override
  final DateTime lastActivityAt;

  @override
  String toString() {
    return 'DeviceSession(id: $id, deviceName: $deviceName, createdAt: $createdAt, lastActivityAt: $lastActivityAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastActivityAt, lastActivityAt) ||
                other.lastActivityAt == lastActivityAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, deviceName, createdAt, lastActivityAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceSessionImplCopyWith<_$DeviceSessionImpl> get copyWith =>
      __$$DeviceSessionImplCopyWithImpl<_$DeviceSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceSessionImplToJson(
      this,
    );
  }
}

abstract class _DeviceSession implements DeviceSession {
  const factory _DeviceSession(
      {required final String id,
      required final String deviceName,
      required final DateTime createdAt,
      required final DateTime lastActivityAt}) = _$DeviceSessionImpl;

  factory _DeviceSession.fromJson(Map<String, dynamic> json) =
      _$DeviceSessionImpl.fromJson;

  @override
  String get id;
  @override
  String get deviceName;
  @override
  DateTime get createdAt;
  @override
  DateTime get lastActivityAt;
  @override
  @JsonKey(ignore: true)
  _$$DeviceSessionImplCopyWith<_$DeviceSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
