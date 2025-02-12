// lib/features/bus_booking/screens/booking/steps/passenger_info_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/config/theme/app_colors.dart';
import '../../auth/models/user.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool _isAddingPassenger = false;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cniController = TextEditingController();

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
                    isDialog:
                        false, // Important : on l'utilise comme formulaire intégré
                    onSubmit: (passenger) {
                      print("Nouveau passager: ${passenger.toString()}");
                      ref
                          .read(bookingProvider.notifier)
                          .addPassenger(passenger);
                      print(
                          "État après ajout: ${ref.read(bookingProvider).passengers.length}");
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
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onPrevious,
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
                  onPressed:
                      bookingState.passengers.isNotEmpty ? widget.onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Continuer'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _submitPassenger() {
    if (_formKey.currentState?.validate() ?? false) {
      final newPassenger = Passenger(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phoneNumber: _phoneController.text,
        cniNumber: int.tryParse(_cniController.text),
      );

      ref.read(bookingProvider.notifier).addPassenger(newPassenger);

      // Réinitialiser le formulaire
      _firstNameController.clear();
      _lastNameController.clear();
      _phoneController.clear();
      _cniController.clear();

      setState(() {
        _isAddingPassenger = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _cniController.dispose();
    super.dispose();
  }
}
