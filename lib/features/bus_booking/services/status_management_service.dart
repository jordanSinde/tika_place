// lib/features/bus_booking/services/status_management_service.dart

import 'dart:async';

import '../../notifications/services/notification_service.dart';
import '../models/booking_model.dart';
import '../paiement/services/payment_persistence_service.dart';
import '../providers/booking_provider.dart';
import '../providers/reservation_state_notifier.dart';
import 'reservation_persistence_service.dart';

class StatusManagementService {
  static final StatusManagementService _instance =
      StatusManagementService._internal();
  Timer? _periodicCheckTimer;
  final Duration _checkInterval = const Duration(minutes: 1);

  factory StatusManagementService() {
    return _instance;
  }

  StatusManagementService._internal() {
    _startPeriodicCheck();
  }

  void _startPeriodicCheck() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = Timer.periodic(_checkInterval, (_) {
      _checkAndUpdateStatuses();
    });
  }

  Future<void> _checkAndUpdateStatuses() async {
    try {
      // Récupérer toutes les réservations en attente
      final reservations =
          await reservationPersistenceService.getPendingReservations();

      for (var reservation in reservations) {
        // 1. Vérifier l'expiration
        if (_isExpired(reservation)) {
          await _handleExpiration(reservation);
          continue;
        }

        // 2. Vérifier la disponibilité des places
        final isAvailable = await _checkAvailability(reservation);
        if (!isAvailable) {
          await _handleUnavailability(reservation);
          continue;
        }

        // 3. Vérifier les tentatives de paiement
        await _checkPaymentAttempts(reservation);

        // 4. Gérer les timeouts de paiement
        await _handlePaymentTimeouts(reservation);
      }
    } catch (e) {
      print('Erreur lors de la vérification des statuts: $e');
    }
  }

  bool _isExpired(TicketReservation reservation) {
    return DateTime.now().isAfter(reservation.expiresAt);
  }

  Future<bool> _checkAvailability(TicketReservation reservation) async {
    try {
      // Vérifier la disponibilité des places
      return await ref
          .read(centralReservationProvider.notifier)
          ._checkSeatAvailability(
            reservation.bus.id,
            reservation.passengers.length,
          );
    } catch (e) {
      print('Erreur lors de la vérification de disponibilité: $e');
      return false;
    }
  }

  Future<void> _handleExpiration(TicketReservation reservation) async {
    try {
      // 1. Mettre à jour le statut
      await reservationPersistenceService.updateReservationStatus(
        reservation.id,
        BookingStatus.expired,
      );

      // 2. Notifier l'utilisateur
      await notificationService.notifyReservationStatusChange(
        reservationId: reservation.id,
        oldStatus: BookingStatus.pending,
        newStatus: BookingStatus.expired,
      );

      // 3. Libérer les ressources
      await _releaseResources(reservation);
    } catch (e) {
      print('Erreur lors du traitement de l\'expiration: $e');
    }
  }

  Future<void> _handleUnavailability(TicketReservation reservation) async {
    try {
      // 1. Mettre à jour le statut
      await reservationPersistenceService.updateReservationStatus(
        reservation.id,
        BookingStatus.cancelled,
        reason: 'Places non disponibles',
      );

      // 2. Notifier l'utilisateur
      await notificationService.notifyAvailabilityChange(
        reservationId: reservation.id,
        busId: reservation.bus.id,
        isAvailable: false,
      );

      // 3. Libérer les ressources
      await _releaseResources(reservation);
    } catch (e) {
      print('Erreur lors du traitement de l\'indisponibilité: $e');
    }
  }

  Future<void> _checkPaymentAttempts(TicketReservation reservation) async {
    try {
      final attempts = await paymentPersistenceService.getPaymentHistory(
        reservation.id,
      );

      // Vérifier les tentatives du jour
      final attemptsToday = attempts.where((attempt) {
        final today = DateTime.now();
        return attempt.timestamp.year == today.year &&
            attempt.timestamp.month == today.month &&
            attempt.timestamp.day == today.day;
      }).length;

      if (attemptsToday >= 3) {
        await reservationPersistenceService.updateReservationStatus(
          reservation.id,
          BookingStatus.failed,
          reason: 'Nombre maximum de tentatives atteint',
        );

        await notificationService.notifyPaymentAttempt(
          reservationId: reservation.id,
          isSuccess: false,
          errorMessage: 'Nombre maximum de tentatives atteint',
        );
      }
    } catch (e) {
      print('Erreur lors de la vérification des tentatives: $e');
    }
  }

  Future<void> _handlePaymentTimeouts(TicketReservation reservation) async {
    try {
      final lastAttempt = await paymentPersistenceService.getLastPaymentAttempt(
        reservation.id,
      );

      if (lastAttempt != null) {
        const timeoutDuration = Duration(minutes: 15);
        if (DateTime.now().difference(lastAttempt.timestamp) >
            timeoutDuration) {
          await paymentPersistenceService.cleanupTimedOutAttempt(
            reservation.id,
            lastAttempt.id,
          );
        }
      }
    } catch (e) {
      print('Erreur lors du traitement des timeouts: $e');
    }
  }

  Future<void> _releaseResources(TicketReservation reservation) async {
    try {
      // Libérer les places réservées
      // Nettoyer les tentatives de paiement
      // Autres nettoyages nécessaires
    } catch (e) {
      print('Erreur lors de la libération des ressources: $e');
    }
  }

  void dispose() {
    _periodicCheckTimer?.cancel();
  }
}

// Instance singleton
final statusManagementService = StatusManagementService();
