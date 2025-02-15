// lib/features/bus_booking/services/reservation_service.dart

import 'dart:async';
import '../../home/models/bus_and_utility_models.dart';
import '../models/booking_model.dart';
import '../models/promo_code.dart';
import '../paiement/services/mobile_money_service.dart';
import '../paiement/services/payment_persistence_service.dart';
import '../providers/booking_provider.dart';
import '../services/reservation_persistence_service.dart';
import '../services/ticket_service.dart';

class ReservationService {
  static final ReservationService _instance = ReservationService._internal();
  final _persistenceService = reservationPersistenceService;
  final _paymentPersistenceService = paymentPersistenceService;
  final _ticketService = ticketService;

  factory ReservationService() {
    return _instance;
  }

  ReservationService._internal();

  // Créer une nouvelle réservation
  Future<TicketReservation> createReservation({
    required Bus bus,
    required List<PassengerInfo> passengers,
    required double totalAmount,
    required String userId,
    PromoCode? promoCode,
    double? discountAmount,
  }) async {
    try {
      // Vérifier la disponibilité des places
      final seatsAvailable = await _checkSeatsAvailability(
        bus.id,
        passengers.length,
      );

      if (!seatsAvailable) {
        throw Exception('Places non disponibles');
      }

      // Créer la réservation
      final reservation = TicketReservation(
        id: 'RES${DateTime.now().millisecondsSinceEpoch}',
        bus: bus,
        passengers: passengers,
        status: BookingStatus.pending,
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
        userId: userId,
        appliedPromoCode: promoCode,
        discountAmount: discountAmount,
        paymentHistory: [],
      );

      // Sauvegarder la réservation
      await _persistenceService.saveReservation(reservation);

      // Démarrer le timer d'expiration
      _startExpirationTimer(reservation);

      return reservation;
    } catch (e) {
      print('Erreur lors de la création de la réservation: $e');
      rethrow;
    }
  }

  // Gérer une tentative de paiement
  Future<PaymentResponse> handlePaymentAttempt({
    required TicketReservation reservation,
    required PaymentMethod method,
    required String phoneNumber,
    required String code,
  }) async {
    try {
      // Vérifier l'état de la réservation
      if (reservation.isExpired) {
        throw Exception('La réservation a expiré');
      }

      // Initier le paiement
      final paymentResponse = await mobileMoneyService.initiatePayment(
        method: method,
        phoneNumber: phoneNumber,
        amount: reservation.totalAmount,
        reservationId: reservation.id,
      );

      // Créer une tentative de paiement
      final attempt = PaymentAttempt(
        timestamp: DateTime.now(),
        status: paymentResponse.isSuccess ? 'success' : 'failed',
        paymentMethod: method.toString(),
        amountPaid: paymentResponse.isSuccess ? reservation.totalAmount : 0,
        errorMessage:
            paymentResponse.isSuccess ? null : paymentResponse.message,
        transactionId: paymentResponse.transactionId,
      );

      // Sauvegarder la tentative
      await _paymentPersistenceService.savePaymentAttempt(
        reservationId: reservation.id,
        attempt: attempt,
        newStatus: paymentResponse.isSuccess
            ? BookingStatus.confirmed
            : BookingStatus.pending,
      );

      // Si le paiement est réussi, générer les tickets
      if (paymentResponse.isSuccess) {
        await _ticketService.generateTicketsForReservation(reservation);
      }

      return paymentResponse;
    } catch (e) {
      print('Erreur lors du paiement: $e');
      rethrow;
    }
  }

  // Annuler une réservation
  Future<void> cancelReservation(
    String reservationId, {
    String? reason,
  }) async {
    try {
      final reservation =
          await _persistenceService.getReservation(reservationId);
      if (reservation == null) {
        throw Exception('Réservation non trouvée');
      }

      if (!reservation.canBeCancelled) {
        throw Exception('Cette réservation ne peut plus être annulée');
      }

      // Mettre à jour le statut
      await _persistenceService.updateReservationStatus(
        reservationId,
        BookingStatus.cancelled,
      );

      // Si des tickets ont été générés, les annuler aussi
      final tickets = await _ticketService.getUserTickets(reservation.userId);
      for (var ticket in tickets) {
        if (ticket.bookingReference == reservationId) {
          await _ticketService.cancelTicket(ticket.id);
        }
      }
    } catch (e) {
      print('Erreur lors de l\'annulation: $e');
      rethrow;
    }
  }

  // Vérifier la disponibilité des places
  Future<bool> _checkSeatsAvailability(String busId, int seatsNeeded) async {
    try {
      // Simulation - à remplacer par l'appel API réel
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      print('Erreur lors de la vérification des places: $e');
      return false;
    }
  }

  // Démarrer le timer d'expiration
  void _startExpirationTimer(TicketReservation reservation) {
    Timer(reservation.timeUntilExpiration, () async {
      try {
        final currentReservation = await _persistenceService.getReservation(
          reservation.id,
        );

        if (currentReservation != null &&
            currentReservation.status == BookingStatus.pending) {
          await _persistenceService.updateReservationStatus(
            reservation.id,
            BookingStatus.expired,
          );
        }
      } catch (e) {
        print('Erreur lors de l\'expiration: $e');
      }
    });
  }

  // Obtenir l'historique des réservations
  Future<List<TicketReservation>> getReservationHistory(String userId) async {
    try {
      return await _persistenceService.getReservationsForUser(userId);
    } catch (e) {
      print('Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }

  // Obtenir les réservations en attente
  Future<List<TicketReservation>> getPendingReservations(String userId) async {
    try {
      final reservations =
          await _persistenceService.getReservationsForUser(userId);
      return reservations
          .where((r) => r.status == BookingStatus.pending && !r.isExpired)
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des réservations en attente: $e');
      return [];
    }
  }

  // Gérer l'expiration automatique des réservations
  Future<void> handleExpiredReservations() async {
    try {
      final now = DateTime.now();
      final allReservations = await _persistenceService.getAllReservations();

      for (var reservation in allReservations) {
        if (reservation.status == BookingStatus.pending &&
            now.isAfter(reservation.expiresAt)) {
          await _persistenceService.updateReservationStatus(
            reservation.id,
            BookingStatus.expired,
          );
        }
      }
    } catch (e) {
      print('Erreur lors du traitement des réservations expirées: $e');
    }
  }

  // Vérifier et mettre à jour les disponibilités
  Future<void> checkAndUpdateAvailability() async {
    try {
      final pendingReservations =
          await _persistenceService.getPendingReservations();

      for (var reservation in pendingReservations) {
        final isStillAvailable = await _checkSeatsAvailability(
          reservation.bus.id,
          reservation.passengers.length,
        );

        if (!isStillAvailable) {
          await _persistenceService.updateReservationStatus(
            reservation.id,
            BookingStatus.cancelled,
            reason: 'Places non disponibles',
          );

          // Notifier l'utilisateur (à implémenter selon votre système de notification)
          notifyUserForCancellation(
            userId: reservation.userId,
            reservationId: reservation.id,
            reason: 'Places non disponibles',
          );
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification des disponibilités: $e');
    }
  }

  // Réessayer un paiement échoué
  Future<PaymentResponse> retryPayment({
    required String reservationId,
    required PaymentMethod method,
    required String phoneNumber,
    required String code,
  }) async {
    try {
      final reservation =
          await _persistenceService.getReservation(reservationId);
      if (reservation == null) {
        throw Exception('Réservation non trouvée');
      }

      if (reservation.isExpired) {
        throw Exception('La réservation a expiré');
      }

      // Vérifier le nombre de tentatives aujourd'hui
      final attemptsToday = await _getPaymentAttemptsToday(reservationId);
      if (attemptsToday >= 3) {
        throw Exception(
            'Nombre maximum de tentatives atteint pour aujourd\'hui');
      }

      // Effectuer la nouvelle tentative
      return await handlePaymentAttempt(
        reservation: reservation,
        method: method,
        phoneNumber: phoneNumber,
        code: code,
      );
    } catch (e) {
      print('Erreur lors de la nouvelle tentative de paiement: $e');
      rethrow;
    }
  }

  // Obtenir le nombre de tentatives de paiement du jour
  Future<int> _getPaymentAttemptsToday(String reservationId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final attempts =
          await _paymentPersistenceService.getPaymentHistory(reservationId);

      return attempts.where((attempt) {
        return attempt.timestamp.isAfter(startOfDay);
      }).length;
    } catch (e) {
      print('Erreur lors du comptage des tentatives: $e');
      return 0;
    }
  }

  // Notifier l'utilisateur de l'annulation (à implémenter)
  void notifyUserForCancellation({
    required String userId,
    required String reservationId,
    required String reason,
  }) {
    // Implémenter selon votre système de notification
    print(
        'Notification à l\'utilisateur $userId: Réservation $reservationId annulée. Raison: $reason');
  }

  // Mettre à jour le statut du paiement
  Future<void> updatePaymentStatus({
    required String reservationId,
    required String transactionId,
    required bool isSuccess,
    String? failureReason,
  }) async {
    try {
      final reservation =
          await _persistenceService.getReservation(reservationId);
      if (reservation == null) {
        throw Exception('Réservation non trouvée');
      }

      // Créer une nouvelle tentative de paiement
      final attempt = PaymentAttempt(
        timestamp: DateTime.now(),
        status: isSuccess ? 'success' : 'failed',
        paymentMethod:
            reservation.lastPaymentAttempt?.paymentMethod ?? 'unknown',
        amountPaid: isSuccess ? reservation.totalAmount : 0,
        errorMessage: isSuccess ? null : failureReason,
        transactionId: transactionId,
      );

      // Sauvegarder la tentative et mettre à jour le statut
      await _paymentPersistenceService.savePaymentAttempt(
        reservationId: reservationId,
        attempt: attempt,
        newStatus: isSuccess ? BookingStatus.confirmed : BookingStatus.pending,
      );

      // Si le paiement est réussi, générer les tickets
      if (isSuccess) {
        await _ticketService.generateTicketsForReservation(reservation);
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du statut de paiement: $e');
      rethrow;
    }
  }

  // Archiver les anciennes réservations
  Future<void> archiveOldReservations() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final oldReservations =
          await _persistenceService.getReservationsOlderThan(thirtyDaysAgo);

      for (var reservation in oldReservations) {
        if (reservation.status == BookingStatus.cancelled ||
            reservation.status == BookingStatus.expired) {
          await _persistenceService.archiveReservation(reservation.id);
        }
      }
    } catch (e) {
      print('Erreur lors de l\'archivage des réservations: $e');
    }
  }
}

// Instance singleton
final reservationService = ReservationService();
