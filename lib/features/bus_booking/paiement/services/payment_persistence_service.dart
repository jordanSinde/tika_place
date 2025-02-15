// lib/features/bus_booking/services/payment_persistence_service.dart

import 'package:sqflite/sqflite.dart';

import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../services/reservation_persistence_service.dart';

class PaymentPersistenceService {
  static final PaymentPersistenceService _instance =
      PaymentPersistenceService._internal();
  final ReservationPersistenceService _reservationService =
      reservationPersistenceService;

  factory PaymentPersistenceService() {
    return _instance;
  }

  PaymentPersistenceService._internal();

  Future<Database> get database async => await _reservationService.database;

  // Sauvegarder une tentative de paiement
  Future<void> savePaymentAttempt({
    required String reservationId,
    required PaymentAttempt attempt,
    required BookingStatus newStatus,
  }) async {
    final db = await database;

    await db.transaction((txn) async {
      // 1. Sauvegarder la tentative
      await txn.insert(
        'payment_attempts',
        {
          'id': 'PAY${DateTime.now().millisecondsSinceEpoch}',
          'reservationId': reservationId,
          'timestamp': attempt.timestamp.millisecondsSinceEpoch,
          'status': attempt.status,
          'paymentMethod': attempt.paymentMethod,
          'amount': attempt.amountPaid,
          'errorMessage': attempt.errorMessage,
          'transactionId': attempt.transactionId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Mettre à jour le statut de la réservation
      await txn.update(
        'reservations',
        {
          'status': newStatus.toString(),
          'lastPaymentAttempt': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [reservationId],
      );
    });
  }

  // Récupérer l'historique des paiements
  Future<List<PaymentAttempt>> getPaymentHistory(String reservationId) async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      'payment_attempts',
      where: 'reservationId = ?',
      whereArgs: [reservationId],
      orderBy: 'timestamp DESC',
    );

    return results
        .map((row) => PaymentAttempt(
              timestamp:
                  DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
              status: row['status'] as String,
              paymentMethod: row['paymentMethod'] as String,
              amountPaid: row['amount'] as double?,
              errorMessage: row['errorMessage'] as String?,
              transactionId: row['transactionId'] as String?,
            ))
        .toList();
  }

  // Vérifier si une tentative de paiement existe
  Future<bool> hasRecentPaymentAttempt(String reservationId) async {
    final db = await database;

    final result = await db.query(
      'payment_attempts',
      where: 'reservationId = ? AND timestamp > ?',
      whereArgs: [
        reservationId,
        DateTime.now()
            .subtract(const Duration(minutes: 5))
            .millisecondsSinceEpoch,
      ],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // Supprimer l'historique des paiements d'une réservation
  Future<void> clearPaymentHistory(String reservationId) async {
    final db = await database;

    await db.delete(
      'payment_attempts',
      where: 'reservationId = ?',
      whereArgs: [reservationId],
    );
  }
}

// Instance singleton
final paymentPersistenceService = PaymentPersistenceService();
