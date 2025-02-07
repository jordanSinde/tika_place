// lib/features/bus_booking/services/ticket_local_persistence_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../providers/booking_provider.dart';
import '../providers/ticket_model.dart';
import 'dart:convert';

class TicketLocalPersistenceService {
  static final TicketLocalPersistenceService _instance =
      TicketLocalPersistenceService._internal();
  Database? _database;

  factory TicketLocalPersistenceService() {
    return _instance;
  }

  TicketLocalPersistenceService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    print("Initialisation de la base de données SQLite");
    try {
      String path = await getDatabasesPath();
      final dbPath = join(path, 'tickets.db');
      print("Chemin de la base de données: $dbPath");

      return await openDatabase(
        dbPath,
        onCreate: (db, version) async {
          print("Création de la table tickets");
          await db.execute('''
          CREATE TABLE tickets(
            id TEXT PRIMARY KEY,
            bookingReference TEXT NOT NULL,
            ticketData TEXT NOT NULL,
            createdAt INTEGER NOT NULL,
            status TEXT NOT NULL
          )
        ''');
          print("Table tickets créée avec succès");
        },
        onOpen: (db) async {
          print("Base de données ouverte");
          // Vérifier si la table existe
          final tables = await db.query('sqlite_master',
              where: 'name = ?', whereArgs: ['tickets']);
          print("Tables existantes: ${tables.length}");
        },
        version: 1,
      );
    } catch (e, stackTrace) {
      print("Erreur lors de l'initialisation de la base de données: $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
  }

  /*Future<Database> _initDB() async {
    String path = await getDatabasesPath();
    return await openDatabase(
      join(path, 'tickets.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tickets(
            id TEXT PRIMARY KEY,
            bookingReference TEXT NOT NULL,
            ticketData TEXT NOT NULL,
            createdAt INTEGER NOT NULL,
            status TEXT NOT NULL
          )
        ''');
      },
      version: 1,
    );
  }*/

  Future<void> saveTicket(ExtendedTicket ticket) async {
    final db = await database;
    await db.insert(
      'tickets',
      {
        'id': ticket.id,
        'bookingReference': ticket.bookingReference,
        'ticketData': jsonEncode(ticket.toJson()),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'status': ticket.status.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveTickets(List<ExtendedTicket> tickets) async {
    print("Début saveTickets");
    final db = await database;
    final batch = db.batch();

    try {
      for (var ticket in tickets) {
        print("Sauvegarde du ticket ${ticket.id}");
        batch.insert(
          'tickets',
          {
            'id': ticket.id,
            'bookingReference': ticket.bookingReference,
            'ticketData': jsonEncode(ticket.toJson()),
            'createdAt': DateTime.now().millisecondsSinceEpoch,
            'status': ticket.status.toString(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit();
      print("Tickets sauvegardés avec succès");
    } catch (e) {
      print("Erreur lors de la sauvegarde des tickets: $e");
      rethrow;
    }
  }

  Future<ExtendedTicket?> getTicketById(String ticketId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tickets',
      where: 'id = ?',
      whereArgs: [ticketId],
    );

    if (maps.isEmpty) return null;

    return ExtendedTicket.fromJson(
      jsonDecode(maps.first['ticketData']),
    );
  }

  Future<List<ExtendedTicket>> getTicketsByBookingReference(
      String bookingReference) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tickets',
      where: 'bookingReference = ?',
      whereArgs: [bookingReference],
    );

    return maps.map((map) {
      return ExtendedTicket.fromJson(
        jsonDecode(map['ticketData']),
      );
    }).toList();
  }

  Future<List<ExtendedTicket>> getAllTickets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tickets');

    return maps.map((map) {
      return ExtendedTicket.fromJson(
        jsonDecode(map['ticketData']),
      );
    }).toList();
  }

  Future<void> updateTicketStatus(String ticketId, BookingStatus status) async {
    final db = await database;

    // D'abord, récupérer le ticket existant
    final ticket = await getTicketById(ticketId);
    if (ticket == null) return;

    // Mettre à jour le ticket avec le nouveau statut
    final updatedTicket = ticket.copyWith(status: status);

    await db.update(
      'tickets',
      {
        'ticketData': jsonEncode(updatedTicket.toJson()),
        'status': status.toString(),
      },
      where: 'id = ?',
      whereArgs: [ticketId],
    );
  }

  Future<void> deleteTicket(String ticketId) async {
    final db = await database;
    await db.delete(
      'tickets',
      where: 'id = ?',
      whereArgs: [ticketId],
    );
  }

  Future<void> deleteAllTickets() async {
    final db = await database;
    await db.delete('tickets');
  }
}

final ticketLocalPersistenceService = TicketLocalPersistenceService();
