import 'package:freezed_annotation/freezed_annotation.dart';
// lib/features/apartments/models/apartment.dart
part 'apartment.freezed.dart';
part 'apartment.g.dart';

@freezed
class Apartment with _$Apartment {
  const factory Apartment({
    required String id,
    required String title,
    required String description,
    required double monthlyPrice,
    required String city,
    required String district,
    required List<String> images,
    required int numberOfRooms,
    required double surfaceArea,
    required bool isFurnished,
    required List<String> amenities,
    @Default([]) List<String> nearbyFacilities,
    String? ownerId,
    String? ownerName,
    String? ownerPhone,
    @Default(true) bool isAvailable,
  }) = _Apartment;

  factory Apartment.fromJson(Map<String, dynamic> json) =>
      _$ApartmentFromJson(json);
}
