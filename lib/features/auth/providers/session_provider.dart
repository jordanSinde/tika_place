// lib/features/auth/providers/session_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/shared_preferences_provider.dart';
import '../models/device_session.dart';
import '../services/session_security_service.dart';

part 'session_provider.g.dart';

@riverpod
SessionSecurityService sessionSecurity(SessionSecurityRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SessionSecurityService(prefs);
}

@riverpod
Stream<List<DeviceSession>> activeSessions(ActiveSessionsRef ref) async* {
  final service = ref.watch(sessionSecurityProvider);
  // Simuler un stream de sessions
  while (true) {
    yield await service.getActiveSessions();
    await Future.delayed(
        const Duration(seconds: 30)); // Rafraîchir toutes les 30 secondes
  }
}

@riverpod
class CurrentSession extends _$CurrentSession {
  @override
  DeviceSession? build() {
    return null;
  }

  Future<void> setCurrentSession(DeviceSession session) async {
    state = session;
  }

  Future<void> updateLastActivity() async {
    if (state != null) {
      await ref.read(sessionSecurityProvider).updateSession(state!.id);
    }
  }
}
