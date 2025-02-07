// lib/features/bus_booking/providers/ticket_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/booking_provider.dart';
import '../providers/ticket_model.dart';
import '../services/ticket_service.dart';
import '../services/ticket_local_persistence_service.dart';
import '../paiement/services/mobile_money_service.dart';

class TicketsState {
  final List<ExtendedTicket> tickets;
  final bool isLoading;
  final String? error;
  final Map<String, List<ExtendedTicket>> ticketsByBooking;

  TicketsState({
    this.tickets = const [],
    this.isLoading = false,
    this.error,
    this.ticketsByBooking = const {},
  });

  TicketsState copyWith({
    List<ExtendedTicket>? tickets,
    bool? isLoading,
    String? error,
    Map<String, List<ExtendedTicket>>? ticketsByBooking,
  }) {
    return TicketsState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      ticketsByBooking: ticketsByBooking ?? this.ticketsByBooking,
    );
  }
}

class TicketsNotifier extends StateNotifier<TicketsState> {
  final BookingState bookingState;

  TicketsNotifier(this.bookingState) : super(TicketsState()) {
    // Charger les tickets locaux au démarrage
    _loadLocalTickets();
  }

  Future<void> _loadLocalTickets() async {
    try {
      final localTickets = await ticketLocalPersistenceService.getAllTickets();
      final ticketsByBooking = <String, List<ExtendedTicket>>{};

      for (final ticket in localTickets) {
        final bookingRef = ticket.bookingReference;
        if (ticketsByBooking.containsKey(bookingRef)) {
          ticketsByBooking[bookingRef]!.add(ticket);
        } else {
          ticketsByBooking[bookingRef] = [ticket];
        }
      }

      state = state.copyWith(
        tickets: localTickets,
        ticketsByBooking: ticketsByBooking,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur lors du chargement des tickets: $e',
      );
    }
  }

  Future<bool> generateTicketsAfterPayment(String transactionReference) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print("Début generateTicketsAfterPayment");
      // Vérifier le statut de la transaction
      final transactionStatus = await mobileMoneyService.checkTransactionStatus(
        transactionReference,
      );

      if (!transactionStatus.isSuccess) {
        throw Exception('La transaction n\'a pas pu être vérifiée');
      }

      // Générer les tickets pour chaque passager
      final newTickets = await ticketService.generateGroupTickets(
        bus: bookingState.selectedBus!,
        passengers: bookingState.passengers,
        bookingReference: bookingState.bookingReference!,
        paymentMethod: bookingState.paymentMethod!,
      );
      print("Tickets générés: ${newTickets.length}");

      // Sauvegarder les tickets localement
      await ticketLocalPersistenceService.saveTickets(newTickets);
      print("Tickets sauvegardés localement");

      // Mettre à jour l'état
      final updatedTicketsByBooking = Map<String, List<ExtendedTicket>>.from(
        state.ticketsByBooking,
      );
      updatedTicketsByBooking[bookingState.bookingReference!] = newTickets;

      state = state.copyWith(
        tickets: [...state.tickets, ...newTickets],
        ticketsByBooking: updatedTicketsByBooking,
        isLoading: false,
      );

      return true;
    } catch (e) {
      print("Erreur dans generateTicketsAfterPayment: $e");
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la génération des tickets: $e',
      );
      return false;
    }
  }

  // Obtenir les tickets pour une réservation spécifique
  Future<List<ExtendedTicket>> getTicketsForBooking(
      String bookingReference) async {
    try {
      // D'abord chercher dans l'état
      if (state.ticketsByBooking.containsKey(bookingReference)) {
        return state.ticketsByBooking[bookingReference]!;
      }

      // Sinon chercher dans le stockage local
      final tickets = await ticketLocalPersistenceService
          .getTicketsByBookingReference(bookingReference);

      // Mettre à jour l'état
      if (tickets.isNotEmpty) {
        final updatedTicketsByBooking =
            Map<String, List<ExtendedTicket>>.from(state.ticketsByBooking);
        updatedTicketsByBooking[bookingReference] = tickets;

        state = state.copyWith(
          tickets: [...state.tickets, ...tickets],
          ticketsByBooking: updatedTicketsByBooking,
        );
      }

      return tickets;
    } catch (e) {
      state = state.copyWith(
          error: 'Erreur lors de la récupération des tickets: $e');
      return [];
    }
  }

  // Obtenir les tickets à venir
  Future<List<ExtendedTicket>> getUpcomingTickets() async {
    try {
      final allTickets = await ticketLocalPersistenceService.getAllTickets();
      final now = DateTime.now();

      return allTickets
          .where((ticket) =>
              ticket.bus.departureTime.isAfter(now) &&
              ticket.status == BookingStatus.paid)
          .toList();
    } catch (e) {
      state = state.copyWith(
          error: 'Erreur lors de la récupération des tickets à venir: $e');
      return [];
    }
  }

  // Obtenir l'historique des tickets
  Future<List<ExtendedTicket>> getTicketHistory() async {
    try {
      final allTickets = await ticketLocalPersistenceService.getAllTickets();
      final now = DateTime.now();

      return allTickets
          .where((ticket) =>
              ticket.bus.departureTime.isBefore(now) ||
              ticket.status == BookingStatus.cancelled)
          .toList();
    } catch (e) {
      state = state.copyWith(
          error: 'Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }

  // Mettre à jour le statut d'un ticket
  Future<void> updateTicketStatus(String ticketId, BookingStatus status) async {
    try {
      await ticketLocalPersistenceService.updateTicketStatus(ticketId, status);
      await _loadLocalTickets(); // Recharger les tickets pour mettre à jour l'état
    } catch (e) {
      state =
          state.copyWith(error: 'Erreur lors de la mise à jour du statut: $e');
    }
  }
}

// Provider
final ticketsProvider =
    StateNotifierProvider<TicketsNotifier, TicketsState>((ref) {
  final bookingState = ref.watch(bookingProvider);
  return TicketsNotifier(bookingState);
});

/*
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../paiement/services/mobile_money_service.dart';
import '../services/ticket_service.dart';
import 'booking_provider.dart';
import 'ticket_model.dart';

class TicketsState {
  final List<ExtendedTicket> tickets;
  final bool isLoading;
  final String? error;
  final Map<String, List<ExtendedTicket>> ticketsByBooking;

  TicketsState({
    this.tickets = const [],
    this.isLoading = false,
    this.error,
    this.ticketsByBooking = const {},
  });

  TicketsState copyWith({
    List<ExtendedTicket>? tickets,
    bool? isLoading,
    String? error,
    Map<String, List<ExtendedTicket>>? ticketsByBooking,
  }) {
    return TicketsState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      ticketsByBooking: ticketsByBooking ?? this.ticketsByBooking,
    );
  }
}

class TicketsNotifier extends StateNotifier<TicketsState> {
  final BookingState bookingState;

  TicketsNotifier(this.bookingState) : super(TicketsState());

  // Générer les tickets après un paiement réussi
  Future<bool> generateTicketsAfterPayment(String transactionReference) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Vérifier le statut de la transaction
      final transactionStatus = await mobileMoneyService.checkTransactionStatus(
        transactionReference,
      );

      if (!transactionStatus.isSuccess) {
        throw Exception('La transaction n\'a pas pu être vérifiée');
      }

      // Générer les tickets pour chaque passager
      final newTickets = await ticketService.generateGroupTickets(
        bus: bookingState.selectedBus!,
        passengers: bookingState.passengers,
        bookingReference: bookingState.bookingReference!,
        paymentMethod: bookingState.paymentMethod!,
      );

      // Mettre à jour l'état
      final updatedTicketsByBooking = Map<String, List<ExtendedTicket>>.from(
        state.ticketsByBooking,
      );
      updatedTicketsByBooking[bookingState.bookingReference!] = newTickets;

      state = state.copyWith(
        tickets: [...state.tickets, ...newTickets],
        ticketsByBooking: updatedTicketsByBooking,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la génération des tickets: $e',
      );
      return false;
    }
  }

  // Charger les tickets d'un utilisateur
  Future<void> loadUserTickets(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tickets = await ticketService.getUserTickets(userId);

      // Organiser les tickets par référence de réservation
      final ticketsByBooking = <String, List<ExtendedTicket>>{};
      for (final ticket in tickets) {
        final bookingRef = ticket.bookingReference;
        ticketsByBooking[bookingRef] = [
          ...ticketsByBooking[bookingRef] ?? [],
          ticket,
        ];
      }

      state = state.copyWith(
        tickets: tickets,
        ticketsByBooking: ticketsByBooking,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement des tickets: $e',
      );
    }
  }

  // Obtenir les tickets pour une réservation spécifique
  List<ExtendedTicket> getTicketsForBooking(String bookingReference) {
    return state.ticketsByBooking[bookingReference] ?? [];
  }

  // Vérifier la validité d'un ticket
  Future<bool> validateTicket(String ticketId, String validatorId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final isValid = await ticketService.validateTicket(ticketId, validatorId);

      if (isValid) {
        // Mettre à jour le statut du ticket dans l'état
        final updatedTickets = state.tickets.map((ticket) {
          if (ticket.id == ticketId) {
            return ticket.copyWith(
              isUsed: true,
              validationDate: DateTime.now(),
              validatedBy: validatorId,
            );
          }
          return ticket;
        }).toList();

        // Mettre à jour les tickets par réservation
        final updatedTicketsByBooking = Map<String, List<ExtendedTicket>>.from(
          state.ticketsByBooking,
        );
        for (final bookingRef in updatedTicketsByBooking.keys) {
          updatedTicketsByBooking[bookingRef] =
              updatedTicketsByBooking[bookingRef]!.map((ticket) {
            if (ticket.id == ticketId) {
              return ticket.copyWith(
                isUsed: true,
                validationDate: DateTime.now(),
                validatedBy: validatorId,
              );
            }
            return ticket;
          }).toList();
        }

        state = state.copyWith(
          tickets: updatedTickets,
          ticketsByBooking: updatedTicketsByBooking,
          isLoading: false,
        );
      }

      return isValid;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la validation du ticket: $e',
      );
      return false;
    }
  }

  // Annuler un ticket
  Future<bool> cancelTicket(String ticketId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await ticketService.cancelTicket(ticketId);

      if (success) {
        // Mettre à jour l'état avec le ticket annulé
        final updatedTickets = state.tickets.map((ticket) {
          if (ticket.id == ticketId) {
            return ticket.copyWith(status: BookingStatus.cancelled);
          }
          return ticket;
        }).toList();

        // Mettre à jour les tickets par réservation
        final updatedTicketsByBooking = Map<String, List<ExtendedTicket>>.from(
          state.ticketsByBooking,
        );
        for (final bookingRef in updatedTicketsByBooking.keys) {
          updatedTicketsByBooking[bookingRef] =
              updatedTicketsByBooking[bookingRef]!.map((ticket) {
            if (ticket.id == ticketId) {
              return ticket.copyWith(status: BookingStatus.cancelled);
            }
            return ticket;
          }).toList();
        }

        state = state.copyWith(
          tickets: updatedTickets,
          ticketsByBooking: updatedTicketsByBooking,
          isLoading: false,
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de l\'annulation du ticket: $e',
      );
      return false;
    }
  }

  // Obtenir les statistiques des tickets
  Map<String, dynamic> getTicketsStats() {
    final validTickets = state.tickets.where((t) => t.isValid).length;
    final usedTickets = state.tickets.where((t) => t.isUsed ?? false).length;
    final expiredTickets = state.tickets.where((t) => t.isExpired).length;
    final cancelledTickets =
        state.tickets.where((t) => t.status == BookingStatus.cancelled).length;

    return {
      'total': state.tickets.length,
      'valid': validTickets,
      'used': usedTickets,
      'expired': expiredTickets,
      'cancelled': cancelledTickets,
    };
  }

  // Filtrer les tickets par statut
  List<ExtendedTicket> getTicketsByStatus(BookingStatus status) {
    return state.tickets.where((ticket) => ticket.status == status).toList();
  }

  // Obtenir les tickets à venir
  List<ExtendedTicket> getUpcomingTickets() {
    final now = DateTime.now();
    return state.tickets
        .where((ticket) =>
            ticket.bus.departureTime.isAfter(now) &&
            ticket.status == BookingStatus.paid)
        .toList();
  }

  // Obtenir l'historique des tickets
  List<ExtendedTicket> getTicketHistory() {
    final now = DateTime.now();
    return state.tickets
        .where((ticket) =>
            ticket.bus.departureTime.isBefore(now) ||
            ticket.status == BookingStatus.cancelled)
        .toList();
  }
}

// Provider
final ticketsProvider =
    StateNotifierProvider<TicketsNotifier, TicketsState>((ref) {
  final bookingState = ref.watch(bookingProvider);
  return TicketsNotifier(bookingState);
});
*/