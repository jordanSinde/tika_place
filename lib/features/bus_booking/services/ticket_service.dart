// lib/features/bus_booking/services/ticket_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../home/models/bus_and_utility_models.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../providers/ticket_model.dart';
import 'ticket_local_persistence_service.dart';

class TicketService {
  static final TicketService _instance = TicketService._internal();
  final _persistenceService = ticketLocalPersistenceService;

  factory TicketService() {
    return _instance;
  }

  TicketService._internal();

  // Générer les tickets après un paiement réussi
  Future<List<ExtendedTicket>> generateTicketsForReservation(
    TicketReservation reservation,
  ) async {
    final tickets = <ExtendedTicket>[];

    try {
      // Vérifier que la réservation est dans un état valide
      if (reservation.status != BookingStatus.confirmed) {
        throw Exception('La réservation n\'est pas confirmée');
      }

      // Générer un ticket pour chaque passager
      for (var i = 0; i < reservation.passengers.length; i++) {
        final passenger = reservation.passengers[i];
        final seatNumber = await _assignSeatNumber(
          reservation.bus.id,
          reservation.id,
          i,
        );

        final ticket = await generateTicket(
          bus: reservation.bus,
          passengerName: '${passenger.firstName} ${passenger.lastName}',
          phoneNumber: passenger.phoneNumber ?? '',
          bookingReference: reservation.id,
          paymentMethod: PaymentMethod.values.firstWhere(
            (m) =>
                m.toString() == reservation.lastPaymentAttempt?.paymentMethod,
          ),
          seatNumber: seatNumber,
          cniNumber: passenger.cniNumber?.toString(),
          transactionId: reservation.lastPaymentAttempt?.transactionId,
        );

        tickets.add(ticket);
      }

      // Sauvegarder tous les tickets
      await _persistenceService.saveTickets(tickets);

      return tickets;
    } catch (e) {
      print('Erreur lors de la génération des tickets: $e');
      rethrow;
    }
  }

  // Générer un ticket individuel
  Future<ExtendedTicket> generateTicket({
    required Bus bus,
    required String passengerName,
    required String phoneNumber,
    required String bookingReference,
    required PaymentMethod paymentMethod,
    required String seatNumber,
    String? cniNumber,
    String? transactionId,
  }) async {
    // Générer un ID unique pour le ticket
    final ticketId = _generateTicketId(bookingReference, seatNumber);

    // Générer le QR code
    final qrCode = _generateQRCode(
      ticketId: ticketId,
      bus: bus,
      passengerName: passengerName,
      seatNumber: seatNumber,
      bookingReference: bookingReference,
    );

    final ticket = ExtendedTicket(
      id: ticketId,
      bus: bus,
      passengerName: passengerName,
      phoneNumber: phoneNumber,
      purchaseDate: DateTime.now(),
      totalPrice: bus.price,
      seatNumber: seatNumber,
      qrCode: qrCode,
      bookingReference: bookingReference,
      paymentMethod: paymentMethod,
      status: BookingStatus.paid,
      cniNumber: cniNumber,
      isUsed: false,
      transactionId: transactionId,
    );

    return ticket;
  }

  // Attribuer un numéro de siège
  Future<String> _assignSeatNumber(
    String busId,
    String bookingReference,
    int passengerIndex,
  ) async {
    // Simulation - à remplacer par la logique réelle
    await Future.delayed(const Duration(milliseconds: 200));
    return 'A${passengerIndex + 1}';
  }

  // Générer un ID unique pour le ticket
  String _generateTicketId(String bookingReference, String seatNumber) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = '$bookingReference-$seatNumber-$timestamp';
    return 'TK${sha256.convert(utf8.encode(data)).toString().substring(0, 8)}';
  }

  // Générer le QR code
  String _generateQRCode({
    required String ticketId,
    required Bus bus,
    required String passengerName,
    required String seatNumber,
    required String bookingReference,
  }) {
    final data = {
      'ticketId': ticketId,
      'busId': bus.id,
      'bookingRef': bookingReference,
      'passenger': passengerName,
      'seat': seatNumber,
      'departure': bus.departureTime.toIso8601String(),
      'validUntil':
          bus.departureTime.add(const Duration(hours: 1)).toIso8601String(),
    };

    return base64Encode(utf8.encode(json.encode(data)));
  }

  // Valider un ticket
  Future<bool> validateTicket(String ticketId, String validatorId) async {
    try {
      final ticket = await _persistenceService.getTicketById(ticketId);
      if (ticket == null) return false;

      // Vérifier si le ticket est valide
      if (!ticket.isValid || ticket.isUsed == true) return false;

      // Mettre à jour le ticket
      final updatedTicket = ticket.copyWith(
        isUsed: true,
        validationDate: DateTime.now(),
        validatedBy: validatorId,
      );

      await _persistenceService.saveTicket(updatedTicket);
      return true;
    } catch (e) {
      print('Erreur lors de la validation du ticket: $e');
      return false;
    }
  }

  // Vérifier la disponibilité d'un siège
  Future<bool> isSeatAvailable(String busId, String seatNumber) async {
    try {
      // Simuler la vérification - à remplacer par la logique réelle
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e) {
      print('Erreur lors de la vérification du siège: $e');
      return false;
    }
  }

  // Annuler un ticket
  Future<bool> cancelTicket(String ticketId) async {
    try {
      final ticket = await _persistenceService.getTicketById(ticketId);
      if (ticket == null) return false;

      // Vérifier si le ticket peut être annulé
      if (!ticket.canBeRefunded) return false;

      // Mettre à jour le statut
      final updatedTicket = ticket.copyWith(
        status: BookingStatus.cancelled,
      );

      await _persistenceService.saveTicket(updatedTicket);
      return true;
    } catch (e) {
      print('Erreur lors de l\'annulation du ticket: $e');
      return false;
    }
  }

  // Obtenir les tickets d'un utilisateur
  Future<List<ExtendedTicket>> getUserTickets(String userId) async {
    try {
      return await _persistenceService.getAllTickets();
    } catch (e) {
      print('Erreur lors de la récupération des tickets: $e');
      return [];
    }
  }
}

// Instance singleton
final ticketService = TicketService();

//V1
/*
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../auth/models/user.dart';
import '../../home/models/bus_and_utility_models.dart';
import '../providers/booking_provider.dart';
import '../providers/ticket_model.dart';

class TicketService {
  static final TicketService _instance = TicketService._internal();

  factory TicketService() {
    return _instance;
  }

  TicketService._internal();

  // Générer un nouveau ticket
  Future<ExtendedTicket> generateTicket({
    required Bus bus,
    required String passengerName,
    required String phoneNumber,
    required String bookingReference,
    required PaymentMethod paymentMethod,
    required String seatNumber,
    String? cniNumber,
  }) async {
    // Simuler un délai de génération
    await Future.delayed(const Duration(milliseconds: 500));

    // Générer un ID unique pour le ticket
    final ticketId = _generateTicketId(bookingReference, seatNumber);

    // Générer le QR code (ici nous générons juste une chaîne unique)
    final qrCode = _generateQRCode(ticketId, bus, passengerName, seatNumber);

    final ticket = ExtendedTicket(
      id: ticketId,
      bus: bus,
      passengerName: passengerName,
      phoneNumber: phoneNumber,
      purchaseDate: DateTime.now(),
      totalPrice: bus.price,
      seatNumber: seatNumber,
      qrCode: qrCode,
      bookingReference: bookingReference,
      paymentMethod: paymentMethod,
      status: BookingStatus.paid,
      cniNumber: cniNumber,
      isUsed: false,
    );

    // Simuler la sauvegarde en base de données
    await _saveTicket(ticket);

    return ticket;
  }

  // Générer plusieurs tickets pour un groupe
  Future<List<ExtendedTicket>> generateGroupTickets({
    required Bus bus,
    required List<Passenger> passengers,
    required String bookingReference,
    required PaymentMethod paymentMethod,
  }) async {
    final tickets = <ExtendedTicket>[];

    for (var i = 0; i < passengers.length; i++) {
      final passenger = passengers[i];
      final seatNumber = 'A${i + 1}';

      final ticket = await generateTicket(
        bus: bus,
        passengerName: '${passenger.firstName} ${passenger.lastName}',
        phoneNumber: passenger.phoneNumber ?? '',
        bookingReference: bookingReference,
        paymentMethod: paymentMethod,
        seatNumber: seatNumber,
        cniNumber: passenger.cniNumber?.toString(),
      );

      tickets.add(ticket);
    }

    return tickets;
  }

  // Valider un ticket
  Future<bool> validateTicket(String ticketId, String validatorId) async {
    try {
      // Simuler la vérification en base de données
      await Future.delayed(const Duration(seconds: 1));

      // Dans un cas réel, on vérifierait en base de données
      return true;
    } catch (e) {
      return false;
    }
  }

  // Vérifier si un siège est disponible
  Future<bool> isSeatAvailable(String busId, String seatNumber) async {
    // Simuler la vérification en base de données
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  // Générer un ID unique pour le ticket
  String _generateTicketId(String bookingReference, String seatNumber) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = '$bookingReference-$seatNumber-$timestamp';
    return 'TK${sha256.convert(utf8.encode(data)).toString().substring(0, 8)}';
  }

  // Générer un QR code (simulation)
  String _generateQRCode(
    String ticketId,
    Bus bus,
    String passengerName,
    String seatNumber,
  ) {
    final data = {
      'ticketId': ticketId,
      'bus': bus.registrationNumber,
      'passenger': passengerName,
      'seat': seatNumber,
      'departure': bus.departureTime.toIso8601String(),
    };

    // Dans un cas réel, on générerait un vrai QR code
    // Ici on retourne juste une chaîne encodée
    return base64Encode(utf8.encode(json.encode(data)));
  }

  // Simuler la sauvegarde d'un ticket
  Future<void> _saveTicket(ExtendedTicket ticket) async {
    // Simuler une sauvegarde en base de données
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Récupérer l'historique des tickets d'un utilisateur
  Future<List<ExtendedTicket>> getUserTickets(String userId) async {
    // Simuler la récupération depuis la base de données
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  // Annuler un ticket
  Future<bool> cancelTicket(String ticketId) async {
    try {
      // Simuler l'annulation en base de données
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Singleton instance
final ticketService = TicketService();
*/