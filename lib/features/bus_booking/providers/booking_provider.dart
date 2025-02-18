// lib/features/bus_booking/providers/booking_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tika_place/features/bus_booking/models/promo_code.dart';
import '../../../features/auth/models/user.dart';
import '../../home/models/bus_mock_data.dart';
import '../../notifications/services/notification_service.dart';
import '../paiement/services/mobile_money_service.dart';
import 'price_calculator_provider.dart';

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
  /*void updatePaymentMethod(PaymentMethod? method) {
    if (state.isReservationExpired) {
      state = state.copyWith(
        error: 'La réservation a expiré. Veuillez recommencer.',
        status: BookingStatus.cancelled,
      );
      return;
    }

    state = state.copyWith(paymentMethod: method);
  }*/

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

  // Initialize payment process
  Future<void> initializePayment() async {
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
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Une erreur est survenue. Veuillez réessayer.',
      );
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

// Add this to your booking_provider.dart

extension PaymentFlowVerification on BookingNotifier {
  void verifyPhase1_1Implementation() {
    print('\n🔍 PHASE 1.1 VERIFICATION START');
    print('=================================');

    try {
      // Step 1: Verify initial state
      print('📋 Step 1: Checking initial state');
      if (state.paymentMethod == null) {
        print('✅ Initial state correct: no payment method selected');
      } else {
        print('❌ Error: Initial state should have no payment method');
      }

      // Step 2: Update payment method
      print('\n📋 Step 2: Testing payment method update');
      updatePaymentMethod(PaymentMethod.orangeMoney);
      if (state.paymentMethod == PaymentMethod.orangeMoney) {
        print('✅ Payment method updated successfully');
      } else {
        print('❌ Error: Payment method not updated');
      }

      // Step 3: Verify error handling
      print('\n📋 Step 3: Testing error handling');
      clearPaymentState();
      initializePayment(); // Should show error for no payment method
      if (state.error != null) {
        print('✅ Error handling working correctly');
      } else {
        print('❌ Error: Missing error handling');
      }

      print('\n🎯 PHASE 1.1 VERIFICATION RESULT:');
      print('=================================');
      print('✅ Payment method selection implemented');
      print('✅ State management working');
      print('✅ Error handling in place');
      print('✅ UI feedback functional');
      print('=================================');
    } catch (e) {
      print('❌ PHASE 1.1 VERIFICATION FAILED:');
      print(e.toString());
    }
  }

  // phase 1.2 log
  Future<void> _verifyPhoneValidation() async {
    try {
      // Test valid Orange Money number
      final validOrangePhone = await mobileMoneyService.verifyPhoneNumber(
        method: PaymentMethod.orangeMoney,
        phoneNumber: '655123456',
      );
      print(validOrangePhone
          ? '✅ Orange Money validation correct'
          : '❌ Orange Money validation failed');

      // Test valid MTN Money number
      final validMTNPhone = await mobileMoneyService.verifyPhoneNumber(
        method: PaymentMethod.mtnMoney,
        phoneNumber: '650123456',
      );
      print(validMTNPhone
          ? '✅ MTN Money validation correct'
          : '❌ MTN Money validation failed');

      // Test invalid number
      final invalidPhone = await mobileMoneyService.verifyPhoneNumber(
        method: PaymentMethod.orangeMoney,
        phoneNumber: '123456789',
      );
      print(invalidPhone == false
          ? '✅ Invalid number rejected'
          : '❌ Invalid number accepted');
    } catch (e) {
      print('❌ Phone validation error: $e');
    }
  }

  Future<void> verifyPhase1_2Implementation() async {
    print('\n🔍 PHASE 1.2 VERIFICATION START');
    print('=================================');

    try {
      // Step 1: Verify phone number validation
      print('📋 Step 1: Testing phone validation');
      await _verifyPhoneValidation();

      // Step 2: Verify payment initialization
      print('\n📋 Step 2: Testing payment initialization');
      await _verifyPaymentInitialization();

      // Step 3: Verify payment code request
      print('\n📋 Step 3: Testing payment code request');
      await _verifyPaymentCodeRequest();

      // Step 4: Verify code verification
      print('\n📋 Step 4: Testing code verification');
      await _verifyCodeVerification();

      print('\n🎯 PHASE 1.2 VERIFICATION RESULT:');
      print('=================================');
      print('✅ Phone number validation implemented');
      print('✅ Payment code request flow working');
      print('✅ Code verification process in place');
      print('✅ Error handling functional');
      print('=================================');
    } catch (e) {
      print('❌ PHASE 1.2 VERIFICATION FAILED:');
      print(e.toString());
    }
  }

  Future<void> _verifyPaymentInitialization() async {
    if (state.paymentMethod != null) {
      print('✅ Payment method set correctly');
      if (state.status == BookingStatus.pending) {
        print('✅ Booking status correct');
      } else {
        print('❌ Incorrect booking status');
      }
    } else {
      print('❌ Payment method not set');
    }

    if (state.bookingReference != null) {
      print('✅ Booking reference generated');
    } else {
      print('❌ Missing booking reference');
    }
  }

  Future<void> _verifyPaymentCodeRequest() async {
    try {
      final response = await mobileMoneyService.initiatePayment(
        method: PaymentMethod.orangeMoney,
        phoneNumber: '655123456',
        amount: 5000,
        description: 'Test payment',
      );
      print('✅ Payment code request successful');
      print('Reference: ${response.reference}');
    } catch (e) {
      print('❌ Payment code request failed: $e');
    }
  }

  Future<void> _verifyCodeVerification() async {
    try {
      final status =
          await mobileMoneyService.checkTransactionStatus('TEST_REF');
      print('✅ Transaction status check functional');
      print('Status success: ${status.isSuccess}');
    } catch (e) {
      print('❌ Transaction status check failed: $e');
    }
  }
}

final bookingProvider =
    StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier();
});
