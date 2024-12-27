import 'package:flutter/material.dart';
import '../../../core/config/theme/app_colors.dart';

class DestinationSelector extends StatelessWidget {
  final String from;
  final String to;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final VoidCallback onSwapTap;

  const DestinationSelector({
    super.key,
    required this.from,
    required this.to,
    required this.onFromTap,
    required this.onToTap,
    required this.onSwapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDestinationField(
            label: 'From',
            value: from,
            onTap: onFromTap,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: Divider()),
              IconButton(
                onPressed: onSwapTap,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_vert,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 8),
          _buildDestinationField(
            label: 'To',
            value: to,
            onTap: onToTap,
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(
              Icons.flight_takeoff,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
