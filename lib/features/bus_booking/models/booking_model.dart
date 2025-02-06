// lib/features/bus_booking/models/booking_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../home/models/bus_mock_data.dart';
import '../providers/booking_provider.dart';
import 'promo_code.dart';

part 'booking_model.freezed.dart';
part 'booking_model.g.dart';

@freezed
class TicketReservation with _$TicketReservation {
  const factory TicketReservation({
    required String id,
    required Bus bus,
    required List<PassengerInfo> passengers,
    required BookingStatus status,
    required double totalAmount,
    required DateTime createdAt,
    required DateTime expiresAt,
    required String userId,
    PromoCode? appliedPromoCode,
    double? discountAmount,
    PaymentAttempt? lastPaymentAttempt,
    List<PaymentAttempt>? paymentHistory,
    String? cancellationReason,
    @Default(false) bool isArchived,
  }) = _TicketReservation;

  factory TicketReservation.fromJson(Map<String, dynamic> json) =>
      _$TicketReservationFromJson(json);
}

@freezed
class PassengerInfo with _$PassengerInfo {
  const factory PassengerInfo({
    required String firstName,
    required String lastName,
    required String? phoneNumber,
    required int? cniNumber,
    required bool isMainPassenger,
    String? seatNumber,
  }) = _PassengerInfo;

  factory PassengerInfo.fromJson(Map<String, dynamic> json) =>
      _$PassengerInfoFromJson(json);
}

@freezed
class PaymentAttempt with _$PaymentAttempt {
  const factory PaymentAttempt({
    required DateTime timestamp,
    required String paymentMethod,
    required String status,
    String? errorMessage,
    String? transactionId,
    double? amountPaid,
  }) = _PaymentAttempt;

  factory PaymentAttempt.fromJson(Map<String, dynamic> json) =>
      _$PaymentAttemptFromJson(json);
}

// Extension pour les méthodes utilitaires
extension ReservationUtils on TicketReservation {
  bool get isActive =>
      status == BookingStatus.pending || status == BookingStatus.confirmed;

  bool get canBeCancelled =>
      status == BookingStatus.pending && DateTime.now().isBefore(expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get canRetryPayment =>
      status == BookingStatus.pending || status == BookingStatus.failed;

  int get totalPassengers => passengers.length;

  double get actualDiscountAmount => discountAmount ?? 0.0;

  double get finalAmount => totalAmount - actualDiscountAmount;

  bool get hasMainPassenger => passengers.any((p) => p.isMainPassenger);

  List<PaymentAttempt> get allPaymentAttempts =>
      paymentHistory ??
      (lastPaymentAttempt != null ? [lastPaymentAttempt!] : []);

  int get remainingPaymentAttempts {
    final today = DateTime.now();
    final attemptsToday = allPaymentAttempts.where((attempt) {
      return attempt.timestamp.year == today.year &&
          attempt.timestamp.month == today.month &&
          attempt.timestamp.day == today.day;
    }).length;

    return 3 - attemptsToday; // Maximum 3 tentatives par jour
  }

  Duration get timeUntilExpiration {
    if (isExpired) return Duration.zero;
    return expiresAt.difference(DateTime.now());
  }

  String get statusText {
    switch (status) {
      case BookingStatus.pending:
        return 'En attente de paiement';
      case BookingStatus.confirmed:
        return 'Confirmée';
      case BookingStatus.paid:
        return 'Payée';
      case BookingStatus.cancelled:
        return 'Annulée';
      case BookingStatus.expired:
        return 'Expirée';
      case BookingStatus.failed:
        return 'Échec de paiement';
    }
  }

  String get formattedTimeUntilExpiration {
    final duration = timeUntilExpiration;
    if (duration.isNegative) return 'Expirée';

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
