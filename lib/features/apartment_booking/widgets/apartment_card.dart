// lib/features/apartment/widgets/apartment_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/config/theme/app_colors.dart';
import '../models/apartment_mock_data.dart';

class ApartmentCard extends StatelessWidget {
  final Apartment apartment;
  final VoidCallback onPressed;
  final DateTime? checkStartDate;
  final DateTime? checkEndDate;

  const ApartmentCard({
    super.key,
    required this.apartment,
    required this.onPressed,
    this.checkStartDate,
    this.checkEndDate,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDateRange = checkStartDate != null && checkEndDate != null;
    final bool isAvailable = hasDateRange
        ? apartment.isAvailableForPeriod(checkStartDate!, checkEndDate!)
        : true;

    final DateTime? nextAvailable = hasDateRange && !isAvailable
        ? apartment.getNextAvailableDateAfter(checkStartDate!)
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image section avec aspect ratio fixe
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image avec placeholder
                        Image.network(
                          apartment.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: AppColors.background,
                            child: const Icon(
                              Icons.apartment,
                              size: 48,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                        // Badges
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _buildBadge(
                            text: apartment.apartmentClass.label,
                            color: Colors.white.withOpacity(0.9),
                            textColor: AppColors.primary,
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: _buildBadge(
                            text: '${apartment.rating}',
                            icon: Icons.star,
                            color: AppColors.secondary.withOpacity(0.9),
                            textColor: Colors.white,
                          ),
                        ),

                        // Badge de disponibilité
                        if (hasDateRange)
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: _buildBadge(
                              text: isAvailable ? 'Disponible' : 'Indisponible',
                              icon: isAvailable
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: isAvailable
                                  ? Colors.green.withOpacity(0.9)
                                  : Colors.red.withOpacity(0.9),
                              textColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Contenu
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apartment.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildLocation(),
                    const SizedBox(height: 8),
                    _buildFeatures(),
                    const SizedBox(height: 8),

                    // Information sur la disponibilité
                    if (hasDateRange && !isAvailable && nextAvailable != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Prochaine disponibilité: ${DateFormat('dd/MM/yyyy').format(nextAvailable)}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),
                    _buildFooter(context, hasDateRange, isAvailable),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge({
    required String text,
    IconData? icon,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        const Icon(
          Icons.location_on,
          size: 16,
          color: AppColors.textLight,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${apartment.district}, ${apartment.city}',
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Row(
      children: [
        _buildFeatureChip(
          icon: Icons.king_bed_outlined,
          label: '${apartment.bedrooms} Ch',
        ),
        const SizedBox(width: 8),
        _buildFeatureChip(
          icon: Icons.bathtub_outlined,
          label: '${apartment.bathrooms} SdB',
        ),
        const SizedBox(width: 8),
        _buildFeatureChip(
          icon: Icons.square_foot,
          label: '${apartment.surface.round()} m²',
        ),
      ],
    );
  }

  Widget _buildFeatureChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
      BuildContext context, bool hasDateRange, bool isAvailable) {
    // Calculer le prix total si des dates ont été sélectionnées
    final String priceText;
    final String priceSubtext;

    if (hasDateRange && checkStartDate != null && checkEndDate != null) {
      final days = checkEndDate!.difference(checkStartDate!).inDays;
      final totalPrice = apartment.pricePerDay * days;

      priceText = '${NumberFormat('#,###').format(totalPrice)} FCFA';
      priceSubtext = 'pour $days ${days > 1 ? 'jours' : 'jour'}';
    } else {
      priceText = '${NumberFormat('#,###').format(apartment.pricePerDay)} FCFA';
      priceSubtext = 'par jour';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              priceText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            Text(
              priceSubtext,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(
          width: 120,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Voir détails',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
