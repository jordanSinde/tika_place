// lib/features/bus_booking/services/payment_manager.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../models/payment_error.dart';
import 'mobile_money_service.dart';

class PaymentAttemptState {
  final DateTime lastAttempt;
  final int attemptCount;
  final int maxAttempts;

  const PaymentAttemptState({
    required this.lastAttempt,
    required this.attemptCount,
    this.maxAttempts = 3,
  });

  int get remainingAttempts => maxAttempts - attemptCount;
  bool get canAttempt => attemptCount < maxAttempts;

  // Vérifie si les tentatives ont été réinitialisées (nouveau jour)
  bool get shouldReset {
    final now = DateTime.now();
    return lastAttempt.day != now.day ||
        lastAttempt.month != now.month ||
        lastAttempt.year != now.year;
  }
}

class PaymentManager {
  static final PaymentManager _instance = PaymentManager._internal();
  final _mobileMoneyService = MobileMoneyService();

  // Stocker les tentatives en mémoire (à remplacer par SQLite plus tard)
  final Map<String, PaymentAttemptState> _attempts = {};

  factory PaymentManager() {
    return _instance;
  }

  PaymentManager._internal();

  bool canAttemptPayment(String reservationId) {
    final state = _attempts[reservationId];
    if (state == null) return true;
    if (state.shouldReset) {
      _attempts.remove(reservationId);
      return true;
    }
    return state.canAttempt;
  }

  int getRemainingAttempts(String reservationId) {
    final state = _attempts[reservationId];
    if (state == null) return 3;
    if (state.shouldReset) {
      _attempts.remove(reservationId);
      return 3;
    }
    return state.remainingAttempts;
  }

  void recordAttempt(String reservationId) {
    final now = DateTime.now();
    final currentState = _attempts[reservationId];

    if (currentState == null || currentState.shouldReset) {
      _attempts[reservationId] = PaymentAttemptState(
        lastAttempt: now,
        attemptCount: 1,
      );
    } else {
      _attempts[reservationId] = PaymentAttemptState(
        lastAttempt: now,
        attemptCount: currentState.attemptCount + 1,
      );
    }
  }

  Future<void> processPayment({
    required String reservationId,
    required String code,
    required PaymentMethod method,
    required double amount,
    required Function(PaymentAttempt) onAttemptCreated,
    required Function(PaymentAttempt) onSuccess,
    required Function(PaymentError) onError,
  }) async {
    if (!canAttemptPayment(reservationId)) {
      throw const PaymentError(
        type: PaymentErrorType.unknown,
        message: 'Nombre maximum de tentatives atteint pour aujourd\'hui',
        canRetry: false,
      );
    }

    try {
      recordAttempt(reservationId);

      // Créer une tentative de paiement
      final attempt = PaymentAttempt(
        timestamp: DateTime.now(),
        paymentMethod: method.toString(),
        status: 'pending',
      );

      onAttemptCreated(attempt);

      // Vérifier le code
      if (code.length != 6) {
        throw PaymentError.invalidCode();
      }

      // Initier le paiement
      final transactionStatus = await _mobileMoneyService.initiatePayment(
        method: method,
        amount: amount,
        description: 'Paiement billet de bus - Ref: $reservationId',
      );

      if (!transactionStatus.isSuccess) {
        throw PaymentError.unknown(
          transactionStatus.message ?? 'Erreur lors du paiement',
        );
      }

      // Monitorer la transaction jusqu'à 2 minutes
      bool isSuccess = false;
      await for (final status in _mobileMoneyService.monitorTransaction(
        transactionStatus.reference,
      )) {
        if (status.isSuccess) {
          isSuccess = true;
          final successAttempt = attempt.copyWith(
            status: 'success',
            amountPaid: amount,
            transactionId: status.reference,
          );
          onSuccess(successAttempt);
          break;
        }
      }

      if (!isSuccess) {
        throw PaymentError.timeout();
      }
    } on PaymentError catch (e) {
      final failedAttempt = PaymentAttempt(
        timestamp: DateTime.now(),
        paymentMethod: method.toString(),
        status: 'failed',
        errorMessage: e.message,
      );

      onAttemptCreated(failedAttempt);
      onError(e);
    } catch (e) {
      final error = PaymentError.unknown(e.toString());
      final failedAttempt = PaymentAttempt(
        timestamp: DateTime.now(),
        paymentMethod: method.toString(),
        status: 'failed',
        errorMessage: error.message,
      );

      onAttemptCreated(failedAttempt);
      onError(error);
    }
  }

  Future<bool> validatePaymentMethod({
    required PaymentMethod method,
    required String phoneNumber,
  }) async {
    try {
      return await _mobileMoneyService.verifyPhoneNumber(
        method: method,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      return false;
    }
  }
}

final paymentManager = PaymentManager();

// Provider pour gérer l'état des tentatives de paiement
final paymentAttemptsProvider = StateNotifierProvider<PaymentAttemptsNotifier,
    Map<String, PaymentAttemptState>>((ref) {
  return PaymentAttemptsNotifier();
});

class PaymentAttemptsNotifier
    extends StateNotifier<Map<String, PaymentAttemptState>> {
  PaymentAttemptsNotifier() : super({});

  bool canAttemptPayment(String reservationId) {
    return paymentManager.canAttemptPayment(reservationId);
  }

  int getRemainingAttempts(String reservationId) {
    return paymentManager.getRemainingAttempts(reservationId);
  }

  void recordAttempt(String reservationId) {
    paymentManager.recordAttempt(reservationId);
    state = Map<String, PaymentAttemptState>.from(state);
  }
}
