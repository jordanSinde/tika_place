// lib/features/apartment/models/apartment_mock_data.dart

import 'package:flutter/material.dart';

enum ApartmentClass {
  economique('Économique'),
  standard('Standard'),
  premium('Premium'),
  luxe('Luxe');

  final String label;
  const ApartmentClass(this.label);
}

enum RentalType {
  shortTerm('Court séjour'),
  longTerm('Long séjour');

  final String label;
  const RentalType(this.label);
}

class ApartmentAmenities {
  final bool hasWifi;
  final bool hasAirConditioning;
  final bool hasParking;
  final bool hasSecurity;
  final bool hasPool;
  final bool hasGym;
  final bool hasBalcony;
  final bool hasFurnished;
  final bool hasWaterHeater;
  final bool hasGenerator;
  final bool hasServiceRoom;
  final bool hasGarden;

  const ApartmentAmenities({
    this.hasWifi = false,
    this.hasAirConditioning = false,
    this.hasParking = false,
    this.hasSecurity = false,
    this.hasPool = false,
    this.hasGym = false,
    this.hasBalcony = false,
    this.hasFurnished = false,
    this.hasWaterHeater = false,
    this.hasGenerator = false,
    this.hasServiceRoom = false,
    this.hasGarden = false,
  });

  ApartmentAmenities copyWith({
    bool? hasWifi,
    bool? hasAirConditioning,
    bool? hasParking,
    bool? hasSecurity,
    bool? hasPool,
    bool? hasGym,
    bool? hasBalcony,
    bool? hasFurnished,
    bool? hasWaterHeater,
    bool? hasGenerator,
    bool? hasServiceRoom,
    bool? hasGarden,
  }) {
    return ApartmentAmenities(
      hasWifi: hasWifi ?? this.hasWifi,
      hasAirConditioning: hasAirConditioning ?? this.hasAirConditioning,
      hasParking: hasParking ?? this.hasParking,
      hasSecurity: hasSecurity ?? this.hasSecurity,
      hasPool: hasPool ?? this.hasPool,
      hasGym: hasGym ?? this.hasGym,
      hasBalcony: hasBalcony ?? this.hasBalcony,
      hasFurnished: hasFurnished ?? this.hasFurnished,
      hasWaterHeater: hasWaterHeater ?? this.hasWaterHeater,
      hasGenerator: hasGenerator ?? this.hasGenerator,
      hasServiceRoom: hasServiceRoom ?? this.hasServiceRoom,
      hasGarden: hasGarden ?? this.hasGarden,
    );
  }
}

class Apartment {
  final String id;
  final String title;
  final String description;
  final String city;
  final String district; // quartier
  final String address;
  final double price;
  final double surface;
  final int bedrooms;
  final int bathrooms;
  final ApartmentClass apartmentClass;
  final RentalType rentalType;
  final ApartmentAmenities amenities;
  final List<String> images;
  final double rating;
  final int reviews;
  final String ownerName;
  final String ownerAvatar;
  final String ownerPhone;
  final bool isAvailable;
  final DateTime availableFrom;
  final List<DateTime> unavailableDates;

  const Apartment({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.district,
    required this.address,
    required this.price,
    required this.surface,
    required this.bedrooms,
    required this.bathrooms,
    required this.apartmentClass,
    required this.rentalType,
    required this.amenities,
    required this.images,
    required this.rating,
    required this.reviews,
    required this.ownerName,
    required this.ownerAvatar,
    required this.ownerPhone,
    required this.isAvailable,
    required this.availableFrom,
    required this.unavailableDates,
  });
}

class ApartmentSearchFilters {
  final String? city;
  final String? district;
  final RentalType? rentalType;
  final ApartmentClass? apartmentClass;
  final RangeValues? priceRange;
  final double? minSurface;
  final int? minBedrooms;
  final int? minBathrooms;
  final ApartmentAmenities? requiredAmenities;
  final DateTime? availableFrom;
  final DateTime? availableTo;

  const ApartmentSearchFilters({
    this.city,
    this.district,
    this.rentalType,
    this.apartmentClass,
    this.priceRange,
    this.minSurface,
    this.minBedrooms,
    this.minBathrooms,
    this.requiredAmenities,
    this.availableFrom,
    this.availableTo,
  });

  ApartmentSearchFilters copyWith({
    String? city,
    String? district,
    RentalType? rentalType,
    ApartmentClass? apartmentClass,
    RangeValues? priceRange,
    double? minSurface,
    int? minBedrooms,
    int? minBathrooms,
    ApartmentAmenities? requiredAmenities,
    DateTime? availableFrom,
    DateTime? availableTo,
  }) {
    return ApartmentSearchFilters(
      city: city ?? this.city,
      district: district ?? this.district,
      rentalType: rentalType ?? this.rentalType,
      apartmentClass: apartmentClass ?? this.apartmentClass,
      priceRange: priceRange ?? this.priceRange,
      minSurface: minSurface ?? this.minSurface,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      minBathrooms: minBathrooms ?? this.minBathrooms,
      requiredAmenities: requiredAmenities ?? this.requiredAmenities,
      availableFrom: availableFrom ?? this.availableFrom,
      availableTo: availableTo ?? this.availableTo,
    );
  }
}

// Données géographiques
final Map<String, Map<String, List<String>>> cityData = {
  'Douala': {
    'Luxe': ['Bonanjo', 'Bonapriso', 'Akwa I', 'Bonamoussadi', 'Makepe'],
    'Standard': ['Akwa Nord', 'Bessengue', 'Deido', 'Bali', 'New-Bell'],
    'Economique': ['Village', 'Bonaberi', 'Ndokoti', 'PK14', 'Nylon'],
  },
  'Yaoundé': {
    'Luxe': ['Bastos', 'Golf', 'Quartier du Lac', 'Santa Barbara'],
    'Standard': ['Mvog-Mbi', 'Essos', 'Mvan', 'Ngousso', 'Ekounou'],
    'Economique': ['Mimboman', 'Nkolbisson', 'Etoudi', 'Nkoldongo'],
  },
  'Kribi': {
    'Luxe': ['Centre Ville', 'Mpangou'],
    'Standard': ['Quartier Administration', 'Petit-Paris'],
    'Economique': ['Dombé', 'Ngoye'],
  },
  // Ajoutez d'autres villes selon vos besoins
};

// Prix de base par m² selon la ville et la catégorie
final Map<String, Map<String, double>> basePricePerM2 = {
  'Douala': {
    'Luxe': 15000.0,
    'Standard': 8000.0,
    'Economique': 5000.0,
  },
  'Yaoundé': {
    'Luxe': 13000.0,
    'Standard': 7000.0,
    'Economique': 4500.0,
  },
  'Kribi': {
    'Luxe': 10000.0,
    'Standard': 6000.0,
    'Economique': 4000.0,
  },
};

final Map<String, List<String>> categoryImages = {
  'Luxe': [
    'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=800&h=600',
    'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?auto=format&fit=crop&w=800&h=600',
    'https://images.unsplash.com/photo-1574362848149-11496d93a7c7?auto=format&fit=crop&w=800&h=600',
    'https://images.unsplash.com/photo-1502005229762-cf1b2da7c5d6?auto=format&fit=crop&w=800&h=600',
  ],
  'Standard': [
    'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=800&h=600',
    'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=800&h=600',
    'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=800&h=600',
    'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=800&h=600',
  ],
  'Economique': [
    'https://images.unsplash.com/photo-1630699144867-37acec97df5a?auto=format&fit=crop&w=800&h=600',
    'https://images.unsplash.com/photo-1554995207-c18c203602cb?auto=format&fit=crop&w=800&h=600',
    'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?auto=format&fit=crop&w=800&h=600',
    'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=800&h=600',
  ],
};

final List<String> ownerAvatars = [
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&h=100',
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&h=100',
  'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=100&h=100',
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=100&h=100',
  'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?auto=format&fit=crop&w=100&h=100',
  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=100&h=100',
  'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?auto=format&fit=crop&w=100&h=100',
  'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=100&h=100',
  'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=100&h=100',
  'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=100&h=100',
];

// Générateur de données mockées
List<Apartment> generateMockApartments() {
  final List<Apartment> apartments = [];
  final random = DateTime.now().millisecondsSinceEpoch;

  for (final city in cityData.keys) {
    for (final category in cityData[city]!.keys) {
      for (final district in cityData[city]![category]!) {
        // Génère plusieurs appartements par district
        for (var i = 0; i < 3; i++) {
          final isLuxury = category == 'Luxe';
          final isStandard = category == 'Standard';

          final apartmentClass = isLuxury
              ? ApartmentClass.luxe
              : isStandard
                  ? ApartmentClass.standard
                  : ApartmentClass.economique;

          final surface = isLuxury
              ? 120.0 + (random % 100)
              : isStandard
                  ? 80.0 + (random % 40)
                  : 50.0 + (random % 30);

          final basePrice = basePricePerM2[city]![category]! * surface;
          final priceVariation = 0.9 + (random % 20) / 100;
          final price = basePrice * priceVariation;

          final int bedrooms = isLuxury
              ? 3 + (random % 2)
              : isStandard
                  ? 2 + (random % 2)
                  : 1 + (random % 2);

          apartments.add(Apartment(
            id: 'APT-${city.substring(0, 3)}-${district.substring(0, 3)}-${random.toString().substring(0, 4)}',
            title: 'Appartement ${bedrooms}Ch - $district',
            description:
                'Magnifique appartement situé dans un quartier prisé...',
            city: city,
            district: district,
            address: '${random % 100} Rue $district',
            price: price,
            surface: surface,
            bedrooms: bedrooms,
            bathrooms: isLuxury
                ? 2 + (random % 2)
                : isStandard
                    ? 2
                    : 1,
            apartmentClass: apartmentClass,
            rentalType:
                (random % 3 == 0) ? RentalType.shortTerm : RentalType.longTerm,
            amenities: ApartmentAmenities(
              hasWifi: isLuxury || isStandard,
              hasAirConditioning: isLuxury || isStandard,
              hasParking: isLuxury,
              hasSecurity: isLuxury || isStandard,
              hasPool: isLuxury && (random % 3 == 0),
              hasGym: isLuxury && (random % 4 == 0),
              hasBalcony: isLuxury || (isStandard && random % 2 == 0),
              hasFurnished: true,
              hasWaterHeater: isLuxury || isStandard,
              hasGenerator: isLuxury,
              hasServiceRoom: isLuxury,
              hasGarden: isLuxury && (random % 2 == 0),
            ),
            images: categoryImages[category]!,
            rating: 4.0 + (random % 10) / 10,
            reviews: 10 + (random % 90),
            ownerName: 'Propriétaire ${random % 100}',
            ownerAvatar: ownerAvatars[random % ownerAvatars.length],
            ownerPhone: '+237 6${random.toString().substring(0, 8)}',
            isAvailable: true,
            availableFrom: DateTime.now().add(Duration(days: random % 30)),
            unavailableDates: [],
          ));
        }
      }
    }
  }

  return apartments;
}
