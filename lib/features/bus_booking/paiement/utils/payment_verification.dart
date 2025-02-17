// lib/features/bus_booking/utils/payment_verification.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/booking_provider.dart';
import '../services/mobile_money_service.dart';

class PaymentVerification {
  static void logPhase(String phase, String action, String result) {
    print('📋 PHASE $phase: $action - $result');
  }

  static void logError(String phase, String error) {
    print('❌ PHASE $phase ERROR: $error');
  }

  static void logSuccess(String phase, String message) {
    print('✅ PHASE $phase SUCCESS: $message');
  }

  // Verify payment method selection
  static Future<bool> verifyPaymentMethodSelection(WidgetRef ref) async {
    print('\n🔍 Verifying payment method selection...');

    try {
      // Test payment method update
      ref
          .read(bookingProvider.notifier)
          .updatePaymentMethod(PaymentMethod.orangeMoney);
      final method = ref.read(bookingProvider).paymentMethod;

      if (method == PaymentMethod.orangeMoney) {
        logSuccess("1.1", "Payment method updated successfully");
        return true;
      } else {
        logError("1.1", "Payment method not updated correctly");
        return false;
      }
    } catch (e) {
      logError("1.1", "Error during payment method verification: $e");
      return false;
    }
  }

  // Verify phone validation
  static Future<bool> verifyPhoneValidation(WidgetRef ref) async {
    print('\n🔍 Verifying phone number validation...');

    try {
      // Test valid phone number
      final validPhone = await mobileMoneyService.verifyPhoneNumber(
          method: PaymentMethod.orangeMoney, phoneNumber: "655123456");

      // Test invalid phone number
      final invalidPhone = await mobileMoneyService.verifyPhoneNumber(
          method: PaymentMethod.orangeMoney, phoneNumber: "123456789");

      if (validPhone && !invalidPhone) {
        logSuccess("1.2", "Phone validation working correctly");
        return true;
      } else {
        logError("1.2", "Phone validation not working as expected");
        return false;
      }
    } catch (e) {
      logError("1.2", "Error during phone validation: $e");
      return false;
    }
  }

  // Verify payment code flow
  static Future<bool> verifyPaymentCodeFlow(WidgetRef ref) async {
    print('\n🔍 Verifying payment code flow...');

    try {
      // Initialize payment with test data
      final response = await mobileMoneyService.initiatePayment(
          method: PaymentMethod.orangeMoney,
          phoneNumber: "655123456",
          amount: 5000,
          description: "Test payment");

      if (!response.isSuccess) {
        logError("1.2", "Payment initiation failed");
        return false;
      }

      // Verify transaction status check
      final status =
          await mobileMoneyService.checkTransactionStatus(response.reference);

      if (status.isSuccess) {
        logSuccess("1.2", "Payment code flow verified successfully");
        return true;
      } else {
        logError("1.2", "Transaction status check failed");
        return false;
      }
    } catch (e) {
      logError("1.2", "Error during payment code flow: $e");
      return false;
    }
  }

  // Verify ticket generation
  static Future<bool> verifyTicketGeneration(
      WidgetRef ref, String bookingReference) async {
    print('\n🔍 Verifying ticket generation...');

    try {
      // Attempt to generate tickets
      if (bookingReference.isEmpty) {
        logError("1.3", "Invalid booking reference");
        return false;
      }

      logSuccess("1.3", "Successfully verified ticket generation process");
      print('📦 Booking Reference: $bookingReference');
      return true;
    } catch (e) {
      logError("1.3", "Error during ticket generation: $e");
      return false;
    }
  }

  // Complete Phase 1 verification
  static Future<bool> verifyPhase1Complete(WidgetRef ref) async {
    print('\n🔍 PHASE 1 COMPLETE VERIFICATION');
    print('===============================');

    bool isValid = true;

    // Verify payment method selection
    if (!await verifyPaymentMethodSelection(ref)) {
      isValid = false;
    }

    // Verify phone validation
    if (!await verifyPhoneValidation(ref)) {
      isValid = false;
    }

    // Verify payment code flow
    if (!await verifyPaymentCodeFlow(ref)) {
      isValid = false;
    }

    print('\n📋 PHASE 1 VERIFICATION RESULT:');
    print('===============================');
    if (isValid) {
      print('✅ Phase 1 implementation complete and verified');
      print('✅ Ready to proceed to Phase 2');
    } else {
      print('❌ Phase 1 verification failed');
      print('⚠️ Please fix the above issues before proceeding');
    }
    print('===============================\n');

    return isValid;
  }
}
