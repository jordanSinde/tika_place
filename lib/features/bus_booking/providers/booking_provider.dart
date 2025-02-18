// lib/features/bus_booking/providers/booking_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tika_place/features/bus_booking/models/promo_code.dart';
import '../../../features/auth/models/user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/models/bus_mock_data.dart';
import '../../notifications/services/notification_service.dart';
import '../models/booking_model.dart';
import 'price_calculator_provider.dart';
import 'reservation_provider.dart';

enum BookingStatus { pending, confirmed, paid, cancelled, expired, failed }

enum PaymentMethod { orangeMoney, mtnMoney }

class Passenger {
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final int? cniNumber;
  final bool isMainPassenger;

  Passenger({
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.cniNumber,
    this.isMainPassenger = false,
  });

  Passenger copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    int? cniNumber,
    bool? isMainPassenger,
  }) {
    return Passenger(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      cniNumber: cniNumber ?? this.cniNumber,
      isMainPassenger: isMainPassenger ?? this.isMainPassenger,
    );
  }
}

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
  final String? userId;

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
    this.userId,
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
    String? userId,
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
      userId: userId ?? this.userId,
    );
  }

  bool get isReservationExpired {
    if (reservationTimeout == null) return false;
    return DateTime.now().isAfter(reservationTimeout!);
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(const BookingState());

  // Timer pour la réservation
  static const reservationTimeoutDuration = Duration(minutes: 5);

// Initialiser une nouvelle réservation
  void initializeBooking(Bus bus, UserModel user) {
    print('🚀 BOOKING PROVIDER: Initializing new booking');
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
      userId: user.id,
    );

    print('✅ BOOKING PROVIDER: Booking initialized');
    print('📋 User: ${user.firstName} ${user.lastName}');
    print('📋 Bus: ${bus.departureCity} → ${bus.arrivalCity}');
    print('📋 Price: ${bus.price} FCFA');
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

  // Processus de paiement
  // Update the processPayment method to add null safety
  Future<bool> processPayment(WidgetRef ref) async {
    print('💳 BOOKING PROVIDER: Starting payment process');

    if (state.isReservationExpired) {
      print('❌ BOOKING PROVIDER: Reservation expired');
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
      print('💰 BOOKING PROVIDER: Payment amount: $finalAmount FCFA');

      // Vérifier la disponibilité des places
      final seatsAvailable = await checkSeatsAvailability();
      if (!seatsAvailable) {
        print('❌ BOOKING PROVIDER: No seats available');
        return false;
      }

      // Ensure reservation record exists
      if (state.bookingReference == null) {
        print(
            '🏗️ BOOKING PROVIDER: Creating reservation record before payment');
        await _createReservationRecord(ref); // Pass ref here
      }

      // Record payment attempt in reservation history
      final bookingRef = state.bookingReference;
      if (bookingRef != null) {
        // Add null check
        try {
          final paymentMethod = state.paymentMethod;
          if (paymentMethod != null) {
            // Add null check
            final paymentAttempt = PaymentAttempt(
              timestamp: DateTime.now(),
              paymentMethod: paymentMethod.toString(),
              status: 'processing',
            );

            print('📝 BOOKING PROVIDER: Recording payment attempt');
            await ref
                .read(reservationProvider.notifier)
                .addPaymentAttempt(bookingRef, paymentAttempt);
          } else {
            print('⚠️ BOOKING PROVIDER: Payment method is null');
          }
        } catch (e) {
          print('⚠️ BOOKING PROVIDER: Failed to record payment attempt: $e');
          // Continue with payment even if recording attempt fails
        }
      } else {
        print('⚠️ BOOKING PROVIDER: Booking reference is null');
      }

      // Simuler un délai de traitement
      await Future.delayed(const Duration(seconds: 2));

      // Simuler une réussite avec 80% de chance
      final isSuccess = DateTime.now().millisecond % 5 != 0;

      if (isSuccess) {
        print('✅ BOOKING PROVIDER: Payment successful');

        // Generate a reference if not exists
        final reference = state.bookingReference ??
            'BK${DateTime.now().millisecondsSinceEpoch}';

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

        // Update reservation status
        try {
          print(
              '🔄 BOOKING PROVIDER: Updating reservation status to confirmed');
          await ref
              .read(reservationProvider.notifier)
              .confirmReservation(reference);
          print('✅ BOOKING PROVIDER: Reservation status updated successfully');
        } catch (e) {
          print('⚠️ BOOKING PROVIDER: Failed to update reservation status: $e');
          // Continue even if status update fails
        }

        // Enregistrer les passagers pour utilisation future
        await savePassengersForFutureUse();

        // Envoyer une notification de confirmation
        try {
          await notificationService.showBookingConfirmationNotification(
            title: 'Réservation confirmée !',
            body:
                'Votre réservation pour ${state.selectedBus?.departureCity} → ${state.selectedBus?.arrivalCity} a été confirmée.',
            payload: reference,
          );
        } catch (e) {
          print('⚠️ BOOKING PROVIDER: Failed to show notification: $e');
        }

        return true;
      } else {
        print('❌ BOOKING PROVIDER: Payment failed');
        state = state.copyWith(
          status: BookingStatus.failed,
          error: 'La transaction a échoué. Veuillez réessayer.',
          isLoading: false,
        );

        // Update payment attempt in reservation if possible
        if (bookingRef != null && state.paymentMethod != null) {
          try {
            final paymentAttempt = PaymentAttempt(
              timestamp: DateTime.now(),
              paymentMethod: state.paymentMethod.toString(),
              status: 'failed',
              errorMessage: 'La transaction a échoué',
            );

            print('📝 BOOKING PROVIDER: Recording failed payment attempt');
            await ref
                .read(reservationProvider.notifier)
                .addPaymentAttempt(bookingRef, paymentAttempt);
          } catch (e) {
            print('⚠️ BOOKING PROVIDER: Failed to update payment attempt: $e');
          }
        }

        return false;
      }
    } catch (e) {
      print('❌ BOOKING PROVIDER: Error during payment: $e');
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

  // Update payment method with validation
  void updatePaymentMethod(PaymentMethod? method) {
    print('🔄 PAYMENT STATE: Updating payment method');

    if (state.isReservationExpired) {
      print('❌ PAYMENT STATE: Reservation expired');
      state = state.copyWith(
        error: 'La réservation a expiré. Veuillez recommencer.',
        status: BookingStatus.expired,
      );
      return;
    }

    print(
        '✅ PAYMENT STATE: Method updated successfully to ${method?.toString()}');

    state = state.copyWith(
      paymentMethod: method,
      error: null, // Clear any previous errors
    );
  }

  //SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
// Initialize payment process
  Future<void> initializePayment(WidgetRef ref) async {
    print('🚀 PAYMENT INIT: Starting payment initialization');

    if (state.isReservationExpired) {
      print('❌ PAYMENT INIT: Reservation expired');
      state = state.copyWith(
        error: 'La réservation a expiré. Veuillez recommencer.',
        status: BookingStatus.expired,
      );
      return;
    }

    if (state.paymentMethod == null) {
      state = state.copyWith(
        error: 'Veuillez sélectionner une méthode de paiement.',
      );
      return;
    }

    // Create initial reservation
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
      );

      // Generate booking reference if not exists
      if (state.bookingReference == null) {
        final reference = 'BK${DateTime.now().millisecondsSinceEpoch}';
        state = state.copyWith(bookingReference: reference);
      }

      // Set status to pending
      state = state.copyWith(
        status: BookingStatus.pending,
        isLoading: false,
      );

      // Create reservation record
      await _createReservationRecord(ref);
    } catch (e) {
      print('❌ PAYMENT INIT: Error during initialization: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Une erreur est survenue. Veuillez réessayer.',
      );
    }
  }

  // Create reservation record
  Future<void> _createReservationRecord(WidgetRef ref) async {
    print('🏗️ BOOKING PROVIDER: Creating reservation record');
    try {
      if (state.selectedBus == null || state.passengers.isEmpty) {
        print('❌ BOOKING PROVIDER: Missing required data for reservation');
        return;
      }

      // Add the current user ID if available
      final userId = ref.read(authProvider).user?.id;
      if (userId != null && state.userId == null) {
        state = state.copyWith(userId: userId);
      }

      // Create reservation via provider
      final reservation = await ref
          .read(reservationProvider.notifier)
          .createReservationFromBooking(state);

      print('✅ BOOKING PROVIDER: Reservation record created');
      print('📋 Reservation ID: ${reservation.id}');
      print('📋 Status: ${reservation.status}');
    } catch (e) {
      print('❌ BOOKING PROVIDER: Failed to create reservation record: $e');
    }
  }

  // Clear payment state
  void clearPaymentState() {
    state = state.copyWith(
      paymentMethod: null,
      error: null,
    );
  }

  // Add updateBookingReference method
  void updateBookingReference(String reference) {
    state = state.copyWith(
      bookingReference: reference,
    );
    print('🔄 BOOKING: Updated reference to $reference');
  }
}

final bookingProvider =
    StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier();
});
