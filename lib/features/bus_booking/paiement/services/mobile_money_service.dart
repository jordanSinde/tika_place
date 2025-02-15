// lib/features/bus_booking/services/mobile_money_service.dart

import 'dart:async';
import '../../providers/booking_provider.dart';

class PaymentResponse {
  final bool isSuccess;
  final String? message;
  final String? transactionId;
  final Map<String, dynamic>? data;

  PaymentResponse({
    required this.isSuccess,
    this.message,
    this.transactionId,
    this.data,
  });
}

class MobileMoneyService {
  static final MobileMoneyService _instance = MobileMoneyService._internal();

  factory MobileMoneyService() {
    return _instance;
  }

  MobileMoneyService._internal();

  // Initier un paiement pour une réservation
  Future<PaymentResponse> initiatePayment({
    required PaymentMethod method,
    required String phoneNumber,
    required double amount,
    required String reservationId,
    String? description,
  }) async {
    try {
      // Simuler un délai d'appel à l'API de paiement
      await Future.delayed(const Duration(seconds: 2));

      // Vérifier le format du numéro avant d'initier
      if (!await verifyPhoneNumber(method: method, phoneNumber: phoneNumber)) {
        return PaymentResponse(
          isSuccess: false,
          message: 'Numéro de téléphone invalide',
        );
      }

      // Générer un ID de transaction unique
      final transactionId = 'TX${DateTime.now().millisecondsSinceEpoch}';

      // Simuler une réponse d'API
      return PaymentResponse(
        isSuccess: true,
        transactionId: transactionId,
        message: 'Code de paiement envoyé',
        data: {
          'reservationId': reservationId,
          'amount': amount,
          'expiresIn': 300, // 5 minutes
        },
      );
    } catch (e) {
      return PaymentResponse(
        isSuccess: false,
        message: 'Erreur lors de l\'initiation du paiement: $e',
      );
    }
  }

  // Vérifier le statut d'une transaction
  Future<PaymentResponse> checkTransactionStatus(
    String paymentCode, {
    required String reservationId,
    required String transactionId,
  }) async {
    try {
      // Simuler la vérification
      await Future.delayed(const Duration(seconds: 1));

      // Simuler une réponse positive avec 80% de chance
      final isSuccess = DateTime.now().millisecond % 5 != 0;

      return PaymentResponse(
        isSuccess: isSuccess,
        transactionId: transactionId,
        message: isSuccess ? 'Paiement confirmé' : 'Code de paiement invalide',
        data: isSuccess
            ? {
                'reservationId': reservationId,
                'status': 'COMPLETED',
                'completedAt': DateTime.now().toIso8601String(),
              }
            : null,
      );
    } catch (e) {
      return PaymentResponse(
        isSuccess: false,
        message: 'Erreur lors de la vérification: $e',
      );
    }
  }

  // Surveiller une transaction en cours
  Stream<PaymentResponse> monitorTransaction({
    required String transactionId,
    required String reservationId,
  }) async* {
    int attempts = 0;
    const maxAttempts = 12; // 1 minute (5s * 12)

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 5));

      final status = await checkTransactionStatus(
        '', // Code n'est pas nécessaire pour la simulation
        reservationId: reservationId,
        transactionId: transactionId,
      );

      yield status;

      if (status.isSuccess) break;
      attempts++;
    }

    if (attempts == maxAttempts) {
      yield PaymentResponse(
        isSuccess: false,
        message: 'Le délai de paiement a expiré',
        transactionId: transactionId,
      );
    }
  }

  // Vérifier le format du numéro de téléphone
  Future<bool> verifyPhoneNumber({
    required PaymentMethod method,
    required String phoneNumber,
  }) async {
    // Simuler la vérification
    await Future.delayed(const Duration(milliseconds: 500));

    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    switch (method) {
      case PaymentMethod.orangeMoney:
        return cleanNumber.startsWith('6') &&
            !cleanNumber.startsWith('65') &&
            cleanNumber.length == 9;

      case PaymentMethod.mtnMoney:
        return cleanNumber.startsWith('65') && cleanNumber.length == 9;
    }
  }

  // Générer un reçu de transaction
  Future<Map<String, dynamic>> generateTransactionReceipt({
    required String transactionId,
    required String reservationId,
    required double amount,
    required PaymentMethod method,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'transactionId': transactionId,
      'reservationId': reservationId,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'COMPLETED',
      'operator': method == PaymentMethod.orangeMoney ? 'ORANGE' : 'MTN',
      'amount': amount,
      'currency': 'XAF',
      'fees': amount * 0.02, // 2% de frais
      'description': 'Paiement de réservation',
    };
  }

  // Sauvegarder l'historique des transactions
  Future<void> saveTransactionHistory({
    required String transactionId,
    required String reservationId,
    required String userId,
    required double amount,
    required PaymentMethod method,
    required bool isSuccess,
    String? failureReason,
  }) async {
    // Simuler la sauvegarde
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: Implémenter la sauvegarde réelle
    print(
        'Transaction $transactionId sauvegardée pour réservation $reservationId');
  }
}

// Instance singleton
final mobileMoneyService = MobileMoneyService();

//V1
/*
import 'dart:async';
import '../../providers/booking_provider.dart';

class TransactionStatus {
  final String reference;
  final bool isSuccess;
  final String? message;
  final Map<String, dynamic>? data;

  TransactionStatus({
    required this.reference,
    required this.isSuccess,
    this.message,
    this.data,
  });
}

class MobileMoneyService {
  static final MobileMoneyService _instance = MobileMoneyService._internal();

  factory MobileMoneyService() {
    return _instance;
  }

  MobileMoneyService._internal();

  Future<TransactionStatus> initiatePayment({
    required PaymentMethod method,
    required String phoneNumber,
    required double amount,
    required String description,
  }) async {
    // Simuler l'appel à l'API de paiement
    await Future.delayed(const Duration(seconds: 2));

    // Simuler une réponse d'API
    return TransactionStatus(
      reference: 'TX${DateTime.now().millisecondsSinceEpoch}',
      isSuccess: true,
      message: 'Transaction initiée avec succès',
      data: {
        'paymentUrl': 'https://payment.example.com/confirm',
        'expiresIn': 300, // 5 minutes
      },
    );
  }

  Future<TransactionStatus> checkTransactionStatus(String reference) async {
    // Simuler la vérification du statut
    await Future.delayed(const Duration(seconds: 1));

    // Simuler une réponse positive avec 80% de chance
    final isSuccess = DateTime.now().millisecond % 5 != 0;

    return TransactionStatus(
      reference: reference,
      isSuccess: isSuccess,
      message: isSuccess
          ? 'Transaction effectuée avec succès'
          : 'En attente de confirmation',
    );
  }

  Stream<TransactionStatus> monitorTransaction(String reference) async* {
    int attempts = 0;
    const maxAttempts = 12; // 1 minute (5s * 12)

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 5));

      final status = await checkTransactionStatus(reference);
      yield status;

      if (status.isSuccess) break;

      attempts++;
    }

    if (attempts == maxAttempts) {
      yield TransactionStatus(
        reference: reference,
        isSuccess: false,
        message: 'Le délai de paiement a expiré',
      );
    }
  }

  Future<bool> verifyPhoneNumber({
    required PaymentMethod method,
    required String phoneNumber,
  }) async {
    // Simuler la vérification du numéro
    await Future.delayed(const Duration(seconds: 1));

    final cleanNumber = phoneNumber.replaceAll(' ', '');

    // Vérifier le format selon l'opérateur
    if (method == PaymentMethod.orangeMoney) {
      return cleanNumber.startsWith('6') && cleanNumber.length == 9;
    } else {
      return cleanNumber.startsWith('65') && cleanNumber.length == 9;
    }
  }

  Future<Map<String, dynamic>> getTransactionReceipt(String reference) async {
    // Simuler la récupération du reçu
    await Future.delayed(const Duration(seconds: 1));

    return {
      'reference': reference,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'COMPLETED',
      'operator': 'ORANGE_MONEY',
      'amount': 5000,
      'currency': 'XAF',
      'fees': 100,
      'description': 'Paiement billet de bus',
    };
  }

  Future<void> saveTransactionHistory({
    required String reference,
    required String userId,
    required double amount,
    required PaymentMethod method,
    required bool isSuccess,
  }) async {
    // Simuler la sauvegarde de l'historique
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: Implémenter la sauvegarde réelle dans la base de données
    print('Transaction saved: $reference for user $userId');
  }
}

// Singleton instance
final mobileMoneyService = MobileMoneyService();
*/