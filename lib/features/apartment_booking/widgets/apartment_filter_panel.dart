// lib/features/apartment/widgets/apartment_filter_panel.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/config/theme/app_colors.dart';
import '../models/apartment_mock_data.dart';

class ApartmentFilterPanel extends StatefulWidget {
  final ApartmentSearchFilters initialFilters;
  final Function(ApartmentSearchFilters) onFiltersChanged;

  const ApartmentFilterPanel({
    super.key,
    required this.initialFilters,
    required this.onFiltersChanged,
  });

  @override
  State<ApartmentFilterPanel> createState() => _ApartmentFilterPanelState();
}

class _ApartmentFilterPanelState extends State<ApartmentFilterPanel> {
  late ApartmentSearchFilters _filters;
  late RangeValues _priceRange;
  final double _minPrice = 50000;
  final double _maxPrice = 1000000;
  int _bedrooms = 1;
  double _minSurface = 0;
  List<String> _availableDistricts = [];

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _priceRange = _filters.priceRange ?? RangeValues(_minPrice, _maxPrice);
    _bedrooms = _filters.minBedrooms ?? 1;
    _minSurface = _filters.minSurface ?? 0;
    _updateAvailableDistricts();
  }

  void _updateAvailableDistricts() {
    if (_filters.city != null) {
      _availableDistricts = cityData[_filters.city!]
              ?.values
              .expand((districts) => districts)
              .toList() ??
          [];
    } else {
      _availableDistricts = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Localisation
          _buildSectionTitle('Localisation'),
          _buildCitySelector(),
          if (_availableDistricts.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDistrictSelector(),
          ],
          const SizedBox(height: 16),

          // Type de location
          _buildSectionTitle('Type de location'),
          _buildRentalTypeSelector(),
          const SizedBox(height: 16),

          // Catégorie
          _buildSectionTitle('Catégorie'),
          _buildApartmentClassSelector(),
          const SizedBox(height: 16),

          // Prix
          _buildSectionTitle('Prix (FCFA)'),
          _buildPriceRangeSelector(),
          const SizedBox(height: 16),

          // Caractéristiques
          _buildSectionTitle('Caractéristiques'),
          _buildCharacteristics(),
          const SizedBox(height: 16),

          // Commodités
          _buildSectionTitle('Commodités'),
          _buildAmenitiesFilter(),
          const SizedBox(height: 24),

          // Bouton Appliquer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onFiltersChanged(_filters);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Appliquer les filtres',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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

  Widget _buildCitySelector() {
    return DropdownButtonFormField<String>(
      value: _filters.city,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintText: 'Sélectionnez une ville',
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Toutes les villes'),
        ),
        ...cityData.keys.map((city) => DropdownMenuItem(
              value: city,
              child: Text(city),
            )),
      ],
      onChanged: (value) {
        setState(() {
          _filters = _filters.copyWith(
            city: value,
            district: null, // Réinitialiser le quartier
          );
          _updateAvailableDistricts();
        });
      },
    );
  }

  Widget _buildDistrictSelector() {
    return DropdownButtonFormField<String>(
      value: _filters.district,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintText: 'Sélectionnez un quartier',
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Tous les quartiers'),
        ),
        ..._availableDistricts.map((district) => DropdownMenuItem(
              value: district,
              child: Text(district),
            )),
      ],
      onChanged: (value) {
        setState(() {
          _filters = _filters.copyWith(district: value);
        });
      },
    );
  }

  Widget _buildRentalTypeSelector() {
    return Row(
      children: RentalType.values.map((type) {
        return Expanded(
          child: RadioListTile<RentalType>(
            title: Text(type.label),
            value: type,
            groupValue: _filters.rentalType,
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(rentalType: value);
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildApartmentClassSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ApartmentClass.values.map((classType) {
        return FilterChip(
          label: Text(classType.label),
          selected: _filters.apartmentClass == classType,
          onSelected: (selected) {
            setState(() {
              _filters = _filters.copyWith(
                apartmentClass: selected ? classType : null,
              );
            });
          },
          selectedColor: AppColors.success,
          backgroundColor: AppColors.background,
          labelStyle: TextStyle(
            color: _filters.apartmentClass == classType
                ? Colors.white
                : AppColors.textSecondary,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeSelector() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${NumberFormat('#,###').format(_priceRange.start.round())} FCFA',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            Text(
              '${NumberFormat('#,###').format(_priceRange.end.round())} FCFA',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        RangeSlider(
          values: _priceRange,
          min: _minPrice,
          max: _maxPrice,
          divisions: 19,
          labels: RangeLabels(
            '${_priceRange.start.round()} FCFA',
            '${_priceRange.end.round()} FCFA',
          ),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
              _filters = _filters.copyWith(priceRange: values);
            });
          },
          activeColor: AppColors.success,
          inactiveColor: AppColors.background,
        ),
      ],
    );
  }

  Widget _buildCharacteristics() {
    return Column(
      children: [
        // Chambres
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Chambres minimum'),
            Row(
              children: [
                IconButton(
                  onPressed: _bedrooms > 1
                      ? () {
                          setState(() {
                            _bedrooms--;
                            _filters =
                                _filters.copyWith(minBedrooms: _bedrooms);
                          });
                        }
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color:
                      _bedrooms > 1 ? AppColors.primary : AppColors.textLight,
                ),
                Text(
                  '$_bedrooms',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _bedrooms++;
                      _filters = _filters.copyWith(minBedrooms: _bedrooms);
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),

        // Surface
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Surface minimum'),
            Text('${_minSurface.round()} m²'),
          ],
        ),
        Slider(
          value: _minSurface,
          min: 0,
          max: 300,
          divisions: 30,
          label: '${_minSurface.round()} m²',
          onChanged: (value) {
            setState(() {
              _minSurface = value;
              _filters = _filters.copyWith(minSurface: value);
            });
          },
          activeColor: AppColors.success,
          inactiveColor: AppColors.background,
        ),
      ],
    );
  }

  Widget _buildAmenitiesFilter() {
    final currentAmenities =
        _filters.requiredAmenities ?? const ApartmentAmenities();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildAmenityChip(
          'Wifi',
          Icons.wifi,
          currentAmenities.hasWifi,
          (selected) => _updateAmenities(hasWifi: selected),
        ),
        _buildAmenityChip(
          'Climatisation',
          Icons.ac_unit,
          currentAmenities.hasAirConditioning,
          (selected) => _updateAmenities(hasAirConditioning: selected),
        ),
        _buildAmenityChip(
          'Parking',
          Icons.local_parking,
          currentAmenities.hasParking,
          (selected) => _updateAmenities(hasParking: selected),
        ),
        _buildAmenityChip(
          'Sécurité',
          Icons.security,
          currentAmenities.hasSecurity,
          (selected) => _updateAmenities(hasSecurity: selected),
        ),
        _buildAmenityChip(
          'Piscine',
          Icons.pool,
          currentAmenities.hasPool,
          (selected) => _updateAmenities(hasPool: selected),
        ),
        _buildAmenityChip(
          'Salle de sport',
          Icons.fitness_center,
          currentAmenities.hasGym,
          (selected) => _updateAmenities(hasGym: selected),
        ),
        _buildAmenityChip(
          'Balcon',
          Icons.balcony,
          currentAmenities.hasBalcony,
          (selected) => _updateAmenities(hasBalcony: selected),
        ),
        _buildAmenityChip(
          'Meublé',
          Icons.chair,
          currentAmenities.hasFurnished,
          (selected) => _updateAmenities(hasFurnished: selected),
        ),
      ],
    );
  }

  Widget _buildAmenityChip(
    String label,
    IconData icon,
    bool selected,
    Function(bool) onSelected,
  ) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected ? Colors.white : AppColors.textLight,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.success,
      backgroundColor: AppColors.background,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  void _updateAmenities({
    bool? hasWifi,
    bool? hasAirConditioning,
    bool? hasParking,
    bool? hasSecurity,
    bool? hasPool,
    bool? hasGym,
    bool? hasBalcony,
    bool? hasFurnished,
  }) {
    final currentAmenities =
        _filters.requiredAmenities ?? const ApartmentAmenities();

    final newAmenities = ApartmentAmenities(
      hasWifi: hasWifi ?? currentAmenities.hasWifi,
      hasAirConditioning:
          hasAirConditioning ?? currentAmenities.hasAirConditioning,
      hasParking: hasParking ?? currentAmenities.hasParking,
      hasSecurity: hasSecurity ?? currentAmenities.hasSecurity,
      hasPool: hasPool ?? currentAmenities.hasPool,
      hasGym: hasGym ?? currentAmenities.hasGym,
      hasBalcony: hasBalcony ?? currentAmenities.hasBalcony,
      hasFurnished: hasFurnished ?? currentAmenities.hasFurnished,
    );

    setState(() {
      _filters = _filters.copyWith(requiredAmenities: newAmenities);
    });
  }
}
