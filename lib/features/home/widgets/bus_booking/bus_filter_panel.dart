// lib/features/bus_booking/widgets/bus_filter_panel.dart

import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../models/bus_mock_data.dart';

class BusFilterPanel extends StatefulWidget {
  final BusSearchFilters initialFilters;
  final Function(BusSearchFilters) onFiltersChanged;

  const BusFilterPanel({
    super.key,
    required this.initialFilters,
    required this.onFiltersChanged,
  });

  @override
  State<BusFilterPanel> createState() => _BusFilterPanelState();
}

class _BusFilterPanelState extends State<BusFilterPanel> {
  late BusSearchFilters _filters;
  late RangeValues _priceRange;
  final double _minPrice = 5000;
  final double _maxPrice = 30000;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _priceRange =
        widget.initialFilters.priceRange ?? RangeValues(_minPrice, _maxPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Classes de bus
          _buildSectionTitle('Classe'),
          Wrap(
            spacing: 8,
            children: BusClass.values.map((busClass) {
              return FilterChip(
                selected: _filters.busClass == busClass,
                label: Text(busClass.label),
                onSelected: (selected) {
                  setState(() {
                    _filters = _filters.copyWith(
                      busClass: selected ? busClass : null,
                    );
                  });
                  widget.onFiltersChanged(_filters);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Plage de prix
          _buildSectionTitle('Prix (FCFA)'),
          RangeSlider(
            values: _priceRange,
            min: _minPrice,
            max: _maxPrice,
            divisions: ((_maxPrice - _minPrice) / 1000).round(),
            labels: RangeLabels(
              '${_priceRange.start.round()} FCFA',
              '${_priceRange.end.round()} FCFA',
            ),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
                _filters = _filters.copyWith(priceRange: values);
              });
              widget.onFiltersChanged(_filters);
            },
          ),
          const SizedBox(height: 16),

          // Commodités
          _buildSectionTitle('Commodités'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAmenityFilter(
                  'Climatisation',
                  Icons.ac_unit,
                  _filters.requiredAmenities?.hasAirConditioning ?? false,
                  (value) => _updateAmenities(hasAirConditioning: value)),
              _buildAmenityFilter(
                  'Toilettes',
                  Icons.wc,
                  _filters.requiredAmenities?.hasToilet ?? false,
                  (value) => _updateAmenities(hasToilet: value)),
              _buildAmenityFilter(
                  'Déjeuner',
                  Icons.restaurant,
                  _filters.requiredAmenities?.hasLunch ?? false,
                  (value) => _updateAmenities(hasLunch: value)),
              _buildAmenityFilter(
                  'WiFi',
                  Icons.wifi,
                  _filters.requiredAmenities?.hasWifi ?? false,
                  (value) => _updateAmenities(hasWifi: value)),
              _buildAmenityFilter(
                  'USB',
                  Icons.usb,
                  _filters.requiredAmenities?.hasUSBCharging ?? false,
                  (value) => _updateAmenities(hasUSBCharging: value)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildAmenityFilter(
    String label,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return FilterChip(
      selected: value,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: value ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: onChanged,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
    );
  }

  void _updateAmenities({
    bool? hasAirConditioning,
    bool? hasToilet,
    bool? hasLunch,
    bool? hasWifi,
    bool? hasUSBCharging,
  }) {
    final currentAmenities = _filters.requiredAmenities ?? const BusAmenities();
    final newAmenities = BusAmenities(
      hasAirConditioning:
          hasAirConditioning ?? currentAmenities.hasAirConditioning,
      hasToilet: hasToilet ?? currentAmenities.hasToilet,
      hasLunch: hasLunch ?? currentAmenities.hasLunch,
      hasWifi: hasWifi ?? currentAmenities.hasWifi,
      hasUSBCharging: hasUSBCharging ?? currentAmenities.hasUSBCharging,
    );

    setState(() {
      _filters = _filters.copyWith(requiredAmenities: newAmenities);
    });
    widget.onFiltersChanged(_filters);
  }
}
