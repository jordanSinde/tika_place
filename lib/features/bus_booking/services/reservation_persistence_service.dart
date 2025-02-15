// lib/features/bus_booking/services/reservation_persistence_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/booking_model.dart';
import '../models/promo_code.dart';
import '../providers/booking_provider.dart';
import '../../home/models/bus_and_utility_models.dart';

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
    _database = await _initDatabase();
    return _database!;
  }

  // Ajoutez cette méthode dans ReservationPersistenceService
  Future<void> deleteDatabase() async {
    try {
      String path = await getDatabasesPath();
      final dbPath = join(path, 'reservations.db');
      print("Suppression de la base de données: $dbPath");
      await databaseFactory.deleteDatabase(dbPath);
      _database = null;
      print("Base de données supprimée avec succès");
    } catch (e) {
      print("Erreur lors de la suppression de la base de données: $e");
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    print("Initialisation de la base de données des réservations");
    try {
      String path = await getDatabasesPath();
      final dbPath = join(path, 'reservations.db');
      print("Chemin de la base de données: $dbPath");

      return await openDatabase(
        dbPath,
        version: 2,
        onCreate: (db, version) async {
          await _createTables(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _updateToV2(db);
          }
        },
      );
    } catch (e) {
      print("Erreur lors de l'initialisation de la base de données: $e");
      rethrow;
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE reservations (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        createdAt INTEGER NOT NULL,
        expiresAt INTEGER NOT NULL,
        cancellationReason TEXT,
        isArchived INTEGER DEFAULT 0,
        lastPaymentAttempt TEXT,
        appliedPromoCode TEXT,
        discountAmount REAL,
        busData TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reservation_passengers (
        id TEXT PRIMARY KEY,
        reservationId TEXT NOT NULL,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        phoneNumber TEXT,
        cniNumber INTEGER,
        isMainPassenger INTEGER DEFAULT 0,
        FOREIGN KEY (reservationId) REFERENCES reservations (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE payment_attempts (
        id TEXT PRIMARY KEY,
        reservationId TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        status TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        amount REAL,
        errorMessage TEXT,
        transactionId TEXT,
        FOREIGN KEY (reservationId) REFERENCES reservations (id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _updateToV2(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS payment_attempts (
        id TEXT PRIMARY KEY,
        reservationId TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        status TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        amount REAL,
        errorMessage TEXT,
        transactionId TEXT,
        FOREIGN KEY (reservationId) REFERENCES reservations (id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<List<TicketReservation>> getReservationsForUser(String userId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> reservations = await db.query(
        'reservations',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );

      final List<TicketReservation> result = [];
      for (var reservation in reservations) {
        final passengersData = await db.query(
          'reservation_passengers',
          where: 'reservationId = ?',
          whereArgs: [reservation['id']],
        );

        final paymentsData = await db.query(
          'payment_attempts',
          where: 'reservationId = ?',
          whereArgs: [reservation['id']],
          orderBy: 'timestamp DESC',
        );

        final paymentHistory = paymentsData
            .map((p) => PaymentAttempt(
                  timestamp: DateTime.fromMillisecondsSinceEpoch(
                      p['timestamp'] as int),
                  status: p['status'] as String,
                  paymentMethod: p['paymentMethod'] as String,
                  amountPaid: p['amount'] as double?,
                  errorMessage: p['errorMessage'] as String?,
                  transactionId: p['transactionId'] as String?,
                ))
            .toList();

        result.add(_convertToReservation(
          reservation,
          passengersData,
          paymentHistory,
        ));
      }

      return result;
    } catch (e) {
      print("Erreur lors de la récupération des réservations: $e");
      rethrow;
    }
  }

  TicketReservation _convertToReservation(
    Map<String, dynamic> reservationData,
    List<Map<String, dynamic>> passengersData,
    List<PaymentAttempt> paymentHistory,
  ) {
    // Convertir les données du bus
    final busJson = jsonDecode(reservationData['busData'] as String);
    final bus = Bus.fromJson(busJson);

    // Convertir les données des passagers
    final passengers = passengersData
        .map((p) => PassengerInfo(
              firstName: p['firstName'] as String,
              lastName: p['lastName'] as String,
              phoneNumber: p['phoneNumber'] as String?,
              cniNumber: p['cniNumber'] as int?,
              isMainPassenger: p['isMainPassenger'] == 1,
            ))
        .toList();

    // Convertir le code promo si présent
    PromoCode? promoCode;
    if (reservationData['appliedPromoCode'] != null) {
      final promoJson =
          jsonDecode(reservationData['appliedPromoCode'] as String);
      promoCode = PromoCode.fromJson(promoJson);
    }

    return TicketReservation(
      id: reservationData['id'] as String,
      bus: bus,
      passengers: passengers,
      status: BookingStatus.values.firstWhere(
        (s) => s.toString() == reservationData['status'],
      ),
      totalAmount: reservationData['totalAmount'] as double,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        reservationData['createdAt'] as int,
      ),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        reservationData['expiresAt'] as int,
      ),
      userId: reservationData['userId'] as String,
      appliedPromoCode: promoCode,
      discountAmount: reservationData['discountAmount'] as double?,
      paymentHistory: paymentHistory,
      cancellationReason: reservationData['cancellationReason'] as String?,
      isArchived: reservationData['isArchived'] == 1,
    );
  }

  Future<void> saveReservation(TicketReservation reservation) async {
    final db = await database;
    await db.transaction((txn) async {
      // Sauvegarder la réservation
      await txn.insert(
        'reservations',
        {
          'id': reservation.id,
          'userId': reservation.userId,
          'type': 'BUS',
          'status': reservation.status.toString(),
          'totalAmount': reservation.totalAmount,
          'createdAt': reservation.createdAt.millisecondsSinceEpoch,
          'expiresAt': reservation.expiresAt.millisecondsSinceEpoch,
          'cancellationReason': reservation.cancellationReason,
          'isArchived': reservation.isArchived ? 1 : 0,
          'appliedPromoCode': reservation.appliedPromoCode != null
              ? jsonEncode(reservation.appliedPromoCode!.toJson())
              : null,
          'discountAmount': reservation.discountAmount,
          'busData': jsonEncode(reservation.bus.toJson()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Sauvegarder les passagers
      for (var passenger in reservation.passengers) {
        await txn.insert(
          'reservation_passengers',
          {
            'id':
                '${reservation.id}_${passenger.firstName}_${passenger.lastName}',
            'reservationId': reservation.id,
            'firstName': passenger.firstName,
            'lastName': passenger.lastName,
            'phoneNumber': passenger.phoneNumber,
            'cniNumber': passenger.cniNumber,
            'isMainPassenger': passenger.isMainPassenger ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Sauvegarder l'historique des paiements
      if (reservation.paymentHistory != null) {
        for (var attempt in reservation.paymentHistory!) {
          await txn.insert(
            'payment_attempts',
            {
              'id': 'PAY${DateTime.now().millisecondsSinceEpoch}',
              'reservationId': reservation.id,
              'timestamp': attempt.timestamp.millisecondsSinceEpoch,
              'status': attempt.status,
              'paymentMethod': attempt.paymentMethod,
              'amount': attempt.amountPaid,
              'errorMessage': attempt.errorMessage,
              'transactionId': attempt.transactionId,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  Future<void> updateReservationStatus(
    String reservationId,
    BookingStatus status,
  ) async {
    final db = await database;
    await db.update(
      'reservations',
      {'status': status.toString()},
      where: 'id = ?',
      whereArgs: [reservationId],
    );
  }

  Future<TicketReservation?> getReservation(String reservationId) async {
    final db = await database;
    final reservations = await db.query(
      'reservations',
      where: 'id = ?',
      whereArgs: [reservationId],
    );

    if (reservations.isEmpty) return null;

    final reservation = reservations.first;
    final passengers = await db.query(
      'reservation_passengers',
      where: 'reservationId = ?',
      whereArgs: [reservationId],
    );

    final paymentHistory = await getPaymentHistory(reservationId);

    return _convertToReservation(reservation, passengers, paymentHistory);
  }

  Future<List<PaymentAttempt>> getPaymentHistory(String reservationId) async {
    final db = await database;
    final attempts = await db.query(
      'payment_attempts',
      where: 'reservationId = ?',
      whereArgs: [reservationId],
      orderBy: 'timestamp DESC',
    );

    return attempts
        .map((data) => PaymentAttempt(
              timestamp:
                  DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int),
              status: data['status'] as String,
              paymentMethod: data['paymentMethod'] as String,
              amountPaid: data['amount'] as double?,
              errorMessage: data['errorMessage'] as String?,
              transactionId: data['transactionId'] as String?,
            ))
        .toList();
  }

  Future<void> savePaymentAttempt(
    String reservationId,
    PaymentAttempt attempt,
  ) async {
    final db = await database;
    final attemptId = 'PAY${DateTime.now().millisecondsSinceEpoch}';

    await db.insert(
      'payment_attempts',
      {
        'id': attemptId,
        'reservationId': reservationId,
        'timestamp': attempt.timestamp.millisecondsSinceEpoch,
        'status': attempt.status,
        'paymentMethod': attempt.paymentMethod,
        'amount': attempt.amountPaid,
        'errorMessage': attempt.errorMessage,
        'transactionId': attempt.transactionId,
      },
    );
  }
}

final reservationPersistenceService = ReservationPersistenceService();



// lib/features/bus_booking/services/reservation_persistence_service.dart
/*
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/booking_model.dart';
import '../models/promo_code.dart';
import '../providers/booking_provider.dart';
import '../../home/models/bus_and_utility_models.dart';

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
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    print("Initialisation de la base de données des réservations");
    try {
      String path = await getDatabasesPath();
      final dbPath = join(path, 'reservations.db');
      print("Chemin de la base de données: $dbPath");

      return await openDatabase(
        dbPath,
        version: 2,
        onCreate: (db, version) async {
          await _createTables(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _updateToV2(db);
          }
        },
      );
    } catch (e) {
      print("Erreur lors de l'initialisation de la base de données: $e");
      rethrow;
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE reservations (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        createdAt INTEGER NOT NULL,
        expiresAt INTEGER NOT NULL,
        cancellationReason TEXT,
        isArchived INTEGER DEFAULT 0,
        lastPaymentAttempt TEXT,
        appliedPromoCode TEXT,
        discountAmount REAL,
        busData TEXT,
        hotelData TEXT,
        apartmentData TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reservation_passengers (
        id TEXT PRIMARY KEY,
        reservationId TEXT NOT NULL,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        phoneNumber TEXT,
        cniNumber TEXT,
        isMainPassenger INTEGER DEFAULT 0,
        FOREIGN KEY (reservationId) REFERENCES reservations (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE payment_attempts (
        id TEXT PRIMARY KEY,
        reservationId TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        status TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        amount REAL NOT NULL,
        errorMessage TEXT,
        transactionId TEXT,
        FOREIGN KEY (reservationId) REFERENCES reservations (id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _updateToV2(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS payment_attempts (
        id TEXT PRIMARY KEY,
        reservationId TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        status TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        amount REAL NOT NULL,
        errorMessage TEXT,
        transactionId TEXT,
        FOREIGN KEY (reservationId) REFERENCES reservations (id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<List<TicketReservation>> getReservationsForUser(String userId) async {
    final db = await database;
    try {
      // Récupérer les réservations
      final List<Map<String, dynamic>> reservations = await db.query(
        'reservations',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );

      // Pour chaque réservation, récupérer les passagers et l'historique des paiements
      final List<TicketReservation> result = [];
      for (var reservation in reservations) {
        final passengersData = await db.query(
          'reservation_passengers',
          where: 'reservationId = ?',
          whereArgs: [reservation['id']],
        );

        final paymentsData = await db.query(
          'payment_attempts',
          where: 'reservationId = ?',
          whereArgs: [reservation['id']],
          orderBy: 'timestamp DESC',
        );

        final paymentHistory = paymentsData
            .map((p) => PaymentAttempt(
                  timestamp: DateTime.fromMillisecondsSinceEpoch(
                      p['timestamp'] as int),
                  status: p['status'] as String,
                  paymentMethod: p['paymentMethod'] as String,
                  amountPaid: p['amount'] as double,
                  errorMessage: p['errorMessage'] as String?,
                  transactionId: p['transactionId'] as String?,
                ))
            .toList();

        result.add(_convertToReservation(
          reservation,
          passengersData,
          paymentHistory,
        ));
      }

      return result;
    } catch (e) {
      print("Erreur lors de la récupération des réservations: $e");
      rethrow;
    }
  }

  TicketReservation _convertToReservation(
    Map<String, dynamic> reservationData,
    List<Map<String, dynamic>> passengersData,
    List<PaymentAttempt> paymentHistory,
  ) {
    // Convertir les données du bus
    final busJson = jsonDecode(reservationData['busData'] as String);
    final bus = Bus.fromJson(busJson);

    // Convertir les données des passagers
    final passengers = passengersData
        .map((p) => PassengerInfo(
              firstName: p['firstName'] as String,
              lastName: p['lastName'] as String,
              phoneNumber: p['phoneNumber'] as String?,
              cniNumber: p['cniNumber'] != null
                  ? int.tryParse(p['cniNumber'] as String)
                  : null,
              isMainPassenger: p['isMainPassenger'] == 1,
            ))
        .toList();

    // Convertir le code promo si présent
    PromoCode? promoCode;
    if (reservationData['appliedPromoCode'] != null) {
      final promoJson =
          jsonDecode(reservationData['appliedPromoCode'] as String);
      promoCode = PromoCode.fromJson(promoJson);
    }

    // Convertir la dernière tentative de paiement si présente
    PaymentAttempt? lastPaymentAttempt;
    if (reservationData['lastPaymentAttempt'] != null) {
      final paymentJson =
          jsonDecode(reservationData['lastPaymentAttempt'] as String);
      lastPaymentAttempt = PaymentAttempt.fromJson(paymentJson);
    }

    return TicketReservation(
      id: reservationData['id'] as String,
      bus: bus,
      passengers: passengers,
      status: BookingStatus.values
          .firstWhere((s) => s.toString() == reservationData['status']),
      totalAmount: reservationData['totalAmount'] as double,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          reservationData['createdAt'] as int),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
          reservationData['expiresAt'] as int),
      userId: reservationData['userId'] as String,
      appliedPromoCode: promoCode,
      discountAmount: reservationData['discountAmount'] as double?,
      lastPaymentAttempt: lastPaymentAttempt,
      paymentHistory: paymentHistory,
      cancellationReason: reservationData['cancellationReason'] as String?,
      isArchived: reservationData['isArchived'] == 1,
    );
  }

  // Les autres méthodes restent inchangées...
  Future<List<PaymentAttempt>> getPaymentHistory(String reservationId) async {
    final db = await database;
    final attempts = await db.query(
      'payment_attempts',
      where: 'reservationId = ?',
      whereArgs: [reservationId],
      orderBy: 'timestamp DESC',
    );

    return attempts.map((attempt) => PaymentAttempt.fromJson(attempt)).toList();
  }

  // Sauvegarder une réservation avec son historique de paiement
  Future<void> saveReservation(TicketReservation reservation) async {
    final db = await database;
    await db.transaction((txn) async {
      // Sauvegarder la réservation
      await txn.insert(
        'reservations',
        {
          'id': reservation.id,
          'userId': reservation.userId,
          'type': 'BUS',
          'status': reservation.status.toString(),
          'totalAmount': reservation.totalAmount,
          'createdAt': reservation.createdAt.toIso8601String(),
          'expiresAt': reservation.expiresAt.toIso8601String(),
          'cancellationReason': reservation.cancellationReason,
          'isArchived': reservation.isArchived ? 1 : 0,
          'lastPaymentAttempt':
              reservation.lastPaymentAttempt?.toJson().toString(),
          'appliedPromoCode': reservation.appliedPromoCode?.toJson().toString(),
          'discountAmount': reservation.discountAmount,
          'busData': json.encode(reservation.bus.toJson()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Sauvegarder les passagers
      for (var passenger in reservation.passengers) {
        await txn.insert(
          'reservation_passengers',
          {
            'id':
                '${reservation.id}_${passenger.firstName}_${passenger.lastName}',
            'reservationId': reservation.id,
            'firstName': passenger.firstName,
            'lastName': passenger.lastName,
            'phoneNumber': passenger.phoneNumber,
            'cniNumber': passenger.cniNumber?.toString(),
            'isMainPassenger': passenger.isMainPassenger ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Sauvegarder l'historique des paiements
      if (reservation.paymentHistory != null) {
        for (var attempt in reservation.paymentHistory!) {
          await txn.insert(
            'payment_attempts',
            {
              'id': 'PAY${DateTime.now().millisecondsSinceEpoch}',
              'reservationId': reservation.id,
              'timestamp': attempt.timestamp.toIso8601String(),
              'status': attempt.status,
              'paymentMethod': attempt.paymentMethod,
              'amount': attempt.amountPaid,
              'errorMessage': attempt.errorMessage,
              'transactionId': attempt.transactionId,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  // Mettre à jour le statut d'une réservation
  Future<void> updateReservationStatus(
      String reservationId, BookingStatus status) async {
    final db = await database;
    await db.update(
      'reservations',
      {'status': status.toString()},
      where: 'id = ?',
      whereArgs: [reservationId],
    );
  }

// Récupérer une réservation complète avec ses relations
  Future<TicketReservation?> getReservation(String reservationId) async {
    final db = await database;
    final reservations = await db.query(
      'reservations',
      where: 'id = ?',
      whereArgs: [reservationId],
    );

    if (reservations.isEmpty) return null;

    final reservation = reservations.first;

    // Récupérer les passagers
    final passengers = await db.query(
      'reservation_passengers',
      where: 'reservationId = ?',
      whereArgs: [reservationId],
    );

    // Récupérer l'historique des paiements
    final paymentHistory = await getPaymentHistory(reservationId);

    // Convertir et retourner la réservation complète
    return _convertToReservation(reservation, passengers, paymentHistory);
  }

  // Sauvegarder une nouvelle tentative de paiement
  Future<void> savePaymentAttempt(
      String reservationId, PaymentAttempt attempt) async {
    final db = await database;
    final attemptId = 'PAY${DateTime.now().millisecondsSinceEpoch}';

    await db.insert(
      'payment_attempts',
      {
        'id': attemptId,
        'reservationId': reservationId,
        'timestamp': attempt.timestamp.toIso8601String(),
        'status': attempt.status,
        'paymentMethod': attempt.paymentMethod,
        'amount': attempt.amountPaid,
        'errorMessage': attempt.errorMessage,
        'transactionId': attempt.transactionId,
      },
    );

    // Mettre à jour la dernière tentative dans la réservation
    await db.update(
      'reservations',
      {'lastPaymentAttempt': json.encode(attempt.toJson())},
      where: 'id = ?',
      whereArgs: [reservationId],
    );
  }
}

final reservationPersistenceService = ReservationPersistenceService();
*/

/*
// lib/features/bus_booking/services/reservation_persistence_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';

class ReservationPersistenceService {
  static Database? _database;
  static final ReservationPersistenceService _instance =
      ReservationPersistenceService._internal();

  factory ReservationPersistenceService() {
    return _instance;
  }

  ReservationPersistenceService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'reservations.db');

    return await openDatabase(
      path,
      version: 2, // Augmenté pour la migration
      onCreate: (Database db, int version) async {
        await _createTables(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          // Ajouter les nouvelles tables si elles n'existent pas
          await _updateToV2(db);
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // Table principale des réservations
    await db.execute('''
      CREATE TABLE reservations (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        createdAt TEXT NOT NULL,
        expiresAt TEXT NOT NULL,
        cancellationReason TEXT,
        isArchived INTEGER DEFAULT 0,
        lastPaymentAttempt TEXT,
        appliedPromoCode TEXT,
        discountAmount REAL,
        busData TEXT,
        hotelData TEXT,
        apartmentData TEXT
      )
    ''');

    // Table des passagers
    await db.execute('''
      CREATE TABLE reservation_passengers (
        id TEXT PRIMARY KEY,
        reservationId TEXT NOT NULL,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        phoneNumber TEXT,
        cniNumber INTEGER,
        isMainPassenger INTEGER DEFAULT 0,
        FOREIGN KEY (reservationId) REFERENCES reservations (id)
          ON DELETE CASCADE
      )
    ''');

    // Table des tentatives de paiement
    await db.execute('''
      CREATE TABLE payment_attempts (
        id TEXT PRIMARY KEY,
        reservationId TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        amount REAL NOT NULL,
        errorMessage TEXT,
        transactionId TEXT,
        FOREIGN KEY (reservationId) REFERENCES reservations (id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _updateToV2(Database db) async {
    // Ajouter la table des tentatives de paiement si elle n'existe pas
    await db.execute('''
      CREATE TABLE IF NOT EXISTS payment_attempts (
        id TEXT PRIMARY KEY,
        reservationId TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        amount REAL NOT NULL,
        errorMessage TEXT,
        transactionId TEXT,
        FOREIGN KEY (reservationId) REFERENCES reservations (id)
          ON DELETE CASCADE
      )
    ''');
  }

  // Sauvegarder une nouvelle tentative de paiement
  Future<void> savePaymentAttempt(
      String reservationId, PaymentAttempt attempt) async {
    final db = await database;
    final attemptId = 'PAY${DateTime.now().millisecondsSinceEpoch}';

    await db.insert(
      'payment_attempts',
      {
        'id': attemptId,
        'reservationId': reservationId,
        'timestamp': attempt.timestamp.toIso8601String(),
        'status': attempt.status,
        'paymentMethod': attempt.paymentMethod,
        'amount': attempt.amountPaid,
        'errorMessage': attempt.errorMessage,
        'transactionId': attempt.transactionId,
      },
    );

    // Mettre à jour la dernière tentative dans la réservation
    await db.update(
      'reservations',
      {'lastPaymentAttempt': json.encode(attempt.toJson())},
      where: 'id = ?',
      whereArgs: [reservationId],
    );
  }

  // Récupérer l'historique des paiements pour une réservation
  Future<List<PaymentAttempt>> getPaymentHistory(String reservationId) async {
    final db = await database;
    final attempts = await db.query(
      'payment_attempts',
      where: 'reservationId = ?',
      whereArgs: [reservationId],
      orderBy: 'timestamp DESC',
    );

    return attempts.map((attempt) => PaymentAttempt.fromJson(attempt)).toList();
  }

  // Sauvegarder une réservation avec son historique de paiement
  Future<void> saveReservation(TicketReservation reservation) async {
    final db = await database;
    await db.transaction((txn) async {
      // Sauvegarder la réservation
      await txn.insert(
        'reservations',
        {
          'id': reservation.id,
          'userId': reservation.userId,
          'type': 'BUS',
          'status': reservation.status.toString(),
          'totalAmount': reservation.totalAmount,
          'createdAt': reservation.createdAt.toIso8601String(),
          'expiresAt': reservation.expiresAt.toIso8601String(),
          'cancellationReason': reservation.cancellationReason,
          'isArchived': reservation.isArchived ? 1 : 0,
          'lastPaymentAttempt':
              reservation.lastPaymentAttempt?.toJson().toString(),
          'appliedPromoCode': reservation.appliedPromoCode?.toJson().toString(),
          'discountAmount': reservation.discountAmount,
          'busData': json.encode(reservation.bus.toJson()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Sauvegarder les passagers
      for (var passenger in reservation.passengers) {
        await txn.insert(
          'reservation_passengers',
          {
            'id':
                '${reservation.id}_${passenger.firstName}_${passenger.lastName}',
            'reservationId': reservation.id,
            'firstName': passenger.firstName,
            'lastName': passenger.lastName,
            'phoneNumber': passenger.phoneNumber,
            'cniNumber': passenger.cniNumber,
            'isMainPassenger': passenger.isMainPassenger ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Sauvegarder l'historique des paiements
      if (reservation.paymentHistory != null) {
        for (var attempt in reservation.paymentHistory!) {
          await txn.insert(
            'payment_attempts',
            {
              'id': 'PAY${DateTime.now().millisecondsSinceEpoch}',
              'reservationId': reservation.id,
              'timestamp': attempt.timestamp.toIso8601String(),
              'status': attempt.status,
              'paymentMethod': attempt.paymentMethod,
              'amount': attempt.amountPaid,
              'errorMessage': attempt.errorMessage,
              'transactionId': attempt.transactionId,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  // Mettre à jour le statut d'une réservation
  Future<void> updateReservationStatus(
      String reservationId, BookingStatus status) async {
    final db = await database;
    await db.update(
      'reservations',
      {'status': status.toString()},
      where: 'id = ?',
      whereArgs: [reservationId],
    );
  }

  // Récupérer une réservation complète avec ses relations
  Future<TicketReservation?> getReservation(String reservationId) async {
    final db = await database;
    final reservations = await db.query(
      'reservations',
      where: 'id = ?',
      whereArgs: [reservationId],
    );

    if (reservations.isEmpty) return null;

    final reservation = reservations.first;

    // Récupérer les passagers
    final passengers = await db.query(
      'reservation_passengers',
      where: 'reservationId = ?',
      whereArgs: [reservationId],
    );

    // Récupérer l'historique des paiements
    final paymentHistory = await getPaymentHistory(reservationId);

    // Convertir et retourner la réservation complète
    return _convertToReservation(reservation, passengers, paymentHistory);
  }

  // Méthode helper pour convertir les données
  TicketReservation _convertToReservation(
    Map<String, dynamic> reservationData,
    List<Map<String, dynamic>> passengersData,
    List<PaymentAttempt> paymentHistory,
  ) {
    // Implémentation de la conversion...
    // À adapter selon votre modèle exact de TicketReservation
    return TicketReservation(
      id: reservationData['id'] as String,
      // ... autres conversions
      paymentHistory: paymentHistory,
    );
  }
}

final reservationPersistenceService = ReservationPersistenceService();
*/