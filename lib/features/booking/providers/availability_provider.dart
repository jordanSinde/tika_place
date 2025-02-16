// lib/features/bus_booking/providers/availability_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/availability_service.dart';

class AvailabilityState {
  final Map<String, AvailabilityResult> results;
  final bool isLoading;
  final String? error;

  const AvailabilityState({
    this.results = const {},
    this.isLoading = false,
    this.error,
  });

  AvailabilityState copyWith({
    Map<String, AvailabilityResult>? results,
    bool? isLoading,
    String? error,
  }) {
    return AvailabilityState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AvailabilityNotifier extends StateNotifier<AvailabilityState> {
  final Map<String, StreamSubscription<AvailabilityResult>> _subscriptions = {};

  AvailabilityNotifier() : super(const AvailabilityState());

  // Vérifier la disponibilité une seule fois
  Future<void> checkAvailability(String id, int seatsNeeded) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await availabilityService.checkBusAvailability(
        id,
        seatsNeeded,
      );

      final updatedResults =
          Map<String, AvailabilityResult>.from(state.results);
      updatedResults[id] = result;

      state = state.copyWith(
        results: updatedResults,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur lors de la vérification: $e',
        isLoading: false,
      );
    }
  }

  // Démarrer le monitoring en temps réel
  void startMonitoring(String id, int seatsNeeded) {
    // Arrêter le monitoring existant si présent
    _subscriptions[id]?.cancel();

    // S'abonner aux mises à jour
    _subscriptions[id] =
        availabilityService.monitorBusAvailability(id, seatsNeeded).listen(
      (result) {
        final updatedResults =
            Map<String, AvailabilityResult>.from(state.results);
        updatedResults[id] = result;

        state = state.copyWith(results: updatedResults);
      },
      onError: (error) {
        state = state.copyWith(error: 'Erreur de monitoring: $error');
      },
    );
  }

  // Arrêter le monitoring
  void stopMonitoring(String id) {
    _subscriptions[id]?.cancel();
    _subscriptions.remove(id);
    availabilityService.stopMonitoring(id);
  }

  // Vérifier plusieurs disponibilités
  Future<void> checkMultipleAvailability(Map<String, int> idsAndSeats) async {
    state = state.copyWith(isLoading: true);

    try {
      final results = await availabilityService.checkMultipleBusAvailability(
        idsAndSeats,
      );

      state = state.copyWith(
        results: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur lors de la vérification multiple: $e',
        isLoading: false,
      );
    }
  }

  // Obtenir le dernier résultat pour un ID
  AvailabilityResult? getLastResult(String id) {
    return state.results[id];
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    availabilityService.dispose();
    super.dispose();
  }
}

final availabilityProvider =
    StateNotifierProvider<AvailabilityNotifier, AvailabilityState>((ref) {
  return AvailabilityNotifier();
});

// Provider pour la disponibilité d'une réservation spécifique
final reservationAvailabilityProvider =
    Provider.family<AvailabilityResult?, String>((ref, id) {
  return ref.watch(availabilityProvider).results[id];
});
