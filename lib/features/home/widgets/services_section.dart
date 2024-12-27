import 'package:flutter/material.dart';
import '../../../core/config/theme/app_colors.dart';

class ServiceSection extends StatelessWidget {
  const ServiceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              _buildServiceButton(
                icon: Icons.flight,
                label: 'Flights',
                isSelected: true,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _buildServiceButton(
                icon: Icons.hotel,
                label: 'Hotel',
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _buildServiceButton(
                icon: Icons.directions_car,
                label: 'Car Rentals',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Stopover',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusButton(
            label: 'Manage Booking / Check in',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildStatusButton(
            label: 'Flight Status',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Expanded(
      child: Material(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
