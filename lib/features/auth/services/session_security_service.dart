// lib/features/auth/services/session_security_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/device_session.dart';

class SessionSecurityService {
  final SharedPreferences _prefs;
  static const String _sessionsKey = 'user_sessions';
  final _uuid = const Uuid();

  SessionSecurityService(this._prefs);

  // Obtenir toutes les sessions actives
  Future<List<DeviceSession>> getActiveSessions() async {
    final sessionsJson = _prefs.getString(_sessionsKey);
    if (sessionsJson == null) return [];

    try {
      final List<dynamic> sessionsList = jsonDecode(sessionsJson);
      return sessionsList.map((json) => DeviceSession.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Créer une nouvelle session
  Future<DeviceSession> createSession() async {
    final sessions = await getActiveSessions();

    final newSession = DeviceSession(
      id: _uuid.v4(),
      deviceName: await _getDeviceName(),
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );

    sessions.add(newSession);
    await _saveSessions(sessions);

    return newSession;
  }

  // Mettre à jour une session existante
  Future<void> updateSession(String sessionId) async {
    final sessions = await getActiveSessions();
    final index = sessions.indexWhere((s) => s.id == sessionId);

    if (index != -1) {
      sessions[index] = sessions[index].copyWith(
        lastActivityAt: DateTime.now(),
      );
      await _saveSessions(sessions);
    }
  }

  // Révoquer une session spécifique
  Future<void> revokeSession(String sessionId) async {
    final sessions = await getActiveSessions();
    sessions.removeWhere((session) => session.id == sessionId);
    await _saveSessions(sessions);
  }

  // Révoquer toutes les sessions sauf la courante
  Future<void> revokeAllOtherSessions(String currentSessionId) async {
    final sessions = await getActiveSessions();
    final currentSession = sessions.firstWhere(
      (session) => session.id == currentSessionId,
    );
    await _saveSessions([currentSession]);
  }

  // Sauvegarder les sessions
  Future<void> _saveSessions(List<DeviceSession> sessions) async {
    final sessionsJson = jsonEncode(
      sessions.map((s) => s.toJson()).toList(),
    );
    await _prefs.setString(_sessionsKey, sessionsJson);
  }

  // Obtenir le nom de l'appareil (à implémenter selon la plateforme)
  Future<String> _getDeviceName() async {
    // TODO: Implémenter la détection du nom de l'appareil
    return 'Unknown Device';
  }
}
