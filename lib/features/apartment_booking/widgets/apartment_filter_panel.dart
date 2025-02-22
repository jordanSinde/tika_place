// lib/features/apartment_booking/widgets/apartment_filter_panel.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/config/theme/app_colors.dart';
import '../data/mock_data.dart';
import '../models/apartment_filters.dart';

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
  String? _selectedNeighborhood;
  final double _minPrice = 50000;
  final double _maxPrice = 2000000;
  int _bedrooms = 1;
  int _bathrooms = 1;
  double _surface = 50;
  final List<String> _cities = cities;
  final Map<String, List<String>> _neighborhoods = neighborhoods;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _priceRange = _filters.priceRange ?? RangeValues(_minPrice, _maxPrice);
    _bedrooms = _filters.minBedrooms ?? 1;
    _bathrooms = _filters.minBathrooms ?? 1;
    _surface = _filters.minSurface ?? 50;
  }

  void _updateFilters() {
    final newFilters = ApartmentSearchFilters(
      city: _filters.city,
      neighborhood: _selectedNeighborhood,
      type: _filters.type,
      duration: _filters.duration,
      moveInDate: _filters.moveInDate,
      priceRange: _priceRange,
      minBedrooms: _bedrooms,
      minBathrooms: _bathrooms,
      minSurface: _surface,
      requiredAmenities: _filters.requiredAmenities,
      petsAllowed: _filters.petsAllowed,
      maxDistanceToCenter: _filters.maxDistanceToCenter,
    );
    widget.onFiltersChanged(newFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sélection de la ville
          _buildCitySelector(),
          const SizedBox(height: 16),

          // Sélection du quartier
          if (_filters.city != null) _buildNeighborhoodSelector(),
          if (_filters.city != null) const SizedBox(height: 16),

          // Type de bien
          _buildTypeSelector(),
          const SizedBox(height: 16),

          // Type de location
          _buildRentalDurationSelector(),
          const SizedBox(height: 16),

          // Date d'emménagement
          _buildDateSelector(),
          const SizedBox(height: 16),

          // Plage de prix
          _buildPriceRangeSelector(),
          const SizedBox(height: 16),

          // Nombre de chambres et salles de bain
          _buildRoomCounters(),
          const SizedBox(height: 16),

          // Surface minimale
          _buildSurfaceSelector(),
          const SizedBox(height: 16),

          // Commodités requises
          _buildAmenitiesSelector(),
          const SizedBox(height: 16),

          // Options supplémentaires
          _buildAdditionalOptions(),
        ],
      ),
    );
  }

  Widget _buildCitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ville',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _filters.city,
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
          onChanged: (newCity) {
            setState(() {
              _selectedNeighborhood = null;
              _filters = _filters.copyWith(city: newCity);
            });
            _updateFilters();
          },
        ),
      ],
    );
  }

  Widget _buildNeighborhoodSelector() {
    final neighborhoods = _neighborhoods[_filters.city!] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quartier',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedNeighborhood,
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
              child: Text('Tous les quartiers'),
            ),
            ...neighborhoods.map((neighborhood) => DropdownMenuItem<String>(
                  value: neighborhood,
                  child: Text(neighborhood),
                )),
          ],
          onChanged: (newNeighborhood) {
            setState(() {
              _selectedNeighborhood = newNeighborhood;
            });
            _updateFilters();
          },
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de bien',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ApartmentType.values.map((type) {
            return FilterChip(
              selected: _filters.type == type,
              label: Text(type.label),
              onSelected: (selected) {
                setState(() {
                  _filters = _filters.copyWith(
                    type: selected ? type : null,
                  );
                });
                _updateFilters();
              },
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: _filters.type == type ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRentalDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Durée de location',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: RentalDuration.values.map((duration) {
            return FilterChip(
              selected: _filters.duration == duration,
              label: Text(duration.label),
              onSelected: (selected) {
                setState(() {
                  _filters = _filters.copyWith(
                    duration: selected ? duration : null,
                  );
                });
                _updateFilters();
              },
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color:
                    _filters.duration == duration ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date d\'emménagement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _filters.moveInDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() {
                _filters = _filters.copyWith(moveInDate: date);
              });
              _updateFilters();
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
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  _filters.moveInDate != null
                      ? DateFormat('dd/MM/yyyy').format(_filters.moveInDate!)
                      : 'Sélectionner une date',
                ),
                const Spacer(),
                if (_filters.moveInDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _filters = _filters.copyWith(moveInDate: null);
                      });
                      _updateFilters();
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Budget (FCFA)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${NumberFormat('#,###').format(_priceRange.start.round())} - ${NumberFormat('#,###').format(_priceRange.end.round())}',
              style: const TextStyle(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _priceRange,
          min: _minPrice,
          max: _maxPrice,
          divisions: 50,
          labels: RangeLabels(
            NumberFormat('#,###').format(_priceRange.start.round()),
            NumberFormat('#,###').format(_priceRange.end.round()),
          ),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
            _updateFilters();
          },
          activeColor: AppColors.primary,
          inactiveColor: AppColors.inputBackground,
        ),
      ],
    );
  }

  Widget _buildRoomCounters() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chambres min.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _bedrooms > 1
                        ? () {
                            setState(() {
                              _bedrooms--;
                            });
                            _updateFilters();
                          }
                        : null,
                  ),
                  Text('$_bedrooms'),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() {
                        _bedrooms++;
                      });
                      _updateFilters();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SdB min.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _bathrooms > 1
                        ? () {
                            setState(() {
                              _bathrooms--;
                            });
                            _updateFilters();
                          }
                        : null,
                  ),
                  Text('$_bathrooms'),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() {
                        _bathrooms++;
                      });
                      _updateFilters();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSurfaceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Surface minimale (m²)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${_surface.round()} m²',
              style: const TextStyle(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _surface,
          min: 20,
          max: 500,
          divisions: 48,
          label: '${_surface.round()} m²',
          onChanged: (value) {
            setState(() {
              _surface = value;
            });
            _updateFilters();
          },
          activeColor: AppColors.primary,
          inactiveColor: AppColors.inputBackground,
        ),
      ],
    );
  }

  Widget _buildAmenitiesSelector() {
    final amenities = [
      {'icon': Icons.wifi, 'label': 'Wifi', 'key': 'hasWifi'},
      {'icon': Icons.ac_unit, 'label': 'Clim', 'key': 'hasAirConditioning'},
      {'icon': Icons.local_parking, 'label': 'Parking', 'key': 'hasParking'},
      {'icon': Icons.pool, 'label': 'Piscine', 'key': 'hasPool'},
      {'icon': Icons.fitness_center, 'label': 'Gym', 'key': 'hasGym'},
      {'icon': Icons.security, 'label': 'Sécurité', 'key': 'hasSecurity'},
      {'icon': Icons.chair, 'label': 'Meublé', 'key': 'hasFurnished'},
      {
        'icon': Icons.water_drop,
        'label': 'Chauffe-eau',
        'key': 'hasWaterHeater'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Équipements',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amenities.map((amenity) {
            final isSelected = _getAmenityValue(amenity['key']!);
            return FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    amenity['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(amenity['label'] as String),
                ],
              ),
              onSelected: (selected) {
                setState(() {
                  _updateAmenity(amenity['key']!, selected);
                });
                _updateFilters();
              },
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdditionalOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Options supplémentaires',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Animaux acceptés'),
          value: _filters.petsAllowed ?? false,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(petsAllowed: value);
            });
            _updateFilters();
          },
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Distance max. du centre (km)'),
            const SizedBox(height: 8),
            Slider(
              value: _filters.maxDistanceToCenter ?? 5.0,
              min: 0.0,
              max: 10.0,
              divisions: 20,
              label:
                  '${(_filters.maxDistanceToCenter ?? 5.0).toStringAsFixed(1)} km',
              onChanged: (value) {
                setState(() {
                  _filters = _filters.copyWith(maxDistanceToCenter: value);
                });
                _updateFilters();
              },
              activeColor: AppColors.primary,
              inactiveColor: AppColors.inputBackground,
            ),
          ],
        ),
      ],
    );
  }

  bool _getAmenityValue(String key) {
    final amenities = _filters.requiredAmenities;
    if (amenities == null) return false;

    switch (key) {
      case 'hasWifi':
        return amenities.hasWifi;
      case 'hasAirConditioning':
        return amenities.hasAirConditioning;
      case 'hasParking':
        return amenities.hasParking;
      case 'hasPool':
        return amenities.hasPool;
      case 'hasGym':
        return amenities.hasGym;
      case 'hasSecurity':
        return amenities.hasSecurity;
      case 'hasFurnished':
        return amenities.hasFurnished;
      case 'hasWaterHeater':
        return amenities.hasWaterHeater;
      default:
        return false;
    }
  }

  void _updateAmenity(String key, bool value) {
    final currentAmenities =
        _filters.requiredAmenities ?? const ApartmentAmenities();
    ApartmentAmenities newAmenities;

    switch (key) {
      case 'hasWifi':
        newAmenities = currentAmenities.copyWith(hasWifi: value);
        break;
      case 'hasAirConditioning':
        newAmenities = currentAmenities.copyWith(hasAirConditioning: value);
        break;
      case 'hasParking':
        newAmenities = currentAmenities.copyWith(hasParking: value);
        break;
      case 'hasPool':
        newAmenities = currentAmenities.copyWith(hasPool: value);
        break;
      case 'hasGym':
        newAmenities = currentAmenities.copyWith(hasGym: value);
        break;
      case 'hasSecurity':
        newAmenities = currentAmenities.copyWith(hasSecurity: value);
        break;
      case 'hasFurnished':
        newAmenities = currentAmenities.copyWith(hasFurnished: value);
        break;
      case 'hasWaterHeater':
        newAmenities = currentAmenities.copyWith(hasWaterHeater: value);
        break;
      default:
        return;
    }

    _filters = _filters.copyWith(requiredAmenities: newAmenities);
  }
}
