// lib/features/apartment/models/apartment_mock_data.dart
// Mise à jour de apartment_mock_data.dart

import 'dart:math';

import 'package:flutter/material.dart';

enum ApartmentClass {
  economique('Économique'),
  standard('Standard'),
  premium('Premium'),
  luxe('Luxe');

  final String label;
  const ApartmentClass(this.label);
}

// Suppression de l'enum RentalType car nous n'aurons plus de distinction entre court et long séjour

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

// Ajout d'une classe pour représenter les avis/commentaires
class ApartmentReview {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;

  const ApartmentReview({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

// Ajout d'une classe pour représenter les périodes d'indisponibilité
class UnavailablePeriod {
  final DateTime startDate;
  final DateTime endDate;
  final String reason; // Optionnel: réservé, maintenance, etc.

  const UnavailablePeriod({
    required this.startDate,
    required this.endDate,
    this.reason = 'Réservé',
  });

  // Vérifie si une période donnée chevauche cette période d'indisponibilité
  bool overlapsWith(DateTime checkStart, DateTime checkEnd) {
    return (checkStart.isBefore(endDate) ||
            checkStart.isAtSameMomentAs(endDate)) &&
        (checkEnd.isAfter(startDate) || checkEnd.isAtSameMomentAs(startDate));
  }
}

class Apartment {
  final String id;
  final String title;
  final String description;
  final String city;
  final String district; // quartier
  final String address;
  final double pricePerDay; // Prix par jour au lieu d'un prix fixe
  final double surface;
  final int bedrooms;
  final int bathrooms;
  final ApartmentClass apartmentClass;
  final ApartmentAmenities amenities;
  final List<String> images;
  final double rating;
  final List<ApartmentReview>
      reviews; // Remplace le simple compteur par une liste
  final String ownerName;
  final String ownerAvatar;
  final String ownerPhone;
  final DateTime availableFrom; // Première date de disponibilité
  final List<UnavailablePeriod>
      unavailablePeriods; // Périodes où l'appartement n'est pas disponible

  const Apartment({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.district,
    required this.address,
    required this.pricePerDay,
    required this.surface,
    required this.bedrooms,
    required this.bathrooms,
    required this.apartmentClass,
    required this.amenities,
    required this.images,
    required this.rating,
    required this.reviews,
    required this.ownerName,
    required this.ownerAvatar,
    required this.ownerPhone,
    required this.availableFrom,
    required this.unavailablePeriods,
  });

  // Méthode pour vérifier si l'appartement est disponible pour une période donnée
  bool isAvailableForPeriod(DateTime startDate, DateTime endDate) {
    // Si la date de début est antérieure à la date à partir de laquelle l'appartement est disponible
    if (startDate.isBefore(availableFrom)) {
      return false;
    }

    // Vérifier si la période demandée chevauche une période d'indisponibilité
    for (var period in unavailablePeriods) {
      if (period.overlapsWith(startDate, endDate)) {
        return false;
      }
    }

    return true;
  }

  // Méthode pour calculer le prix total pour une période donnée
  double calculateTotalPrice(DateTime startDate, DateTime endDate) {
    final days = endDate.difference(startDate).inDays;
    return pricePerDay * days;
  }

  // Méthode pour obtenir la prochaine date disponible après une date donnée
  DateTime? getNextAvailableDateAfter(DateTime date) {
    // Si la date est antérieure à availableFrom, retourner availableFrom
    if (date.isBefore(availableFrom)) {
      return availableFrom;
    }

    // Trier les périodes d'indisponibilité par date de début
    final sortedPeriods = List<UnavailablePeriod>.from(unavailablePeriods)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    // Chercher la prochaine période disponible
    DateTime nextAvailable = date;

    for (var period in sortedPeriods) {
      if (nextAvailable.isBefore(period.startDate)) {
        // Il y a un espace disponible avant cette période
        return nextAvailable;
      }

      // Si on est à l'intérieur ou juste avant une période indisponible,
      // la prochaine date disponible sera après cette période
      if (nextAvailable.isBefore(period.endDate) ||
          nextAvailable.isAtSameMomentAs(period.endDate)) {
        nextAvailable = period.endDate.add(const Duration(days: 1));
      }
    }

    // Si on arrive ici, c'est que la date est après toutes les périodes d'indisponibilité
    return nextAvailable;
  }
}

class ApartmentSearchFilters {
  final String? city;
  final String? district;
  final DateTime? startDate; // Date d'arrivée
  final DateTime? endDate; // Date de départ
  final ApartmentClass? apartmentClass;
  final RangeValues? priceRange;
  final double? minSurface;
  final int? minBedrooms;
  final int? minBathrooms;
  final ApartmentAmenities? requiredAmenities;
  final bool
      showOnlyAvailable; // Nouveau paramètre pour filtrer seulement les disponibles

  const ApartmentSearchFilters({
    this.city,
    this.district,
    this.startDate,
    this.endDate,
    this.apartmentClass,
    this.priceRange,
    this.minSurface,
    this.minBedrooms,
    this.minBathrooms,
    this.requiredAmenities,
    this.showOnlyAvailable = true,
  });

  ApartmentSearchFilters copyWith({
    String? city,
    String? district,
    DateTime? startDate,
    DateTime? endDate,
    ApartmentClass? apartmentClass,
    RangeValues? priceRange,
    double? minSurface,
    int? minBedrooms,
    int? minBathrooms,
    ApartmentAmenities? requiredAmenities,
    bool? showOnlyAvailable,
  }) {
    return ApartmentSearchFilters(
      city: city ?? this.city,
      district: district ?? this.district,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      apartmentClass: apartmentClass ?? this.apartmentClass,
      priceRange: priceRange ?? this.priceRange,
      minSurface: minSurface ?? this.minSurface,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      minBathrooms: minBathrooms ?? this.minBathrooms,
      requiredAmenities: requiredAmenities ?? this.requiredAmenities,
      showOnlyAvailable: showOnlyAvailable ?? this.showOnlyAvailable,
    );
  }
}

// Données géographiques (inchangées)
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
};

// Prix de base par m² selon la ville et la catégorie
final Map<String, Map<String, double>> basePricePerM2 = {
  'Douala': {
    'Luxe': 600.0, // Prix par jour au m²
    'Standard': 350.0,
    'Economique': 200.0,
  },
  'Yaoundé': {
    'Luxe': 550.0,
    'Standard': 300.0,
    'Economique': 180.0,
  },
  'Kribi': {
    'Luxe': 500.0,
    'Standard': 250.0,
    'Economique': 150.0,
  },
};

// Listes d'images pour les appartements
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

// Liste d'avatars pour les avis
final List<String> reviewAvatars = [
  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&h=100',
  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&h=100',
  'https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=100&h=100',
  'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?auto=format&fit=crop&w=100&h=100',
  'https://images.unsplash.com/photo-1633332755192-727a05c4013d?auto=format&fit=crop&w=100&h=100',
];

// Liste de commentaires génériques pour les avis
final List<String> reviewComments = [
  'Très bel appartement, propre et bien situé. Je recommande vivement !',
  'Séjour parfait, l\'accueil était chaleureux et le propriétaire très réactif.',
  'Bonne expérience globale, mais quelques soucis avec la climatisation.',
  'Emplacement idéal, près de toutes les commodités. Appartement confortable.',
  'Excellent rapport qualité-prix. Je reviendrai sûrement.',
  'Un peu bruyant le soir mais l\'appartement est très bien aménagé.',
  'Tout était parfait, de l\'accueil au départ. Merci !',
  'Propreté impeccable, lit confortable, que demander de plus ?',
  'Bon séjour mais la connexion Wi-Fi était parfois instable.',
  'Vue magnifique et appartement très fonctionnel. À recommander !',
];

// Générateur de données mockées mis à jour
// Ajoutez cette fonction dans votre fichier apartment_mock_data.dart
// Elle génère des appartements supplémentaires avec des périodes de disponibilité variées

List<Apartment> addAdditionalMockApartments() {
  final List<Apartment> additionalApartments = [];
  final random = DateTime.now().millisecondsSinceEpoch;
  final now = DateTime.now();

  // Créez des appartements très disponibles (sans périodes d'indisponibilité)
  final cities = ['Douala', 'Yaoundé', 'Kribi'];
  final categories = ['Luxe', 'Standard', 'Economique'];

  for (final city in cities) {
    for (final category in categories) {
      // Récupérer des districts pour cette ville et catégorie
      final districts = cityData[city]?[category] ?? [];

      for (final district in districts) {
        // Ajouter 3 appartements très disponibles (sans périodes d'indisponibilité) par district
        for (var i = 0; i < 3; i++) {
          final isLuxury = category == 'Luxe';
          final isStandard = category == 'Standard';

          final apartmentClass = isLuxury
              ? ApartmentClass.luxe
              : isStandard
                  ? ApartmentClass.standard
                  : ApartmentClass.economique;

          final surface = isLuxury
              ? 120.0 + ((random + i) % 100)
              : isStandard
                  ? 80.0 + ((random + i) % 40)
                  : 50.0 + ((random + i) % 30);

          final basePrice = basePricePerM2[city]![category]! * surface / 100;
          final priceVariation = 0.9 + ((random + i) % 20) / 100;
          final pricePerDay =
              max(5000.0, min(100000.0, basePrice * priceVariation));

          final bedrooms = isLuxury
              ? 3 + ((random + i) % 2)
              : isStandard
                  ? 2 + ((random + i) % 2)
                  : 1 + ((random + i) % 2);

          // Générer quelques avis aléatoires
          final reviewCount = 2 + ((random + i) % 8);
          final reviews = <ApartmentReview>[];
          double totalRating = 0;

          for (int j = 0; j < reviewCount; j++) {
            final reviewRating =
                3.0 + ((random + i + j) % 20) / 10; // Entre 3.0 et 5.0
            totalRating += reviewRating;

            reviews.add(ApartmentReview(
              id: 'REV-NEW-${(random + i + j).toString().substring(0, 5)}',
              userName: 'Utilisateur ${(random + i + j) % 1000}',
              userAvatar:
                  reviewAvatars[(random + i + j) % reviewAvatars.length],
              rating: reviewRating,
              comment: reviewComments[(random + i + j) % reviewComments.length],
              date: now.subtract(Duration(days: 1 + ((random + i + j) % 180))),
            ));
          }

          // Calculer la note moyenne
          final averageRating =
              double.parse((totalRating / reviewCount).toStringAsFixed(2));

          // Créer quelques appartements sans périodes d'indisponibilité (toujours disponibles)
          additionalApartments.add(Apartment(
            id: 'APT-DISP-${city.substring(0, 3)}-${district.substring(0, 3)}-${(random + i).toString().substring(0, 4)}',
            title: 'Bel Appartement ${bedrooms}Ch - $district',
            description:
                'Superbe appartement situé dans un endroit privilégié de $district à $city. Cet espace de ${surface.round()} m² est idéal pour un séjour confortable. Entièrement meublé avec une décoration soignée, cet appartement offre une vue imprenable sur la ville.',
            city: city,
            district: district,
            address: '${(random + i) % 150} Avenue $district',
            pricePerDay: pricePerDay.roundToDouble(),
            surface: surface,
            bedrooms: bedrooms,
            bathrooms: isLuxury
                ? 2 + ((random + i) % 2)
                : isStandard
                    ? 2
                    : 1,
            apartmentClass: apartmentClass,
            amenities: ApartmentAmenities(
              hasWifi: true,
              hasAirConditioning: isLuxury || isStandard,
              hasParking: isLuxury || ((random + i) % 2 == 0),
              hasSecurity: isLuxury || isStandard,
              hasPool: isLuxury && ((random + i) % 3 == 0),
              hasGym: isLuxury && ((random + i) % 4 == 0),
              hasBalcony: isLuxury || (isStandard && (random + i) % 2 == 0),
              hasFurnished: true,
              hasWaterHeater: isLuxury || isStandard,
              hasGenerator: isLuxury,
              hasServiceRoom: isLuxury,
              hasGarden: isLuxury && ((random + i) % 2 == 0),
            ),
            images: categoryImages[category]!,
            rating: averageRating,
            reviews: reviews,
            ownerName: 'Proprio ${(random + i) % 100}',
            ownerAvatar: ownerAvatars[(random + i) % ownerAvatars.length],
            ownerPhone: '+237 6${(random + i).toString().substring(0, 8)}',
            availableFrom: now, // Disponible dès maintenant
            unavailablePeriods: [], // Aucune période d'indisponibilité (toujours disponible)
          ));
        }

        // Ajouter 2 appartements avec des périodes d'indisponibilité futures
        for (var i = 0; i < 2; i++) {
          final isLuxury = category == 'Luxe';
          final isStandard = category == 'Standard';

          final apartmentClass = isLuxury
              ? ApartmentClass.luxe
              : isStandard
                  ? ApartmentClass.standard
                  : ApartmentClass.economique;

          final surface = isLuxury
              ? 120.0 + ((random + i + 100) % 100)
              : isStandard
                  ? 80.0 + ((random + i + 100) % 40)
                  : 50.0 + ((random + i + 100) % 30);

          final basePrice = basePricePerM2[city]![category]! * surface / 100;
          final priceVariation = 0.9 + ((random + i + 100) % 20) / 100;
          final pricePerDay =
              max(5000.0, min(100000.0, basePrice * priceVariation));

          final bedrooms = isLuxury
              ? 3 + ((random + i + 100) % 2)
              : isStandard
                  ? 2 + ((random + i + 100) % 2)
                  : 1 + ((random + i + 100) % 2);

          // Générer une seule période d'indisponibilité dans le futur
          final startDaysOffset =
              30 + ((random + i + 100) % 60); // Entre 30 et 90 jours
          final durationDays =
              3 + ((random + i + 100) % 10); // Entre 3 et 12 jours

          final startDate = now.add(Duration(days: startDaysOffset));
          final endDate = startDate.add(Duration(days: durationDays));

          final unavailablePeriods = [
            UnavailablePeriod(
              startDate: startDate,
              endDate: endDate,
              reason: 'Réservé à l\'avance',
            )
          ];

          // Générer quelques avis aléatoires
          final reviewCount = 2 + ((random + i + 100) % 8);
          final reviews = <ApartmentReview>[];
          double totalRating = 0;

          for (int j = 0; j < reviewCount; j++) {
            final reviewRating =
                4.0 + ((random + i + j + 100) % 10) / 10; // Entre 4.0 et 5.0
            totalRating += reviewRating;

            reviews.add(ApartmentReview(
              id: 'REV-PART-${(random + i + j + 100).toString().substring(0, 5)}',
              userName: 'Client ${(random + i + j + 100) % 1000}',
              userAvatar:
                  reviewAvatars[(random + i + j + 100) % reviewAvatars.length],
              rating: reviewRating,
              comment: reviewComments[
                  (random + i + j + 100) % reviewComments.length],
              date: now
                  .subtract(Duration(days: 1 + ((random + i + j + 100) % 180))),
            ));
          }

          // Calculer la note moyenne
          final averageRating = totalRating / reviewCount;

          additionalApartments.add(Apartment(
            id: 'APT-PART-${city.substring(0, 3)}-${district.substring(0, 3)}-${(random + i + 100).toString().substring(0, 4)}',
            title: 'Appartement Premium ${bedrooms}Ch - $district',
            description:
                'Magnifique appartement premium situé au cœur de $district à $city. Cet espace moderne de ${surface.round()} m² offre tout le confort nécessaire pour un séjour exceptionnel. L\'appartement bénéficie d\'une excellente situation, proche de toutes commodités.',
            city: city,
            district: district,
            address: '${(random + i + 100) % 150} Boulevard $district',
            pricePerDay: pricePerDay.roundToDouble(),
            surface: surface,
            bedrooms: bedrooms,
            bathrooms: isLuxury
                ? 2 + ((random + i + 100) % 2)
                : isStandard
                    ? 2
                    : 1,
            apartmentClass: apartmentClass,
            amenities: ApartmentAmenities(
              hasWifi: true,
              hasAirConditioning: true,
              hasParking: isLuxury || ((random + i + 100) % 2 == 0),
              hasSecurity: true,
              hasPool: isLuxury && ((random + i + 100) % 3 == 0),
              hasGym: isLuxury && ((random + i + 100) % 4 == 0),
              hasBalcony:
                  isLuxury || (isStandard && (random + i + 100) % 2 == 0),
              hasFurnished: true,
              hasWaterHeater: true,
              hasGenerator: isLuxury,
              hasServiceRoom: isLuxury,
              hasGarden: isLuxury && ((random + i + 100) % 2 == 0),
            ),
            images: categoryImages[category]!,
            rating: averageRating,
            reviews: reviews,
            ownerName: 'Propriétaire ${(random + i + 100) % 100}',
            ownerAvatar: ownerAvatars[(random + i + 100) % ownerAvatars.length],
            ownerPhone:
                '+237 6${(random + i + 100).toString().substring(0, 8)}',
            availableFrom: now, // Disponible dès maintenant
            unavailablePeriods: unavailablePeriods,
          ));
        }
      }
    }
  }

  return additionalApartments;
}

// Modifiez la fonction generateMockApartments() pour inclure les appartements supplémentaires
List<Apartment> generateMockApartments() {
  final List<Apartment> apartments = [];
  final random = DateTime.now().millisecondsSinceEpoch;
  final now = DateTime.now();

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

          final basePrice = basePricePerM2[city]![category]! * surface / 100;
          final priceVariation = 0.9 + (random % 20) / 100;
          final pricePerDay =
              max(5000.0, min(100000.0, basePrice * priceVariation));

          final int bedrooms = isLuxury
              ? 3 + (random % 2)
              : isStandard
                  ? 2 + (random % 2)
                  : 1 + (random % 2);

          // Générer des périodes d'indisponibilité aléatoires (entre 0 et 3)
          final unavailablePeriods = <UnavailablePeriod>[];
          int numPeriods = random % 4; // 0 à 3 périodes
          for (int j = 0; j < numPeriods; j++) {
            // Ajouter une période entre aujourd'hui et les 3 prochains mois
            final startDaysOffset = (random % 90) + j * 10;
            final durationDays = 3 + (random % 10); // Entre 3 et 12 jours

            final startDate = now.add(Duration(days: startDaysOffset));
            final endDate = startDate.add(Duration(days: durationDays));

            unavailablePeriods.add(UnavailablePeriod(
              startDate: startDate,
              endDate: endDate,
              reason: 'Réservé',
            ));
          }

          // Générer quelques avis aléatoires (entre 2 et 10)
          final reviewCount = 2 + (random % 8);
          final reviews = <ApartmentReview>[];
          double totalRating = 0;

          for (int j = 0; j < reviewCount; j++) {
            final reviewRating = 3.0 + (random % 20) / 10; // Entre 3.0 et 5.0
            totalRating += reviewRating;

            reviews.add(ApartmentReview(
              id: 'REV-${random.toString().substring(j, j + 5)}',
              userName: 'Utilisateur ${random % 1000}',
              userAvatar: reviewAvatars[random % reviewAvatars.length],
              rating: reviewRating,
              comment: reviewComments[random % reviewComments.length],
              date: now.subtract(Duration(
                  days: 1 +
                      (random % 180))), // Commentaire dans les 6 derniers mois
            ));
          }

          // Calculer la note moyenne
          final averageRating =
              double.parse((totalRating / reviewCount).toStringAsFixed(2));

          apartments.add(Apartment(
            id: 'APT-${city.substring(0, 3)}-${district.substring(0, 3)}-${random.toString().substring(0, 4)}',
            title: 'Appartement ${bedrooms}Ch - $district',
            description:
                'Magnifique appartement situé dans un quartier prisé de $district à $city. Cet espace de ${surface.round()} m² offre tout le confort nécessaire pour un séjour agréable, que ce soit pour quelques jours ou plusieurs mois. Entièrement meublé et équipé, vous n\'aurez qu\'à poser vos valises.',
            city: city,
            district: district,
            address: '${random % 100} Rue $district',
            pricePerDay: pricePerDay.roundToDouble(),
            surface: surface,
            bedrooms: bedrooms,
            bathrooms: isLuxury
                ? 2 + (random % 2)
                : isStandard
                    ? 2
                    : 1,
            apartmentClass: apartmentClass,
            amenities: ApartmentAmenities(
              hasWifi: isLuxury || isStandard,
              hasAirConditioning: isLuxury || isStandard,
              hasParking: isLuxury,
              hasSecurity: isLuxury || isStandard,
              hasPool: isLuxury && (random % 3 == 0),
              hasGym: isLuxury && (random % 4 == 0),
              hasBalcony: isLuxury || (isStandard && random % 2 == 0),
              hasFurnished: true, // Toujours meublé maintenant
              hasWaterHeater: isLuxury || isStandard,
              hasGenerator: isLuxury,
              hasServiceRoom: isLuxury,
              hasGarden: isLuxury && (random % 2 == 0),
            ),
            images: categoryImages[category]!,
            rating: averageRating,
            reviews: reviews,
            ownerName: 'Propriétaire ${random % 100}',
            ownerAvatar: ownerAvatars[random % ownerAvatars.length],
            ownerPhone: '+237 6${random.toString().substring(0, 8)}',
            availableFrom: now.add(Duration(
                days: random %
                    10)), // Disponible entre aujourd'hui et dans 10 jours
            unavailablePeriods: unavailablePeriods,
          ));
        }
      }
    }
  }

  // Ajouter les appartements supplémentaires
  apartments.addAll(addAdditionalMockApartments());

  return apartments;
}
