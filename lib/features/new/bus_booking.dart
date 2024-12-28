// lib/features/bus/models/bus_booking.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'bus_booking.freezed.dart';
part 'bus_booking.g.dart';

@freezed
class BusBooking with _$BusBooking {
  const factory BusBooking({
    required String id,
    required String routeId,
    required String userId,
    required int numberOfPassengers,
    required bool hasExtraLuggage,
    required double totalAmount,
    required DateTime bookingDate,
    @Default('pending') String status,
    String? paymentId,
    String? qrCode,
  }) = _BusBooking;

  factory BusBooking.fromJson(Map<String, dynamic> json) =>
      _$BusBookingFromJson(json);
}
