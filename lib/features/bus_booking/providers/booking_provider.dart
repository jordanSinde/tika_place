// lib/features/bus_booking/providers/booking_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/models/user.dart';
import '../../home/models/bus_and_utility_models.dart';
import 'price_calculator_provider.dart';
import 'reservation_provider.dart';
import 'reservation_state_notifier.dart';

enum BookingStatus { pending, confirmed, paid, cancelled, expired, failed }

enum PaymentMethod { orangeMoney, mtnMoney }

class BookingState {
  final Bus? selectedBus;
  final List<Passenger> passengers;
  final BookingStatus status;
  final PaymentMethod? paymentMethod;
  final String? bookingReference;
  final double? totalAmount;
  final bool isLoading;
  final String? error;
  final double? appliedDiscount;
  final String? appliedPromoCode;
  final DateTime? reservationTimeout;

  const BookingState({
    this.selectedBus,
    this.passengers = const [],
    this.status = BookingStatus.pending,
    this.paymentMethod,
    this.bookingReference,
    this.totalAmount,
    this.isLoading = false,
    this.error,
    this.appliedDiscount,
    this.appliedPromoCode,
    this.reservationTimeout,
  });

  BookingState copyWith({
    Bus? selectedBus,
    List<Passenger>? passengers,
    BookingStatus? status,
    PaymentMethod? paymentMethod,
    String? bookingReference,
    double? totalAmount,
    bool? isLoading,
    String? error,
    double? appliedDiscount,
    String? appliedPromoCode,
    DateTime? reservationTimeout,
  }) {
    return BookingState(
      selectedBus: selectedBus ?? this.selectedBus,
      passengers: passengers ?? this.passengers,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bookingReference: bookingReference ?? this.bookingReference,
      totalAmount: totalAmount ?? this.totalAmount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      appliedDiscount: appliedDiscount ?? this.appliedDiscount,
      appliedPromoCode: appliedPromoCode ?? this.appliedPromoCode,
      reservationTimeout: reservationTimeout ?? this.reservationTimeout,
    );
  }

  bool get isReservationExpired {
    if (reservationTimeout == null) return false;
    return DateTime.now().isAfter(reservationTimeout!);
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final Ref ref;

  BookingNotifier(this.ref) : super(const BookingState());

  Future<void> initializeBooking(Bus bus, UserModel user) async {
    state = state.copyWith(isLoading: true);

    try {
      // Vérifier s'il n'y a pas déjà une réservation en cours
      final hasDuplicate = await ref
          .read(centralReservationProvider.notifier)
          .checkDuplicateReservation(user.id, bus.id);

      if (hasDuplicate) {
        throw Exception('Une réservation est déjà en cours pour ce voyage');
      }

      // Vérifier la disponibilité
      final isAvailable = await ref
          .read(centralReservationProvider.notifier)
          ._checkSeatAvailability(bus.id, 1);

      if (!isAvailable) {
        throw Exception('Places non disponibles');
      }

      // Créer le passager principal
      final mainPassenger = Passenger(
        firstName: user.firstName,
        lastName: user.lastName ?? '',
        phoneNumber: user.phoneNumber,
        cniNumber: user.cniNumber,
        isMainPassenger: true,
      );

      // Initialiser l'état
      state = state.copyWith(
        selectedBus: bus,
        passengers: [mainPassenger],
        totalAmount: bus.price,
        status: BookingStatus.pending,
        isLoading: false,
      );

      // Calculer le prix initial
      ref.read(priceCalculatorProvider.notifier).calculatePrice(bus.price);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> addPassenger(Passenger passenger) async {
    if (state.isReservationExpired) {
      state = state.copyWith(
        error: 'La réservation a expiré. Veuillez recommencer.',
        status: BookingStatus.expired,
      );
      return;
    }

    try {
      // Vérifier la disponibilité pour le nouveau passager
      final isAvailable = await ref
          .read(centralReservationProvider.notifier)
          ._checkSeatAvailability(
            state.selectedBus!.id,
            state.passengers.length + 1,
          );

      if (!isAvailable) {
        throw Exception('Plus de places disponibles');
      }

      final updatedPassengers = [...state.passengers, passenger];
      final newTotalAmount =
          state.selectedBus!.price * updatedPassengers.length;

      state = state.copyWith(
        passengers: updatedPassengers,
        totalAmount: newTotalAmount,
      );

      // Recalculer le prix
      ref.read(priceCalculatorProvider.notifier).calculatePrice(newTotalAmount);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> processPayment(WidgetRef ref) async {
    if (state.isReservationExpired) {
      state = state.copyWith(
        error: 'La réservation a expiré. Veuillez recommencer.',
        status: BookingStatus.expired,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final priceState = ref.read(priceCalculatorProvider);
      final finalAmount = priceState.total;

      // Vérifier la disponibilité
      final isAvailable = await ref
          .read(centralReservationProvider.notifier)
          ._checkSeatAvailability(
            state.selectedBus!.id,
            state.passengers.length,
          );

      if (!isAvailable) {
        throw Exception('Places non disponibles');
      }

      // Créer la réservation
      final reservation =
          await ref.read(reservationProvider.notifier).createReservation(
                bus: state.selectedBus!,
                passengers: state.passengers,
                totalAmount: finalAmount,
                promoCode: priceState.appliedPromoCode,
                discountAmount: priceState.discount,
              );

      if (reservation == null) {
        throw Exception('Erreur lors de la création de la réservation');
      }

      state = state.copyWith(
        bookingReference: reservation.id,
        status: BookingStatus.pending,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        status: BookingStatus.failed,
        isLoading: false,
      );
      return false;
    }
  }

  // ... autres méthodes existantes ...
}

final bookingProvider =
    StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier(ref);
});


/*
class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(const BookingState());

  // Timer pour la réservation
  static const reservationTimeoutDuration = Duration(minutes: 5);

  // Initialiser une nouvelle réservation
  void initializeBooking(Bus bus, UserModel user) {
    final mainPassenger = Passenger(
      firstName: user.firstName,
      lastName: user.lastName ?? '',
      phoneNumber: user.phoneNumber,
      cniNumber: user.cniNumber,
      isMainPassenger: true,
    );

    state = state.copyWith(
      selectedBus: bus,
      passengers: [mainPassenger],
      totalAmount: bus.price,
      status: BookingStatus.pending,
      reservationTimeout: DateTime.now().add(reservationTimeoutDuration),
    );
  }

  // Ajouter un passager
  void addPassenger(Passenger passenger) {
    if (state.isReservationExpired) {
      state = state.copyWith(
        error: 'La réservation a expiré. Veuillez recommencer.',
        status: BookingStatus.cancelled,
      );
      return;
    }

    final updatedPassengers = [...state.passengers, passenger];
    final newTotalAmount = state.selectedBus!.price * updatedPassengers.length;

    state = state.copyWith(
      passengers: updatedPassengers,
      totalAmount: newTotalAmount,
    );
  }

  // Supprimer un passager
  void removePassenger(int index) {
    if (index == 0 || index >= state.passengers.length) {
      return; // Ne pas supprimer le passager principal
    }

    final updatedPassengers = [...state.passengers];
    updatedPassengers.removeAt(index);
    final newTotalAmount = state.selectedBus!.price * updatedPassengers.length;

    state = state.copyWith(
      passengers: updatedPassengers,
      totalAmount: newTotalAmount,
    );
  }

  // Mettre à jour la méthode de paiement
  void updatePaymentMethod(PaymentMethod? method) {
    if (state.isReservationExpired) {
      state = state.copyWith(
        error: 'La réservation a expiré. Veuillez recommencer.',
        status: BookingStatus.cancelled,
      );
      return;
    }

    state = state.copyWith(paymentMethod: method);
  }

  // Processus de paiement
  Future<bool> processPayment(WidgetRef ref) async {
    if (state.isReservationExpired) {
      state = state.copyWith(
        error: 'La réservation a expiré. Veuillez recommencer.',
        status: BookingStatus.cancelled,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Récupérer le montant total calculé avec les taxes et réductions
      final priceState = ref.read(priceCalculatorProvider);
      final finalAmount = priceState.total;

      // Vérifier la disponibilité des places
      final seatsAvailable = await checkSeatsAvailability();
      if (!seatsAvailable) {
        return false;
      }

      // Simuler un délai de traitement
      await Future.delayed(const Duration(seconds: 2));

      // Simuler une réussite avec 80% de chance
      final isSuccess = DateTime.now().millisecond % 5 != 0;

      if (isSuccess) {
        final reference = 'BK${DateTime.now().millisecondsSinceEpoch}';

        // Enregistrer l'utilisation du code promo
        final promoCode = ref.read(priceCalculatorProvider).appliedPromoCode;
        if (promoCode != null) {
          state = state.copyWith(
            appliedPromoCode: promoCode.code,
            appliedDiscount:
                promoCode.calculateDiscount(state.totalAmount ?? 0),
          );
        }

        // Mettre à jour l'état avec le succès
        state = state.copyWith(
          status: BookingStatus.paid,
          bookingReference: reference,
          totalAmount: finalAmount,
          isLoading: false,
        );

        // Enregistrer les passagers pour utilisation future
        await savePassengersForFutureUse();

        // Envoyer une notification de confirmation
        await notificationService.showBookingConfirmationNotification(
          title: 'Réservation confirmée !',
          body:
              'Votre réservation pour ${state.selectedBus!.departureCity} → ${state.selectedBus!.arrivalCity} a été confirmée.',
          payload: reference,
        );

        return true;
      } else {
        state = state.copyWith(
          status: BookingStatus.failed,
          error: 'La transaction a échoué. Veuillez réessayer.',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: BookingStatus.failed,
        error: 'Une erreur est survenue. Veuillez réessayer.',
        isLoading: false,
      );
      return false;
    }
  }

  // Vérifier la disponibilité des sièges
  Future<bool> checkSeatsAvailability() async {
    try {
      state = state.copyWith(isLoading: true);

      // Simuler une vérification de disponibilité
      await Future.delayed(const Duration(seconds: 1));

      final seatsNeeded = state.passengers.length;
      final seatsAvailable = state.selectedBus!.availableSeats;

      if (seatsAvailable >= seatsNeeded) {
        return true;
      } else {
        state = state.copyWith(
          error: 'Désolé, il ne reste que $seatsAvailable places disponibles.',
          status: BookingStatus.cancelled,
        );
        return false;
      }
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Récupérer les proches enregistrés
  Future<List<Passenger>> getSavedPassengers() async {
    // Simuler la récupération depuis une base de données
    await Future.delayed(const Duration(seconds: 1));

    // Retourner une liste fictive de passagers
    return [
      Passenger(
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+237600000000',
        cniNumber: 12345678,
      ),
      Passenger(
        firstName: 'Jane',
        lastName: 'Doe',
        phoneNumber: '+237600000001',
        cniNumber: 12345679,
      ),
    ];
  }

  // Sauvegarder les passagers pour une utilisation future
  Future<void> savePassengersForFutureUse() async {
    try {
      state.passengers.where((p) => !p.isMainPassenger);

      // Simuler la sauvegarde dans une base de données
      await Future.delayed(const Duration(milliseconds: 500));

      // Envoyer une notification de confirmation
      await notificationService.showBookingConfirmationNotification(
        title: 'Contacts enregistrés',
        body:
            'Vos proches ont été enregistrés pour vos prochaines réservations.',
      );
    } catch (e) {
      print('Erreur lors de la sauvegarde des passagers: $e');
    }
  }

  // Réinitialiser l'état
  void reset() {
    state = const BookingState();
  }
}*/

