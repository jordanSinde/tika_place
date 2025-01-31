//lib/features/bus_booking/services/sync_service.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  final _connectivity = Connectivity();
  Timer? _syncTimer;
  bool _isSyncing = false;

  // File de modifications en attente
  final List<Map<String, dynamic>> _pendingChanges = [];

  factory SyncService() {
    return _instance;
  }

  SyncService._internal();

  Future<void> initialize() async {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (!result.contains(ConnectivityResult.none)) {
        syncWithBackend();
      }
    });
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    // Synchroniser toutes les 15 minutes
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      syncWithBackend();
    });
  }

  /*void _handleConnectivityChange(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      syncWithBackend();
    }
  }*/

  Future<void> syncWithBackend() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // Vérifier la connectivité
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        _isSyncing = false;
        return;
      }

      // Traiter les modifications en attente
      while (_pendingChanges.isNotEmpty) {
        final change = _pendingChanges.first;
        await _processPendingChange(change);
        _pendingChanges.removeAt(0);
      }

      // Simuler une synchronisation avec le backend
      await Future.delayed(const Duration(seconds: 2));

      _isSyncing = false;
    } catch (e) {
      print('Erreur de synchronisation: $e');
      _isSyncing = false;
    }
  }

  Future<void> _processPendingChange(Map<String, dynamic> change) async {
    try {
      switch (change['type']) {
        case 'ticket_validation':
          await _syncTicketValidation(change['data']);
          break;
        case 'ticket_cancellation':
          await _syncTicketCancellation(change['data']);
          break;
        // Ajouter d'autres types de changements si nécessaire
      }
    } catch (e) {
      // En cas d'erreur, remettre le changement dans la file
      _pendingChanges.add(change);
      rethrow;
    }
  }

  // Ajouter une modification à synchroniser plus tard
  void addPendingChange(String type, Map<String, dynamic> data) {
    _pendingChanges.add({
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _syncTicketValidation(Map<String, dynamic> data) async {
    // Simuler un appel API pour la validation d'un ticket
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _syncTicketCancellation(Map<String, dynamic> data) async {
    // Simuler un appel API pour l'annulation d'un ticket
    await Future.delayed(const Duration(seconds: 1));
  }

  // Forcer une synchronisation immédiate
  Future<void> forceSyncNow() async {
    await syncWithBackend();
  }

  // Vérifier s'il y a des modifications en attente
  bool hasPendingChanges() {
    return _pendingChanges.isNotEmpty;
  }

  // Obtenir le nombre de modifications en attente
  int getPendingChangesCount() {
    return _pendingChanges.length;
  }

  // Nettoyer les ressources lors de la fermeture de l'application
  void dispose() {
    _syncTimer?.cancel();
  }
}

// Singleton instance
final syncService = SyncService();
