import 'package:flutter/material.dart';

import 'hotel_review.dart';

enum RoomType {
  single('Chambre Simple'),
  double('Chambre Double'),
  twin('Chambre Twin'),
  deluxe('Chambre Deluxe'),
  suite('Suite'),
  family('Chambre Familiale');

  final String label;
  const RoomType(this.label);
}

class HotelAmenities {
  final bool hasWifi;
  final bool hasPool;
  final bool hasRestaurant;
  final bool hasFitnessCenter;
  final bool hasSpa;
  final bool hasRoomService;
  final bool hasAirConditioning;
  final bool hasParking;
  final bool hasConferenceRoom;
  final bool hasChildrenActivities;
  final bool hasBusiness;
  final bool hasAccessibility;

  const HotelAmenities({
    this.hasWifi = false,
    this.hasPool = false,
    this.hasRestaurant = false,
    this.hasFitnessCenter = false,
    this.hasSpa = false,
    this.hasRoomService = false,
    this.hasAirConditioning = false,
    this.hasParking = false,
    this.hasConferenceRoom = false,
    this.hasChildrenActivities = false,
    this.hasBusiness = false,
    this.hasAccessibility = false,
  });
}

class RoomAmenities {
  final bool hasWifi;
  final bool hasTV;
  final bool hasMinibar;
  final bool hasSafe;
  final bool hasPrivateBathroom;
  final bool hasAirConditioning;
  final bool hasBalcony;
  final bool hasSeaView;
  final bool hasCityView;
  final bool hasWorkDesk;

  const RoomAmenities({
    this.hasWifi = false,
    this.hasTV = false,
    this.hasMinibar = false,
    this.hasSafe = false,
    this.hasPrivateBathroom = false,
    this.hasAirConditioning = false,
    this.hasBalcony = false,
    this.hasSeaView = false,
    this.hasCityView = false,
    this.hasWorkDesk = false,
  });
}

class HotelRoom {
  final String id;
  final String name;
  final String description;
  final RoomType type;
  final double pricePerNight;
  final int maxAdults;
  final int maxChildren;
  final int roomSize; // en mètres carrés
  final RoomAmenities amenities;
  final List<String> images;
  final List<UnavailablePeriod> unavailablePeriods;
  final int availableRooms; // Nombre de chambres de ce type disponibles
  final bool refundable;
  final String bedType; // Ex: "1 grand lit" ou "2 lits simples"
  final String cancellationPolicy;

  const HotelRoom({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.pricePerNight,
    required this.maxAdults,
    required this.maxChildren,
    required this.roomSize,
    required this.amenities,
    required this.images,
    required this.unavailablePeriods,
    required this.availableRooms,
    required this.refundable,
    required this.bedType,
    required this.cancellationPolicy,
  });

  // Méthode pour vérifier si la chambre est disponible pour une période donnée
  bool isAvailableForPeriod(
      DateTime startDate, DateTime endDate, int roomsNeeded) {
    // Vérifier si la période demandée chevauche une période d'indisponibilité
    for (var period in unavailablePeriods) {
      if (period.overlapsWith(startDate, endDate)) {
        return period.availableRooms >= roomsNeeded;
      }
    }

    return availableRooms >= roomsNeeded;
  }

  // Méthode pour calculer le prix total pour une période donnée
  double calculateTotalPrice(DateTime startDate, DateTime endDate) {
    final nights = endDate.difference(startDate).inDays;
    return pricePerNight * nights;
  }
}

class Hotel {
  final String id;
  final String name;
  final String description;
  final String country;
  final String city;
  final String address;
  final double rating;
  final int starsCount; // 1 à 5 étoiles
  final List<HotelReview> reviews;
  final List<String> images;
  final HotelAmenities amenities;
  final List<HotelRoom> rooms;
  final String checkInTime; // Ex: "14:00"
  final String checkOutTime; // Ex: "11:00"
  final List<String> houseRules;
  final double latitude;
  final double longitude;

  const Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.country,
    required this.city,
    required this.address,
    required this.rating,
    required this.starsCount,
    required this.reviews,
    required this.images,
    required this.amenities,
    required this.rooms,
    required this.checkInTime,
    required this.checkOutTime,
    required this.houseRules,
    required this.latitude,
    required this.longitude,
  });

  // Récupérer les chambres disponibles selon les critères
  List<HotelRoom> getAvailableRooms(DateTime startDate, DateTime endDate,
      int adults, int children, int roomsNeeded) {
    return rooms.where((room) {
      // Vérifier si la chambre peut accueillir le nombre de personnes
      bool canAccommodate = room.maxAdults >= (adults / roomsNeeded).ceil() &&
          room.maxChildren >= (children / roomsNeeded).ceil();

      // Vérifier la disponibilité
      bool isAvailable =
          room.isAvailableForPeriod(startDate, endDate, roomsNeeded);

      return canAccommodate && isAvailable;
    }).toList();
  }
}

class UnavailablePeriod {
  final DateTime startDate;
  final DateTime endDate;
  final int
      availableRooms; // Pour gérer l'inventaire partagé avec d'autres plateformes

  const UnavailablePeriod({
    required this.startDate,
    required this.endDate,
    this.availableRooms = 0,
  });

  // Vérifie si une période donnée chevauche cette période d'indisponibilité
  bool overlapsWith(DateTime checkStart, DateTime checkEnd) {
    return (checkStart.isBefore(endDate) ||
            checkStart.isAtSameMomentAs(endDate)) &&
        (checkEnd.isAfter(startDate) || checkEnd.isAtSameMomentAs(startDate));
  }
}

class HotelSearchFilters {
  final String? country;
  final String? city;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int adults;
  final int children;
  final int rooms;
  final RangeValues? priceRange;
  final int? minStars;
  final double? minRating;
  final HotelAmenities? requiredAmenities;
  final RoomAmenities? requiredRoomAmenities;

  const HotelSearchFilters({
    this.country,
    this.city,
    this.checkInDate,
    this.checkOutDate,
    this.adults = 1,
    this.children = 0,
    this.rooms = 1,
    this.priceRange,
    this.minStars,
    this.minRating,
    this.requiredAmenities,
    this.requiredRoomAmenities,
  });

  HotelSearchFilters copyWith({
    String? country,
    String? city,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? adults,
    int? children,
    int? rooms,
    RangeValues? priceRange,
    int? minStars,
    double? minRating,
    HotelAmenities? requiredAmenities,
    RoomAmenities? requiredRoomAmenities,
  }) {
    return HotelSearchFilters(
      country: country ?? this.country,
      city: city ?? this.city,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      rooms: rooms ?? this.rooms,
      priceRange: priceRange ?? this.priceRange,
      minStars: minStars ?? this.minStars,
      minRating: minRating ?? this.minRating,
      requiredAmenities: requiredAmenities ?? this.requiredAmenities,
      requiredRoomAmenities:
          requiredRoomAmenities ?? this.requiredRoomAmenities,
    );
  }
}
