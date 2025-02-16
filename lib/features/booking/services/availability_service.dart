// lib/features/bus_booking/services/availability_service.dart

import 'dart:async';

import 'package:retry/retry.dart';

enum AvailabilityStatus { available, partiallyAvailable, unavailable, unknown }

class AvailabilityResult {
  final AvailabilityStatus status;
  final int? availableCount;
  final String? message;
  final DateTime timestamp;

  AvailabilityResult({
    required this.status,
    this.availableCount,
    this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isAvailable => status == AvailabilityStatus.available;
}

class AvailabilityService {
  static final AvailabilityService _instance = AvailabilityService._internal();

  // Stream controllers pour chaque type de réservation
  final _busAvailabilityControllers =
      <String, StreamController<AvailabilityResult>>{};

  // Timers pour les vérifications périodiques
  final _checkTimers = <String, Timer>{};

  // Retry configuration
  final _retry = const RetryOptions(
    maxAttempts: 3,
    delayFactor: Duration(seconds: 1),
  );

  factory AvailabilityService() {
    return _instance;
  }

  AvailabilityService._internal();

  // Vérifier la disponibilité du bus
  Future<AvailabilityResult> checkBusAvailability(
    String busId,
    int seatsNeeded,
  ) async {
    try {
      return await _retry.retry(
        () async {
          // Simuler un appel API
          await Future.delayed(const Duration(seconds: 1));

          // Simuler une réponse avec 80% de chance d'être disponible
          final random = DateTime.now().millisecond;
          final availableSeats = random % 5 + seatsNeeded;

          if (availableSeats >= seatsNeeded) {
            return AvailabilityResult(
              status: AvailabilityStatus.available,
              availableCount: availableSeats,
              message: 'Places disponibles',
            );
          } else if (availableSeats > 0) {
            return AvailabilityResult(
              status: AvailabilityStatus.partiallyAvailable,
              availableCount: availableSeats,
              message: 'Seulement $availableSeats places disponibles',
            );
          } else {
            return AvailabilityResult(
              status: AvailabilityStatus.unavailable,
              message: 'Plus de places disponibles',
            );
          }
        },
        // En cas d'erreur réseau
        retryIf: (e) => e is Exception,
      );
    } catch (e) {
      return AvailabilityResult(
        status: AvailabilityStatus.unknown,
        message: 'Erreur lors de la vérification: $e',
      );
    }
  }

  // Démarrer le monitoring en temps réel
  Stream<AvailabilityResult> monitorBusAvailability(
    String busId,
    int seatsNeeded,
  ) {
    // Créer un nouveau controller si nécessaire
    _busAvailabilityControllers[busId]?.close();
    _busAvailabilityControllers[busId] =
        StreamController<AvailabilityResult>.broadcast();

    // Configurer la vérification périodique
    _checkTimers[busId]?.cancel();
    _checkTimers[busId] = Timer.periodic(
      const Duration(minutes: 1),
      (_) async {
        final result = await checkBusAvailability(busId, seatsNeeded);
        _busAvailabilityControllers[busId]?.add(result);
      },
    );

    // Effectuer une première vérification immédiate
    checkBusAvailability(busId, seatsNeeded).then(
      (result) => _busAvailabilityControllers[busId]?.add(result),
    );

    return _busAvailabilityControllers[busId]!.stream;
  }

  // Arrêter le monitoring
  void stopMonitoring(String id) {
    _busAvailabilityControllers[id]?.close();
    _busAvailabilityControllers.remove(id);
    _checkTimers[id]?.cancel();
    _checkTimers.remove(id);
  }

  // Vérifier plusieurs disponibilités en même temps
  Future<Map<String, AvailabilityResult>> checkMultipleBusAvailability(
    Map<String, int> busSeatsNeeded,
  ) async {
    final results = <String, AvailabilityResult>{};

    await Future.wait(
      busSeatsNeeded.entries.map((entry) async {
        results[entry.key] = await checkBusAvailability(
          entry.key,
          entry.value,
        );
      }),
    );

    return results;
  }

  // En cas de besoin de nettoyage
  void dispose() {
    for (final controller in _busAvailabilityControllers.values) {
      controller.close();
    }
    _busAvailabilityControllers.clear();

    for (final timer in _checkTimers.values) {
      timer.cancel();
    }
    _checkTimers.clear();
  }
}

final availabilityService = AvailabilityService();

/*
class AvailabilityService {
  static final AvailabilityService _instance = AvailabilityService._internal();

  factory AvailabilityService() {
    return _instance;
  }

  AvailabilityService._internal();

  Future<bool> checkBusAvailability(String busId, int seatsNeeded) async {
    try {
      // Simuler une vérification d'API
      await Future.delayed(const Duration(seconds: 1));

      // Pour le moment, simulation avec une réponse aléatoire
      // À remplacer par un vrai appel API plus tard
      return DateTime.now().millisecond % 5 !=
          0; // 80% de chance d'être disponible
    } catch (e) {
      print('Erreur lors de la vérification de disponibilité: $e');
      // En cas d'erreur, on suppose que c'est disponible pour éviter
      // d'annuler des réservations par erreur
      return true;
    }
  }

  Future<bool> checkHotelAvailability(String hotelId, String roomId,
      DateTime checkIn, DateTime checkOut) async {
    // À implémenter quand l'API hôtel sera prête
    return true;
  }

  Future<bool> checkApartmentAvailability(
      String apartmentId, DateTime startDate, DateTime endDate) async {
    // À implémenter quand l'API appartement sera prête
    return true;
  }
}

final availabilityService = AvailabilityService();
*/