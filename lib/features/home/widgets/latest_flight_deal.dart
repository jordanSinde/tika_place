import 'package:flutter/material.dart';
import '../../../core/config/theme/app_colors.dart';

class LatestFlightDeals extends StatelessWidget {
  const LatestFlightDeals({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Latest Flight Deals',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildDealCard(
                context: context,
                imageUrl: 'assets/images/tour/tour-4.png',
                from: 'Dubai',
                to: 'Maldives',
                dates: '14 Aug, 2023 - 20 Aug 2023',
                price: 980,
                travelClass: 'Business Class',
              ),
              const SizedBox(width: 16),
              // Ajoutez d'autres cartes ici
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDealCard({
    required BuildContext context,
    required String imageUrl,
    required String from,
    required String to,
    required String dates,
    required int price,
    required String travelClass,
  }) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route
                Text(
                  '$from to $to',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                // Dates
                Text(
                  dates,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                ),
                const SizedBox(height: 16),
                // Prix et Classe
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          travelClass,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '\$$price',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Booking Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
