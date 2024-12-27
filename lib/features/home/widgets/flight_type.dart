import 'package:flutter/material.dart';
import '../../../core/config/theme/app_colors.dart';

enum FlightType {
  oneWay('One way'),
  roundTrip('Round-trip'),
  multiCity('Multi-City');

  final String label;
  const FlightType(this.label);
}

class FlightTypeSelector extends StatefulWidget {
  final ValueChanged<FlightType> onTypeChanged;
  final FlightType initialType;

  const FlightTypeSelector({
    super.key,
    required this.onTypeChanged,
    this.initialType = FlightType.roundTrip,
  });

  @override
  State<FlightTypeSelector> createState() => _FlightTypeSelectorState();
}

class _FlightTypeSelectorState extends State<FlightTypeSelector> {
  late FlightType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: FlightType.values.map((type) {
          final isSelected = type == _selectedType;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildRadioButton(
                label: type.label,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedType = type;
                  });
                  widget.onTypeChanged(type);
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRadioButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
