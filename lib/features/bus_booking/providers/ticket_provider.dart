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
      print("🎫 TICKET PROVIDER: Beginning ticket generation process");
      // Vérifier le statut de la transaction
      final transactionStatus = await mobileMoneyService.checkTransactionStatus(
        transactionReference,
      );

      if (!transactionStatus.isSuccess) {
        print("❌ TICKET PROVIDER: Transaction verification failed");
        throw Exception('La transaction n\'a pas pu être vérifiée');
      }

      // Get booking information from provider
      //final bookingState = bookingState;
      if (bookingState.selectedBus == null || bookingState.passengers.isEmpty) {
        print("❌ TICKET PROVIDER: Missing booking data for tickets");
        throw Exception(
            'Données de réservation insuffisantes pour générer les tickets');
      }

      // Générer les tickets pour chaque passager
      print(
          "🎫 TICKET PROVIDER: Generating tickets for ${bookingState.passengers.length} passengers");
      final newTickets = await ticketService.generateGroupTickets(
        bus: bookingState.selectedBus!,
        passengers: bookingState.passengers,
        bookingReference: bookingState.bookingReference!,
        paymentMethod: bookingState.paymentMethod!,
      );
      print("✅ TICKET PROVIDER: Generated ${newTickets.length} tickets");

      // Sauvegarder les tickets localement
      await ticketLocalPersistenceService.saveTickets(newTickets);
      print("💾 TICKET PROVIDER: Tickets saved locally");

      // Verify tickets were saved
      final savedTickets = await ticketLocalPersistenceService
          .getTicketsByBookingReference(bookingState.bookingReference!);
      print("📊 TICKET PROVIDER: Found ${savedTickets.length} saved tickets");

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
      print("❌ TICKET PROVIDER: Error in generateTicketsAfterPayment: $e");
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
