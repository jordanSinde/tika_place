// lib/features/apartment/screens/apartment_booking_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/config/theme/app_colors.dart';
import 'apartment_search_card.dart';
import 'models/apartment_mock_data.dart';

class ApartmentBookingView extends ConsumerWidget {
  const ApartmentBookingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Carte de recherche
          ApartmentSearchCard(
            onSearch: (filters) {
              context.go('/apartments/list', extra: {'filters': filters});
            },
          ),

          // Section appartements en vedette
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'En Vedette',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeaturedApartments(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedApartments(BuildContext context) {
    final featuredApartments = generateMockApartments()
        .where((apartment) => apartment.apartmentClass == ApartmentClass.luxe)
        .take(3)
        .toList();

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: featuredApartments.length,
        itemBuilder: (context, index) {
          final apartment = featuredApartments[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            child: _buildFeaturedApartmentCard(context, apartment),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedApartmentCard(
      BuildContext context, Apartment apartment) {
    return GestureDetector(
      onTap: () {
        // Définir une période par défaut (par exemple, une semaine à partir d'aujourd'hui)
        final DateTime defaultStartDate =
            DateTime.now().add(const Duration(days: 1));
        final DateTime defaultEndDate =
            defaultStartDate.add(const Duration(days: 7));

        context.push('/apartments/details', extra: {
          'apartment': apartment,
          'initialStartDate': defaultStartDate,
          'initialEndDate': defaultEndDate,
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Ajout de cette ligne
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                // Utilisation de AspectRatio pour contrôler la taille
                aspectRatio: 16 / 9,
                child: Image.network(
                  apartment.images.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.background,
                    child: const Icon(Icons.apartment, size: 48),
                  ),
                ),
              ),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Ajout de cette ligne
                children: [
                  Row(
                    children: [
                      Text(
                        apartment.apartmentClass.label,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.star, size: 16, color: Colors.amber[600]),
                      const SizedBox(width: 4),
                      Text(
                        apartment.rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    apartment.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${apartment.district}, ${apartment.city}',
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${NumberFormat('#,###').format(apartment.pricePerDay)} FCFA',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
