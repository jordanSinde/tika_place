// lib/features/bus_booking/services/validation_service.dart

import '../models/booking_model.dart';
import '../providers/booking_provider.dart';

class ValidationService {
  static final ValidationService _instance = ValidationService._internal();

  factory ValidationService() {
    return _instance;
  }

  ValidationService._internal();

  // Validation des données de réservation
  bool validateReservationData(TicketReservation reservation) {
    if (reservation.passengers.isEmpty) return false;
    if (reservation.totalAmount <= 0) return false;
    if (reservation.userId.isEmpty) return false;

    // Validation des passagers
    for (var passenger in reservation.passengers) {
      if (!_validatePassengerData(passenger)) return false;
    }

    return true;
  }

  // Validation des données passager
  bool _validatePassengerData(PassengerInfo passenger) {
    if (passenger.firstName.isEmpty) return false;
    if (passenger.lastName.isEmpty) return false;

    // Valider le numéro de téléphone si présent
    if (passenger.phoneNumber != null &&
        !_isValidPhoneNumber(passenger.phoneNumber!)) {
      return false;
    }

    // Valider le CNI si présent
    if (passenger.cniNumber != null && passenger.cniNumber! <= 0) {
      return false;
    }

    return true;
  }

  // Validation du numéro de téléphone
  bool _isValidPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length == 9 &&
        (cleanPhone.startsWith('6') || cleanPhone.startsWith('2'));
  }

  // Validation de la méthode de paiement
  bool validatePaymentMethod(PaymentMethod method, String phoneNumber) {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    switch (method) {
      case PaymentMethod.orangeMoney:
        return cleanPhone.startsWith('6') &&
            !cleanPhone.startsWith('65') &&
            cleanPhone.length == 9;

      case PaymentMethod.mtnMoney:
        return cleanPhone.startsWith('65') && cleanPhone.length == 9;
    }
  }

  // Validation du code de paiement
  bool validatePaymentCode(String code, PaymentMethod method) {
    if (code.isEmpty) return false;

    switch (method) {
      case PaymentMethod.orangeMoney:
        return RegExp(r'^\d{6}$').hasMatch(code);

      case PaymentMethod.mtnMoney:
        return RegExp(r'^\d{5}$').hasMatch(code);
    }
  }

  // Validation des montants
  bool validateAmount(double amount, {double? minAmount, double? maxAmount}) {
    if (amount <= 0) return false;

    if (minAmount != null && amount < minAmount) return false;
    if (maxAmount != null && amount > maxAmount) return false;

    return true;
  }

  // Validation du timing
  bool validateTiming(DateTime reservationTime, DateTime departureTime) {
    final now = DateTime.now();

    // La réservation ne peut pas être dans le passé
    if (reservationTime.isBefore(now)) return false;

    // Le départ doit être au moins 30 minutes après la réservation
    final minDepartureTime = reservationTime.add(const Duration(minutes: 30));
    if (departureTime.isBefore(minDepartureTime)) return false;

    return true;
  }

  // Validation des doublons
  Future<bool> validateNoDuplicates(
    String userId,
    String busId,
    List<TicketReservation> existingReservations,
  ) async {
    return !existingReservations.any((reservation) =>
        reservation.userId == userId &&
        reservation.bus.id == busId &&
        reservation.status == BookingStatus.pending &&
        !reservation.isExpired);
  }

  // Génération de messages d'erreur
  String getValidationErrorMessage(String field, String value) {
    switch (field) {
      case 'phoneNumber':
        return 'Le numéro de téléphone $value n\'est pas valide';
      case 'paymentCode':
        return 'Le code de paiement doit contenir uniquement des chiffres';
      case 'amount':
        return 'Le montant $value n\'est pas valide';
      case 'timing':
        return 'L\'horaire sélectionné n\'est pas valide';
      case 'duplicate':
        return 'Une réservation existe déjà pour ce voyage';
      default:
        return 'Données non valides';
    }
  }
}

// Instance singleton
final validationService = ValidationService();
