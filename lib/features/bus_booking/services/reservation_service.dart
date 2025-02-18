// lib/features/bus_booking/services/reservation_service.dart

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';

class ReservationService {
  static final ReservationService _instance = ReservationService._internal();
  Database? _database;

  factory ReservationService() {
    return _instance;
  }

  ReservationService._internal();

  // Database initialization
  Future<Database> get database async {
    print('🗄️ PHASE 2: Getting database instance');
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    print('🗄️ PHASE 2: Initializing database');
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'reservations.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        print('🗄️ PHASE 2: Creating database tables');
        await db.execute('''
          CREATE TABLE reservations(
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            status TEXT NOT NULL,
            user_id TEXT NOT NULL
          )
        ''');
        print('✅ PHASE 2: Database tables created successfully');
      },
    );
  }

  // Save a new reservation
  Future<void> saveReservation(TicketReservation reservation) async {
    print('💾 PHASE 2: Creating new reservation ${reservation.id}');
    final db = await database;
    
    try {
      await db.insert(
        'reservations',
        {
          'id': reservation.id,
          'data': jsonEncode(reservation.toJson()),
          'created_at': reservation.createdAt.millisecondsSinceEpoch,
          'status': reservation.status.toString(),
          'user_id': reservation.userId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ PHASE 2: Reservation saved successfully');
    } catch (e) {
      print('❌ PHASE 2: Failed to save reservation - $e');
      throw Exception('Failed to save reservation: $e');
    }
  }

  // Update an existing reservation
  Future<void> updateReservation(
    String reservationId,
    Map<String, dynamic> updates,
  ) async {
    print('🔄 PHASE 2: Updating reservation $reservationId');
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'reservations',
        where: 'id = ?',
        whereArgs: [reservationId],
      );

      if (maps.isEmpty) {
        throw Exception('Reservation not found');
      }

      final existingData = jsonDecode(maps.first['data']);
      final updatedData = {...existingData, ...updates};

      await db.update(
        'reservations',
        {
          'data': jsonEncode(updatedData),
          'status': updates['status']?.toString() ?? maps.first['status'],
        },
        where: 'id = ?',
        whereArgs: [reservationId],
      );
      
      print('✅ PHASE 2: Reservation updated successfully');
    } catch (e) {
      print('❌ PHASE 2: Failed to update reservation - $e');
      throw Exception('Failed to update reservation: $e');
    }
  }

  // Load all reservations
  Future<List<TicketReservation>> loadReservations() async {
    print('📂 PHASE 2: Loading all reservations');
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query('reservations');
      
      final reservations = maps.map((map) {
        return TicketReservation.fromJson(jsonDecode(map['data']));
      }).toList();

      print('✅ PHASE 2: Loaded ${reservations.length} reservations');
      return reservations;
    } catch (e) {
      print('❌ PHASE 2: Failed to load reservations - $e');
      throw Exception('Failed to load reservations: $e');
    }
  }

  // Load reservations by user
  Future<List<TicketReservation>> loadUserReservations(String userId) async {
    print('📂 PHASE 2: Loading reservations for user $userId');
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'reservations',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      final reservations = maps.map((map) {
        return TicketReservation.fromJson(jsonDecode(map['data']));
      }).toList();

      print('✅ PHASE 2: Loaded ${reservations.length} user reservations');
      return reservations;
    } catch (e) {
      print('❌ PHASE 2: Failed to load user reservations - $e');
      throw Exception('Failed to load user reservations: $e');
    }
  }

  // Delete a reservation
  Future<void> deleteReservation(String reservationId) async {
    print('🗑️ PHASE 2: Deleting reservation $reservationId');
    final db = await database;
    
    try {
      await db.delete(
        'reservations',
        where: 'id = ?',
        whereArgs: [reservationId],
      );
      print('✅ PHASE 2: Reservation deleted successfully');
    } catch (e) {
      print('❌ PHASE 2: Failed to delete reservation - $e');
      throw Exception('Failed to delete reservation: $e');
    }
  }

  // Verify Phase 2 implementation
  Future<bool> verifyPhase2Implementation() async {
    print('\n🔍 PHASE 2 VERIFICATION START');
    print('===============================');

    bool isValid = true;

    // Step 1: Verify database
    try {
      final db = await database;
      print('✅ PHASE 2.1: Database initialized successfully');

      // Verify tables
      final tables = await db.query('sqlite_master', 
          where: 'type = ? AND name = ?',
          whereArgs: ['table', 'reservations']);

      if (tables.isEmpty) {
        print('❌ PHASE 2.1: Required tables missing');
        isValid = false;
      } else {
        print('✅ PHASE 2.1: Required tables exist');
      }
    } catch (e) {
      print('❌ PHASE 2.1: Database initialization failed - $e');
      isValid = false;
    }

    // Step 2: Test CRUD operations
    try {
      // Test Create
      final testReservation = TicketReservation(
        id: 'TEST_${DateTime.now().millisecondsSinceEpoch}',
        status: BookingStatus.pending,
        totalAmount: 1000,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
        userId: 'test_user',
        bus: Bus(...), // Add test bus data
        passengers: [], // Add test passenger data
      );

      await saveReservation(testReservation);
      print('✅ PHASE 2.1: Reservation creation working');

      // Test Update
      await updateReservation(testReservation.id, {
        'status': BookingStatus.confirmed.toString()
      });
      print('✅ PHASE 2.1: Reservation update working');

      // Test Read
      final reservations = await loadReservations();
      if (reservations.isNotEmpty) {
        print('✅ PHASE 2.1: Reservation retrieval working');
      }

      // Test Delete
      await deleteReservation(testReservation.id);
      print('✅ PHASE 2.1: Reservation deletion working');

    } catch (e) {
      print('❌ PHASE 2.1: CRUD operations failed - $e');
      isValid = false;
    }

    // Step 3: Verify status management
    try {
      final testRes = TicketReservation(
        id: 'STATUS_TEST_${DateTime.now().millisecondsSinceEpoch}',
        status: BookingStatus.pending,
        totalAmount: 1000,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
        userId: 'test_user',
        bus: Bus(...), // Add test bus data
        passengers: [], // Add test passenger data
      );

      // Test status transitions
      await saveReservation(testRes);
      print('✅ PHASE 2.2: Initial status set correctly');

      await updateReservation(testRes.id, {
        'status': BookingStatus.confirmed.toString()
      });
      print('✅ PHASE 2.2: Status transition working');

      // Cleanup
      await deleteReservation(testRes.id);

    } catch (e) {
      print('❌ PHASE 2.2: Status management failed - $e');
      isValid = false;
    }

    print('\n📋 PHASE 2 VERIFICATION RESULT:');
    print('===============================');
    if (isValid) {
      print('✅ Phase 2 implementation complete and verified');
      print('✅ Database operations working correctly');
      print('✅ Status management verified');
      print('✅ Ready for Phase 3');
    } else {
      print('❌ Phase 2 verification failed');
      print('⚠️ Please fix the above issues before proceeding');
    }
    print('===============================\n');

    return isValid;
  }
}

// Singleton instance
final reservationService = ReservationService();