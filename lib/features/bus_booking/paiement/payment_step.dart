// lib/features/bus_booking/screens/booking/steps/payment_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/config/theme/app_colors.dart';
import 'payment_success_screen.dart';
import '../providers/booking_provider.dart';

class PaymentStep extends ConsumerStatefulWidget {
  final VoidCallback onPrevious;

  const PaymentStep({
    super.key,
    required this.onPrevious,
  });

  @override
  ConsumerState<PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends ConsumerState<PaymentStep> {
  PaymentMethod? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderSummary(bookingState),
          const SizedBox(height: 24),
          const Text(
            'Mode de paiement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethods(),
          const SizedBox(height: 24),
          if (bookingState.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bookingState.error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: bookingState.isLoading ? null : widget.onPrevious,
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
                  onPressed: bookingState.isLoading || _selectedMethod == null
                      ? null
                      : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: bookingState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Payer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BookingState state) {
    final bus = state.selectedBus!;
    final totalAmount = state.totalAmount!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé de la commande',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              'Trajet',
              '${bus.departureCity} → ${bus.arrivalCity}',
            ),
            _buildSummaryRow(
              'Date',
              DateFormat('dd MMM yyyy HH:mm').format(bus.departureTime),
            ),
            _buildSummaryRow(
              'Passagers',
              '${state.passengers.length} personne(s)',
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total à payer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${NumberFormat('#,###').format(totalAmount)} FCFA',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: [
        _buildPaymentMethodCard(
          method: PaymentMethod.orangeMoney,
          title: 'Orange Money',
          icon: 'assets/icons/orange_money.png',
          description: 'Paiement via Orange Money',
        ),
        const SizedBox(height: 12),
        _buildPaymentMethodCard(
          method: PaymentMethod.mtnMoney,
          title: 'MTN Mobile Money',
          icon: 'assets/icons/mtn_momo.png',
          description: 'Paiement via MTN Mobile Money',
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard({
    required PaymentMethod method,
    required String title,
    required String icon,
    required String description,
  }) {
    final isSelected = _selectedMethod == method;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
        ref.read(bookingProvider.notifier).updatePaymentMethod(method);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.payment, color: AppColors.primary),
              // Remplacer par Image.asset(icon) quand les assets seront disponibles
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textLight.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Radio<PaymentMethod>(
              value: method,
              groupValue: _selectedMethod,
              onChanged: (PaymentMethod? value) {
                setState(() {
                  _selectedMethod = value;
                });
                if (value != null) {
                  ref.read(bookingProvider.notifier).updatePaymentMethod(value);
                }
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    final success = await ref.read(bookingProvider.notifier).processPayment();

    if (success && mounted) {
      // Navigation vers l'écran de succès
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const PaymentSuccessScreen(),
        ),
      );
    }
  }
}
