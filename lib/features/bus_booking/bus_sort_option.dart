// lib/features/bus_booking/models/bus_sort_options.dart

import '../home/models/bus_mock_data.dart';

enum BusSortOption {
  departureTimeAsc('Départ (plus tôt)'),
  departureTimeDesc('Départ (plus tard)'),
  priceAsc('Prix (croissant)'),
  priceDesc('Prix (décroissant)'),
  durationAsc('Durée (plus court)'),
  durationDesc('Durée (plus long)'),
  availabilityDesc('Places disponibles'),
  ratingDesc('Mieux notés');

  final String label;
  const BusSortOption(this.label);

  int compare(Bus a, Bus b) {
    switch (this) {
      case BusSortOption.departureTimeAsc:
        return a.departureTime.compareTo(b.departureTime);
      case BusSortOption.departureTimeDesc:
        return b.departureTime.compareTo(a.departureTime);
      case BusSortOption.priceAsc:
        return a.price.compareTo(b.price);
      case BusSortOption.priceDesc:
        return b.price.compareTo(a.price);
      case BusSortOption.durationAsc:
        return (a.arrivalTime.difference(a.departureTime))
            .compareTo(b.arrivalTime.difference(b.departureTime));
      case BusSortOption.durationDesc:
        return (b.arrivalTime.difference(b.departureTime))
            .compareTo(a.arrivalTime.difference(a.departureTime));
      case BusSortOption.availabilityDesc:
        return b.availableSeats.compareTo(a.availableSeats);
      case BusSortOption.ratingDesc:
        return b.rating.compareTo(a.rating);
    }
  }
}
