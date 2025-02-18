// lib/features/bus_booking/widgets/payment_error_dialog.dart

import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../models/payment_error.dart';

class PaymentErrorDialog extends StatelessWidget {
  final PaymentError error;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;
  final bool showViewReservation;

  const PaymentErrorDialog({
    super.key,
    required this.error,
    this.onRetry,
    this.onClose,
    this.showViewReservation = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            _getIconForErrorType(error.type),
            color: AppColors.error,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Échec du paiement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            error.message,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          if (showViewReservation)
            const Text(
              'Vous retrouverez votre réservation dans votre historique et pourrez réessayer le paiement ultérieurement.',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
          if (error.technicalDetails != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Détails techniques :',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.technicalDetails!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (onClose != null)
          TextButton(
            onPressed: onClose,
            child: const Text('Fermer'),
          ),
        if (error.canRetry && onRetry != null)
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Réessayer'),
          ),
      ],
    );
  }

  IconData _getIconForErrorType(PaymentErrorType type) {
    switch (type) {
      case PaymentErrorType.invalidPhone:
        return Icons.phone_android;
      case PaymentErrorType.invalidCode:
        return Icons.password;
      case PaymentErrorType.insufficientFunds:
        return Icons.account_balance_wallet;
      case PaymentErrorType.networkError:
        return Icons.signal_wifi_off;
      case PaymentErrorType.timeout:
        return Icons.timer_off;
      case PaymentErrorType.cancelled:
        return Icons.cancel;
      case PaymentErrorType.unknown:
        return Icons.error_outline;
    }
  }
}
