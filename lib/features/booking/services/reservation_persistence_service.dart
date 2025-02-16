// lib/features/common/services/reservation_persistence_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

import '../../bus_booking/models/booking_model.dart';
import '../models/base_reservation.dart';

class ReservationPersistenceService {
  static final ReservationPersistenceService _instance =
      ReservationPersistenceService._internal();
  Database? _database;

  factory ReservationPersistenceService() {
    return _instance;
  }

  ReservationPersistenceService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'reservations.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Table pour les réservations de base
        await db.execute('''
          CREATE TABLE reservations(
            id TEXT PRIMARY KEY,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER NOT NULL,
            type TEXT NOT NULL,
            status TEXT NOT NULL,
            amount REAL NOT NULL,
            userId TEXT NOT NULL,
            paymentId TEXT,
            cancellationReason TEXT,
            isArchived INTEGER NOT NULL DEFAULT 0,
            details TEXT NOT NULL
          )
        ''');

        // Table pour les tentatives de paiement
        await db.execute('''
          CREATE TABLE payment_attempts(
            id TEXT PRIMARY KEY,
            reservationId TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            amount REAL NOT NULL,
            status TEXT NOT NULL,
            paymentMethod TEXT NOT NULL,
            errorMessage TEXT,
            FOREIGN KEY(reservationId) REFERENCES reservations(id)
          )
        ''');
      },
    );
  }

  Future<void> saveReservation(BaseReservation reservation) async {
    final db = await database;
    await db.insert(
      'reservations',
      {
        'id': reservation.id,
        'createdAt': reservation.createdAt.millisecondsSinceEpoch,
        'updatedAt': reservation.updatedAt.millisecondsSinceEpoch,
        'type': reservation.type.toString(),
        'status': reservation.status.toString(),
        'amount': reservation.amount,
        'userId': reservation.userId,
        'paymentId': reservation.paymentId,
        'cancellationReason': reservation.cancellationReason,
        'isArchived': reservation.isArchived ? 1 : 0,
        'details': jsonEncode(reservation.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BaseReservation>> getReservations({
    ReservationType? type,
    String? userId,
    bool includeArchived = false,
  }) async {
    final db = await database;

    var query = 'SELECT * FROM reservations WHERE 1=1';
    final args = <dynamic>[];

    if (type != null) {
      query += ' AND type = ?';
      args.add(type.toString());
    }

    if (userId != null) {
      query += ' AND userId = ?';
      args.add(userId);
    }

    if (!includeArchived) {
      query += ' AND isArchived = 0';
    }

    query += ' ORDER BY createdAt DESC';

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);

    return maps.map((map) {
      final details = jsonDecode(map['details'] as String);
      switch (ReservationType.values
          .byName(map['type'].toString().split('.').last)) {
        case ReservationType.bus:
          return BusReservation.fromJson(details);
        case ReservationType.hotel:
          return HotelReservation.fromJson(details);
        case ReservationType.apartment:
          return ApartmentReservation.fromJson(details);
      }
    }).toList();
  }

  Future<void> updateReservationStatus(String id, ReservationStatus status,
      {String? cancellationReason}) async {
    final db = await database;
    final now = DateTime.now();

    await db.update(
      'reservations',
      {
        'status': status.toString(),
        'updatedAt': now.millisecondsSinceEpoch,
        if (cancellationReason != null)
          'cancellationReason': cancellationReason,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> archiveReservation(String id) async {
    final db = await database;
    await db.update(
      'reservations',
      {'isArchived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> savePaymentAttempt(
    String reservationId,
    PaymentAttempt attempt,
  ) async {
    final db = await database;
    await db.insert(
      'payment_attempts',
      {
        'id': '${reservationId}_${DateTime.now().millisecondsSinceEpoch}',
        'reservationId': reservationId,
        'timestamp': attempt.timestamp.millisecondsSinceEpoch,
        'amount': attempt.amountPaid,
        'status': attempt.status,
        'paymentMethod': attempt.paymentMethod,
        'errorMessage': attempt.errorMessage,
      },
    );
  }

  Future<List<PaymentAttempt>> getPaymentAttempts(String reservationId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payment_attempts',
      where: 'reservationId = ?',
      whereArgs: [reservationId],
      orderBy: 'timestamp DESC',
    );

    return maps
        .map((map) => PaymentAttempt(
              timestamp:
                  DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
              status: map['status'] as String,
              paymentMethod: map['paymentMethod'] as String,
              amountPaid: map['amount'] as double?,
              errorMessage: map['errorMessage'] as String?,
            ))
        .toList();
  }

  Future<void> deleteReservation(String id) async {
    final db = await database;
    await db.delete(
      'reservations',
      where: 'id = ?',
      whereArgs: [id],
    );
    await db.delete(
      'payment_attempts',
      where: 'reservationId = ?',
      whereArgs: [id],
    );
  }

  //

  Future<BaseReservation> createReservation({
    required ReservationType type,
    required double amount,
    required String userId,
    required Map<String, dynamic> details,
  }) async {
    final db = await database;
    final now = DateTime.now();
    final id = 'RES${DateTime.now().millisecondsSinceEpoch}';

    final baseReservation = BaseReservation(
      id: id,
      createdAt: now,
      updatedAt: now,
      type: type,
      status: ReservationStatus.pending,
      amount: amount,
      userId: userId,
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
    await db.insert(
      'reservations',
      {
        'id': reservation.base.id,
        'createdAt': reservation.base.createdAt.millisecondsSinceEpoch,
        'updatedAt': reservation.base.updatedAt.millisecondsSinceEpoch,
        'type': reservation.base.type.toString(),
        'status': reservation.base.status.toString(),
        'amount': reservation.base.amount,
        'userId': reservation.base.userId,
        'details': jsonEncode(
          type == ReservationType.bus
              ? (reservation as BusReservation).toJson()
              : type == ReservationType.hotel
                  ? (reservation as HotelReservation).toJson()
                  : (reservation as ApartmentReservation).toJson(),
        ),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return reservation;
  }

  Future<void> deleteOldReservations() async {
    final db = await database;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    await db.delete(
      'reservations',
      where: 'createdAt < ? AND status != ?',
      whereArgs: [
        thirtyDaysAgo.millisecondsSinceEpoch,
        ReservationStatus.paid.toString(),
      ],
    );
  }

  Future<List<Object>> getExpiredPendingReservations() async {
    final db = await database;
    final thirtyMinutesAgo = DateTime.now()
        .subtract(const Duration(minutes: 30))
        .millisecondsSinceEpoch;

    final List<Map<String, dynamic>> maps = await db.query(
      'reservations',
      where: 'status = ? AND createdAt < ?',
      whereArgs: [ReservationStatus.pending.toString(), thirtyMinutesAgo],
    );

    return maps.map((map) {
      final details = jsonDecode(map['details'] as String);
      final type =
          ReservationType.values.byName(map['type'].toString().split('.').last);

      return switch (type) {
        ReservationType.bus => BusReservation.fromJson(details),
        ReservationType.hotel => HotelReservation.fromJson(details),
        ReservationType.apartment => ApartmentReservation.fromJson(details),
      };
    }).toList();
  }

  Future<Object?> getReservationById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reservations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    final details = jsonDecode(map['details'] as String);
    final type =
        ReservationType.values.byName(map['type'].toString().split('.').last);

    return switch (type) {
      ReservationType.bus => BusReservation.fromJson(details),
      ReservationType.hotel => HotelReservation.fromJson(details),
      ReservationType.apartment => ApartmentReservation.fromJson(details),
    };
  }

  Future<List<BaseReservation>> getActiveReservations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reservations',
      where: 'status IN (?, ?)',
      whereArgs: [
        ReservationStatus.pending.toString(),
        ReservationStatus.confirmed.toString(),
      ],
    );

    return maps.map((map) {
      final details = jsonDecode(map['details'] as String);
      final type =
          ReservationType.values.byName(map['type'].toString().split('.').last);

      return switch (type) {
        ReservationType.bus => BusReservation.fromJson(details),
        ReservationType.hotel => HotelReservation.fromJson(details),
        ReservationType.apartment => ApartmentReservation.fromJson(details),
      };
    }).toList();
  }

  Future<void> cleanup() async {
    try {
      await deleteOldReservations();
      final expiredReservations = await getExpiredPendingReservations();

      for (final reservation in expiredReservations) {
        await updateReservationStatus(
          reservation.base.id,
          ReservationStatus.expired,
          cancellationReason: 'La réservation a expiré',
        );
      }
    } catch (e) {
      print('Erreur lors du nettoyage des réservations: $e');
    }
  }
}

final reservationPersistenceService = ReservationPersistenceService();
