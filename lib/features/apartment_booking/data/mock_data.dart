// lib/features/apartment_booking/data/mock_data.dart

import 'dart:math';
import '../models/apartment_filters.dart';

final Random _random = Random();

// Constantes publiques pour les données statiques
const List<String> cities = [
  'Douala',
  'Yaoundé',
  'Bafoussam',
  'Kribi',
  'Buea',
  'Bamenda',
  'Garoua',
];

const Map<String, List<String>> neighborhoods = {
  'Douala': [
    'Bonanjo',
    'Akwa',
    'Bonapriso',
    'Bonamoussadi',
    'Makepe',
    'Deido',
    'Bali',
  ],
  'Yaoundé': [
    'Bastos',
    'Nlongkak',
    'Tsinga',
    'Mvan',
    'Omnisport',
    'Mfandena',
    'Centre-ville',
  ],
  'Bafoussam': [
    'Tamdja',
    'Kamkop',
    'Banengo',
    'Centre-ville',
    'Djeleng',
  ],
  'Kribi': [
    'Centre-ville',
    'Village',
    'Mboa-Manga',
    'Dombé',
  ],
  'Buea': [
    'Molyko',
    'Bonduma',
    'GRA',
    'Mile 17',
    'Clerks Quarter',
  ],
  'Bamenda': [
    'Up Station',
    'Down Town',
    'Old Town',
    'Nkwen',
    'Mile 2',
  ],
  'Garoua': [
    'Marouaré',
    'Roumdé Adjia',
    'Centre-ville',
    'Djamboutou',
  ],
};

// Données privées pour la génération
const _propertyTitles = [
  'Appartement Moderne',
  'Studio Luxueux',
  'Villa Contemporaine',
  'Duplex Spacieux',
  'Résidence de Standing',
  'Penthouse Vue Panoramique',
  'Appartement Cosy',
];

const _amenities = [
  'Wifi haut débit',
  'Climatisation',
  'Parking sécurisé',
  'Piscine',
  'Salle de sport',
  'Sécurité 24/7',
  'Groupe électrogène',
  'Ascenseur',
  'Jardins aménagés',
  'Tennis',
  'Buanderie',
  'Cuisine équipée',
];

class Apartment {
  final String id;
  final String title;
  final String description;
  final String city;
  final String neighborhood;
  final String fullAddress;
  final ApartmentType type;
  final RentalDuration duration;
  final double price;
  final int bedrooms;
  final int bathrooms;
  final double surface;
  final List<String> amenities;
  final List<String> images;
  final bool isAvailable;
  final DateTime availableFrom;
  final double rating;
  final int reviews;
  final String ownerName;
  final String ownerAvatar;
  final double distanceToCenter;
  final bool petsAllowed;
  final DateTime listedDate;

  const Apartment({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.neighborhood,
    required this.fullAddress,
    required this.type,
    required this.duration,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.surface,
    required this.amenities,
    required this.images,
    required this.isAvailable,
    required this.availableFrom,
    required this.rating,
    required this.reviews,
    required this.ownerName,
    required this.ownerAvatar,
    required this.distanceToCenter,
    required this.petsAllowed,
    required this.listedDate,
  });
}

// Fonction de génération d'appartements mockés
List<Apartment> generateApartments({int count = 50}) {
  final random = Random();
  final List<Apartment> apartments = [];
  final now = DateTime.now();

  for (var i = 0; i < count; i++) {
    final city = cities[random.nextInt(cities.length)];
    final neighborhoodsList = neighborhoods[city]!;
    final neighborhood =
        neighborhoodsList[random.nextInt(neighborhoodsList.length)];

    final isLuxuryArea = neighborhood.toLowerCase().contains('bastos') ||
        neighborhood.toLowerCase().contains('bonapriso');

    // Générer le type d'appartement
    const types = ApartmentType.values;
    final type = isLuxuryArea
        ? (random.nextBool() ? ApartmentType.villa : ApartmentType.apartment)
        : types[random.nextInt(types.length)];

    // Générer le nombre de chambres en fonction du type
    final bedrooms = type == ApartmentType.studio
        ? 0
        : isLuxuryArea
            ? random.nextInt(3) + 3 // 3-5 chambres
            : random.nextInt(2) + 1; // 1-2 chambres

    // Calculer la surface en fonction du type et du nombre de chambres
    final baseSize = type == ApartmentType.studio
        ? 30.0
        : type == ApartmentType.apartment
            ? 50.0 + (bedrooms * 20.0)
            : 100.0 + (bedrooms * 30.0);
    final surface = baseSize * (0.9 + random.nextDouble() * 0.3);

    // Calculer le prix en fonction de la surface et de la zone
    final basePrice = isLuxuryArea ? 15000.0 : 8000.0;
    final price = basePrice * surface * (0.9 + random.nextDouble() * 0.3);

    // Sélectionner des équipements
    final shuffledAmenities = List<String>.from(_amenities)..shuffle(random);
    final amenityCount =
        isLuxuryArea ? random.nextInt(4) + 6 : random.nextInt(4) + 3;
    final selectedAmenities = shuffledAmenities.take(amenityCount).toList();

    apartments.add(Apartment(
      id: 'APT-${now.year}${i.toString().padLeft(4, '0')}',
      title:
          '${_propertyTitles[random.nextInt(_propertyTitles.length)]} à $neighborhood',
      description:
          _generateDescription(type, selectedAmenities, neighborhood, surface),
      city: city,
      neighborhood: neighborhood,
      fullAddress:
          '${random.nextInt(100)} Rue ${neighborhoods[city]![random.nextInt(neighborhoods[city]!.length)]}, $city',
      type: type,
      duration: _generateRentalDuration(type),
      price: price,
      bedrooms: bedrooms,
      bathrooms:
          type == ApartmentType.studio ? 1 : bedrooms - random.nextInt(2),
      surface: surface,
      amenities: selectedAmenities,
      images: _generateImages(random),
      isAvailable: random.nextDouble() > 0.2,
      availableFrom: now.add(Duration(days: random.nextInt(30))),
      rating: 3.5 + random.nextDouble() * 1.5,
      reviews: random.nextInt(50) + 5,
      ownerName: _generateOwnerName(random),
      ownerAvatar: 'https://i.pravatar.cc/150?img=${random.nextInt(70)}',
      distanceToCenter: random.nextDouble() * 5,
      petsAllowed: random.nextBool(),
      listedDate: now.subtract(Duration(days: random.nextInt(30))),
    ));
  }

  return apartments;
}

String _generateDescription(ApartmentType type, List<String> amenities,
    String neighborhood, double surface) {
  final descriptions = [
    'Magnifique ${type.label.toLowerCase()} de ${surface.round()}m² situé dans le quartier prisé de $neighborhood.',
    'Superbe ${type.label.toLowerCase()} lumineux et spacieux avec une excellente exposition.',
    'Beau ${type.label.toLowerCase()} dans une résidence calme et sécurisée.',
  ];

  final random = Random();
  final description = descriptions[random.nextInt(descriptions.length)];
  return '$description\n\nÉquipements inclus: ${amenities.join(", ")}.';
}

List<String> _generateImages(Random random) {
  final imageCount = random.nextInt(3) + 3; // 3-5 images
  return List.generate(
      imageCount,
      (index) =>
          'https://picsum.photos/800/600?random=${random.nextInt(1000)}');
}

String _generateOwnerName(Random random) {
  final firstNames = ['Jean', 'Paul', 'Marie', 'Pierre', 'Sophie', 'André'];
  final lastNames = ['Kamga', 'Fotsing', 'Nkeng', 'Tchinda', 'Mboula', 'Takam'];
  return '${firstNames[random.nextInt(firstNames.length)]} ${lastNames[random.nextInt(lastNames.length)]}';
}

RentalDuration _generateRentalDuration(ApartmentType type) {
  final random = Random();
  switch (type) {
    case ApartmentType.studio:
      return random.nextBool() ? RentalDuration.daily : RentalDuration.monthly;
    case ApartmentType.apartment:
      return random.nextBool() ? RentalDuration.monthly : RentalDuration.yearly;
    case ApartmentType.house:
    case ApartmentType.villa:
      return RentalDuration.yearly;
  }
}

/*
// Données de base pour la génération
final List<String> CITIES = [
  'Douala',
  'Yaoundé',
  'Bafoussam',
  'Kribi',
  'Buea',
  'Bamenda',
  'Garoua',
];

final Map<String, List<String>> NEIGHBORHOODS = {
  'Douala': [
    'Bonanjo',
    'Akwa',
    'Bonapriso',
    'Bonamoussadi',
    'Makepe',
    'Deido',
    'Bali',
  ],
  'Yaoundé': [
    'Bastos',
    'Nlongkak',
    'Tsinga',
    'Mvan',
    'Omnisport',
    'Mfandena',
    'Centre-ville',
  ],
  'Bafoussam': [
    'Tamdja',
    'Kamkop',
    'Banengo',
    'Centre-ville',
    'Djeleng',
  ],
  'Kribi': [
    'Centre-ville',
    'Village',
    'Mboa-Manga',
    'Dombé',
  ],
  'Buea': [
    'Molyko',
    'Bonduma',
    'GRA',
    'Mile 17',
    'Clerks Quarter',
  ],
  'Bamenda': [
    'Up Station',
    'Down Town',
    'Old Town',
    'Nkwen',
    'Mile 2',
  ],
  'Garoua': [
    'Marouaré',
    'Roumdé Adjia',
    'Centre-ville',
    'Djamboutou',
  ],
};

final List<String> _streetNames = [
  'Rue de la Paix',
  'Avenue Kennedy',
  'Boulevard de la Liberté',
  'Rue des Palmiers',
  'Avenue de l\'Indépendance',
  'Rue du Commerce',
  'Boulevard Maritime',
];

final List<String> _propertyTitles = [
  'Appartement Moderne',
  'Studio Luxueux',
  'Villa Contemporaine',
  'Duplex Spacieux',
  'Résidence de Standing',
  'Penthouse Vue Panoramique',
  'Appartement Cosy',
];

final List<String> _amenities = [
  'Wifi haut débit',
  'Climatisation',
  'Parking sécurisé',
  'Piscine',
  'Salle de sport',
  'Sécurité 24/7',
  'Groupe électrogène',
  'Ascenseur',
  'Jardins aménagés',
  'Tennis',
  'Buanderie',
  'Cuisine équipée',
];

// Classe Apartment pour représenter un appartement
class Apartment {
  final String id;
  final String title;
  final String description;
  final String city;
  final String neighborhood;
  final String fullAddress;
  final ApartmentType type;
  final RentalDuration duration;
  final double price;
  final int bedrooms;
  final int bathrooms;
  final double surface;
  final List<String> amenities;
  final List<String> images;
  final bool isAvailable;
  final DateTime availableFrom;
  final double rating;
  final int reviews;
  final String ownerName;
  final String ownerAvatar;
  final double distanceToCenter;
  final bool petsAllowed;
  final DateTime listedDate;

  const Apartment({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.neighborhood,
    required this.fullAddress,
    required this.type,
    required this.duration,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.surface,
    required this.amenities,
    required this.images,
    required this.isAvailable,
    required this.availableFrom,
    required this.rating,
    required this.reviews,
    required this.ownerName,
    required this.ownerAvatar,
    required this.distanceToCenter,
    required this.petsAllowed,
    required this.listedDate,
  });
}

List<Apartment> generateMockApartments({int count = 50}) {
  final List<Apartment> apartments = [];
  final now = DateTime.now();

  for (var i = 0; i < count; i++) {
    // Sélection aléatoire de la ville et du quartier
    final city = _cities[_random.nextInt(_cities.length)];
    final neighborhoods = _neighborhoods[city]!;
    final neighborhood = neighborhoods[_random.nextInt(neighborhoods.length)];

    // Génération du type et caractéristiques en fonction du quartier
    final isLuxuryArea = neighborhood.toLowerCase().contains('bastos') ||
        neighborhood.toLowerCase().contains('bonapriso') ||
        neighborhood.toLowerCase().contains('bonanjo');

    final type = _generateApartmentType(isLuxuryArea);
    final bedrooms = _generateBedrooms(type, isLuxuryArea);
    final bathrooms = max(1, bedrooms - 1 + _random.nextInt(2));
    final surface = _generateSurface(type, bedrooms, isLuxuryArea);
    final price = _generatePrice(type, surface, isLuxuryArea, city);

    // Génération des commodités
    final amenitiesCount = isLuxuryArea
        ? _random.nextInt(3) + 7
        : // 7-9 commodités pour les zones luxueuses
        _random.nextInt(5) + 3; // 3-7 commodités pour les autres zones
    final shuffledAmenities = List<String>.from(_amenities)..shuffle();
    final selectedAmenities = shuffledAmenities.take(amenitiesCount).toList();

    apartments.add(MockApartment(
      id: 'APT-${now.year}${i.toString().padLeft(4, '0')}',
      title:
          '${_propertyTitles[_random.nextInt(_propertyTitles.length)]} à $neighborhood',
      description: _generateDescription(type, selectedAmenities, neighborhood),
      city: city,
      neighborhood: neighborhood,
      fullAddress:
          '${_streetNames[_random.nextInt(_streetNames.length)]}, $neighborhood, $city',
      type: type,
      duration: _generateRentalDuration(type),
      price: price,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      surface: surface,
      amenities: selectedAmenities,
      images: _generateImages(type),
      isAvailable: _random.nextDouble() > 0.2,
      availableFrom: now.add(Duration(days: _random.nextInt(30))),
      rating: 3.5 + _random.nextDouble() * 1.5,
      reviews: _random.nextInt(50) + 5,
      ownerName: _generateOwnerName(),
      ownerAvatar: _generateAvatarUrl(),
      distanceToCenter: _random.nextDouble() * 5,
      petsAllowed: _random.nextBool(),
      listedDate: now.subtract(Duration(days: _random.nextInt(30))),
    ));
  }

  return apartments;
}

ApartmentType _generateApartmentType(bool isLuxuryArea) {
  if (isLuxuryArea) {
    return _random.nextDouble() > 0.3
        ? ApartmentType.apartment
        : ApartmentType.villa;
  }
  const types = ApartmentType.values;
  return types[_random.nextInt(types.length)];
}

int _generateBedrooms(ApartmentType type, bool isLuxuryArea) {
  switch (type) {
    case ApartmentType.studio:
      return 0;
    case ApartmentType.apartment:
      return isLuxuryArea
          ? _random.nextInt(3) + 2
          : // 2-4 chambres
          _random.nextInt(2) + 1; // 1-2 chambres
    case ApartmentType.house:
      return _random.nextInt(3) + 2; // 2-4 chambres
    case ApartmentType.villa:
      return _random.nextInt(4) + 3; // 3-6 chambres
  }
}

double _generateSurface(ApartmentType type, int bedrooms, bool isLuxuryArea) {
  double baseSize;
  switch (type) {
    case ApartmentType.studio:
      baseSize = 25.0;
      break;
    case ApartmentType.apartment:
      baseSize = 45.0 + (bedrooms * 15.0);
      break;
    case ApartmentType.house:
      baseSize = 80.0 + (bedrooms * 20.0);
      break;
    case ApartmentType.villa:
      baseSize = 120.0 + (bedrooms * 30.0);
      break;
  }

  if (isLuxuryArea) {
    baseSize *= 1.3;
  }

  // Ajouter une variation aléatoire de ±10%
  return baseSize * (0.9 + (_random.nextDouble() * 0.2));
}

double _generatePrice(
    ApartmentType type, double surface, bool isLuxuryArea, String city) {
  // Prix de base par m² selon la ville
  final Map<String, double> basePricePerM2 = {
    'Douala': 3500,
    'Yaoundé': 3300,
    'Bafoussam': 2000,
    'Kribi': 2800,
    'Buea': 2200,
    'Bamenda': 2000,
    'Garoua': 1800,
  };

  double basePrice = basePricePerM2[city]! * surface;

  // Facteurs multiplicateurs selon le type
  switch (type) {
    case ApartmentType.studio:
      basePrice *= 0.9;
      break;
    case ApartmentType.apartment:
      basePrice *= 1.0;
      break;
    case ApartmentType.house:
      basePrice *= 1.2;
      break;
    case ApartmentType.villa:
      basePrice *= 1.5;
      break;
  }

  // Majoration pour les zones luxueuses
  if (isLuxuryArea) {
    basePrice *= 1.4;
  }

  // Variation aléatoire de ±10%
  return basePrice * (0.9 + (_random.nextDouble() * 0.2));
}

RentalDuration _generateRentalDuration(ApartmentType type) {
  switch (type) {
    case ApartmentType.studio:
      return _random.nextBool() ? RentalDuration.daily : RentalDuration.monthly;
    case ApartmentType.apartment:
      return _random.nextBool()
          ? RentalDuration.monthly
          : RentalDuration.yearly;
    case ApartmentType.house:
    case ApartmentType.villa:
      return RentalDuration.yearly;
  }
}

String _generateDescription(
    ApartmentType type, List<String> amenities, String neighborhood) {
  final descriptions = [
    'Magnifique ${type.label.toLowerCase()} situé dans le quartier prisé de $neighborhood.',
    'Superbe ${type.label.toLowerCase()} bien entretenu avec une excellente exposition.',
    'Beau ${type.label.toLowerCase()} dans une résidence calme et sécurisée.',
  ];

  final description = descriptions[_random.nextInt(descriptions.length)];
  return '$description\n\nÉquipements inclus: ${amenities.join(", ")}.';
}

List<String> _generateImages(ApartmentType type) {
  // Dans une vraie application, ces URLs seraient des images réelles
  // Pour le mock, on utilise des placeholders
  final imageCount = _random.nextInt(3) + 3; // 3-5 images
  return List.generate(imageCount, (index) {
    const width = 800;
    const height = 600;
    return 'https://picsum.photos/$width/$height?random=${_random.nextInt(1000)}';
  });
}

String _generateOwnerName() {
  final firstNames = ['Jean', 'Paul', 'Marie', 'Pierre', 'Sophie', 'André'];
  final lastNames = ['Kamga', 'Fotsing', 'Nkeng', 'Tchinda', 'Mboula', 'Takam'];
  return '${firstNames[_random.nextInt(firstNames.length)]} ${lastNames[_random.nextInt(lastNames.length)]}';
}

String _generateAvatarUrl() {
  return 'https://i.pravatar.cc/150?img=${_random.nextInt(70)}';
}
*/