// lib/features/bus_booking/widgets/bus_amenities_row.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../models/bus_mock_data.dart';

class BusAmenitiesRow extends StatelessWidget {
  final BusAmenities amenities;

  const BusAmenitiesRow({
    super.key,
    required this.amenities,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (amenities.hasAirConditioning)
            _buildAmenityChip(
              icon: FontAwesomeIcons.snowflake,
              label: 'Climatisation',
            ),
          if (amenities.hasToilet)
            _buildAmenityChip(
              icon: FontAwesomeIcons.toilet,
              label: 'Toilettes',
            ),
          if (amenities.hasLunch)
            _buildAmenityChip(
              icon: FontAwesomeIcons.utensils,
              label: 'Déjeuner',
            ),
          if (amenities.hasDrinks)
            _buildAmenityChip(
              icon: FontAwesomeIcons.wineGlass,
              label: 'Boissons',
            ),
          if (amenities.hasWifi)
            _buildAmenityChip(
              icon: FontAwesomeIcons.wifi,
              label: 'WiFi',
            ),
          if (amenities.hasUSBCharging)
            _buildAmenityChip(
              icon: FontAwesomeIcons.bolt,
              label: 'USB',
            ),
          if (amenities.hasTv)
            _buildAmenityChip(
              icon: FontAwesomeIcons.tv,
              label: 'TV',
            ),
          if (amenities.hasLuggageSpace)
            _buildAmenityChip(
              icon: FontAwesomeIcons.suitcase,
              label: 'Bagages',
            ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip({
    required IconData icon,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              size: 12,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
