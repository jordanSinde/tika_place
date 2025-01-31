// lib/features/bus_booking/providers/booking_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/models/user.dart';
import '../../home/models/bus_mock_data.dart';
import '../../notifications/services/notification_service.dart';

enum BookingStatus { pending, confirmed, paid, cancelled, failed }

enum PaymentMethod { orangeMoney, mtnMoney }

class Passenger {
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final int? cniNumber;
  final bool isMainPassenger;

  Passenger({
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.cniNumber,
    this.isMainPassenger = false,
  });
}

class BookingState {
  final Bus? selectedBus;
  final List<Passenger> passengers;
  final BookingStatus status;
  final PaymentMethod? paymentMethod;
  final String? bookingReference;
  final double? totalAmount;
  final bool isLoading;
  final String? error;

  BookingState({
    this.selectedBus,
    this.passengers = const [],
    this.status = BookingStatus.pending,
    this.paymentMethod,
    this.bookingReference,
    this.totalAmount,
    this.isLoading = false,
    this.error,
  });

  BookingState copyWith({
    Bus? selectedBus,
    List<Passenger>? passengers,
    BookingStatus? status,
    PaymentMethod? paymentMethod,
    String? bookingReference,
    double? totalAmount,
    bool? isLoading,
    String? error,
  }) {
    return BookingState(
      selectedBus: selectedBus ?? this.selectedBus,
      passengers: passengers ?? this.passengers,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bookingReference: bookingReference ?? this.bookingReference,
      totalAmount: totalAmount ?? this.totalAmount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(BookingState());

  // Simuler l'ajout d'un passager principal
  void initializeBooking(Bus bus, UserModel user) {
    final mainPassenger = Passenger(
      firstName: user.firstName,
      lastName: user.lastName ?? '',
      phoneNumber: user.phoneNumber,
      cniNumber: user.cniNumber,
      isMainPassenger: true,
    );

    state = state.copyWith(
      selectedBus: bus,
      passengers: [mainPassenger],
      totalAmount: bus.price,
    );
  }

  // Ajouter un passager supplémentaire
  void addPassenger(Passenger passenger) {
    final updatedPassengers = [...state.passengers, passenger];
    final newTotalAmount = state.selectedBus!.price * updatedPassengers.length;

    state = state.copyWith(
      passengers: updatedPassengers,
      totalAmount: newTotalAmount,
    );
  }

  // Supprimer un passager
  void removePassenger(int index) {
    if (index == 0 || index >= state.passengers.length)
      return; // Ne pas supprimer le passager principal

    final updatedPassengers = [...state.passengers];
    updatedPassengers.removeAt(index);
    final newTotalAmount = state.selectedBus!.price * updatedPassengers.length;

    state = state.copyWith(
      passengers: updatedPassengers,
      totalAmount: newTotalAmount,
    );
  }

  // Mettre à jour le mode de paiement
  void updatePaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  // Simuler un processus de paiement
  Future<bool> processPayment() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simuler un délai de traitement
      await Future.delayed(const Duration(seconds: 2));

      // Simuler une réussite avec 80% de chance
      final isSuccess = DateTime.now().millisecond % 5 != 0;

      if (isSuccess) {
        final reference = 'BK${DateTime.now().millisecondsSinceEpoch}';

        // Mettre à jour l'état avec le succès
        state = state.copyWith(
          status: BookingStatus.paid,
          bookingReference: reference,
          isLoading: false,
        );

        // Envoyer une notification de confirmation
        await notificationService.showBookingConfirmationNotification(
          title: 'Réservation confirmée !',
          body:
              'Votre réservation pour ${state.selectedBus!.departureCity} → ${state.selectedBus!.arrivalCity} a été confirmée.',
          payload: reference,
        );

        return true;
      } else {
        state = state.copyWith(
          status: BookingStatus.failed,
          error: 'La transaction a échoué. Veuillez réessayer.',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: BookingStatus.failed,
        error: 'Une erreur est survenue. Veuillez réessayer.',
        isLoading: false,
      );
      return false;
    }
  }

  // Générer les billets PDF
  Future<bool> generateBookingDocuments() async {
    try {
      // Simuler un délai pour la génération
      await Future.delayed(const Duration(seconds: 1));

      // Générer un PDF pour chaque passager
      final ticketData = {
        'reference': state.bookingReference!,
        'bus': {
          'company': state.selectedBus!.company,
          'departure': state.selectedBus!.departureCity,
          'arrival': state.selectedBus!.arrivalCity,
          'departureTime': state.selectedBus!.departureTime.toString(),
          'arrivalTime': state.selectedBus!.arrivalTime.toString(),
          'busNumber': state.selectedBus!.registrationNumber,
        },
        'passengers': state.passengers
            .map((p) => {
                  'firstName': p.firstName,
                  'lastName': p.lastName,
                  'phoneNumber': p.phoneNumber,
                  'cniNumber': p.cniNumber,
                })
            .toList(),
        'totalAmount': state.totalAmount,
        'paymentMethod': state.paymentMethod.toString(),
        'generatedAt': DateTime.now().toString(),
      };

      // Enregistrer les données du billet (simulation)
      await Future.delayed(const Duration(milliseconds: 500));

      // Envoyer le billet par email (simulation)
      await Future.delayed(const Duration(milliseconds: 500));

      // Envoyer une notification de confirmation
      await notificationService.showBookingConfirmationNotification(
        title: 'Billets générés avec succès !',
        body: 'Vos billets sont prêts. Vous pouvez les télécharger maintenant.',
        payload: state.bookingReference,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur lors de la génération des documents: $e',
      );
      return false;
    }
  }

  // Enregistrer les proches pour une utilisation future
  Future<void> savePassengersForFutureUse() async {
    try {
      final nonMainPassengers =
          state.passengers.where((p) => !p.isMainPassenger);

      // Simuler la sauvegarde des passagers dans la base de données
      await Future.delayed(const Duration(milliseconds: 500));

      // Envoyer une notification de confirmation
      await notificationService.showBookingConfirmationNotification(
        title: 'Contacts enregistrés',
        body:
            'Vos proches ont été enregistrés pour vos prochaines réservations.',
      );
    } catch (e) {
      print('Erreur lors de la sauvegarde des passagers: $e');
    }
  }

  // Vérifier la disponibilité des sièges
  Future<bool> checkSeatsAvailability() async {
    try {
      state = state.copyWith(isLoading: true);

      // Simuler une vérification de disponibilité
      await Future.delayed(const Duration(seconds: 1));

      final seatsNeeded = state.passengers.length;
      final seatsAvailable = state.selectedBus!.availableSeats;

      if (seatsAvailable >= seatsNeeded) {
        return true;
      } else {
        state = state.copyWith(
          error: 'Désolé, il ne reste que $seatsAvailable places disponibles.',
        );
        return false;
      }
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Récupérer les proches enregistrés
  Future<List<Passenger>> getSavedPassengers() async {
    // Simuler la récupération des passagers depuis la base de données
    await Future.delayed(const Duration(seconds: 1));

    // Retourner une liste fictive de passagers
    return [
      Passenger(
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+237600000000',
        cniNumber: 12345678,
      ),
      Passenger(
        firstName: 'Jane',
        lastName: 'Doe',
        phoneNumber: '+237600000001',
        cniNumber: 12345679,
      ),
    ];
  }

  // Réinitialiser l'état
  void reset() {
    state = BookingState();
  }
}

final bookingProvider =
    StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier();
});
