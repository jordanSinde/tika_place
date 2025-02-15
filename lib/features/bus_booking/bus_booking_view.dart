// lib/features/home/widgets/bus_booking/bus_booking_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/theme/app_colors.dart';
import '../home/models/bus_and_utility_models.dart';
import 'bus_search_card.dart';
import 'package:go_router/go_router.dart';

enum BusClass { economy, business, vip }

// lib/features/bus_booking/screens/bus_booking_view.dart

class BusBookingView extends ConsumerWidget {
  const BusBookingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Formulaire de recherche
          BusSearchCard(
            onSearch: (searchParams) {
              // Créer les filtres à partir des paramètres de recherche
              final filters = BusSearchFilters(
                departureCity: searchParams['departureCity'] as String?,
                arrivalCity: searchParams['arrivalCity'] as String?,
                departureDate: searchParams['date'] as DateTime?,
                departureTime: searchParams['time'] as TimeOfDay?,
              );

              // Naviguer vers la liste des bus avec les filtres
              context.go('/bus-list', extra: {'filters': filters});
            },
          ),

          // Section des trajets populaires
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trajets populaires',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildPopularRoutes(),
              ],
            ),
          ),

          // Informations supplémentaires
          _buildInfoSection(context),
        ],
      ),
    );
  }

  Widget _buildPopularRoutes() {
    return Column(
      children: [
        _buildPopularRouteCard(
          departureCity: 'Douala',
          arrivalCity: 'Yaoundé',
          duration: '4h',
          minPrice: 6000,
        ),
        const SizedBox(height: 12),
        _buildPopularRouteCard(
          departureCity: 'Yaoundé',
          arrivalCity: 'Bafoussam',
          duration: '5h',
          minPrice: 7000,
        ),
        const SizedBox(height: 12),
        _buildPopularRouteCard(
          departureCity: 'Douala',
          arrivalCity: 'Kribi',
          duration: '3h',
          minPrice: 5000,
        ),
      ],
    );
  }

  Widget _buildPopularRouteCard({
    required String departureCity,
    required String arrivalCity,
    required String duration,
    required int minPrice,
  }) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          // Naviguer vers la liste des bus avec les filtres préremplis
          final filters = BusSearchFilters(
            departureCity: departureCity,
            arrivalCity: arrivalCity,
          );
          context.go('/bus-list', extra: {'filters': filters});
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          departureCity,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      height: 20,
                      width: 1,
                      color: AppColors.divider,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          arrivalCity,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: AppColors.divider,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'À partir de',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '$minPrice FCFA',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations importantes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.info_outline,
            text: 'Arrivez 30 minutes avant le départ',
          ),
          _buildInfoItem(
            icon: Icons.card_membership,
            text: 'Une pièce d\'identité est requise',
          ),
          _buildInfoItem(
            icon: Icons.luggage,
            text: 'Un bagage en soute gratuit',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
