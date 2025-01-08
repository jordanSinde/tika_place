// lib/features/home/models/apartment_mock_data.dart

class Apartment {
  final String id;
  final String title;
  final String location;
  final double price;
  final List<String> images;
  final int bedrooms;
  final int bathrooms;
  final double surface;
  final List<String> amenities;
  final String description;
  final RentalType rentalType;
  final String ownerName;
  final String ownerAvatar;
  final double rating;
  final int reviews;

  const Apartment({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.images,
    required this.bedrooms,
    required this.bathrooms,
    required this.surface,
    required this.amenities,
    required this.description,
    required this.rentalType,
    required this.ownerName,
    required this.ownerAvatar,
    required this.rating,
    required this.reviews,
  });
}

enum RentalType {
  shortTerm('Court terme'),
  longTerm('Long terme');

  final String label;
  const RentalType(this.label);
}

final List<Apartment> mockApartments = [
  const Apartment(
    id: '1',
    title: 'Appartement Moderne à Bonapriso',
    location: 'Bonapriso, Douala',
    price: 450000,
    images: [
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
      'https://images.unsplash.com/photo-1484154218962-a197022b5858',
    ],
    bedrooms: 3,
    bathrooms: 2,
    surface: 120,
    amenities: [
      'Wifi',
      'Climatisation',
      'Cuisine équipée',
      'Balcon',
      'Parking',
      'Sécurité 24/7'
    ],
    description:
        'Magnifique appartement moderne avec vue sur la ville. Entièrement meublé et équipé.',
    rentalType: RentalType.longTerm,
    ownerName: 'Jean Pierre',
    ownerAvatar: 'https://i.pravatar.cc/150?img=1',
    rating: 4.8,
    reviews: 24,
  ),
  const Apartment(
    id: '2',
    title: 'Studio Meublé à Bastos',
    location: 'Bastos, Yaoundé',
    price: 250000,
    images: [
      'https://images.unsplash.com/photo-1536376072261-38c75010e6c9',
      'https://images.unsplash.com/photo-1507089947368-19c1da9775ae',
    ],
    bedrooms: 1,
    bathrooms: 1,
    surface: 45,
    amenities: ['Wifi', 'Climatisation', 'Cuisine équipée', 'Ascenseur'],
    description:
        'Studio moderne et confortable, idéal pour les professionnels.',
    rentalType: RentalType.shortTerm,
    ownerName: 'Marie Claire',
    ownerAvatar: 'https://i.pravatar.cc/150?img=5',
    rating: 4.6,
    reviews: 18,
  ),
  const Apartment(
    id: '3',
    title: 'Villa de Luxe à Bonanjo',
    location: 'Bonanjo, Douala',
    price: 850000,
    images: [
      'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
      'https://images.unsplash.com/photo-1613545325278-f24b0cae1224',
    ],
    bedrooms: 4,
    bathrooms: 3,
    surface: 250,
    amenities: [
      'Piscine',
      'Jardin',
      'Garage',
      'Climatisation',
      'Sécurité 24/7',
      'Cuisine équipée'
    ],
    description:
        'Magnifique villa avec piscine et jardin, dans un quartier prisé.',
    rentalType: RentalType.longTerm,
    ownerName: 'Robert Manga',
    ownerAvatar: 'https://i.pravatar.cc/150?img=3',
    rating: 4.9,
    reviews: 32,
  ),
];
