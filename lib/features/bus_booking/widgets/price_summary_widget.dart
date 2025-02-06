// lib/features/bus_booking/widgets/price_summary_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/price_calculator_provider.dart';
import '../../../core/config/theme/app_colors.dart';

class PriceSummaryWidget extends ConsumerWidget {
  final VoidCallback? onPromoCodeRemoved;

  const PriceSummaryWidget({
    super.key,
    this.onPromoCodeRemoved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceState = ref.watch(priceCalculatorProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Détails du prix',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildPriceRow('Sous-total', priceState.subtotal),
        _buildPriceRow('Taxe mobile (2.5%)', priceState.mobileTax),
        _buildPriceRow('Commission', priceState.commission),
        _buildPriceRow('Taxe de transport', priceState.transportTax),
        if (priceState.discount > 0) ...[
          _buildDiscountRow(
            'Réduction (${priceState.appliedPromoCode?.code})',
            priceState.discount,
            onRemove: onPromoCodeRemoved,
          ),
        ],
        const Divider(height: 24),
        _buildTotalRow('Total à payer', priceState.total),
        if (priceState.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              priceState.error!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textLight,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(0)} FCFA',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountRow(String label, double amount,
      {VoidCallback? onRemove}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.success,
              ),
            ),
          ),
          Text(
            '-${amount.toStringAsFixed(0)} FCFA',
            style: const TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onRemove,
              color: AppColors.error,
            ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(0)} FCFA',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}
