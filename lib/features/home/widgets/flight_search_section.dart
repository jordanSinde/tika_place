import 'package:flutter/material.dart';
import '../../../core/config/theme/app_colors.dart';
import 'date_selector.dart';
import 'destinations_selector.dart';
import 'flight_type.dart';

/*

// Dans FlightSearchSection, ajoutez ces propriétés
int _passengerCount = 2;
String _travelClass = 'Business';

// Ajoutez ce widget juste avant le bouton de recherche
PassengerClassSelector(
  passengerCount: _passengerCount,
  travelClass: _travelClass,
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => PassengerClassDialog(
        initialPassengers: _passengerCount,
        initialClass: _travelClass,
        onSave: (passengers, travelClass) {
          setState(() {
            _passengerCount = passengers;
            _travelClass = travelClass;
          });
        },
      ),
    );
  },
),
const SizedBox(height: 24),

*/

class FlightSearchSection extends StatefulWidget {
  const FlightSearchSection({super.key});

  @override
  State<FlightSearchSection> createState() => _FlightSearchSectionState();
}

class _FlightSearchSectionState extends State<FlightSearchSection> {
  FlightType _flightType = FlightType.roundTrip;
  DateTime _departureDate = DateTime.now();
  DateTime _returnDate = DateTime.now().add(const Duration(days: 7));
  String _fromLocation = 'Dubai';
  String _toLocation = 'Maldives';

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDeparture ? _departureDate : _returnDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlightTypeSelector(
            initialType: _flightType,
            onTypeChanged: (type) {
              setState(() {
                _flightType = type;
              });
            },
          ),
          const SizedBox(height: 24),
          DestinationSelector(
            from: _fromLocation,
            to: _toLocation,
            onFromTap: () {
              // Implémenter la sélection de l'origine
            },
            onToTap: () {
              // Implémenter la sélection de la destination
            },
            onSwapTap: () {
              setState(() {
                final temp = _fromLocation;
                _fromLocation = _toLocation;
                _toLocation = temp;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DateSelector(
                  selectedDate: _departureDate,
                  label: 'Departure',
                  onTap: () => _selectDate(context, true),
                ),
              ),
              if (_flightType == FlightType.roundTrip) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: DateSelector(
                    selectedDate: _returnDate,
                    label: 'Return',
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Implémenter la recherche de vol
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Search Flights',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
