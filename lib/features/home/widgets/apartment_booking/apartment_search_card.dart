// lib/features/home/widgets/apartment_booking/apartment_search_card.dart

import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../models/apartment_mock_data.dart';

class ApartmentSearchCard extends StatefulWidget {
  final Function(Map<String, dynamic>) onSearch;

  const ApartmentSearchCard({
    super.key,
    required this.onSearch,
  });

  @override
  State<ApartmentSearchCard> createState() => _ApartmentSearchCardState();
}

class _ApartmentSearchCardState extends State<ApartmentSearchCard> {
  final List<String> _cities = ['Douala', 'Yaoundé', 'Kribi', 'Bafoussam'];
  String? _selectedCity;
  RangeValues _priceRange = const RangeValues(100000, 1000000);
  RentalType _selectedRentalType = RentalType.shortTerm;
  int _bedrooms = 1;
  double _minSurface = 0;

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

    widget.onSearch({
      'city': _selectedCity,
      'priceRange': _priceRange,
      'rentalType': _selectedRentalType,
      'bedrooms': _bedrooms,
      'minSurface': _minSurface,
    });
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
            items: _cities,
            onChanged: (value) => setState(() => _selectedCity = value),
          ),
          const SizedBox(height: 16),

          // Type de location
          _buildLabel('Type de location'),
          Row(
            children: RentalType.values
                .map((type) => Expanded(
                      child: RadioListTile<RentalType>(
                        title: Text(
                          type.label,
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: type,
                        groupValue: _selectedRentalType,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedRentalType = value);
                          }
                        },
                        dense: true,
                        activeColor: AppColors.primary,
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          // Fourchette de prix
          _buildLabel('Budget (FCFA)'),
          RangeSlider(
            values: _priceRange,
            min: 50000,
            max: 1000000,
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
          _buildLabel('Surface minimale (m²)'),
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
          const SizedBox(height: 24),

          // Bouton de recherche
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSearch,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
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
