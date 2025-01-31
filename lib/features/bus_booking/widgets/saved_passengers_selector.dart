// lib/features/bus_booking/widgets/saved_passengers_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';
import '../providers/booking_provider.dart';

class SavedPassengersSelector extends ConsumerStatefulWidget {
  final Function(Passenger) onPassengerSelected;

  const SavedPassengersSelector({
    super.key,
    required this.onPassengerSelected,
  });

  @override
  ConsumerState<SavedPassengersSelector> createState() =>
      _SavedPassengersSelectorState();
}

class _SavedPassengersSelectorState
    extends ConsumerState<SavedPassengersSelector> {
  bool _isLoading = true;
  List<Passenger> _savedPassengers = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPassengers();
  }

  Future<void> _loadSavedPassengers() async {
    setState(() => _isLoading = true);
    try {
      final passengers =
          await ref.read(bookingProvider.notifier).getSavedPassengers();
      setState(() {
        _savedPassengers = passengers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_savedPassengers.isEmpty) {
      return const Center(
        child: Text('Aucun proche enregistré'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sélectionner un proche',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _savedPassengers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final passenger = _savedPassengers[index];
            return InkWell(
              onTap: () => widget.onPassengerSelected(passenger),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        '${passenger.firstName[0]}${passenger.lastName[0]}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${passenger.firstName} ${passenger.lastName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (passenger.phoneNumber != null)
                            Text(
                              passenger.phoneNumber!,
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.add_circle_outline,
                        color: AppColors.success),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
