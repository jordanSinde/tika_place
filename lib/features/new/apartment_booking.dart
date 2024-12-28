import 'package:freezed_annotation/freezed_annotation.dart';
part 'apartment_booking.freezed.dart';
part 'apartment_booking.g.dart';

@freezed
class ApartmentBooking with _$ApartmentBooking {
  const factory ApartmentBooking({
    required String id,
    required String apartmentId,
    required String userId,
    required DateTime startDate,
    required int durationInMonths,
    required double monthlyRent,
    required double deposit,
    required double totalAmount,
    @Default('pending') String status,
    String? paymentId,
    String? contractUrl,
    Map<String, dynamic>? tenantInfo,
  }) = _ApartmentBooking;

  factory ApartmentBooking.fromJson(Map<String, dynamic> json) =>
      _$ApartmentBookingFromJson(json);
}
