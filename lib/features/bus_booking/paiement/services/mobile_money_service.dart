// lib/features/bus_booking/services/mobile_money_service.dart

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
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate reference with special prefixes for test numbers
    String reference;

    if (phoneNumber == '655123456') {
      reference = 'FAIL_${DateTime.now().millisecondsSinceEpoch}';
    } else if (phoneNumber == '651234567') {
      reference = 'TIMEOUT_${DateTime.now().millisecondsSinceEpoch}';
    } else if (phoneNumber == '654321789') {
      reference = 'PENDING_${DateTime.now().millisecondsSinceEpoch}';
    } else if (phoneNumber == '650000000') {
      reference = 'NETWORK_${DateTime.now().millisecondsSinceEpoch}';
    } else {
      reference = 'TX${DateTime.now().millisecondsSinceEpoch}';
    }

    // Simuler une réponse d'API
    return TransactionStatus(
      reference: reference,
      isSuccess: true,
      message: 'Transaction initiée avec succès',
      data: {
        'paymentUrl': 'https://payment.example.com/confirm',
        'expiresIn': 300, // 5 minutes
      },
    );
  }

  /*<TransactionStatus> initiatePayment({
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
  }*/

  Future<TransactionStatus> checkTransactionStatus(String reference) async {
    // Simulate the verification delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if the reference contains special test codes
    // These will allow you to test specific failure scenarios
    if (reference.toLowerCase().contains('fail')) {
      return TransactionStatus(
        reference: reference,
        isSuccess: false,
        message: 'Échec de la transaction: fonds insuffisants',
      );
    } else if (reference.toLowerCase().contains('timeout')) {
      return TransactionStatus(
        reference: reference,
        isSuccess: false,
        message: 'Délai d\'attente dépassé: aucune réponse du fournisseur',
      );
    } else if (reference.toLowerCase().contains('pending')) {
      return TransactionStatus(
        reference: reference,
        isSuccess: false,
        message: 'Transaction en attente: confirmation requise',
      );
    } else if (reference.toLowerCase().contains('network')) {
      return TransactionStatus(
        reference: reference,
        isSuccess: false,
        message: 'Erreur réseau: vérifiez votre connexion',
      );
    }

    // Default behavior (80% success rate)
    final isSuccess = DateTime.now().millisecond % 5 != 0;
    return TransactionStatus(
      reference: reference,
      isSuccess: isSuccess,
      message: isSuccess
          ? 'Transaction effectuée avec succès'
          : 'Échec de la transaction pour une raison inconnue',
    );
  }

  /*Future<TransactionStatus> checkTransactionStatus(String reference) async {
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
  }*/

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
