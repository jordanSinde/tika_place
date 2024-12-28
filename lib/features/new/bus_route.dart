// lib/features/bus/models/bus_route.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bus_route.freezed.dart';
part 'bus_route.g.dart';

@freezed
class BusRoute with _$BusRoute {
  const factory BusRoute({
    required String id,
    required String departureCity,
    required String arrivalCity,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required double price,
    required String busType,
    required int availableSeats,
    @Default(false) bool hasAC,
    @Default(false) bool hasWifi,
    String? companyName,
    String? companyLogo,
  }) = _BusRoute;

  factory BusRoute.fromJson(Map<String, dynamic> json) =>
      _$BusRouteFromJson(json);
}
