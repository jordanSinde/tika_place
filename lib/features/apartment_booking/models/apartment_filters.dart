// lib/features/apartment_booking/models/apartment_filters.dart

import 'package:flutter/material.dart';

enum ApartmentType {
  studio('Studio'),
  apartment('Appartement'),
  house('Maison'),
  villa('Villa');

  final String label;
  const ApartmentType(this.label);
}

enum RentalDuration {
  daily('Journalier'),
  weekly('Hebdomadaire'),
  monthly('Mensuel'),
  yearly('Annuel');

  final String label;
  const RentalDuration(this.label);
}

class ApartmentAmenities {
  final bool hasWifi;
  final bool hasAirConditioning;
  final bool hasParking;
  final bool hasPool;
  final bool hasGym;
  final bool hasSecurity;
  final bool hasFurnished;
  final bool hasWaterHeater;

  const ApartmentAmenities({
    this.hasWifi = false,
    this.hasAirConditioning = false,
    this.hasParking = false,
    this.hasPool = false,
    this.hasGym = false,
    this.hasSecurity = false,
    this.hasFurnished = false,
    this.hasWaterHeater = false,
  });

  ApartmentAmenities copyWith({
    bool? hasWifi,
    bool? hasAirConditioning,
    bool? hasParking,
    bool? hasPool,
    bool? hasGym,
    bool? hasSecurity,
    bool? hasFurnished,
    bool? hasWaterHeater,
  }) {
    return ApartmentAmenities(
      hasWifi: hasWifi ?? this.hasWifi,
      hasAirConditioning: hasAirConditioning ?? this.hasAirConditioning,
      hasParking: hasParking ?? this.hasParking,
      hasPool: hasPool ?? this.hasPool,
      hasGym: hasGym ?? this.hasGym,
      hasSecurity: hasSecurity ?? this.hasSecurity,
      hasFurnished: hasFurnished ?? this.hasFurnished,
      hasWaterHeater: hasWaterHeater ?? this.hasWaterHeater,
    );
  }
}

class ApartmentSearchFilters {
  final String? city;
  final String? neighborhood;
  final ApartmentType? type;
  final RentalDuration? duration;
  final DateTime? moveInDate;
  final RangeValues? priceRange;
  final int? minBedrooms;
  final int? minBathrooms;
  final double? minSurface;
  final ApartmentAmenities? requiredAmenities;
  final bool? petsAllowed;
  final double? maxDistanceToCenter;

  const ApartmentSearchFilters({
    this.city,
    this.neighborhood,
    this.type,
    this.duration,
    this.moveInDate,
    this.priceRange,
    this.minBedrooms,
    this.minBathrooms,
    this.minSurface,
    this.requiredAmenities,
    this.petsAllowed,
    this.maxDistanceToCenter,
  });

  ApartmentSearchFilters copyWith({
    String? city,
    String? neighborhood,
    ApartmentType? type,
    RentalDuration? duration,
    DateTime? moveInDate,
    RangeValues? priceRange,
    int? minBedrooms,
    int? minBathrooms,
    double? minSurface,
    ApartmentAmenities? requiredAmenities,
    bool? petsAllowed,
    double? maxDistanceToCenter,
  }) {
    return ApartmentSearchFilters(
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      moveInDate: moveInDate ?? this.moveInDate,
      priceRange: priceRange ?? this.priceRange,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      minBathrooms: minBathrooms ?? this.minBathrooms,
      minSurface: minSurface ?? this.minSurface,
      requiredAmenities: requiredAmenities ?? this.requiredAmenities,
      petsAllowed: petsAllowed ?? this.petsAllowed,
      maxDistanceToCenter: maxDistanceToCenter ?? this.maxDistanceToCenter,
    );
  }
}
