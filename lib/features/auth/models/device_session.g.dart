// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeviceSessionImpl _$$DeviceSessionImplFromJson(Map<String, dynamic> json) =>
    _$DeviceSessionImpl(
      id: json['id'] as String,
      deviceName: json['deviceName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
    );

Map<String, dynamic> _$$DeviceSessionImplToJson(_$DeviceSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceName': instance.deviceName,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastActivityAt': instance.lastActivityAt.toIso8601String(),
    };
