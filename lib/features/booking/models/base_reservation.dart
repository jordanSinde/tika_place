// lib/features/common/models/reservation/base_reservation.dart

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../bus_booking/models/booking_model.dart';
import '../../bus_booking/models/promo_code.dart';
import '../../home/models/bus_mock_data.dart';

part 'base_reservation.freezed.dart';
part 'base_reservation.g.dart';

enum ReservationType { bus, hotel, apartment }

enum ReservationStatus {
  pending('En attente'),
  confirmed('Confirmée'),
  paid('Payée'),
  cancelled('Annulée'),
  expired('Expirée'),
  failed('Échec');

  final String label;
  const ReservationStatus(this.label);
}

@freezed
class BaseReservation with _$BaseReservation {
  const factory BaseReservation({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required ReservationType type,
    required ReservationStatus status,
    required double amount,
    required String userId,
    String? paymentId,
    String? cancellationReason,
    @Default(false) bool isArchived,
  }) = _BaseReservation;

  factory BaseReservation.fromJson(Map<String, dynamic> json) =>
      _$BaseReservationFromJson(json);
}

@freezed
class BusReservation with _$BusReservation {
  const factory BusReservation({
    required BaseReservation base,
    required Bus bus,
    required List<PassengerInfo> passengers,
    PromoCode? appliedPromoCode,
    double? discountAmount,
    PaymentAttempt? lastPaymentAttempt,
    List<PaymentAttempt>? paymentHistory,
  }) = _BusReservation;

  factory BusReservation.fromJson(Map<String, dynamic> json) =>
      _$BusReservationFromJson(json);
}

@freezed
class HotelReservation with _$HotelReservation {
  const factory HotelReservation({
    required BaseReservation base,
    required String hotelId,
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    String? specialRequests,
  }) = _HotelReservation;

  factory HotelReservation.fromJson(Map<String, dynamic> json) =>
      _$HotelReservationFromJson(json);
}

@freezed
class ApartmentReservation with _$ApartmentReservation {
  const factory ApartmentReservation({
    required BaseReservation base,
    required String apartmentId,
    required DateTime startDate,
    required DateTime endDate,
    required int guests,
    String? specialRequests,
  }) = _ApartmentReservation;

  factory ApartmentReservation.fromJson(Map<String, dynamic> json) =>
      _$ApartmentReservationFromJson(json);
}

// Extensions utilitaires
extension ReservationStatusUtils on ReservationStatus {
  bool get isActive =>
      this == ReservationStatus.pending || this == ReservationStatus.confirmed;

  bool get canBeCancelled => this == ReservationStatus.pending;

  bool get canRetryPayment =>
      this == ReservationStatus.pending || this == ReservationStatus.failed;

  Color get color {
    switch (this) {
      case ReservationStatus.confirmed:
      case ReservationStatus.paid:
        return AppColors.success;
      case ReservationStatus.pending:
        return AppColors.warning;
      case ReservationStatus.cancelled:
      case ReservationStatus.expired:
      case ReservationStatus.failed:
        return AppColors.error;
    }
  }
}
