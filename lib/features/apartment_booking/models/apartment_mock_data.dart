// lib/features/apartment_booking/models/apartment_sort_option.dart

import '../data/mock_data.dart';

enum ApartmentSortOption {
  priceAsc('Prix (croissant)'),
  priceDesc('Prix (décroissant)'),
  surfaceAsc('Surface (croissant)'),
  surfaceDesc('Surface (décroissant)'),
  ratingDesc('Mieux notés'),
  newest('Plus récents'),
  distanceAsc('Distance (proche)'),
  availabilityAsc('Disponibilité (plus tôt)');

  final String label;
  const ApartmentSortOption(this.label);

  int compare(Apartment a, Apartment b) {
    switch (this) {
      case ApartmentSortOption.priceAsc:
        return a.price.compareTo(b.price);
      case ApartmentSortOption.priceDesc:
        return b.price.compareTo(a.price);
      case ApartmentSortOption.surfaceAsc:
        return a.surface.compareTo(b.surface);
      case ApartmentSortOption.surfaceDesc:
        return b.surface.compareTo(a.surface);
      case ApartmentSortOption.ratingDesc:
        return b.rating.compareTo(a.rating);
      case ApartmentSortOption.newest:
        // Assuming we add a 'listedDate' field to Apartment model
        return 0; // To be implemented
      case ApartmentSortOption.distanceAsc:
        // Assuming we add a 'distanceToCenter' field to Apartment model
        return 0; // To be implemented
      case ApartmentSortOption.availabilityAsc:
        // Assuming we add an 'availableFrom' field to Apartment model
        return 0; // To be implemented
    }
  }
}
