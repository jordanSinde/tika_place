import '../../../features/home/models/destination.dart';

abstract class DestinationsMock {
  static const List<Destination> popularDestinations = [
    Destination(
      id: '1',
      city: 'Dubai',
      country: 'UAE',
      imageUrl: 'assets/images/images/dubai.png',
      price: '980',
      hasHotels: true,
      description: 'Experience luxury in the heart of the desert',
    ),
    Destination(
      id: '2',
      city: 'Sydney',
      country: 'Australia',
      imageUrl: 'assets/images/cities/image-3.png',
      hasHotels: true,
      description: 'Iconic landmarks and stunning harbors',
    ),
    Destination(
      id: '3',
      city: 'Rome',
      country: 'Italy',
      imageUrl: 'assets/images/cities/image-1.png',
      price: '340',
      hasHotels: true,
      description: 'Ancient history meets modern culture',
    ),
    Destination(
      id: '4',
      city: 'Tokyo',
      country: 'Japan',
      imageUrl: 'assets/images/cities/image-2.png',
      hasHotels: true,
      description: 'Where tradition meets innovation',
    ),
  ];
}
