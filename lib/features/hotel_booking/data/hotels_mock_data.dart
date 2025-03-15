// lib/features/hotel_booking/models/hotel_mock_data.dart

import 'dart:math';
import '../models/hotel_review.dart';
import '../models/models.dart';

List<Hotel> generateMockHotels() {
  final List<Hotel> hotels = [];
  final random = Random();
  final now = DateTime.now();

  // Liste des pays et villes
  final Map<String, List<String>> countryCities = {
    'Cameroun': ['Yaoundé', 'Douala', 'Kribi', 'Bamenda', 'Bafoussam'],
    'Côte d\'ivoire': [
      'Londres',
      'Manchester',
      'Liverpool',
      'Édimbourg',
      'Glasgow'
    ],
    'Ghana': ['Accra', 'Ville2', 'Ville3', 'Ville4', 'Ville5'],
    'Nigeria': ['Abudja', 'Ville2', 'Ville3', 'Ville4', 'Ville5'],
    'Mali': ['Bamako', 'Berlin', 'Ville3', 'Ville4', 'Ville5'],
  };

  // Liste des noms d'hôtels par catégorie
  final Map<int, List<String>> hotelNamesByStars = {
    5: [
      'Grand Palace Hotel',
      'Royal Luxe',
      'Imperial Suites',
      'Elite Grand Hotel',
      'The Presidential'
    ],
    4: [
      'Premium Comfort Hotel',
      'City Prestige',
      'Metropolitan Hotel',
      'Business Class Hotel',
      'Urban Elegance'
    ],
    3: [
      'Comfort Inn',
      'Central Hotel',
      'City Hotel',
      'Park View Hotel',
      'Urban Stay'
    ],
    2: [
      'Budget Inn',
      'Economy Hotel',
      'Simple Stay',
      'Basic Lodge',
      'Value Hotel'
    ],
    1: [
      'Backpacker\'s Hostel',
      'Budget Sleep',
      'Economy Rooms',
      'Basic Stay',
      'Simple Lodging'
    ],
  };

  // Liste des descriptions d'hôtels
  final List<String> hotelDescriptions = [
    "Cet hôtel élégant offre un confort exceptionnel au cœur de la ville. Avec ses chambres spacieuses et son service attentionné, c'est le choix idéal pour les voyageurs exigeants.",
    "Idéalement situé près des attractions principales, cet établissement combine parfaitement style moderne et ambiance chaleureuse pour un séjour réussi.",
    "Un havre de paix en plein centre-ville, offrant des installations de qualité et un personnel dévoué pour rendre votre séjour inoubliable.",
    "Découvrez un mélange unique de luxe contemporain et de charme traditionnel dans cet hôtel qui saura répondre à toutes vos attentes.",
    "Avec sa vue imprenable et son emplacement stratégique, cet hôtel est le point de départ parfait pour explorer la ville et ses environs."
  ];

  // Liste des règles de maison
  final List<String> houseRules = [
    "Enregistrement à partir de 14h00, départ jusqu'à 11h00",
    "Animaux de compagnie non autorisés",
    "Établissement entièrement non-fumeur",
    "Pas de fête ni d'événements autorisés",
    "Les enfants sont les bienvenus",
    "Petit-déjeuner servi de 6h30 à 10h30",
    "Parking disponible sur réservation uniquement",
    "Paiement accepté en espèces ou par carte de crédit"
  ];

  // Images d'hôtels
  final List<String> hotelImages = [
    "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&h=600",
    "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=800&h=600",
    "https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=800&h=600",
    "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=800&h=600",
    "https://images.unsplash.com/photo-1445019980597-93fa8acb246c?auto=format&fit=crop&w=800&h=600",
  ];

  // Images de chambres
  final List<String> roomImages = [
    "https://images.unsplash.com/photo-1631049307264-da0ec9d70304?auto=format&fit=crop&w=800&h=600",
    "https://images.unsplash.com/photo-1540518614846-7eded433c457?auto=format&fit=crop&w=800&h=600",
    "https://images.unsplash.com/photo-1595576508898-0ad5c879a061?auto=format&fit=crop&w=800&h=600",
    "https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=800&h=600",
    "https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=800&h=600",
  ];

  // Avatars pour les avis
  final List<String> reviewAvatars = [
    "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&h=100",
    "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&h=100",
    "https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=100&h=100",
    "https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?auto=format&fit=crop&w=100&h=100",
    "https://images.unsplash.com/photo-1607746882042-944635dfe10e?auto=format&fit=crop&w=100&h=100",
  ];

  // Liste de commentaires génériques pour les avis
  final List<String> reviewComments = [
    "Excellent séjour ! La chambre était propre et spacieuse. Le personnel était très attentionné.",
    "Bon rapport qualité-prix. L'emplacement est idéal pour explorer la ville.",
    "Très bel hôtel, mais le petit-déjeuner pourrait être amélioré. Sinon, tout était parfait.",
    "Chambre confortable et propre. Le service était rapide et efficace.",
    "Personnel accueillant et serviable. La piscine était magnifique. Je reviendrai !",
    "Parfait pour un séjour d'affaires. Wifi rapide et bureau spacieux dans la chambre.",
    "Vue incroyable depuis la chambre. Le restaurant de l'hôtel est également excellent.",
    "Bon emplacement, à proximité des transports en commun et des attractions touristiques.",
    "Lit très confortable, j'ai dormi comme un bébé ! Petit-déjeuner varié et copieux.",
    "Service impeccable, mais la chambre était un peu petite pour le prix payé."
  ];

  // Générer 30 hôtels aléatoires
  for (int i = 0; i < 30; i++) {
    final String country =
        countryCities.keys.elementAt(random.nextInt(countryCities.keys.length));
    final String city =
        countryCities[country]![random.nextInt(countryCities[country]!.length)];

    final int starsCount = random.nextInt(4) + 2; // 2 à 5 étoiles
    final String hotelName = hotelNamesByStars[starsCount]![
        random.nextInt(hotelNamesByStars[starsCount]!.length)];

    // Mélanger les images
    final List<String> shuffledHotelImages = List.from(hotelImages)
      ..shuffle(random);
    final List<String> shuffledRoomImages = List.from(roomImages)
      ..shuffle(random);

    // Générer quelques avis aléatoires
    final int reviewCount = 3 + random.nextInt(10); // 3 à 12 avis
    final List<HotelReview> reviews = [];
    double totalRating = 0;

    for (int j = 0; j < reviewCount; j++) {
      final double reviewRating = 3.0 + random.nextDouble() * 2.0; // 3.0 à 5.0
      totalRating += reviewRating;

      reviews.add(HotelReview(
        id: 'REV-${i}-${j}',
        userName: 'Client ${100 + random.nextInt(900)}',
        userAvatar: reviewAvatars[random.nextInt(reviewAvatars.length)],
        rating: double.parse(reviewRating.toStringAsFixed(1)),
        comment: reviewComments[random.nextInt(reviewComments.length)],
        date: now.subtract(Duration(
            days: random.nextInt(180))), // Avis dans les 6 derniers mois
      ));
    }

    // Calculer la note moyenne
    final double averageRating =
        double.parse((totalRating / reviewCount).toStringAsFixed(1));

    // Générer les règles de maison pour cet hôtel
    final List<String> selectedRules = [];
    final List<String> tempRules = List.from(houseRules);
    tempRules.shuffle(random);
    final int rulesCount = 3 + random.nextInt(4); // 3 à 6 règles
    for (int k = 0; k < rulesCount && k < tempRules.length; k++) {
      selectedRules.add(tempRules[k]);
    }

    // Générer les chambres
    final List<HotelRoom> rooms = [];

    // Nombre de types de chambres différents selon le nombre d'étoiles
    final int roomTypesCount = 1 + starsCount ~/ 2; // 1 à 3 types de chambres

    // Liste des types de chambres disponibles selon la catégorie de l'hôtel
    final List<RoomType> availableRoomTypes = [];

    if (starsCount >= 4) {
      availableRoomTypes.addAll(
          [RoomType.deluxe, RoomType.suite, RoomType.double, RoomType.twin]);
    } else if (starsCount == 3) {
      availableRoomTypes
          .addAll([RoomType.double, RoomType.twin, RoomType.single]);
    } else {
      availableRoomTypes.addAll([RoomType.double, RoomType.single]);
    }

    // Randomiser l'ordre
    availableRoomTypes.shuffle(random);

    for (int t = 0; t < roomTypesCount; t++) {
      final RoomType roomType =
          availableRoomTypes[t % availableRoomTypes.length];

      // Déterminer le nombre de chambres disponibles
      final int availableRoomsCount = 3 + random.nextInt(8); // 3 à 10 chambres

      // Prix de base selon le type de chambre et le nombre d'étoiles
      double basePrice;
      switch (roomType) {
        case RoomType.single:
          basePrice = 20000 + (starsCount * 5000);
          break;
        case RoomType.double:
          basePrice = 25000 + (starsCount * 7000);
          break;
        case RoomType.twin:
          basePrice = 30000 + (starsCount * 7000);
          break;
        case RoomType.deluxe:
          basePrice = 40000 + (starsCount * 10000);
          break;
        case RoomType.suite:
          basePrice = 60000 + (starsCount * 15000);
          break;
        case RoomType.family:
          basePrice = 50000 + (starsCount * 12000);
          break;
      }

      // Variation aléatoire du prix (±10%)
      basePrice = basePrice * (0.9 + (random.nextDouble() * 0.2));

      // Capacité selon le type de chambre
      int maxAdults;
      int maxChildren;
      String bedType;

      switch (roomType) {
        case RoomType.single:
          maxAdults = 1;
          maxChildren = 0;
          bedType = "1 lit simple";
          break;
        case RoomType.double:
          maxAdults = 2;
          maxChildren = 1;
          bedType = "1 grand lit";
          break;
        case RoomType.twin:
          maxAdults = 2;
          maxChildren = 1;
          bedType = "2 lits simples";
          break;
        case RoomType.deluxe:
          maxAdults = 2;
          maxChildren = 2;
          bedType = "1 très grand lit";
          break;
        case RoomType.suite:
          maxAdults = 3;
          maxChildren = 2;
          bedType = "1 très grand lit et 1 canapé-lit";
          break;
        case RoomType.family:
          maxAdults = 4;
          maxChildren = 2;
          bedType = "2 grands lits";
          break;
      }

      // Surface selon le type de chambre et le nombre d'étoiles
      final int roomSize = roomType == RoomType.single
          ? 12 + (starsCount * 2)
          : roomType == RoomType.suite
              ? 35 + (starsCount * 5)
              : 18 + (starsCount * 3);

      // Commodités selon le type de chambre et le nombre d'étoiles
      final RoomAmenities amenities = RoomAmenities(
        hasWifi: starsCount >= 3 || random.nextBool(),
        hasTV: true,
        hasMinibar: starsCount >= 4 || (starsCount >= 3 && random.nextBool()),
        hasSafe: starsCount >= 4 || (starsCount >= 3 && random.nextBool()),
        hasPrivateBathroom: true,
        hasAirConditioning: starsCount >= 3 || random.nextBool(),
        hasBalcony: starsCount >= 4 && random.nextBool(),
        hasSeaView: random.nextInt(10) == 0, // 10% de chance
        hasCityView: random.nextInt(3) == 0, // 33% de chance
        hasWorkDesk: starsCount >= 3 || random.nextBool(),
      );

      // Politique d'annulation
      final bool refundable = starsCount >= 4 || random.nextBool();
      final String cancellationPolicy = refundable
          ? "Annulation gratuite jusqu'à 24 heures avant l'arrivée. Après cette période, la première nuit sera facturée."
          : "Non remboursable. Le montant total sera débité au moment de la réservation.";

      // Périodes d'indisponibilité aléatoires
      final List<UnavailablePeriod> unavailablePeriods = [];
      final int numPeriods = random.nextInt(3); // 0 à 2 périodes

      for (int p = 0; p < numPeriods; p++) {
        final int startDaysOffset =
            7 + random.nextInt(60); // Entre 7 et 67 jours
        final int durationDays = 2 + random.nextInt(5); // Entre 2 et 6 jours

        final DateTime periodStart = now.add(Duration(days: startDaysOffset));
        final DateTime periodEnd =
            periodStart.add(Duration(days: durationDays));
        final int roomsAvailable = 3 + random.nextInt(8);
        // Nombre de chambres encore disponibles durant cette période (si ce n'est pas 0)
        final int availableRoomsInPeriod = random.nextInt(roomsAvailable);

        unavailablePeriods.add(UnavailablePeriod(
          startDate: periodStart,
          endDate: periodEnd,
          availableRooms: availableRoomsInPeriod,
        ));
      }

      // Créer la chambre
      rooms.add(HotelRoom(
        id: 'ROOM-${i}-${t}',
        name:
            '${roomType.label} ${t == 0 ? "Standard" : t == 1 ? "Supérieure" : "Deluxe"}',
        description:
            'Chambre ${roomType.label.toLowerCase()} spacieuse et confortable avec ${amenities.hasBalcony ? "balcon et " : ""}tout le confort nécessaire pour un séjour agréable. ${amenities.hasSeaView ? "Vue sur la mer. " : ""}${amenities.hasCityView ? "Vue sur la ville. " : ""}',
        type: roomType,
        pricePerNight: basePrice.roundToDouble(),
        maxAdults: maxAdults,
        maxChildren: maxChildren,
        roomSize: roomSize,
        amenities: amenities,
        images: shuffledRoomImages.take(3).toList(),
        unavailablePeriods: unavailablePeriods,
        availableRooms: availableRoomsCount,
        refundable: refundable,
        bedType: bedType,
        cancellationPolicy: cancellationPolicy,
      ));
    }

    // Créer l'hôtel
    hotels.add(Hotel(
      id: 'HOTEL-${i}',
      name: hotelName,
      description: hotelDescriptions[random.nextInt(hotelDescriptions.length)],
      country: country,
      city: city,
      address: '${random.nextInt(200) + 1}, ${[
        "Rue",
        "Avenue",
        "Boulevard"
      ].elementAt(random.nextInt(3))} ${[
        "Principale",
        "du Centre",
        "de la Gare",
        "de la Liberté"
      ].elementAt(random.nextInt(4))}',
      rating: averageRating,
      starsCount: starsCount,
      reviews: reviews,
      images: shuffledHotelImages.take(4).toList(),
      amenities: HotelAmenities(
        hasWifi: true,
        hasPool: starsCount >= 4 || (starsCount == 3 && random.nextBool()),
        hasRestaurant: starsCount >= 3 || random.nextBool(),
        hasFitnessCenter:
            starsCount >= 4 || (starsCount == 3 && random.nextBool()),
        hasSpa: starsCount >= 4 && random.nextBool(),
        hasRoomService: starsCount >= 3 || random.nextBool(),
        hasAirConditioning: starsCount >= 3 || random.nextBool(),
        hasParking: true,
        hasConferenceRoom: starsCount >= 4 && random.nextBool(),
        hasChildrenActivities: starsCount >= 4 && random.nextBool(),
        hasBusiness: starsCount >= 4 || (starsCount == 3 && random.nextBool()),
        hasAccessibility: random.nextBool(),
      ),
      rooms: rooms,
      checkInTime: "14:00",
      checkOutTime: "11:00",
      houseRules: selectedRules,
      latitude:
          0, // Ces valeurs seraient à remplacer par des coordonnées réelles
      longitude: 0,
    ));
  }

  return hotels;
}
