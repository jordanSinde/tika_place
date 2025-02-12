// lib/features/common/widgets/passenger_form_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../auth/models/user.dart';
import '../../common/widgets/inputs/custom_textfield.dart';

class PassengerFormDialog extends StatefulWidget {
  final Passenger? initialPassenger;
  final Function(Passenger) onSubmit;
  final VoidCallback onCancel;
  final bool isDialog;

  const PassengerFormDialog({
    super.key,
    this.initialPassenger,
    required this.onSubmit,
    required this.onCancel,
    this.isDialog = true,
  });

  @override
  State<PassengerFormDialog> createState() => _PassengerFormDialogState();
}

class _PassengerFormDialogState extends State<PassengerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _cniController;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.initialPassenger?.firstName);
    _lastNameController =
        TextEditingController(text: widget.initialPassenger?.lastName);
    _phoneController =
        TextEditingController(text: widget.initialPassenger?.phoneNumber);
    _cniController = TextEditingController(
      text: widget.initialPassenger?.cniNumber?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _cniController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final passenger = Passenger(
        id: widget.initialPassenger?.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        cniNumber: int.tryParse(_cniController.text),
        isMainPassenger: widget.initialPassenger?.isMainPassenger ?? false,
      );

      widget.onSubmit(passenger);
    }
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.initialPassenger == null
                ? 'Nouveau passager'
                : 'Modifier le passager',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _firstNameController,
            label: 'Prénom',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Veuillez entrer le prénom';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _lastNameController,
            label: 'Nom',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Veuillez entrer le nom';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            label: 'Téléphone',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Veuillez entrer le numéro de téléphone';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _cniController,
            label: 'Numéro CNI',
            keyboardType: TextInputType.number,
            //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Annuler'),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                      widget.initialPassenger == null ? 'Ajouter' : 'Modifier'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDialog) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: _buildForm(),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildForm(),
      ),
    );
  }
}
