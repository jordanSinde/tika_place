// lib/features/bus_booking/data/mock_data.dart

import '../home/models/bus_and_utility_models.dart';

final List<String> agencesList = [
  'Finex Voyages',
  'Générale Express',
  'Global Voyages',
  'Le Transporteur',
  'Buca Voyages',
  'Tresor Voyages',
  'Men Travel',
];

final List<String> cityLocations = {
  'Douala': [
    'Bonabéri',
    'Bonanjo',
    'Akwa',
    'Ndokoti',
    'Bessengue',
  ],
  'Yaoundé': [
    'Mvan',
    'Nsam',
    'Mvog-Mbi',
    'Omnisport',
    'Ekounou',
  ],
  'Bafoussam': [
    'Marché A',
    'Marché B',
    'Banengo',
  ],
  'Bamenda': [
    'Commercial Avenue',
    'City Chemist',
    'Food Market',
  ],
  'Buea': [
    'Molyko',
    'Mile 17',
    'Check Point',
  ],
  'Kribi': [
    'Centre Ville',
    'Village',
    'Port',
  ],
  'Garoua': [
    'Centre Commercial',
    'Marché Central',
    'Gare Routière',
  ],
}.entries.expand((e) => e.value.map((loc) => '$loc, ${e.key}')).toList();

List<Bus> generateMockBuses() {
  final now = DateTime.now();
  final List<Bus> buses = [];

  // Générer des bus pour les prochaines 24 heures
  for (var hour = 6; hour < 22; hour += 2) {
    for (final company in agencesList) {
      // Trajets populaires
      buses.addAll([
        _createMockBus(
          company: company,
          departureCity: 'Douala',
          arrivalCity: 'Yaoundé',
          baseTime: now.copyWith(hour: hour),
          duration: const Duration(hours: 4),
          isPopularRoute: true,
        ),
        _createMockBus(
          company: company,
          departureCity: 'Yaoundé',
          arrivalCity: 'Douala',
          baseTime: now.copyWith(hour: hour),
          duration: const Duration(hours: 4),
          isPopularRoute: true,
        ),
        _createMockBus(
          company: company,
          departureCity: 'Douala',
          arrivalCity: 'Bafoussam',
          baseTime: now.copyWith(hour: hour),
          duration: const Duration(hours: 5),
          isPopularRoute: true,
        ),
      ]);

      // Autres trajets
      if (hour % 4 == 0) {
        buses.addAll([
          _createMockBus(
            company: company,
            departureCity: 'Douala',
            arrivalCity: 'Kribi',
            baseTime: now.copyWith(hour: hour),
            duration: const Duration(hours: 3),
          ),
          _createMockBus(
            company: company,
            departureCity: 'Yaoundé',
            arrivalCity: 'Bamenda',
            baseTime: now.copyWith(hour: hour),
            duration: const Duration(hours: 6),
          ),
          _createMockBus(
            company: company,
            departureCity: 'Bafoussam',
            arrivalCity: 'Garoua',
            baseTime: now.copyWith(hour: hour),
            duration: const Duration(hours: 8),
          ),
        ]);
      }
    }
  }

  return buses;
}

Bus _createMockBus({
  required String company,
  required String departureCity,
  required String arrivalCity,
  required DateTime baseTime,
  required Duration duration,
  bool isPopularRoute = false,
}) {
  // Générer un emplacement aléatoire pour l'agence
  final random = DateTime.now().millisecondsSinceEpoch;
  final departureCityLocations =
      cityLocations.where((loc) => loc.endsWith(departureCity)).toList();
  final agencyLocation =
      departureCityLocations[random % departureCityLocations.length];

  // Générer une classe de bus aléatoire avec une distribution réaliste
  final busClassRandom = random % 10;
  final busClass = busClassRandom < 5
      ? BusClass.standard
      : busClassRandom < 8
          ? BusClass.vip
          : BusClass.luxe;

  // Définir le prix en fonction de la classe et de la durée
  final basePrice = duration.inHours * 1500.0;
  final price = busClass == BusClass.standard
      ? basePrice
      : busClass == BusClass.vip
          ? basePrice * 1.5
          : basePrice * 2;

  // Générer les commodités en fonction de la classe
  final amenities = BusAmenities(
    hasAirConditioning: busClass != BusClass.standard,
    hasToilet: busClass == BusClass.luxe,
    hasLunch: busClass == BusClass.luxe,
    hasDrinks: busClass != BusClass.standard,
    hasWifi: busClass != BusClass.standard,
    hasUSBCharging: busClass != BusClass.standard,
    hasTv: busClass == BusClass.luxe,
  );

  // Générer un numéro d'immatriculation aléatoire
  final registrationNumber = 'CE-${(random % 900 + 100)}-${(random % 90 + 10)}';

  // Générer une note aléatoire réaliste
  final rating = 4.0 + (random % 10) / 10;
  final reviews = 50 + (random % 200);

  // Capacité et places disponibles
  final totalSeats = busClass == BusClass.standard ? 70 : 45;
  final availableSeats = random % (totalSeats ~/ 2) + (totalSeats ~/ 3);

  // Prochains départs disponibles
  final nextDepartures = List.generate(3, (index) {
    return baseTime.add(Duration(days: index + 1));
  });

  return Bus(
    id: 'BUS-${random.toString().substring(5, 13)}',
    company: company,
    agencyLocation: agencyLocation,
    registrationNumber: registrationNumber,
    departureCity: departureCity,
    arrivalCity: arrivalCity,
    departureTime: baseTime,
    arrivalTime: baseTime.add(duration),
    busClass: busClass,
    price: price,
    totalSeats: totalSeats,
    availableSeats: availableSeats,
    amenities: amenities,
    busNumber: 'BUS${(random % 900 + 100)}',
    rating: rating,
    reviews: reviews,
    isPopularRoute: isPopularRoute,
    nextAvailableDepartures: nextDepartures,
  );
}
