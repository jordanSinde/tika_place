// lib/features/bus_booking/providers/ticket_provider.dart

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/booking_provider.dart';
import '../providers/ticket_model.dart';
import '../services/ticket_local_persistence_service.dart';
import '../services/ticket_service.dart';

class TicketsState {
  final List<ExtendedTicket> tickets;
  final bool isLoading;
  final String? error;
  final Map<String, List<ExtendedTicket>> ticketsByBooking;

  const TicketsState({
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

  TicketsNotifier(this.bookingState) : super(const TicketsState()) {
    _loadLocalTickets();
  }

  Future<void> loadUserTickets(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print("Chargement des tickets pour l'utilisateur: $userId");
      final tickets = await ticketLocalPersistenceService.getAllTickets();
      final ticketsByBooking = <String, List<ExtendedTicket>>{};

      // Organiser les tickets par référence de réservation
      for (final ticket in tickets) {
        final ref = ticket.bookingReference;
        if (ticketsByBooking.containsKey(ref)) {
          ticketsByBooking[ref]!.add(ticket);
        } else {
          ticketsByBooking[ref] = [ticket];
        }
      }

      state = state.copyWith(
        tickets: tickets,
        ticketsByBooking: ticketsByBooking,
        isLoading: false,
      );
      print("Tickets chargés avec succès: ${tickets.length}");
    } catch (e) {
      print("Erreur lors du chargement des tickets: $e");
      state = state.copyWith(
        error: 'Erreur lors du chargement des tickets: $e',
        isLoading: false,
      );
    }
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
      if (state.ticketsByBooking.containsKey(bookingReference)) {
        return state.ticketsByBooking[bookingReference]!;
      }

      final tickets = await ticketLocalPersistenceService
          .getTicketsByBookingReference(bookingReference);

      if (tickets.isNotEmpty) {
        final updatedTicketsByBooking = Map<String, List<ExtendedTicket>>.from(
          state.ticketsByBooking,
        );
        updatedTicketsByBooking[bookingReference] = tickets;

        state = state.copyWith(
          tickets: [...state.tickets, ...tickets],
          ticketsByBooking: updatedTicketsByBooking,
        );
      }

      return tickets;
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur lors de la récupération des tickets: $e',
      );
      return [];
    }
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
