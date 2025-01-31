// lib/features/bus_booking/screens/booking/steps/payment/transaction_receipt.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/config/theme/app_colors.dart';
import '../../providers/booking_provider.dart';

class TransactionReceipt extends StatelessWidget {
  final Map<String, dynamic> receiptData;
  final PaymentMethod paymentMethod;

  const TransactionReceipt({
    super.key,
    required this.receiptData,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final timestamp = DateTime.parse(receiptData['timestamp']);
    final isOrangeMoney = paymentMethod == PaymentMethod.orangeMoney;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du reçu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOrangeMoney ? 'Orange Money' : 'MTN Mobile Money',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'PAYÉ',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Détails de la transaction
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildReceiptRow(
                  'Référence',
                  receiptData['reference'],
                ),
                const Divider(height: 24),
                _buildReceiptRow(
                  'Date',
                  DateFormat('dd/MM/yyyy HH:mm').format(timestamp),
                ),
                const Divider(height: 24),
                _buildReceiptRow(
                  'Montant',
                  '${NumberFormat('#,###').format(receiptData['amount'])} FCFA',
                  valueStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                if (receiptData['fees'] != null) ...[
                  const Divider(height: 24),
                  _buildReceiptRow(
                    'Frais',
                    '${NumberFormat('#,###').format(receiptData['fees'])} FCFA',
                  ),
                ],
                const Divider(height: 24),
                _buildReceiptRow(
                  'Description',
                  receiptData['description'],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implémenter le partage du reçu
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonctionnalité à venir'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Partager'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implémenter le téléchargement du reçu
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Téléchargement du reçu...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Télécharger'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textLight,
          ),
        ),
        Text(
          value,
          style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
