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

  const BusAmenities({
    this.hasAirConditioning = false,
    this.hasToilet = false,
    this.hasLunch = false,
    this.hasDrinks = false,
    this.hasWifi = false,
    this.hasUSBCharging = false,
    this.hasTv = false,
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

  bool isValid() {
    return departureTime.isBefore(arrivalTime);
  }

  factory Bus.fromJson(Map<String, dynamic> json) {
    final departureTime = DateTime.parse(json['departureTime'] as String);
    final arrivalTime = DateTime.parse(json['arrivalTime'] as String);

    if (departureTime.isAfter(arrivalTime)) {
      throw ArgumentError(
          "Le temps de départ doit être avant le temps d'arrivée");
    }

    return Bus(
      id: json['id'] as String,
      company: json['company'] as String,
      agencyLocation: json['agencyLocation'] as String,
      registrationNumber: json['registrationNumber'] as String,
      departureCity: json['departureCity'] as String,
      arrivalCity: json['arrivalCity'] as String,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      busClass: BusClass.values[json['busClass'] as int],
      price: (json['price'] as num).toDouble(),
      totalSeats: json['totalSeats'] as int,
      availableSeats: json['availableSeats'] as int,
      amenities: BusAmenities(
        hasAirConditioning: json['amenities']['hasAirConditioning'] as bool,
        hasToilet: json['amenities']['hasToilet'] as bool,
        hasLunch: json['amenities']['hasLunch'] as bool,
        hasDrinks: json['amenities']['hasDrinks'] as bool,
        hasWifi: json['amenities']['hasWifi'] as bool,
        hasUSBCharging: json['amenities']['hasUSBCharging'] as bool,
        hasTv: json['amenities']['hasTv'] as bool,
      ),
      busNumber: json['busNumber'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviews: json['reviews'] as int,
      isPopularRoute: json['isPopularRoute'] as bool? ?? false,
      nextAvailableDepartures:
          (json['nextAvailableDepartures'] as List<dynamic>?)
                  ?.map((e) => DateTime.parse(e as String))
                  .toList() ??
              [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company,
      'agencyLocation': agencyLocation,
      'registrationNumber': registrationNumber,
      'departureCity': departureCity,
      'arrivalCity': arrivalCity,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'busClass': busClass.index,
      'price': price,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'amenities': {
        'hasAirConditioning': amenities.hasAirConditioning,
        'hasToilet': amenities.hasToilet,
        'hasLunch': amenities.hasLunch,
        'hasDrinks': amenities.hasDrinks,
        'hasWifi': amenities.hasWifi,
        'hasUSBCharging': amenities.hasUSBCharging,
        'hasTv': amenities.hasTv,
      },
      'busNumber': busNumber,
      'rating': rating,
      'reviews': reviews,
      'isPopularRoute': isPopularRoute,
      'nextAvailableDepartures':
          nextAvailableDepartures.map((d) => d.toIso8601String()).toList(),
    };
  }
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
