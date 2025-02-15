// lib/features/bus_booking/widgets/reservation_cancellation_dialog.dart
/*
import 'package:flutter/material.dart';
import '../../../core/config/theme/app_colors.dart';

class ReservationCancellationDialog extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isLoading;

  const ReservationCancellationDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    this.isLoading = false,
  });

  @override
  State<ReservationCancellationDialog> createState() =>
      _ReservationCancellationDialogState();
}

class _ReservationCancellationDialogState
    extends State<ReservationCancellationDialog> {
  String _reason = '';
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          SizedBox(width: 8),
          Text('Annuler la réservation ?'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cette action est irréversible. Les places seront libérées pour d\'autres voyageurs.',
            style: TextStyle(color: AppColors.textLight),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Raison de l\'annulation (optionnel)',
              border: OutlineInputBorder(),
              hintText: 'Ex: Changement de plans...',
            ),
            maxLines: 2,
            onChanged: (value) => _reason = value,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.isLoading ? null : widget.onCancel,
          child: const Text('Garder la réservation'),
        ),
        ElevatedButton(
          onPressed: widget.isLoading
              ? null
              : () {
                  widget.onConfirm();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Annuler la réservation'),
        ),
      ],
    );
  }
}
*/