// lib/features/bus_booking/providers/reservation_state_notifier.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../notifications/services/notification_service.dart';
import '../models/booking_model.dart';
import 'booking_provider.dart';
import 'ticket_model.dart';
import 'reservation_provider.dart';

// État central qui combine tous les états nécessaires
class CentralReservationState {
  final List<TicketReservation> reservations;
  final List<ExtendedTicket> tickets;
  final Map<String, Timer> expirationTimers;
  final Map<String, bool> seatsAvailability;
  final bool isLoading;
  final String? error;
  final DateTime lastCheck;
  final Map<String, int> paymentAttempts;

  const CentralReservationState({
    this.reservations = const [],
    this.tickets = const [],
    this.expirationTimers = const {},
    this.seatsAvailability = const {},
    this.isLoading = false,
    this.error,
    DateTime? lastCheck,
    this.paymentAttempts = const {},
  }) : lastCheck = lastCheck ?? DateTime.now();

  CentralReservationState copyWith({
    List<TicketReservation>? reservations,
    List<ExtendedTicket>? tickets,
    Map<String, Timer>? expirationTimers,
    Map<String, bool>? seatsAvailability,
    bool? isLoading,
    String? error,
    DateTime? lastCheck,
    Map<String, int>? paymentAttempts,
  }) {
    return CentralReservationState(
      reservations: reservations ?? this.reservations,
      tickets: tickets ?? this.tickets,
      expirationTimers: expirationTimers ?? this.expirationTimers,
      seatsAvailability: seatsAvailability ?? this.seatsAvailability,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastCheck: lastCheck ?? this.lastCheck,
      paymentAttempts: paymentAttempts ?? this.paymentAttempts,
    );
  }
}

class CentralReservationNotifier
    extends StateNotifier<CentralReservationState> {
  final Ref ref;
  Timer? _periodicCheckTimer;
  static const _checkInterval = Duration(minutes: 5);
  static const _maxPaymentAttempts = 3;

  CentralReservationNotifier(this.ref)
      : super(const CentralReservationState()) {
    _initializePeriodicCheck();
  }

  void _initializePeriodicCheck() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = Timer.periodic(_checkInterval, (_) {
      _checkAvailabilityAndExpiration();
    });
  }

  // Vérification périodique des disponibilités et expirations
  Future<void> _checkAvailabilityAndExpiration() async {
    try {
      state = state.copyWith(isLoading: true);

      // 1. Vérifier les disponibilités pour toutes les réservations en attente
      final pendingReservations = state.reservations
          .where((r) => r.status == BookingStatus.pending)
          .toList();

      final availabilityUpdates = <String, bool>{};
      for (var reservation in pendingReservations) {
        final isAvailable = await _checkSeatAvailability(
          reservation.bus.id,
          reservation.passengers.length,
        );
        availabilityUpdates[reservation.id] = isAvailable;

        // Si les places ne sont plus disponibles, annuler la réservation
        if (!isAvailable) {
          await _cancelReservation(
            reservation.id,
            'Places non disponibles',
            true,
          );
        }
      }

      // 2. Vérifier les expirations
      final now = DateTime.now();
      for (var reservation in state.reservations) {
        if (reservation.status == BookingStatus.pending &&
            now.isAfter(reservation.expiresAt)) {
          await _handleExpiration(reservation.id);
        }
      }

      state = state.copyWith(
        seatsAvailability: availabilityUpdates,
        lastCheck: now,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur lors de la vérification: $e',
        isLoading: false,
      );
    }
  }

  // Vérification des disponibilités
  Future<bool> _checkSeatAvailability(String busId, int seatsNeeded) async {
    try {
      // Appel au service de réservation
      return await ref
          .read(reservationProvider.notifier)
          .checkSeatsAvailability(
            busId,
            seatsNeeded,
          );
    } catch (e) {
      print('Erreur lors de la vérification des sièges: $e');
      return false;
    }
  }

  // Gestion des expirations
  Future<void> _handleExpiration(String reservationId) async {
    try {
      // 1. Mettre à jour le statut
      await ref.read(reservationProvider.notifier).updateReservationStatus(
            reservationId,
            BookingStatus.expired,
          );

      // 2. Nettoyer les timers
      final expirationTimers = Map<String, Timer>.from(state.expirationTimers);
      expirationTimers[reservationId]?.cancel();
      expirationTimers.remove(reservationId);

      // 3. Notifier l'utilisateur
      await notificationService.showBookingConfirmationNotification(
        title: 'Réservation expirée',
        body:
            'Votre réservation a expiré. Veuillez effectuer une nouvelle réservation.',
      );

      // 4. Mettre à jour l'état
      final updatedReservations = state.reservations.map((reservation) {
        if (reservation.id == reservationId) {
          return reservation.copyWith(status: BookingStatus.expired);
        }
        return reservation;
      }).toList();

      state = state.copyWith(
        reservations: updatedReservations,
        expirationTimers: expirationTimers,
      );
    } catch (e) {
      print('Erreur lors de l\'expiration: $e');
    }
  }

  // Vérification des doublons
  Future<bool> checkDuplicateReservation(String userId, String busId) async {
    return state.reservations.any((reservation) =>
        reservation.userId == userId &&
        reservation.bus.id == busId &&
        reservation.status == BookingStatus.pending &&
        !reservation.isExpired);
  }

  // Validation du paiement
  Future<bool> validatePaymentAttempt(String reservationId) async {
    final attempts = state.paymentAttempts[reservationId] ?? 0;
    if (attempts >= _maxPaymentAttempts) {
      state = state.copyWith(
        error: 'Nombre maximum de tentatives de paiement atteint',
      );
      return false;
    }

    final paymentAttempts = Map<String, int>.from(state.paymentAttempts);
    paymentAttempts[reservationId] = attempts + 1;
    state = state.copyWith(paymentAttempts: paymentAttempts);

    return true;
  }

  // Annulation avec notification
  Future<void> _cancelReservation(
    String reservationId,
    String reason,
    bool notifyUser,
  ) async {
    try {
      await ref.read(reservationProvider.notifier).cancelReservation(
            reservationId,
            reason: reason,
          );

      if (notifyUser) {
        await notificationService.showBookingConfirmationNotification(
          title: 'Réservation annulée',
          body: reason,
        );
      }

      final updatedReservations = state.reservations.map((reservation) {
        if (reservation.id == reservationId) {
          return reservation.copyWith(
            status: BookingStatus.cancelled,
            cancellationReason: reason,
          );
        }
        return reservation;
      }).toList();

      state = state.copyWith(reservations: updatedReservations);
    } catch (e) {
      print('Erreur lors de l\'annulation: $e');
    }
  }

  @override
  void dispose() {
    _periodicCheckTimer?.cancel();
    super.dispose();
  }
}

// Provider global
final centralReservationProvider =
    StateNotifierProvider<CentralReservationNotifier, CentralReservationState>(
  (ref) => CentralReservationNotifier(ref),
);
