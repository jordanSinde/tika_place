// lib/features/bus_booking/widgets/payment_history_dialog.dart

import 'package:flutter/material.dart';
import '../../../core/config/theme/app_colors.dart';
import '../models/booking_model.dart';

class PaymentHistoryDialog extends StatelessWidget {
  final List<PaymentAttempt> paymentHistory;

  const PaymentHistoryDialog({
    super.key,
    required this.paymentHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history),
                SizedBox(width: 8),
                Text(
                  'Historique des paiements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (paymentHistory.isEmpty)
              const Center(
                child: Text('Aucune tentative de paiement'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                itemCount: paymentHistory.length,
                itemBuilder: (context, index) {
                  final attempt = paymentHistory[index];
                  return _PaymentAttemptItem(attempt: attempt);
                },
              ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentAttemptItem extends StatelessWidget {
  final PaymentAttempt attempt;

  const _PaymentAttemptItem({required this.attempt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(),
                color: _getStatusColor(),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusText(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(attempt.timestamp),
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (attempt.amountPaid != null) ...[
            const SizedBox(height: 4),
            Text(
              'Montant: ${attempt.amountPaid!.toStringAsFixed(0)} FCFA',
              style: const TextStyle(fontSize: 12),
            ),
          ],
          if (attempt.errorMessage != null) ...[
            const SizedBox(height: 4),
            Text(
              'Erreur: ${attempt.errorMessage}',
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ],
          if (attempt.transactionId != null) ...[
            const SizedBox(height: 4),
            Text(
              'Transaction: ${attempt.transactionId}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (attempt.status.toLowerCase()) {
      case 'success':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textLight;
    }
  }

  IconData _getStatusIcon() {
    switch (attempt.status.toLowerCase()) {
      case 'success':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'failed':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  String _getStatusText() {
    switch (attempt.status.toLowerCase()) {
      case 'success':
        return 'Réussi';
      case 'pending':
        return 'En cours';
      case 'failed':
        return 'Échoué';
      default:
        return 'Inconnu';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
