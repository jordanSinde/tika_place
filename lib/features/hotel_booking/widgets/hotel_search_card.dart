// lib/features/home/widgets/hotel_booking/hotel_search_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/config/theme/app_colors.dart';
import '../models/models.dart';

class HotelSearchCard extends StatefulWidget {
  final Function(HotelSearchFilters) onSearch;

  const HotelSearchCard({
    super.key,
    required this.onSearch,
  });

  @override
  State<HotelSearchCard> createState() => _HotelSearchCardState();
}

class _HotelSearchCardState extends State<HotelSearchCard> {
  String? _selectedCountry;
  String? _selectedCity;
  List<String> _availableCities = [];
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _adults = 1;
  int _children = 0;
  int _rooms = 1;

  @override
  void initState() {
    super.initState();
    _checkInDate = DateTime.now().add(const Duration(days: 1));
    _checkOutDate = DateTime.now().add(const Duration(days: 2));
  }

  void _updateCities(String? country) {
    if (country == null) {
      setState(() {
        _availableCities = [];
        _selectedCity = null;
      });
      return;
    }

    // Récupérer les villes disponibles pour le pays sélectionné
    final cities = countryCityData[country] ?? [];
    setState(() {
      _availableCities = cities;
      _selectedCity = null;
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

    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner des dates'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_checkOutDate!.isBefore(_checkInDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de départ doit être après la date d\'arrivée'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final filters = HotelSearchFilters(
      country: _selectedCountry,
      city: _selectedCity,
      checkInDate: _checkInDate,
      checkOutDate: _checkOutDate,
      adults: _adults,
      children: _children,
      rooms: _rooms,
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
          // Sélection du pays
          _buildDropdown(
            label: 'Pays',
            value: _selectedCountry,
            items: countryCityData.keys.toList(),
            onChanged: (value) {
              setState(() {
                _selectedCountry = value;
                _updateCities(value);
              });
            },
          ),
          const SizedBox(height: 16),

          // Sélection de la ville
          _buildDropdown(
            label: 'Ville',
            value: _selectedCity,
            items: _availableCities,
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Date d'arrivée
          _buildLabel('Date d\'arrivée'),
          _buildDatePicker(
            selectedDate: _checkInDate,
            hintText: 'Sélectionner une date d\'arrivée',
            onDateSelected: (date) {
              setState(() {
                _checkInDate = date;
                if (_checkOutDate != null &&
                    _checkOutDate!.isBefore(_checkInDate!)) {
                  _checkOutDate = _checkInDate!.add(const Duration(days: 1));
                }
              });
            },
          ),
          const SizedBox(height: 16),

          // Date de départ
          _buildLabel('Date de départ'),
          _buildDatePicker(
            selectedDate: _checkOutDate,
            hintText: 'Sélectionner une date de départ',
            onDateSelected: (date) {
              setState(() {
                _checkOutDate = date;
              });
            },
            minDate: _checkInDate?.add(const Duration(days: 1)),
          ),
          const SizedBox(height: 16),

          // Nombre de voyageurs et chambres
          _buildLabel('Voyageurs et chambres'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Adultes
                _buildCounter(
                  icon: Icons.person,
                  label: 'Adultes',
                  value: _adults,
                  onDecrement: _adults > 1
                      ? () {
                          setState(() {
                            _adults--;
                          });
                        }
                      : null,
                  onIncrement: () {
                    setState(() {
                      _adults++;
                    });
                  },
                ),
                const Divider(height: 24),

                // Enfants
                _buildCounter(
                  icon: Icons.child_care,
                  label: 'Enfants',
                  value: _children,
                  onDecrement: _children > 0
                      ? () {
                          setState(() {
                            _children--;
                          });
                        }
                      : null,
                  onIncrement: () {
                    setState(() {
                      _children++;
                    });
                  },
                ),
                const Divider(height: 24),

                // Chambres
                _buildCounter(
                  icon: Icons.hotel,
                  label: 'Chambres',
                  value: _rooms,
                  onDecrement: _rooms > 1
                      ? () {
                          setState(() {
                            _rooms--;
                          });
                        }
                      : null,
                  onIncrement: () {
                    setState(() {
                      _rooms++;
                    });
                  },
                ),
              ],
            ),
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

  Widget _buildCounter({
    required IconData icon,
    required String label,
    required int value,
    required VoidCallback? onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textLight),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_circle_outline),
          color: onDecrement != null ? AppColors.primary : AppColors.textLight,
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add_circle_outline),
          color: AppColors.primary,
        ),
      ],
    );
  }

  // Ajouter ces méthodes à la classe _HotelSearchCardState

// Données pour les pays et villes
  final Map<String, List<String>> countryCityData = {
    'France': ['Paris', 'Nice', 'Lyon', 'Marseille', 'Bordeaux'],
    'Royaume-Uni': [
      'Londres',
      'Manchester',
      'Liverpool',
      'Édimbourg',
      'Glasgow'
    ],
    'Espagne': ['Madrid', 'Barcelone', 'Séville', 'Valence', 'Malaga'],
    'Italie': ['Rome', 'Milan', 'Florence', 'Venise', 'Naples'],
    'Allemagne': ['Berlin', 'Munich', 'Francfort', 'Hambourg', 'Cologne'],
  };

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
}
/*class HotelSearchCard extends StatefulWidget {
  final Function(Map<String, dynamic>) onSearch;

  const HotelSearchCard({
    super.key,
    required this.onSearch,
  });

  @override
  State<HotelSearchCard> createState() => _HotelSearchCardState();
}

class _HotelSearchCardState extends State<HotelSearchCard> {
  final List<String> _cities = ['Douala', 'Yaoundé', 'Kribi', 'Buea', 'Limbé'];
  String? _selectedCity;
  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 1));
  int _adults = 2;
  int _children = 0;
  int _rooms = 1;

  Future<void> _selectDate(bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkInDate : _checkOutDate,
      firstDate: isCheckIn ? DateTime.now() : _checkInDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate.isBefore(_checkInDate)) {
            _checkOutDate = _checkInDate.add(const Duration(days: 1));
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  void _handleSearch() {
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a city'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    widget.onSearch({
      'city': _selectedCity,
      'checkIn': _checkInDate,
      'checkOut': _checkOutDate,
      'adults': _adults,
      'children': _children,
      'rooms': _rooms,
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
          // City Selection
          _buildDropdown(
            label: 'Destination',
            value: _selectedCity,
            items: _cities,
            onChanged: (value) => setState(() => _selectedCity = value),
          ),
          const SizedBox(height: 16),

          // Date Selection
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Check-in',
                  value: _checkInDate,
                  onTap: () => _selectDate(true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  label: 'Check-out',
                  value: _checkOutDate,
                  onTap: () => _selectDate(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Guests and Rooms
          Row(
            children: [
              Expanded(
                child: _buildCounter(
                  label: 'Adults',
                  value: _adults,
                  onDecrement:
                      _adults > 1 ? () => setState(() => _adults--) : null,
                  onIncrement: () => setState(() => _adults++),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCounter(
                  label: 'Children',
                  value: _children,
                  onDecrement:
                      _children > 0 ? () => setState(() => _children--) : null,
                  onIncrement: () => setState(() => _children++),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCounter(
            label: 'Rooms',
            value: _rooms,
            onDecrement: _rooms > 1 ? () => setState(() => _rooms--) : null,
            onIncrement: () => setState(() => _rooms++),
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
                'Search Hotels',
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

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
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
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM yyyy').format(value),
                  style: const TextStyle(
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

  Widget _buildCounter({
    required String label,
    required int value,
    required VoidCallback? onDecrement,
    required VoidCallback onIncrement,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: const Icon(Icons.remove_circle_outline),
                color: onDecrement == null
                    ? AppColors.textLight
                    : AppColors.primary,
              ),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: onIncrement,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
*/