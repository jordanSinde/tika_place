// lib/features/home/widgets/bus_booking/bus_search_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/theme/app_colors.dart';
import 'package:intl/intl.dart';

import '../home/models/bus_mock_data.dart';

class BusSearchCard extends StatefulWidget {
  final Function(Map<String, dynamic>) onSearch;

  const BusSearchCard({
    super.key,
    required this.onSearch,
  });

  @override
  State<BusSearchCard> createState() => _BusSearchCardState();
}

class _BusSearchCardState extends State<BusSearchCard> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _departureCity = '';
  String _arrivalCity = '';

  final List<String> _cities = [
    'Douala',
    'Yaoundé',
    'Bafoussam',
    'Bamenda',
    'Buea',
    'Kribi',
    'Garoua',
  ];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Dans BusSearchCard, modifiez la méthode _handleSearch

  void _handleSearch() {
    if (_departureCity.isEmpty || _arrivalCity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Veuillez sélectionner les villes de départ et d\'arrivée'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Créer les filtres initiaux
    final filters = BusSearchFilters(
      departureCity: _departureCity,
      arrivalCity: _arrivalCity,
      departureDate: _selectedDate,
      departureTime: _selectedTime,
    );

    // Naviguer vers la page de liste des bus
    context.go('/bus-list', extra: {'filters': filters});
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
          // City Selection
          _buildDropdown(
            label: 'Departure City',
            value: _departureCity.isEmpty ? null : _departureCity,
            items: _cities,
            onChanged: (value) {
              setState(() {
                _departureCity = value ?? '';
              });
            },
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Arrival City',
            value: _arrivalCity.isEmpty ? null : _arrivalCity,
            items: _cities,
            onChanged: (value) {
              setState(() {
                _arrivalCity = value ?? '';
              });
            },
            icon: Icons.location_on,
          ),
          const SizedBox(height: 16),

          // Date and Time Selection
          Row(
            children: [
              Expanded(
                child: _buildSelectionField(
                  label: 'Date',
                  value: DateFormat('dd MMM yyyy').format(_selectedDate),
                  onTap: _selectDate,
                  icon: Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSelectionField(
                  label: 'Time',
                  value: _selectedTime.format(context),
                  onTap: _selectTime,
                  icon: Icons.access_time,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search Button
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
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
          ),
        ),
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
                'Select $label',
                style: TextStyle(
                  color: AppColors.textLight.withOpacity(0.5),
                ),
              ),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
              items: items.map((String item) {
                return DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(item),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionField({
    required String label,
    required String value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
