// lib/features/bus_booking/widgets/bus_sort_selector.dart

import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';
import 'bus_sort_option.dart';

class BusSortSelector extends StatelessWidget {
  final BusSortOption selectedOption;
  final Function(BusSortOption) onSortChanged;

  const BusSortSelector({
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
          trailing: PopupMenuButton<BusSortOption>(
            initialValue: selectedOption,
            onSelected: onSortChanged,
            itemBuilder: (context) => BusSortOption.values
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

  PopupMenuItem<BusSortOption> _buildSortMenuItem(
    BuildContext context,
    BusSortOption option,
  ) {
    IconData getIconForOption() {
      switch (option) {
        case BusSortOption.departureTimeAsc:
          return Icons.access_time;
        case BusSortOption.departureTimeDesc:
          return Icons.access_time;
        case BusSortOption.priceAsc:
          return Icons.arrow_upward;
        case BusSortOption.priceDesc:
          return Icons.arrow_downward;
        case BusSortOption.durationAsc:
          return Icons.speed;
        case BusSortOption.durationDesc:
          return Icons.speed;
        case BusSortOption.availabilityDesc:
          return Icons.event_seat;
        case BusSortOption.ratingDesc:
          return Icons.star;
      }
    }

    return PopupMenuItem<BusSortOption>(
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
