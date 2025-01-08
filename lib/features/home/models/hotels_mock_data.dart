// lib/features/home/models/hotel_mock_data.dart

class Hotel {
  final String id;
  final String name;
  final String location;
  final double rating;
  final int reviews;
  final List<String> images;
  final double price;
  final List<String> amenities;
  final int stars;

  const Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.images,
    required this.price,
    required this.amenities,
    required this.stars,
  });
}

final List<Hotel> mockHotels = [
  const Hotel(
    id: '1',
    name: 'Hilton Yaoundé',
    location: 'Centre ville, Yaoundé',
    rating: 4.8,
    reviews: 524,
    images: [
      'https://images.unsplash.com/photo-1566073771259-6a8506099945',
      'https://images.unsplash.com/photo-1582719508461-905c673771fd',
      'https://images.unsplash.com/photo-1595576508898-0ad5c879a061',
    ],
    price: 75000,
    amenities: [
      'Wifi gratuit',
      'Piscine',
      'Spa',
      'Restaurant',
      'Salle de sport',
      'Bar',
      'Service en chambre'
    ],
    stars: 5,
  ),
  const Hotel(
    id: '2',
    name: 'La Falaise Douala',
    location: 'Akwa, Douala',
    rating: 4.5,
    reviews: 328,
    images: [
      'https://images.unsplash.com/photo-1566073771259-6a8506099945',
      'https://images.unsplash.com/photo-1582719508461-905c673771fd',
    ],
    price: 55000,
    amenities: ['Wifi gratuit', 'Restaurant', 'Bar', 'Service en chambre'],
    stars: 4,
  ),
  const Hotel(
    id: '3',
    name: 'Mont Fébé Hotel',
    location: 'Mont Fébé, Yaoundé',
    rating: 4.7,
    reviews: 412,
    images: [
      'https://images.unsplash.com/photo-1566073771259-6a8506099945',
      'https://images.unsplash.com/photo-1582719508461-905c673771fd',
    ],
    price: 65000,
    amenities: [
      'Wifi gratuit',
      'Piscine',
      'Restaurant',
      'Vue panoramique',
      'Bar'
    ],
    stars: 4,
  ),
];

class Room {
  final String id;
  final String name;
  final String description;
  final double price;
  final int capacity;
  final List<String> amenities;
  final List<String> images;

  const Room({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.capacity,
    required this.amenities,
    required this.images,
  });
}

final List<Room> mockRooms = [
  const Room(
    id: '1',
    name: 'Chambre Deluxe',
    description: 'Chambre spacieuse avec vue sur la ville',
    price: 75000,
    capacity: 2,
    amenities: [
      'Lit King size',
      'Balcon privé',
      'Mini-bar',
      'Coffre-fort',
      'TV LED'
    ],
    images: [
      'https://images.unsplash.com/photo-1566073771259-6a8506099945',
      'https://images.unsplash.com/photo-1582719508461-905c673771fd',
    ],
  ),
  const Room(
    id: '2',
    name: 'Suite Junior',
    description: 'Suite élégante avec salon séparé',
    price: 120000,
    capacity: 3,
    amenities: [
      'Lit King size',
      'Salon séparé',
      'Baignoire jacuzzi',
      'Mini-bar',
      'Machine à café'
    ],
    images: [
      'https://images.unsplash.com/photo-1566073771259-6a8506099945',
      'https://images.unsplash.com/photo-1582719508461-905c673771fd',
    ],
  ),
];
