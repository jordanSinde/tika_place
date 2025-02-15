// lib/features/bus_booking/screens/booking/steps/passenger_info_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/config/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/widgets/passenger_form_dialog.dart';
import '../providers/booking_provider.dart';

class PassengerInfoStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const PassengerInfoStep({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  ConsumerState<PassengerInfoStep> createState() => _PassengerInfoStepState();
}

class _PassengerInfoStepState extends ConsumerState<PassengerInfoStep> {
  bool _isAddingPassenger = false;
  final bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final user = ref.watch(authProvider).user;

    if (user == null) return const Center(child: Text('Erreur de chargement'));

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Passagers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Liste des passagers existants
                ...bookingState.passengers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final passenger = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title:
                          Text('${passenger.firstName} ${passenger.lastName}'),
                      subtitle: Text(passenger.phoneNumber ?? 'No phone'),
                      trailing: index == 0
                          ? const Chip(
                              label: Text('Principal'),
                              backgroundColor: AppColors.background,
                            )
                          : IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                ref
                                    .read(bookingProvider.notifier)
                                    .removePassenger(index);
                              },
                            ),
                    ),
                  );
                }),

                // Formulaire d'ajout de passager
                if (_isAddingPassenger)
                  PassengerFormDialog(
                    isDialog: false,
                    onSubmit: (passenger) {
                      ref
                          .read(bookingProvider.notifier)
                          .addPassenger(passenger);
                      setState(() {
                        _isAddingPassenger = false;
                      });
                    },
                    onCancel: () {
                      setState(() {
                        _isAddingPassenger = false;
                      });
                    },
                  ),

                // Bouton d'ajout de passager
                if (!_isAddingPassenger) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isAddingPassenger = true;
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un passager'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        _buildBottomButtons(bookingState),
      ],
    );
  }

  Widget _buildBottomButtons(BookingState bookingState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isProcessing ? null : widget.onPrevious,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.primary),
              ),
              child: const Text('Retour'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isProcessing || bookingState.passengers.isEmpty
                  ? null
                  : widget.onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Continuer'),
            ),
          ),
        ],
      ),
    );
  }
}
