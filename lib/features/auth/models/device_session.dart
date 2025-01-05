// lib/features/auth/models/device_session.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_session.freezed.dart';
part 'device_session.g.dart';

@freezed
class DeviceSession with _$DeviceSession {
  const factory DeviceSession({
    required String id,
    required String deviceName,
    required DateTime createdAt,
    required DateTime lastActivityAt,
  }) = _DeviceSession;

  factory DeviceSession.fromJson(Map<String, dynamic> json) =>
      _$DeviceSessionFromJson(json);
}
