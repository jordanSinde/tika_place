// lib/features/apartment/widgets/apartment_search_card.dart

import 'package:flutter/material.dart';
import '../../core/config/theme/app_colors.dart';
import 'models/apartment_mock_data.dart';

import 'package:intl/intl.dart';

class ApartmentSearchCard extends StatefulWidget {
  final Function(ApartmentSearchFilters) onSearch;

  const ApartmentSearchCard({
    super.key,
    required this.onSearch,
  });

  @override
  State<ApartmentSearchCard> createState() => _ApartmentSearchCardState();
}

class _ApartmentSearchCardState extends State<ApartmentSearchCard> {
  String? _selectedCity;
  String? _selectedDistrict;
  List<String> _availableDistricts = [];
  DateTime? _startDate;
  DateTime? _endDate;
  RangeValues _priceRange = const RangeValues(5000, 100000);
  final double _minSurface = 0;
  int _bedrooms = 1;
  ApartmentClass? _selectedClass;
  bool _showOnlyAvailable = true;

  @override
  void initState() {
    super.initState();

    // Initialiser les dates par défaut
    _startDate = DateTime.now().add(const Duration(days: 1));
    _endDate = DateTime.now().add(const Duration(days: 8));
  }

  void _updateDistricts(String? city) {
    if (city == null) {
      setState(() {
        _availableDistricts = [];
        _selectedDistrict = null;
      });
      return;
    }

    final districts =
        cityData[city]?.values.expand((list) => list).toList() ?? [];
    setState(() {
      _availableDistricts = districts;
      _selectedDistrict = null;
    });
  }

  void _handleSearch() {
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une ville'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner des dates'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de départ doit être après la date d\'arrivée'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final filters = ApartmentSearchFilters(
      city: _selectedCity,
      district: _selectedDistrict,
      startDate: _startDate,
      endDate: _endDate,
      apartmentClass: _selectedClass,
      priceRange: _priceRange,
      minSurface: _minSurface,
      minBedrooms: _bedrooms,
      showOnlyAvailable: _showOnlyAvailable,
    );

    widget.onSearch(filters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sélection de la ville
          _buildDropdown(
            label: 'Ville',
            value: _selectedCity,
            items: cityData.keys.toList(),
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
                _updateDistricts(value);
              });
            },
          ),
          const SizedBox(height: 16),

          // Sélection du quartier
          if (_availableDistricts.isNotEmpty) ...[
            _buildDropdown(
              label: 'Quartier',
              value: _selectedDistrict,
              items: _availableDistricts,
              onChanged: (value) {
                setState(() {
                  _selectedDistrict = value;
                });
              },
            ),
            const SizedBox(height: 16),
          ],

          // Date d'arrivée
          _buildLabel('Date d\'arrivée'),
          _buildDatePicker(
            selectedDate: _startDate,
            hintText: 'Sélectionner une date d\'arrivée',
            onDateSelected: (date) {
              setState(() {
                _startDate = date;

                // Si la date de départ est avant la nouvelle date d'arrivée, on la met à jour
                if (_endDate != null && _endDate!.isBefore(_startDate!)) {
                  _endDate = _startDate!.add(const Duration(days: 7));
                }
              });
            },
          ),
          const SizedBox(height: 16),

          // Date de départ
          _buildLabel('Date de départ'),
          _buildDatePicker(
            selectedDate: _endDate,
            hintText: 'Sélectionner une date de départ',
            onDateSelected: (date) {
              setState(() {
                _endDate = date;
              });
            },
            minDate: _startDate?.add(const Duration(days: 1)),
          ),
          const SizedBox(height: 16),

          /* // Classe d'appartement
          _buildLabel('Catégorie'),
          Wrap(
            spacing: 8,
            children: ApartmentClass.values
                .map((classType) => ChoiceChip(
                      label: Text(classType.label),
                      selected: _selectedClass == classType,
                      onSelected: (selected) {
                        setState(() {
                          _selectedClass = selected ? classType : null;
                        });
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),*/

          // Fourchette de prix
          _buildLabel('Budget journalier (FCFA)'),
          RangeSlider(
            values: _priceRange,
            min: 5000,
            max: 100000,
            divisions: 19,
            labels: RangeLabels(
              '${_priceRange.start.round()} FCFA',
              '${_priceRange.end.round()} FCFA',
            ),
            onChanged: (values) => setState(() => _priceRange = values),
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),

          // Nombre de chambres
          _buildLabel('Chambres'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed:
                    _bedrooms > 1 ? () => setState(() => _bedrooms--) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: _bedrooms > 1 ? AppColors.primary : AppColors.textLight,
              ),
              Text(
                '$_bedrooms ${_bedrooms > 1 ? 'chambres' : 'chambre'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _bedrooms++),
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Surface minimale
          /*_buildLabel('Surface minimale (m²)'),
          Slider(
            value: _minSurface,
            min: 0,
            max: 300,
            divisions: 30,
            label: '${_minSurface.round()} m²',
            onChanged: (value) => setState(() => _minSurface = value),
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),*/

          // Option pour afficher seulement les disponibles
          Row(
            children: [
              Checkbox(
                value: _showOnlyAvailable,
                onChanged: (value) {
                  setState(() {
                    _showOnlyAvailable = value ?? true;
                  });
                },
                activeColor: AppColors.primary,
              ),
              const Expanded(
                child: Text(
                  'Afficher uniquement les appartements disponibles',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bouton de recherche
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSearch,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Rechercher',
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                'Sélectionner une $label',
                style: TextStyle(
                  color: AppColors.textLight.withOpacity(0.5),
                ),
              ),
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required DateTime? selectedDate,
    required String hintText,
    required Function(DateTime) onDateSelected,
    DateTime? minDate,
  }) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate:
              selectedDate ?? DateTime.now().add(const Duration(days: 1)),
          firstDate: minDate ?? DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  onSurface: AppColors.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 20,
              color: AppColors.textLight,
            ),
            const SizedBox(width: 12),
            Text(
              selectedDate != null ? dateFormat.format(selectedDate) : hintText,
              style: TextStyle(
                color: selectedDate != null
                    ? AppColors.textPrimary
                    : AppColors.textLight.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textLight,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
