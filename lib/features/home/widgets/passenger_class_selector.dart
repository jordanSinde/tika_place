// lib/features/home/widgets/passenger_class_selector.dart
import 'package:flutter/material.dart';
import '../../../core/config/theme/app_colors.dart';

class PassengerClassSelector extends StatelessWidget {
  final int passengerCount;
  final String travelClass;
  final VoidCallback onTap;

  const PassengerClassSelector({
    super.key,
    required this.passengerCount,
    required this.travelClass,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.divider,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.person_outline,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Passengers and Class',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$passengerCount Passengers / $travelClass',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// Dialogue pour sélectionner les passagers et la classe
class PassengerClassDialog extends StatefulWidget {
  final int initialPassengers;
  final String initialClass;
  final Function(int passengers, String travelClass) onSave;

  const PassengerClassDialog({
    super.key,
    required this.initialPassengers,
    required this.initialClass,
    required this.onSave,
  });

  @override
  State<PassengerClassDialog> createState() => _PassengerClassDialogState();
}

class _PassengerClassDialogState extends State<PassengerClassDialog> {
  late int _passengers;
  late String _selectedClass;

  final List<String> _travelClasses = ['Economy', 'Business', 'First'];

  @override
  void initState() {
    super.initState();
    _passengers = widget.initialPassengers;
    _selectedClass = widget.initialClass;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Passengers and Class',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Passengers'),
                Row(
                  children: [
                    IconButton(
                      onPressed: _passengers > 1
                          ? () => setState(() => _passengers--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.primary,
                    ),
                    Text(
                      '$_passengers',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      onPressed: _passengers < 9
                          ? () => setState(() => _passengers++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Travel Class'),
                const SizedBox(height: 8),
                ...List.generate(
                  _travelClasses.length,
                  (index) => RadioListTile<String>(
                    title: Text(_travelClasses[index]),
                    value: _travelClasses[index],
                    groupValue: _selectedClass,
                    onChanged: (value) {
                      setState(() {
                        _selectedClass = value!;
                      });
                    },
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_passengers, _selectedClass);
                  Navigator.of(context).pop();
                },
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
