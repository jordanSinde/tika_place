// lib/features/bus_booking/models/ticket_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../home/models/bus_and_utility_models.dart';
import '../providers/booking_provider.dart';

part 'ticket_model.freezed.dart';
part 'ticket_model.g.dart';

@freezed
class ExtendedTicket with _$ExtendedTicket {
  const factory ExtendedTicket({
    required String id,
    required Bus bus,
    required String passengerName,
    required String phoneNumber,
    required DateTime purchaseDate,
    required double totalPrice,
    required String seatNumber,
    required String qrCode,
    required String bookingReference,
    required PaymentMethod paymentMethod,
    required BookingStatus status,
    String? cniNumber,
    // Informations supplémentaires pour la gestion
    DateTime? validationDate,
    String? validatedBy,
    bool? isUsed,
    String? transactionId,
  }) = _ExtendedTicket;

  factory ExtendedTicket.fromJson(Map<String, dynamic> json) =>
      _$ExtendedTicketFromJson(json);

  factory ExtendedTicket.fromTicket(
    Ticket ticket, {
    required String seatNumber,
    required String qrCode,
    required String bookingReference,
    required PaymentMethod paymentMethod,
    required BookingStatus status,
    String? cniNumber,
  }) {
    return ExtendedTicket(
      id: ticket.id,
      bus: ticket.bus,
      passengerName: ticket.passengerName,
      phoneNumber: ticket.phoneNumber,
      purchaseDate: ticket.purchaseDate,
      totalPrice: ticket.totalPrice,
      seatNumber: seatNumber,
      qrCode: qrCode,
      bookingReference: bookingReference,
      paymentMethod: paymentMethod,
      status: status,
      cniNumber: cniNumber,
    );
  }
}

// Enum pour le statut de validation du billet
enum TicketValidationStatus { pending, validated, used, expired, cancelled }

// Extension pour les méthodes utilitaires du ticket
extension TicketUtils on ExtendedTicket {
  bool get isValid {
    final now = DateTime.now();
    return bus.departureTime.isAfter(now) && status == BookingStatus.paid;
  }

  bool get isExpired {
    final now = DateTime.now();
    return bus.departureTime.isBefore(now);
  }

  bool get canBeRefunded {
    final now = DateTime.now();
    final refundDeadline =
        bus.departureTime.subtract(const Duration(hours: 24));
    return now.isBefore(refundDeadline) &&
        !isUsed! &&
        status == BookingStatus.paid;
  }

  String get formattedSeatNumber {
    return 'Siège $seatNumber';
  }
}
