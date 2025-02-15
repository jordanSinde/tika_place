// lib/features/bus_booking/widgets/payment_history_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../models/booking_model.dart';
import '../../providers/reservation_state_notifier.dart';

class PaymentHistoryWidget extends ConsumerWidget {
  final String reservationId;

  const PaymentHistoryWidget({
    super.key,
    required this.reservationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écouter l'historique des paiements via le provider central
    final centralState = ref.watch(centralReservationProvider);
    final attempts = ref.watch(paymentHistoryProvider(reservationId));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.history, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Historique des paiements (${attempts.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '${centralState.paymentAttempts[reservationId] ?? 0}/3 tentatives',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (attempts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Aucune tentative de paiement',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attempts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final attempt = attempts[index];
                return _PaymentAttemptItem(attempt: attempt);
              },
            ),
        ],
      ),
    );
  }
}

class _PaymentAttemptItem extends StatelessWidget {
  final PaymentAttempt attempt;

  const _PaymentAttemptItem({
    required this.attempt,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = attempt.status.toLowerCase() == 'success';
    final color = isSuccess ? AppColors.success : AppColors.error;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isSuccess ? 'Paiement réussi' : 'Échec du paiement',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDateTime(attempt.timestamp),
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (attempt.amountPaid != null)
                  Text(
                    'Montant: ${attempt.amountPaid!.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (attempt.paymentMethod.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Méthode: ${_formatPaymentMethod(attempt.paymentMethod)}',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (attempt.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    attempt.errorMessage!,
                    style: TextStyle(
                      color: AppColors.error.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
                if (attempt.transactionId != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Transaction: ${attempt.transactionId}',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'orangemoney':
        return 'Orange Money';
      case 'mtnmoney':
        return 'MTN Mobile Money';
      default:
        return method;
    }
  }
}

// Provider pour l'historique des paiements
final paymentHistoryProvider = Provider.family<List<PaymentAttempt>, String>(
  (ref, reservationId) {
    final centralState = ref.watch(centralReservationProvider);
    final reservation = centralState.reservations.firstWhere(
      (r) => r.id == reservationId,
      orElse: () => throw Exception('Réservation non trouvée'),
    );

    return reservation.paymentHistory ?? [];
  },
);
