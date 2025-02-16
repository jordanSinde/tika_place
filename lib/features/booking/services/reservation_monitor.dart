// lib/features/common/services/reservation_monitor.dart

import 'dart:async';
import '../../notifications/services/notification_service.dart';
import '../models/base_reservation.dart';
import '../providers/availability_provider.dart';
import '../providers/reservation_provider.dart';
import 'availability_service.dart';

class ReservationMonitor {
  static final ReservationMonitor _instance = ReservationMonitor._internal();
  final Map<String, Timer> _expirationTimers = {};
  final Map<String, Timer> _availabilityTimers = {};
  static const _availabilityCheckInterval = Duration(minutes: 1);
  static const _reservationTimeout = Duration(minutes: 30);

  factory ReservationMonitor() {
    return _instance;
  }

  ReservationMonitor._internal();

  void startMonitoring(
      BaseReservation reservation, ReservationNotifier notifier) {
    // Arrêter les timers existants si présents
    _expirationTimers[reservation.id]?.cancel();
    _availabilityTimers[reservation.id]?.cancel();

    // Configurer le timer d'expiration pour les réservations en attente
    if (reservation.status == ReservationStatus.pending) {
      final expirationTime = reservation.createdAt.add(_reservationTimeout);
      final now = DateTime.now();

      if (now.isBefore(expirationTime)) {
        _expirationTimers[reservation.id] = Timer(
          expirationTime.difference(now),
          () => _handleExpiration(reservation, notifier),
        );
      } else {
        // Si déjà expiré
        _handleExpiration(reservation, notifier);
        return;
      }

      // Configurer le timer de vérification de disponibilité
      _availabilityTimers[reservation.id] = Timer.periodic(
        _availabilityCheckInterval,
        (_) => _checkAvailability(reservation, notifier),
      );
    }
  }

  Future<void> _handleExpiration(
    BaseReservation reservation,
    ReservationNotifier notifier,
  ) async {
    // Mettre à jour le statut
    await notifier.updateReservationStatus(
      reservation.id,
      ReservationStatus.expired,
      'La réservation a expiré',
    );

    // Envoyer une notification
    await notificationService.showBookingConfirmationNotification(
      title: 'Réservation expirée',
      body: 'Votre réservation a expiré. Vous pouvez en créer une nouvelle.',
    );

    // Nettoyer les timers
    _cleanup(reservation.id);
  }

  Future<void> _checkAvailability(
    BaseReservation reservation,
    ReservationNotifier notifier,
  ) async {
    if (reservation is BusReservation) {
      try {
        final result = await availabilityService.checkBusAvailability(
          reservation.bus.id,
          reservation.passengers.length,
        );

        if (result.status == AvailabilityStatus.unavailable) {
          // Mettre à jour le statut
          await notifier.updateReservationStatus(
            reservation.id,
            ReservationStatus.cancelled,
            'Plus de places disponibles',
          );

          // Envoyer une notification
          await notificationService.showBookingConfirmationNotification(
            title: 'Réservation annulée',
            body: 'Plus de places disponibles pour votre réservation.',
          );

          // Nettoyer les timers
          _cleanup(reservation.id);
        } else if (result.status == AvailabilityStatus.partiallyAvailable) {
          // Envoyer une notification d'avertissement
          await notificationService.showBookingConfirmationNotification(
            title: 'Places limitées',
            body:
                'Il ne reste que ${result.availableCount} places disponibles. Complétez votre réservation rapidement.',
          );
        }
      } catch (e) {
        print('Erreur lors de la vérification de disponibilité: $e');
      }
    }
    // Ajouter des vérifications similaires pour les hôtels et appartements
  }

  // Pour démarrer le monitoring en temps réel
  void startRealTimeMonitoring(BaseReservation reservation) {
    if (reservation is BusReservation) {
      availabilityProvider.startMonitoring(
        reservation.bus.id,
        reservation.passengers.length,
      );
    }
  }

  // Pour arrêter le monitoring en temps réel
  void stopRealTimeMonitoring(BaseReservation reservation) {
    if (reservation is BusReservation) {
      availabilityProvider.stopMonitoring(reservation.bus.id);
    }
  }

  void stopMonitoring(String reservationId) {
    _cleanup(reservationId);
  }

  void _cleanup(String reservationId) {
    _expirationTimers[reservationId]?.cancel();
    _expirationTimers.remove(reservationId);

    _availabilityTimers[reservationId]?.cancel();
    _availabilityTimers.remove(reservationId);
  }

  // Pour le nettoyage des anciennes réservations
  Future<void> cleanupOldReservations(ReservationNotifier notifier) async {
    try {
      final now = DateTime.now();
      final oldReservations = await notifier.getOldReservations();

      for (final reservation in oldReservations) {
        if (reservation.status == ReservationStatus.pending) {
          // Mettre à jour les réservations en attente expirées
          final expirationTime = reservation.createdAt.add(_reservationTimeout);
          if (now.isAfter(expirationTime)) {
            await notifier.updateReservationStatus(
              reservation.id,
              ReservationStatus.expired,
              'La réservation a expiré',
            );
          }
        }
      }
    } catch (e) {
      print('Erreur lors du nettoyage des anciennes réservations: $e');
    }
  }

  // Pour la vérification initiale
  Future<void> initializeMonitoring(ReservationNotifier notifier) async {
    try {
      final activeReservations = await notifier.getActiveReservations();

      for (final reservation in activeReservations) {
        startMonitoring(reservation, notifier);
      }

      // Nettoyer les anciennes réservations
      await cleanupOldReservations(notifier);
    } catch (e) {
      print('Erreur lors de l\'initialisation du monitoring: $e');
    }
  }
}

final reservationMonitor = ReservationMonitor();
