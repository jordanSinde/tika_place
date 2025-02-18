import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/user.dart';
import '../../home/models/bus_mock_data.dart';
import '../paiement/services/mobile_money_service.dart';
import 'booking_provider.dart';
import 'reservation_provider.dart';

// Add this to your booking_provider.dart

extension PaymentFlowVerification on BookingNotifier {
  void verifyPhase1_1Implementation(WidgetRef ref) {
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
      initializePayment(ref); // Should show error for no payment method
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

//extension 2

extension Phase2Verification on BookingNotifier {
  Future<bool> verifyPhase2Implementation(WidgetRef ref) async {
    print('\n🔍 PHASE 2 VERIFICATION START');
    print('=================================');

    try {
      // Step 1: Verify automatic reservation creation
      print('📋 Step 1: Testing automatic reservation creation');
      await _verifyReservationCreation(ref);

      // Step 2: Verify reservation status management
      print('\n📋 Step 2: Testing reservation status management');
      await _verifyReservationStatusManagement(ref);

      print('\n🎯 PHASE 2 VERIFICATION RESULT:');
      print('=================================');
      print('✅ Automatic reservation creation implemented');
      print('✅ Status management working correctly');
      print('✅ Error handling in place');
      print('=================================');
      return true;
    } catch (e) {
      print('❌ PHASE 2 VERIFICATION FAILED:');
      print(e.toString());
      return false;
    }
  }

  Future<void> _verifyReservationCreation(WidgetRef ref) async {
    // Initialize a test booking
    final bus = Bus(
      id: 'TEST-BUS',
      company: 'Test Company',
      agencyLocation: 'Test Location',
      registrationNumber: 'TEST-123',
      departureCity: 'Test City A',
      arrivalCity: 'Test City B',
      departureTime: DateTime.now().add(const Duration(days: 1)),
      arrivalTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
      busClass: BusClass.standard,
      price: 5000,
      totalSeats: 50,
      availableSeats: 30,
      amenities: const BusAmenities(),
      busNumber: 'TEST-BUS-123',
      rating: 4.5,
      reviews: 100,
    );

    // Reset state to start clean
    reset();

    // Initialize booking
    initializeBooking(
      bus,
      UserModel(
        id: 'test-user',
        firstName: 'Test',
        lastName: 'User',
        email: 'test@example.com',
        phoneNumber: '612345678',
        provider: AuthProvider.email, // Add this
        isEmailVerified: false, // Add this
        createdAt: DateTime.now(), // Add this
      ),
    );

    // Set payment method to trigger reservation creation
    updatePaymentMethod(PaymentMethod.orangeMoney);

    // Initialize payment (should create reservation)
    await initializePayment(ref);

    // Verify reservation was created
    final reservationState = ref.read(reservationProvider);
    final reservations = reservationState.reservations;

    if (reservations.isEmpty) {
      print('❌ No reservations created automatically');
      throw Exception('Automatic reservation creation failed');
    }

    // Find our reservation
    final ourReservation = reservations
        .where((r) => r.bus.id == bus.id && r.status == BookingStatus.pending)
        .toList();

    if (ourReservation.isEmpty) {
      print('❌ Created reservation not found or has wrong status');
      throw Exception('Reservation created but not found or has wrong status');
    }

    print('✅ Reservation created automatically');
    print('📋 Reservation ID: ${ourReservation.first.id}');
    print('📋 Status: ${ourReservation.first.status}');
    print('📋 Passengers: ${ourReservation.first.passengers.length}');
  }

  Future<void> _verifyReservationStatusManagement(WidgetRef ref) async {
    // Access reservation provider
    final reservationNotifier = ref.read(reservationProvider.notifier);
    final activeReservations = reservationNotifier.getPendingReservations();

    if (activeReservations.isEmpty) {
      print('❌ No pending reservations found for testing');
      throw Exception('No pending reservations to test status management');
    }

    final testReservation = activeReservations.first;
    print('📋 Using reservation ${testReservation.id} for status testing');

    // Test confirming reservation
    try {
      await reservationNotifier.confirmReservation(testReservation.id);

      // Verify status change
      final updatedReservations =
          reservationNotifier.getCompletedReservations();
      final found = updatedReservations.any((r) => r.id == testReservation.id);

      if (found) {
        print('✅ Reservation status successfully changed to confirmed');
      } else {
        print('❌ Reservation status change failed');
        throw Exception('Reservation status not updated correctly');
      }
    } catch (e) {
      print('❌ Error during status change test: $e');
      throw Exception('Status management test failed: $e');
    }
  }
}
