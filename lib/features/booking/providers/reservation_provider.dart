// lib/features/common/providers/reservation_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../bus_booking/models/booking_model.dart';
import '../../notifications/services/notification_service.dart';
import '../models/base_reservation.dart';
import '../services/reservation_persistence_service.dart';
import '../../auth/providers/auth_provider.dart';

import '../services/reservation_monitor.dart';

class ReservationState {
  final Map<ReservationType, List<BaseReservation>> reservations;
  final bool isLoading;
  final String? error;

  const ReservationState({
    this.reservations = const {},
    this.isLoading = false,
    this.error,
  });

  ReservationState copyWith({
    Map<ReservationType, List<BaseReservation>>? reservations,
    bool? isLoading,
    String? error,
  }) {
    return ReservationState(
      reservations: reservations ?? this.reservations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ReservationNotifier extends StateNotifier<ReservationState> {
  final Ref ref;

  ReservationNotifier(this.ref) : super(const ReservationState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadReservations();
    await reservationMonitor.initializeMonitoring(this);
  }

  Future<void> _loadReservations() async {
    state = state.copyWith(isLoading: true);

    try {
      final userId = ref.read(authProvider).user?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final allReservations =
          await reservationPersistenceService.getReservations(
        userId: userId,
      );

      final groupedReservations = <ReservationType, List<BaseReservation>>{};
      for (final type in ReservationType.values) {
        groupedReservations[type] =
            allReservations.where((r) => r.type == type).toList();
      }

      state = state.copyWith(
        reservations: groupedReservations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur lors du chargement des réservations: $e',
        isLoading: false,
      );
    }
  }

  Future<String> createPendingReservation({
    required ReservationType type,
    required double amount,
    required Map<String, dynamic> details,
  }) async {
    final user = ref.read(authProvider).user;
    if (user == null) throw Exception('Utilisateur non connecté');

    final reservation = await reservationPersistenceService.createReservation(
      type: type,
      amount: amount,
      userId: user.id,
      details: details,
    );

    // Mettre à jour l'état
    final updatedReservations =
        Map<ReservationType, List<BaseReservation>>.from(state.reservations);
    updatedReservations[type] = [reservation, ...?updatedReservations[type]];
    state = state.copyWith(reservations: updatedReservations);

    // Démarrer le monitoring
    reservationMonitor.startMonitoring(reservation, this);

    return reservation.id;
  }

  Future<void> updateReservationStatus(
      String reservationId, ReservationStatus newStatus,
      [String? reason]) async {
    try {
      await reservationPersistenceService.updateReservationStatus(
        reservationId,
        newStatus,
        reason,
      );

      // Si la réservation n'est plus active, arrêter le monitoring
      if (!newStatus.isActive) {
        reservationMonitor.stopMonitoring(reservationId);
      }

      // Recharger les réservations
      await _loadReservations();

      // Envoyer une notification si nécessaire
      if (newStatus == ReservationStatus.cancelled ||
          newStatus == ReservationStatus.expired) {
        await notificationService.showBookingConfirmationNotification(
          title: 'Statut de réservation mis à jour',
          body: reason ??
              'Votre réservation a été ${newStatus.label.toLowerCase()}.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur lors de la mise à jour du statut: $e',
      );
    }
  }

  Future<void> addPaymentAttempt(
    String reservationId,
    PaymentAttempt attempt,
  ) async {
    await reservationPersistenceService.savePaymentAttempt(
      reservationId,
      attempt,
    );

    if (attempt.status == 'success') {
      await updateReservationStatus(reservationId, ReservationStatus.paid);
    } else if (attempt.status == 'failed') {
      await updateReservationStatus(reservationId, ReservationStatus.failed);
    }
  }

  Future<List<BaseReservation>> getActiveReservations() async {
    return state.reservations.values
        .expand((list) => list)
        .where((r) => r.status.isActive)
        .toList();
  }

  Future<List<BaseReservation>> getOldReservations() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return state.reservations.values
        .expand((list) => list)
        .where((r) => r.createdAt.isBefore(thirtyDaysAgo))
        .toList();
  }

  Future<BaseReservation?> getReservationById(String id) async {
    return state.reservations.values
        .expand((list) => list)
        .firstWhere((r) => r.id == id);
  }

  @override
  void dispose() {
    // Arrêter tous les monitorings en cours
    for (final reservations in state.reservations.values) {
      for (final reservation in reservations) {
        reservationMonitor.stopMonitoring(reservation.id);
      }
    }
    super.dispose();
  }
}

final reservationProvider =
    StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
  return ReservationNotifier(ref);
});


/*
class ReservationState {
  final Map<ReservationType, List<BaseReservation>> reservations;
  final bool isLoading;
  final String? error;
  final Map<String, Timer> availabilityTimers;

  ReservationState({
    this.reservations = const {},
    this.isLoading = false,
    this.error,
    this.availabilityTimers = const {},
  });

  ReservationState copyWith({
    Map<ReservationType, List<BaseReservation>>? reservations,
    bool? isLoading,
    String? error,
    Map<String, Timer>? availabilityTimers,
  }) {
    return ReservationState(
      reservations: reservations ?? this.reservations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      availabilityTimers: availabilityTimers ?? this.availabilityTimers,
    );
  }

  List<BaseReservation> getReservationsByType(ReservationType type) {
    return reservations[type] ?? [];
  }
}

class ReservationNotifier extends StateNotifier<ReservationState> {
  final Ref ref;
  static const availabilityCheckInterval = Duration(minutes: 1);
  final _uuid = const Uuid();

  ReservationNotifier(this.ref) : super(ReservationState()) {
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    state = state.copyWith(isLoading: true);

    try {
      final allReservations =
          await reservationPersistenceService.getReservations(
        userId: ref.read(authProvider).user?.id,
      );

      final groupedReservations = <ReservationType, List<BaseReservation>>{};
      for (final type in ReservationType.values) {
        groupedReservations[type] =
            allReservations.where((r) => r.type == type).toList();
      }

      state = state.copyWith(
        reservations: groupedReservations,
        isLoading: false,
      );

      _initializeAvailabilityTimers();
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur lors du chargement des réservations: $e',
        isLoading: false,
      );
    }
  }

  void _initializeAvailabilityTimers() {
    final timers = <String, Timer>{};

    for (final reservations in state.reservations.values) {
      for (final reservation in reservations) {
        if (reservation.status == ReservationStatus.pending) {
          timers[reservation.id] = _createAvailabilityTimer(reservation);
        }
      }
    }

    state = state.copyWith(availabilityTimers: timers);
  }

  Timer _createAvailabilityTimer(BaseReservation reservation) {
    return Timer.periodic(availabilityCheckInterval, (_) {
      _checkAvailability(reservation);
    });
  }

  Future<void> _checkAvailability(BaseReservation reservation) async {
    try {
      bool isAvailable = false;

      switch (reservation.type) {
        case ReservationType.bus:
          final busReservation = reservation as BusReservation;
          isAvailable = await availabilityService.checkBusAvailability(
            busReservation.bus.id,
            busReservation.passengers.length,
          );
          break;
        case ReservationType.hotel:
          // Implement hotel availability check when ready
          break;
        case ReservationType.apartment:
          // Implement apartment availability check when ready
          break;
      }

      if (!isAvailable) {
        await updateReservationStatus(
          reservation.id,
          ReservationStatus.cancelled,
          'Plus de places disponibles',
        );
      }
    } catch (e) {
      print('Erreur lors de la vérification de disponibilité: $e');
    }
  }

  Future<String> createPendingReservation({
    required ReservationType type,
    required double amount,
    required Map<String, dynamic> details,
  }) async {
    final user = ref.read(authProvider).user;
    if (user == null) throw Exception('Utilisateur non connecté');

    final reservationId = _uuid.v4();
    final now = DateTime.now();

    final baseReservation = BaseReservation(
      id: reservationId,
      createdAt: now,
      updatedAt: now,
      type: type,
      status: ReservationStatus.pending,
      amount: amount,
      userId: user.id,
    );

    // Créer la réservation spécifique selon le type
    final reservation = switch (type) {
      ReservationType.bus => BusReservation(
          base: baseReservation,
          bus: details['bus'],
          passengers: details['passengers'],
        ),
      ReservationType.hotel => HotelReservation(
          base: baseReservation,
          hotelId: details['hotelId'],
          roomId: details['roomId'],
          checkIn: details['checkIn'],
          checkOut: details['checkOut'],
          guests: details['guests'],
        ),
      ReservationType.apartment => ApartmentReservation(
          base: baseReservation,
          apartmentId: details['apartmentId'],
          startDate: details['startDate'],
          endDate: details['endDate'],
          guests: details['guests'],
        ),
    };

    // Sauvegarder dans la base de données
    await reservationPersistenceService.saveReservation(reservation);

    // Mettre à jour l'état
    final updatedReservations =
        Map<ReservationType, List<BaseReservation>>.from(state.reservations);
    updatedReservations[type] = [reservation, ...?updatedReservations[type]];

    // Démarrer le timer de vérification de disponibilité
    final timers = Map<String, Timer>.from(state.availabilityTimers);
    timers[reservationId] = _createAvailabilityTimer(reservation);

    state = state.copyWith(
      reservations: updatedReservations,
      availabilityTimers: timers,
    );

    return reservationId;
  }

  Future<void> updateReservationStatus(
      String reservationId, ReservationStatus newStatus,
      [String? reason]) async {
    try {
      await reservationPersistenceService.updateReservationStatus(
        reservationId,
        newStatus,
        cancellationReason: reason,
      );

      // Arrêter le timer si la réservation n'est plus en attente
      if (newStatus != ReservationStatus.pending) {
        state.availabilityTimers[reservationId]?.cancel();
        final updatedTimers = Map<String, Timer>.from(state.availabilityTimers)
          ..remove(reservationId);
        state = state.copyWith(availabilityTimers: updatedTimers);
      }

      // Recharger les réservations pour mettre à jour l'état
      await _loadReservations();

      // Envoyer une notification à l'utilisateur
      if (newStatus == ReservationStatus.cancelled) {
        await notificationService.showBookingConfirmationNotification(
          title: 'Réservation annulée',
          body: reason ?? 'Votre réservation a été annulée.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur lors de la mise à jour du statut: $e',
      );
    }
  }

  Future<void> addPaymentAttempt(
    String reservationId,
    PaymentAttempt attempt,
  ) async {
    await reservationPersistenceService.savePaymentAttempt(
      reservationId,
      attempt,
    );

    if (attempt.status == 'success') {
      await updateReservationStatus(reservationId, ReservationStatus.paid);
    } else if (attempt.status == 'failed') {
      await updateReservationStatus(reservationId, ReservationStatus.failed);
    }
  }

  List<BaseReservation> getActiveReservations(ReservationType type) {
    return state.reservations[type]
            ?.where((r) =>
                r.status == ReservationStatus.pending ||
                r.status == ReservationStatus.confirmed)
            .toList() ??
        [];
  }

  List<BaseReservation> getPendingReservations(ReservationType type) {
    return state.reservations[type]
            ?.where((r) => r.status == ReservationStatus.pending)
            .toList() ??
        [];
  }

  @override
  void dispose() {
    // Annuler tous les timers
    for (final timer in state.availabilityTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}

final reservationProvider =
    StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
  return ReservationNotifier(ref);
});
*/