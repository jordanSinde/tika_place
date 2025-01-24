// lib/features/home/models/bus_mock_data.dart
// lib/features/bus_booking/models/bus_models.dart

import 'package:flutter/material.dart';

enum BusClass { standard, vip, luxe }

extension BusClassExtension on BusClass {
  String get label {
    switch (this) {
      case BusClass.standard:
        return 'Standard';
      case BusClass.vip:
        return 'VIP';
      case BusClass.luxe:
        return 'Luxe';
    }
  }
}

class BusAmenities {
  final bool hasAirConditioning;
  final bool hasToilet;
  final bool hasLunch;
  final bool hasDrinks;
  final bool hasWifi;
  final bool hasUSBCharging;
  final bool hasTv;
  final bool hasLuggageSpace;

  const BusAmenities({
    this.hasAirConditioning = false,
    this.hasToilet = false,
    this.hasLunch = false,
    this.hasDrinks = false,
    this.hasWifi = false,
    this.hasUSBCharging = false,
    this.hasTv = false,
    this.hasLuggageSpace = true,
  });
}

class Bus {
  final String id;
  final String company;
  final String agencyLocation;
  final String registrationNumber;
  final String departureCity;
  final String arrivalCity;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final BusClass busClass;
  final double price;
  final int totalSeats;
  final int availableSeats;
  final BusAmenities amenities;
  final String busNumber;
  final double rating;
  final int reviews;
  final bool isPopularRoute;
  final List<DateTime> nextAvailableDepartures;

  const Bus({
    required this.id,
    required this.company,
    required this.agencyLocation,
    required this.registrationNumber,
    required this.departureCity,
    required this.arrivalCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.busClass,
    required this.price,
    required this.totalSeats,
    required this.availableSeats,
    required this.amenities,
    required this.busNumber,
    required this.rating,
    required this.reviews,
    this.isPopularRoute = false,
    this.nextAvailableDepartures = const [],
  });
}

class BusSearchFilters {
  final String? departureCity;
  final String? arrivalCity;
  final DateTime? departureDate;
  final TimeOfDay? departureTime;
  final BusClass? busClass;
  final RangeValues? priceRange;
  final BusAmenities? requiredAmenities;
  final String? company;

  const BusSearchFilters({
    this.departureCity,
    this.arrivalCity,
    this.departureDate,
    this.departureTime,
    this.busClass,
    this.priceRange,
    this.requiredAmenities,
    this.company,
  });

  BusSearchFilters copyWith({
    String? departureCity,
    String? arrivalCity,
    DateTime? departureDate,
    TimeOfDay? departureTime,
    BusClass? busClass,
    RangeValues? priceRange,
    BusAmenities? requiredAmenities,
    String? company,
  }) {
    return BusSearchFilters(
      departureCity: departureCity ?? this.departureCity,
      arrivalCity: arrivalCity ?? this.arrivalCity,
      departureDate: departureDate ?? this.departureDate,
      departureTime: departureTime ?? this.departureTime,
      busClass: busClass ?? this.busClass,
      priceRange: priceRange ?? this.priceRange,
      requiredAmenities: requiredAmenities ?? this.requiredAmenities,
      company: company ?? this.company,
    );
  }
}

class Ticket {
  final String id;
  final Bus bus;
  final String passengerName;
  final String phoneNumber;
  final DateTime purchaseDate;
  final double totalPrice;

  const Ticket({
    required this.id,
    required this.bus,
    required this.passengerName,
    required this.phoneNumber,
    required this.purchaseDate,
    required this.totalPrice,
  });
}
