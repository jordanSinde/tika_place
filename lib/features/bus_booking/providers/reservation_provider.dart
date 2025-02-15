// lib/features/bus_booking/providers/reservation_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/models/bus_and_utility_models.dart';
import '../models/booking_model.dart';
import '../models/promo_code.dart';
import '../paiement/services/mobile_money_service.dart';
import '../providers/booking_provider.dart';
import '../services/reservation_persistence_service.dart';
import '../../notifications/services/notification_service.dart';

class ReservationState {
  final List<TicketReservation> reservations;
  final bool isLoading;
  final String? error;
  final Map<String, Timer> expirationTimers;
  final TicketReservation? currentReservation;

  const ReservationState({
    this.reservations = const [],
    this.isLoading = false,
    this.error,
    this.expirationTimers = const {},
    this.currentReservation,
  });

  ReservationState copyWith({
    List<TicketReservation>? reservations,
    bool? isLoading,
    String? error,
    Map<String, Timer>? expirationTimers,
    TicketReservation? currentReservation,
  }) {
    return ReservationState(
      reservations: reservations ?? this.reservations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      expirationTimers: expirationTimers ?? this.expirationTimers,
      currentReservation: currentReservation ?? this.currentReservation,
    );
  }
}

class ReservationNotifier extends StateNotifier<ReservationState> {
  final Ref ref;
  static const reservationTimeout = Duration(minutes: 30);
  final _persistenceService = reservationPersistenceService;

  ReservationNotifier(this.ref) : super(const ReservationState()) {
    _loadReservations();
    _startPeriodicCheck();
  }

  Future<void> _loadReservations() async {
    state = state.copyWith(isLoading: true);

    try {
      final userId = ref.read(authProvider).user?.id;
      if (userId == null) return;

      final reservations =
          await _persistenceService.getReservationsForUser(userId);

      state = state.copyWith(
        reservations: reservations,
        isLoading: false,
      );

      _initializeExpirationTimers();
    } catch (e) {
      print('Erreur lors du chargement des réservations: $e');
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

  // Vérifie périodiquement les places disponibles pour les réservations en attente
  void _startPeriodicCheck() {
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkAvailabilityForPendingReservations();
    });
  }

  Future<void> _checkAvailabilityForPendingReservations() async {
    final pendingReservations = getPendingReservations();

    for (final reservation in pendingReservations) {
      try {
        // Simuler la vérification de disponibilité
        final isAvailable = await _checkAvailability(reservation);

        if (!isAvailable) {
          await cancelReservation(
            reservation.id,
            reason: 'Plus de places disponibles',
          );
        }
      } catch (e) {
        print('Erreur lors de la vérification de disponibilité: $e');
      }
    }
  }

  List<TicketReservation> getPendingReservations() {
    return state.reservations
        .where((r) => r.status == BookingStatus.pending && !r.isExpired)
        .toList();
  }

  // Simulation de vérification de disponibilité
  Future<bool> _checkAvailability(TicketReservation reservation) async {
    // Simulation - à remplacer par l'appel API réel
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // Créer une nouvelle réservation
  Future<TicketReservation?> createReservation({
    required Bus bus,
    required List<PassengerInfo> passengers,
    required double totalAmount,
    PromoCode? promoCode,
    double? discountAmount,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userId = ref.read(authProvider).user?.id;
      if (userId == null) throw Exception('Utilisateur non connecté');

      // Vérifier la disponibilité des places
      if (!await _checkSeatsAvailability(bus.id, passengers.length)) {
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
        expiresAt: DateTime.now().add(reservationTimeout),
        userId: userId,
        appliedPromoCode: promoCode,
        discountAmount: discountAmount,
        paymentHistory: [],
      );

      // Sauvegarder en base de données
      await _persistenceService.saveReservation(reservation);

      // Mettre à jour l'état
      final updatedReservations = [...state.reservations, reservation];
      final expirationTimers = Map<String, Timer>.from(state.expirationTimers);
      expirationTimers[reservation.id] = _createExpirationTimer(reservation);

      state = state.copyWith(
        reservations: updatedReservations,
        currentReservation: reservation,
        expirationTimers: expirationTimers,
        isLoading: false,
      );

      return reservation;
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur lors de la création de la réservation: $e',
        isLoading: false,
      );
      return null;
    }
  }

  // Ajouter une tentative de paiement
  Future<void> addPaymentAttempt(
    String reservationId,
    PaymentAttempt attempt,
  ) async {
    try {
      // Sauvegarder la tentative dans la base de données
      await _persistenceService.savePaymentAttempt(reservationId, attempt);

      // Récupérer la réservation mise à jour
      final updatedReservation =
          await _persistenceService.getReservation(reservationId);
      if (updatedReservation == null) return;

      // Mettre à jour l'état
      _updateReservation(updatedReservation);

      // Envoyer une notification si nécessaire
      if (attempt.status.toLowerCase() == 'failed') {
        await notificationService.showBookingConfirmationNotification(
          title: 'Échec du paiement',
          body: attempt.errorMessage ??
              'Une erreur est survenue lors du paiement.',
        );
      }
    } catch (e) {
      print('Erreur lors de l\'ajout de la tentative de paiement: $e');
      rethrow;
    }
  }

  // Gérer une tentative de paiement
  Future<bool> handlePaymentAttempt({
    required String reservationId,
    required PaymentMethod method,
    required String phoneNumber,
    required String paymentCode,
  }) async {
    try {
      final reservation =
          await _persistenceService.getReservation(reservationId);
      if (reservation == null) throw Exception('Réservation non trouvée');

      if (reservation.isExpired) {
        throw Exception('La réservation a expiré');
      }

      // Créer une nouvelle tentative de paiement
      final attempt = PaymentAttempt(
        timestamp: DateTime.now(),
        paymentMethod: method.toString(),
        status: 'pending',
        amountPaid: reservation.totalAmount,
      );

      // Sauvegarder la tentative
      await _persistenceService.savePaymentAttempt(reservationId, attempt);

      // Vérifier le paiement avec le service mobile money
      final paymentResult =
          await mobileMoneyService.checkTransactionStatus(paymentCode);

      if (paymentResult.isSuccess) {
        // Mettre à jour le statut de la réservation
        await updateReservationStatus(reservationId, BookingStatus.confirmed);
        return true;
      } else {
        // Enregistrer l'échec
        await recordPaymentFailure(
          reservationId,
          paymentResult.message ?? 'Échec du paiement',
          method.toString(),
        );
        return false;
      }
    } catch (e) {
      print('Erreur lors du paiement: $e');
      return false;
    }
  }

  // Vérifier la disponibilité des places
  Future<bool> _checkSeatsAvailability(String busId, int seatsNeeded) async {
    // Simuler une vérification - à remplacer par un appel API réel
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // Créer un timer d'expiration
  Timer _createExpirationTimer(TicketReservation reservation) {
    return Timer(reservation.timeUntilExpiration, () {
      _handleReservationExpiration(reservation);
    });
  }

  // Gérer l'expiration d'une réservation
  Future<void> _handleReservationExpiration(
      TicketReservation reservation) async {
    try {
      if (reservation.status == BookingStatus.pending) {
        await updateReservationStatus(reservation.id, BookingStatus.expired);

        await notificationService.showBookingConfirmationNotification(
          title: 'Réservation expirée',
          body:
              'Votre réservation pour ${reservation.bus.departureCity} → ${reservation.bus.arrivalCity} a expiré.',
        );
      }
    } catch (e) {
      print('Erreur lors de l\'expiration: $e');
    }
  }

  // Enregistrer un échec de paiement
  Future<void> recordPaymentFailure(
    String reservationId,
    String errorMessage,
    String paymentMethod,
  ) async {
    try {
      final failedAttempt = PaymentAttempt(
        timestamp: DateTime.now(),
        status: 'failed',
        paymentMethod: paymentMethod,
        amountPaid: 0,
        errorMessage: errorMessage,
      );

      await addPaymentAttempt(reservationId, failedAttempt);
    } catch (e) {
      print('Erreur lors de l\'enregistrement de l\'échec: $e');
      rethrow;
    }
  }

  // Mettre à jour le statut d'une réservation
  Future<void> updateReservationStatus(
      String reservationId, BookingStatus newStatus) async {
    try {
      await _persistenceService.updateReservationStatus(
          reservationId, newStatus);

      final updatedReservation =
          await _persistenceService.getReservation(reservationId);
      if (updatedReservation != null) {
        _updateReservationInState(updatedReservation);
      }

      if (newStatus == BookingStatus.expired ||
          newStatus == BookingStatus.cancelled) {
        _cleanupTimer(reservationId);
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
    }
  }

  // Autres méthodes utilitaires
  void _updateReservationInState(TicketReservation updatedReservation) {
    final updatedReservations = state.reservations.map((reservation) {
      if (reservation.id == updatedReservation.id) {
        return updatedReservation;
      }
      return reservation;
    }).toList();

    state = state.copyWith(
      reservations: updatedReservations,
      currentReservation: updatedReservation.id == state.currentReservation?.id
          ? updatedReservation
          : state.currentReservation,
    );
  }

  void _cleanupTimer(String reservationId) {
    final timer = state.expirationTimers[reservationId];
    timer?.cancel();

    final expirationTimers = Map<String, Timer>.from(state.expirationTimers)
      ..remove(reservationId);

    state = state.copyWith(expirationTimers: expirationTimers);
  }

  Future<void> cancelReservation(String reservationId, {String? reason}) async {
    try {
      final reservation = state.reservations.firstWhere(
        (r) => r.id == reservationId,
      );

      if (!reservation.canBeCancelled) {
        throw Exception('Cette réservation ne peut plus être annulée');
      }

      await _persistenceService.updateReservationStatus(
        reservationId,
        BookingStatus.cancelled,
      );

      final updatedReservation = reservation.copyWith(
        status: BookingStatus.cancelled,
        cancellationReason: reason,
      );

      _updateReservation(updatedReservation);
      _cleanupTimer(reservationId);

      await notificationService.showBookingConfirmationNotification(
        title: 'Réservation annulée',
        body: reason ?? 'Votre réservation a été annulée.',
      );
    } catch (e) {
      print('Erreur lors de l\'annulation de la réservation: $e');
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

    state = state.copyWith(
      reservations: updatedReservations,
      currentReservation: updatedReservation.id == state.currentReservation?.id
          ? updatedReservation
          : state.currentReservation,
    );
  }

  // Autres méthodes existantes...
}

final reservationProvider =
    StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
  return ReservationNotifier(ref);
});


// V1
/*
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/models/bus_and_utility_models.dart';
import '../../notifications/services/notification_service.dart';
import '../models/booking_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/promo_code.dart';
import '../services/reservation_persistence_service.dart';
import 'booking_provider.dart';

class ReservationState {
  final List<TicketReservation> reservations;
  final bool isLoading;
  final String? error;
  final Map<String, Timer> expirationTimers;
  final TicketReservation? currentReservation;

  const ReservationState({
    this.reservations = const [],
    this.isLoading = false,
    this.error,
    this.expirationTimers = const {},
    this.currentReservation,
  });

  ReservationState copyWith({
    List<TicketReservation>? reservations,
    bool? isLoading,
    String? error,
    Map<String, Timer>? expirationTimers,
    TicketReservation? currentReservation,
  }) {
    return ReservationState(
      reservations: reservations ?? this.reservations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      expirationTimers: expirationTimers ?? this.expirationTimers,
      currentReservation: currentReservation ?? this.currentReservation,
    );
  }
}

class ReservationNotifier extends StateNotifier<ReservationState> {
  final Ref ref;
  static const reservationDuration = Duration(minutes: 30);
  final _persistenceService = reservationPersistenceService;

  ReservationNotifier(this.ref) : super(const ReservationState()) {
    _loadReservations();
    _startPeriodicCheck();
  }

  // Charge les réservations depuis la persistance locale
  Future<void> _loadReservations() async {
    state = state.copyWith(isLoading: true);

    try {
      final userId = ref.read(authProvider).user?.id;
      if (userId == null) return;

      final reservations =
          await _persistenceService.getReservationsForUser(userId);

      state = state.copyWith(
        reservations: reservations,
        isLoading: false,
      );

      _initializeExpirationTimers();
    } catch (e) {
      print('Erreur lors du chargement des réservations: $e');
      state = state.copyWith(
        error: 'Erreur lors du chargement des réservations: $e',
        isLoading: false,
      );
    }
  }

  // Vérifie périodiquement les places disponibles pour les réservations en attente
  void _startPeriodicCheck() {
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkAvailabilityForPendingReservations();
    });
  }

  Future<void> _checkAvailabilityForPendingReservations() async {
    final pendingReservations = getPendingReservations();

    for (final reservation in pendingReservations) {
      try {
        // Simuler la vérification de disponibilité
        final isAvailable = await _checkAvailability(reservation);

        if (!isAvailable) {
          await cancelReservation(
            reservation.id,
            reason: 'Plus de places disponibles',
          );
        }
      } catch (e) {
        print('Erreur lors de la vérification de disponibilité: $e');
      }
    }
  }

  // Simulation de vérification de disponibilité
  Future<bool> _checkAvailability(TicketReservation reservation) async {
    // Simulation - à remplacer par l'appel API réel
    await Future.delayed(const Duration(seconds: 1));
    return true;
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
    try {
      await _persistenceService.updateReservationStatus(
        reservation.id,
        BookingStatus.expired,
      );

      final updatedReservation = reservation.copyWith(
        status: BookingStatus.expired,
      );
      _updateReservation(updatedReservation);

      await notificationService.showBookingConfirmationNotification(
        title: 'Réservation expirée',
        body:
            'Votre réservation pour ${reservation.bus.departureCity} → ${reservation.bus.arrivalCity} a expiré.',
      );

      _cleanupTimer(reservation.id);
    } catch (e) {
      print('Erreur lors de l\'expiration de la réservation: $e');
    }
  }

  void _cleanupTimer(String reservationId) {
    final timer = state.expirationTimers[reservationId];
    timer?.cancel();
    final expirationTimers = Map<String, Timer>.from(state.expirationTimers)
      ..remove(reservationId);
    state = state.copyWith(expirationTimers: expirationTimers);
  }

  // Ajouter une tentative de paiement
  Future<void> addPaymentAttempt(
    String reservationId,
    PaymentAttempt attempt,
  ) async {
    try {
      // Sauvegarder la tentative dans la base de données
      await _persistenceService.savePaymentAttempt(reservationId, attempt);

      // Récupérer la réservation mise à jour
      final updatedReservation =
          await _persistenceService.getReservation(reservationId);
      if (updatedReservation == null) return;

      // Mettre à jour l'état
      _updateReservation(updatedReservation);

      // Envoyer une notification si nécessaire
      if (attempt.status.toLowerCase() == 'failed') {
        await notificationService.showBookingConfirmationNotification(
          title: 'Échec du paiement',
          body: attempt.errorMessage ??
              'Une erreur est survenue lors du paiement.',
        );
      }
    } catch (e) {
      print('Erreur lors de l\'ajout de la tentative de paiement: $e');
      rethrow;
    }
  }

  // Obtenir l'historique des paiements
  Future<List<PaymentAttempt>> getPaymentHistory(String reservationId) async {
    try {
      return await _persistenceService.getPaymentHistory(reservationId);
    } catch (e) {
      print(
          'Erreur lors de la récupération de l\'historique des paiements: $e');
      return [];
    }
  }

  // Créer une réservation avec suivi des paiements
  // Dans ReservationNotifier
  Future<TicketReservation> createReservation({
    required Bus bus,
    required List<PassengerInfo> passengers,
    required double totalAmount,
    PromoCode? promoCode,
    double? discountAmount,
  }) async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final reservation = TicketReservation(
        id: 'RES${DateTime.now().millisecondsSinceEpoch}',
        bus: bus,
        passengers: passengers,
        status: BookingStatus.pending,
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(reservationDuration),
        userId: userId,
        appliedPromoCode: promoCode,
        discountAmount: discountAmount,
        paymentHistory: [],
      );

      // Sauvegarder la réservation
      await _persistenceService.saveReservation(reservation);

      state = state.copyWith(
        reservations: [...state.reservations, reservation],
        currentReservation: reservation,
        error: null,
      );

      // Configurer le timer pour l'expiration
      final expirationTimers = Map<String, Timer>.from(state.expirationTimers);
      expirationTimers[reservation.id] = _createExpirationTimer(reservation);
      state = state.copyWith(expirationTimers: expirationTimers);

      return reservation;
    } catch (e) {
      print('Erreur lors de la création de la réservation: $e');
      throw Exception('Impossible de créer la réservation: $e');
    }
  }

  // Confirmer un paiement réussi
  Future<void> confirmPayment(
      String reservationId, String transactionId) async {
    try {
      final reservation = state.reservations.firstWhere(
        (r) => r.id == reservationId,
      );

      // Créer une tentative de paiement réussie
      final successfulAttempt = PaymentAttempt(
        timestamp: DateTime.now(),
        status: 'success',
        paymentMethod:
            reservation.lastPaymentAttempt?.paymentMethod ?? 'unknown',
        amountPaid: reservation.totalAmount,
        transactionId: transactionId,
      );

      // Sauvegarder la tentative
      await addPaymentAttempt(reservationId, successfulAttempt);

      // Mettre à jour le statut de la réservation
      await confirmReservation(reservationId);
    } catch (e) {
      print('Erreur lors de la confirmation du paiement: $e');
      rethrow;
    }
  }

  // Enregistrer un échec de paiement
  Future<void> recordPaymentFailure(
    String reservationId,
    String errorMessage,
    String paymentMethod,
  ) async {
    try {
      final failedAttempt = PaymentAttempt(
        timestamp: DateTime.now(),
        status: 'failed',
        paymentMethod: paymentMethod,
        amountPaid: 0,
        errorMessage: errorMessage,
      );

      await addPaymentAttempt(reservationId, failedAttempt);
    } catch (e) {
      print('Erreur lors de l\'enregistrement de l\'échec: $e');
      rethrow;
    }
  }

  List<TicketReservation> getPendingReservations() {
    return state.reservations
        .where((r) => r.status == BookingStatus.pending && !r.isExpired)
        .toList();
  }

  Future<void> confirmReservation(String reservationId) async {
    try {
      await _persistenceService.updateReservationStatus(
        reservationId,
        BookingStatus.confirmed,
      );

      final reservation = state.reservations.firstWhere(
        (r) => r.id == reservationId,
      );

      final updatedReservation = reservation.copyWith(
        status: BookingStatus.confirmed,
      );

      _updateReservation(updatedReservation);
      _cleanupTimer(reservationId);

      await notificationService.showBookingConfirmationNotification(
        title: 'Réservation confirmée !',
        body:
            'Votre réservation pour ${reservation.bus.departureCity} → ${reservation.bus.arrivalCity} a été confirmée.',
      );
    } catch (e) {
      print('Erreur lors de la confirmation de la réservation: $e');
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

    state = state.copyWith(
      reservations: updatedReservations,
      currentReservation: updatedReservation.id == state.currentReservation?.id
          ? updatedReservation
          : state.currentReservation,
    );
  }

  Future<void> cancelReservation(String reservationId, {String? reason}) async {
    try {
      final reservation = state.reservations.firstWhere(
        (r) => r.id == reservationId,
      );

      if (!reservation.canBeCancelled) {
        throw Exception('Cette réservation ne peut plus être annulée');
      }

      await _persistenceService.updateReservationStatus(
        reservationId,
        BookingStatus.cancelled,
      );

      final updatedReservation = reservation.copyWith(
        status: BookingStatus.cancelled,
        cancellationReason: reason,
      );

      _updateReservation(updatedReservation);
      _cleanupTimer(reservationId);

      await notificationService.showBookingConfirmationNotification(
        title: 'Réservation annulée',
        body: reason ?? 'Votre réservation a été annulée.',
      );
    } catch (e) {
      print('Erreur lors de l\'annulation de la réservation: $e');
      rethrow;
    }
  }
}

final reservationProvider =
    StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
  return ReservationNotifier(ref);
});
*/