// lib/features/bus_booking/widgets/bus_filter_panel.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/config/theme/app_colors.dart';
import '../home/models/bus_mock_data.dart';

class BusFilterPanel extends StatefulWidget {
  final BusSearchFilters initialFilters;
  final Function(BusSearchFilters) onFiltersChanged;
  final List<String> agencies; // Liste des agences disponibles

  const BusFilterPanel({
    super.key,
    required this.initialFilters,
    required this.onFiltersChanged,
    required this.agencies,
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

  // Liste des villes (à récupérer depuis mes données)
  final List<String> _cities = [
    'Douala',
    'Yaoundé',
    'Bafoussam',
    'Bamenda',
    'Buea',
    'Kribi',
    'Garoua',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Important pour le sizing
        children: [
          // Sélection des villes
          _buildCitySelector(
            label: 'Ville de départ',
            value: _filters.departureCity,
            onChanged: (newCity) {
              setState(() {
                _filters = _filters.copyWith(departureCity: newCity);
              });
              widget.onFiltersChanged(_filters);
            },
          ),
          const SizedBox(height: 16),

          _buildCitySelector(
            label: 'Ville d\'arrivée',
            value: _filters.arrivalCity,
            onChanged: (newCity) {
              setState(() {
                _filters = _filters.copyWith(arrivalCity: newCity);
              });
              widget.onFiltersChanged(_filters);
            },
          ),
          const SizedBox(height: 16),

          // Date et Heure
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(context),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTimePicker(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sélecteur d'agence
          _buildAgencySelector(),
          const SizedBox(height: 16),

          // Le reste de vos filtres existants...
          _buildSectionTitle('Classe'),
          _buildBusClassFilter(),
          const SizedBox(height: 16),

          _buildSectionTitle('Prix (FCFA)'),
          _buildPriceRangeFilter(),
          const SizedBox(height: 16),

          _buildSectionTitle('Commodités'),
          _buildAmenitiesFilter(),
        ],
      ),
    );
  }

  Widget _buildCitySelector({
    required String label,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Toutes les villes'),
            ),
            ..._cities.map((city) => DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                )),
          ],
          onChanged: onChanged,
        ),
      ],
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

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _filters.departureDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 90)),
            );
            if (picked != null) {
              setState(() {
                _filters = _filters.copyWith(departureDate: picked);
              });
              widget.onFiltersChanged(_filters);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16), //
                const SizedBox(width: 8),
                Text(
                  _filters.departureDate != null
                      ? DateFormat('dd/MM/yyyy').format(_filters.departureDate!)
                      : 'Sélectionner',
                ),
                const Spacer(),
                if (_filters.departureDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _filters = _filters.copyWith(departureDate: null);
                      });
                      widget.onFiltersChanged(_filters);
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Heure',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: _filters.departureTime ?? TimeOfDay.now(),
            );
            if (picked != null) {
              setState(() {
                _filters = _filters.copyWith(departureTime: picked);
              });
              widget.onFiltersChanged(_filters);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 8),
                Text(
                  _filters.departureTime != null
                      ? _filters.departureTime!.format(context)
                      : 'Sélectionner',
                ),
                const Spacer(),
                if (_filters.departureTime != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _filters = _filters.copyWith(departureTime: null);
                      });
                      widget.onFiltersChanged(_filters);
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Agence',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _filters.company,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Toutes les agences'),
            ),
            ...widget.agencies.map((agency) => DropdownMenuItem<String>(
                  value: agency,
                  child: Text(agency),
                )),
          ],
          onChanged: (newAgency) {
            setState(() {
              _filters = _filters.copyWith(company: newAgency);
            });
            widget.onFiltersChanged(_filters);
          },
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${NumberFormat('#,###').format(_priceRange.start.round())} FCFA',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${NumberFormat('#,###').format(_priceRange.end.round())} FCFA',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _priceRange,
          min: _minPrice,
          max: _maxPrice,
          divisions: ((_maxPrice - _minPrice) / 1000).round(),
          activeColor: AppColors.success,
          inactiveColor: AppColors.background,
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
      ],
    );
  }

  Widget _buildBusClassFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
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
          selectedColor: AppColors.success,
          backgroundColor: AppColors.background,
          labelStyle: TextStyle(
            color: _filters.busClass == busClass
                ? Colors.white
                : AppColors.textSecondary,
          ),
          checkmarkColor: Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildAmenitiesFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildAmenityFilter(
          'Climatisation',
          Icons.ac_unit,
          Icons.ac_unit_outlined,
          _filters.requiredAmenities?.hasAirConditioning ?? false,
          (value) => _updateAmenities(hasAirConditioning: value),
        ),
        _buildAmenityFilter(
          'Toilettes',
          Icons.wc,
          Icons.no_adult_content_outlined,
          _filters.requiredAmenities?.hasToilet ?? false,
          (value) => _updateAmenities(hasToilet: value),
        ),
        _buildAmenityFilter(
          'Déjeuner',
          Icons.restaurant,
          Icons.no_meals_outlined,
          _filters.requiredAmenities?.hasLunch ?? false,
          (value) => _updateAmenities(hasLunch: value),
        ),
        _buildAmenityFilter(
          'WiFi',
          Icons.wifi,
          Icons.wifi_off,
          _filters.requiredAmenities?.hasWifi ?? false,
          (value) => _updateAmenities(hasWifi: value),
        ),
        _buildAmenityFilter(
          'USB',
          Icons.usb,
          Icons.usb_off,
          _filters.requiredAmenities?.hasUSBCharging ?? false,
          (value) => _updateAmenities(hasUSBCharging: value),
        ),
      ],
    );
  }

  void _updateAmenities({
    bool? hasAirConditioning,
    bool? hasToilet,
    bool? hasLunch,
    bool? hasWifi,
    bool? hasUSBCharging,
    bool? hasTv,
  }) {
    final currentAmenities = _filters.requiredAmenities ?? const BusAmenities();
    final newAmenities = BusAmenities(
      hasAirConditioning:
          hasAirConditioning ?? currentAmenities.hasAirConditioning,
      hasToilet: hasToilet ?? currentAmenities.hasToilet,
      hasLunch: hasLunch ?? currentAmenities.hasLunch,
      hasWifi: hasWifi ?? currentAmenities.hasWifi,
      hasUSBCharging: hasUSBCharging ?? currentAmenities.hasUSBCharging,
      hasTv: hasTv ?? currentAmenities.hasTv,
    );

    setState(() {
      _filters = _filters.copyWith(requiredAmenities: newAmenities);
    });
    widget.onFiltersChanged(_filters);
  }

  Widget _buildAmenityFilter(
    String label,
    IconData availableIcon,
    IconData unavailableIcon,
    bool value,
    Function(bool) onChanged,
  ) {
    return FilterChip(
      selected: value,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            value ? availableIcon : unavailableIcon,
            size: 16,
            color: value ? Colors.white : AppColors.textLight,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: onChanged,
      selectedColor: AppColors.success,
      backgroundColor: AppColors.background,
      checkmarkColor: Colors.transparent,
    );
  }
}
