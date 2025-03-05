// lib/features/apartment/widgets/apartment_sort_selector.dart

import 'package:flutter/material.dart';
import '../../../core/config/theme/app_colors.dart';
import '../screens/apartment_list_screen.dart';

class ApartmentSortSelector extends StatelessWidget {
  final ApartmentSortOption selectedOption;
  final Function(ApartmentSortOption) onSortChanged;

  const ApartmentSortSelector({
    super.key,
    required this.selectedOption,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Row(
            children: [
              const Icon(Icons.sort, color: AppColors.textLight),
              const SizedBox(width: 8),
              Text(
                'Trier par',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          trailing: PopupMenuButton<ApartmentSortOption>(
            initialValue: selectedOption,
            onSelected: onSortChanged,
            itemBuilder: (context) => ApartmentSortOption.values
                .map((option) => _buildSortMenuItem(context, option))
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedOption.label,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  PopupMenuItem<ApartmentSortOption> _buildSortMenuItem(
    BuildContext context,
    ApartmentSortOption option,
  ) {
    IconData getIconForOption() {
      switch (option) {
        case ApartmentSortOption.priceAsc:
          return Icons.arrow_upward;
        case ApartmentSortOption.priceDesc:
          return Icons.arrow_downward;
        case ApartmentSortOption.surfaceAsc:
          return Icons.square_foot;
        case ApartmentSortOption.surfaceDesc:
          return Icons.square_foot;
        case ApartmentSortOption.ratingDesc:
          return Icons.star;
        case ApartmentSortOption.availabilityAsc:
          return Icons.event_available;
      }
    }

    return PopupMenuItem<ApartmentSortOption>(
      value: option,
      child: Row(
        children: [
          Icon(
            getIconForOption(),
            color: selectedOption == option ? AppColors.secondary : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            option.label,
            style: TextStyle(
              color: selectedOption == option ? AppColors.secondary : null,
              fontWeight: selectedOption == option ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}
