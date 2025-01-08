// lib/features/home/models/bus_mock_data.dart

class Bus {
  final String id;
  final String company;
  final String departureCity;
  final String arrivalCity;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final BusClass busClass;
  final double price;
  final int availableSeats;
  final List<String> amenities;
  final String busNumber;
  final double rating;
  final int reviews;

  const Bus({
    required this.id,
    required this.company,
    required this.departureCity,
    required this.arrivalCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.busClass,
    required this.price,
    required this.availableSeats,
    required this.amenities,
    required this.busNumber,
    required this.rating,
    required this.reviews,
  });
}

enum BusClass {
  economy('Économique', 1.0),
  business('Business', 1.5),
  vip('VIP', 2.0);

  final String label;
  final double priceMultiplier;
  const BusClass(this.label, this.priceMultiplier);
}

final List<Bus> mockBuses = [
  Bus(
    id: '1',
    company: 'Finex Voyages',
    departureCity: 'Douala',
    arrivalCity: 'Yaoundé',
    departureTime: DateTime.now().add(const Duration(hours: 2)),
    arrivalTime: DateTime.now().add(const Duration(hours: 6)),
    busClass: BusClass.vip,
    price: 7000,
    availableSeats: 15,
    amenities: ['Wifi', 'Climatisation', 'USB', 'Collation'],
    busNumber: 'FX-001',
    rating: 4.8,
    reviews: 245,
  ),
  Bus(
    id: '2',
    company: 'Générale Express',
    departureCity: 'Yaoundé',
    arrivalCity: 'Douala',
    departureTime: DateTime.now().add(const Duration(hours: 3)),
    arrivalTime: DateTime.now().add(const Duration(hours: 7)),
    busClass: BusClass.business,
    price: 5000,
    availableSeats: 20,
    amenities: ['Climatisation', 'USB'],
    busNumber: 'GE-102',
    rating: 4.5,
    reviews: 180,
  ),
  Bus(
    id: '3',
    company: 'Buca Voyages',
    departureCity: 'Douala',
    arrivalCity: 'Buea',
    departureTime: DateTime.now().add(const Duration(hours: 1)),
    arrivalTime: DateTime.now().add(const Duration(hours: 4)),
    busClass: BusClass.economy,
    price: 3000,
    availableSeats: 25,
    amenities: ['Climatisation'],
    busNumber: 'BV-203',
    rating: 4.2,
    reviews: 156,
  ),
];

class Seat {
  final String id;
  final int number;
  final bool isAvailable;
  final bool isWindow;

  const Seat({
    required this.id,
    required this.number,
    required this.isAvailable,
    required this.isWindow,
  });
}

List<Seat> generateMockSeats(int totalSeats, int availableSeats) {
  final List<Seat> seats = [];
  for (int i = 1; i <= totalSeats; i++) {
    seats.add(Seat(
      id: 'S$i',
      number: i,
      isAvailable: i <= availableSeats,
      isWindow: i % 2 == 0,
    ));
  }
  return seats;
}

class Ticket {
  final String id;
  final Bus bus;
  final List<int> seatNumbers;
  final String passengerName;
  final String phoneNumber;
  final DateTime purchaseDate;
  final double totalPrice;

  const Ticket({
    required this.id,
    required this.bus,
    required this.seatNumbers,
    required this.passengerName,
    required this.phoneNumber,
    required this.purchaseDate,
    required this.totalPrice,
  });
}
