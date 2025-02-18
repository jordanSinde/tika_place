// lib/features/bus_booking/providers/reservation_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/models/bus_mock_data.dart';
import '../../notifications/services/notification_service.dart';
import '../models/booking_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/promo_code.dart';
import '../services/reservation_service.dart';
import 'booking_provider.dart';

class ReservationState {
  final List<TicketReservation> reservations;
  final bool isLoading;
  final String? error;
  final Map<String, Timer> expirationTimers;

  ReservationState({
    this.reservations = const [],
    this.isLoading = false,
    this.error,
    this.expirationTimers = const {},
  });

  ReservationState copyWith({
    List<TicketReservation>? reservations,
    bool? isLoading,
    String? error,
    Map<String, Timer>? expirationTimers,
  }) {
    return ReservationState(
      reservations: reservations ?? this.reservations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      expirationTimers: expirationTimers ?? this.expirationTimers,
    );
  }
}

class ReservationNotifier extends StateNotifier<ReservationState> {
  final Ref ref;
  static const reservationDuration = Duration(minutes: 30);

  ReservationNotifier(this.ref) : super(ReservationState()) {
    // Charger les réservations au démarrage
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    state = state.copyWith(isLoading: true);

    try {
      // Simulation du chargement depuis une API
      await Future.delayed(const Duration(seconds: 1));

      // Pour le moment, on utilise une liste vide
      // Implémenter le chargement réel depuis l'API
      state = state.copyWith(
        reservations: [],
        isLoading: false,
      );

      // Initialiser les timers pour les réservations en attente
      _initializeExpirationTimers();
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur lors du chargement des réservations: $e',
        isLoading: false,
      );
    }
  }

  void _initializeExpirationTimers() {
    final timers = <String, Timer>{};

    for (final reservation in state.reservations) {
      if (reservation.status == BookingStatus.pending &&
          !reservation.isExpired) {
        timers[reservation.id] = _createExpirationTimer(reservation);
      }
    }

    state = state.copyWith(expirationTimers: timers);
  }

  Timer _createExpirationTimer(TicketReservation reservation) {
    return Timer(reservation.timeUntilExpiration, () {
      _handleReservationExpiration(reservation);
    });
  }

  Future<void> _handleReservationExpiration(
      TicketReservation reservation) async {
    // Mettre à jour le statut de la réservation
    final updatedReservation =
        reservation.copyWith(status: BookingStatus.expired);
    _updateReservation(updatedReservation);

    // Envoyer une notification
    await notificationService.showBookingConfirmationNotification(
      title: 'Réservation expirée',
      body:
          'Votre réservation pour ${reservation.bus.departureCity} → ${reservation.bus.arrivalCity} a expiré.',
    );
  }

  Future<TicketReservation> createReservation({
    required Bus bus,
    required List<PassengerInfo> passengers,
    required double totalAmount,
    PromoCode? promoCode,
    double? discountAmount,
  }) async {
    print('🚀 RESERVATION PROVIDER: Creating reservation');

    // Créer une nouvelle réservation
    final reservation = TicketReservation(
      id: 'RES${DateTime.now().millisecondsSinceEpoch}',
      bus: bus,
      passengers: passengers,
      status: BookingStatus.pending,
      totalAmount: totalAmount,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(reservationDuration),
      userId: ref.read(authProvider).user?.id ?? '',
      appliedPromoCode: promoCode,
      discountAmount: discountAmount,
    );

    // Mettre à jour l'état
    state = state.copyWith(
      reservations: [...state.reservations, reservation],
    );

    // Créer un timer pour l'expiration
    final expirationTimers = Map<String, Timer>.from(state.expirationTimers);
    expirationTimers[reservation.id] = _createExpirationTimer(reservation);
    state = state.copyWith(expirationTimers: expirationTimers);

    print('✅ RESERVATION PROVIDER: Reservation created');
    print('📋 Reservation ID: ${reservation.id}');
    print('📋 Passengers: ${reservation.passengers.length}');
    print('📋 Status: ${reservation.status}');
    print(
        '📋 Expires in: ${reservation.timeUntilExpiration.inMinutes} minutes');

    return reservation;
  }

  // Create reservation from booking state
  Future<TicketReservation> createReservationFromBooking(
      BookingState bookingState) async {
    print('🚀 RESERVATION PROVIDER: Creating reservation from booking');

    try {
      final reservation =
          await reservationService.createReservationFromBooking(bookingState);

      // Add to state
      state = state.copyWith(
        reservations: [...state.reservations, reservation],
      );

      // Create timer for expiration
      final expirationTimers = Map<String, Timer>.from(state.expirationTimers);
      expirationTimers[reservation.id] = _createExpirationTimer(reservation);
      state = state.copyWith(expirationTimers: expirationTimers);

      print('✅ RESERVATION PROVIDER: Reservation added to state');
      return reservation;
    } catch (e) {
      print('❌ RESERVATION PROVIDER: Failed to create reservation: $e');
      rethrow;
    }
  }

  void _updateReservation(TicketReservation updatedReservation) {
    final updatedReservations = state.reservations.map((reservation) {
      if (reservation.id == updatedReservation.id) {
        return updatedReservation;
      }
      return reservation;
    }).toList();

    state = state.copyWith(reservations: updatedReservations);
  }

  Future<void> cancelReservation(String reservationId, {String? reason}) async {
    final reservation = state.reservations.firstWhere(
      (r) => r.id == reservationId,
    );

    if (!reservation.canBeCancelled) {
      throw Exception('Cette réservation ne peut plus être annulée');
    }

    // Mettre à jour la réservation
    final updatedReservation = reservation.copyWith(
      status: BookingStatus.cancelled,
      cancellationReason: reason,
    );

    _updateReservation(updatedReservation);

    // Arrêter le timer s'il existe
    final timer = state.expirationTimers[reservationId];
    timer?.cancel();

    // Mettre à jour les timers
    final expirationTimers = Map<String, Timer>.from(state.expirationTimers);
    expirationTimers.remove(reservationId);
    state = state.copyWith(expirationTimers: expirationTimers);
  }

  Future<void> addPaymentAttempt(
    String reservationId,
    PaymentAttempt attempt,
  ) async {
    final reservation = state.reservations.firstWhere(
      (r) => r.id == reservationId,
    );

    // Convertir explicitement en List<PaymentAttempt>
    final List<PaymentAttempt> currentHistory =
        (reservation.paymentHistory ?? []).cast<PaymentAttempt>();

    // Créer la nouvelle liste avec le bon type
    final List<PaymentAttempt> paymentHistory = [...currentHistory, attempt];

    final updatedReservation = reservation.copyWith(
      lastPaymentAttempt: attempt,
      paymentHistory: paymentHistory,
    );

    _updateReservation(updatedReservation);
  }

  Future<void> confirmReservation(String reservationId) async {
    final reservation = state.reservations.firstWhere(
      (r) => r.id == reservationId,
    );

    final updatedReservation = reservation.copyWith(
      status: BookingStatus.confirmed,
    );

    _updateReservation(updatedReservation);

    // Arrêter le timer s'il existe
    final timer = state.expirationTimers[reservationId];
    timer?.cancel();

    // Mettre à jour les timers
    final expirationTimers = Map<String, Timer>.from(state.expirationTimers);
    expirationTimers.remove(reservationId);
    state = state.copyWith(expirationTimers: expirationTimers);

    // Envoyer une notification de confirmation
    await notificationService.showBookingConfirmationNotification(
      title: 'Réservation confirmée !',
      body:
          'Votre réservation pour ${reservation.bus.departureCity} → ${reservation.bus.arrivalCity} a été confirmée.',
    );
  }

  List<TicketReservation> getActiveReservations() {
    return state.reservations.where((r) => r.isActive).toList();
  }

  List<TicketReservation> getPendingReservations() {
    return state.reservations
        .where((r) => r.status == BookingStatus.pending && !r.isExpired)
        .toList();
  }

  List<TicketReservation> getCompletedReservations() {
    return state.reservations
        .where((r) => r.status == BookingStatus.confirmed)
        .toList();
  }

  List<TicketReservation> getCancelledReservations() {
    return state.reservations
        .where((r) =>
            r.status == BookingStatus.cancelled ||
            r.status == BookingStatus.expired)
        .toList();
  }

  @override
  void dispose() {
    // Annuler tous les timers
    for (final timer in state.expirationTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}

final reservationProvider =
    StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
  return ReservationNotifier(ref);
});
