// lib/features/bus_booking/screens/booking/steps/payment_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/config/theme/app_colors.dart';
import '../providers/price_calculator_provider.dart';
import '../providers/ticket_provider.dart';
import '../widgets/price_summary_widget.dart';
import '../widgets/promo_code_input.dart';
import 'payment_success_screen.dart';
import '../providers/booking_provider.dart';
import 'widgets/payment_code_form.dart';

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
  void initState() {
    super.initState();
    // Initialiser le calculateur de prix avec le montant de base
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingState = ref.read(bookingProvider);
      if (bookingState.totalAmount != null) {
        ref
            .read(priceCalculatorProvider.notifier)
            .calculatePrice(bookingState.totalAmount!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final priceState = ref.watch(priceCalculatorProvider);

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

          // Afficher le formulaire de paiement si une méthode est sélectionnée
          if (_selectedMethod != null) ...[
            const SizedBox(height: 24),
            PaymentCodeForm(
              paymentMethod: _selectedMethod!,
              onCodeSubmitted: (code) => _handlePayment(code, priceState.total),
              onClose: () {
                setState(() {
                  _selectedMethod = null;
                });
                ref.read(bookingProvider.notifier).updatePaymentMethod(null);
              },
            ),
          ],

          if (bookingState.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 24),
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

          // Uniquement le bouton Retour
          OutlinedButton(
            onPressed: bookingState.isLoading ? null : widget.onPrevious,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size(
                  double.infinity, 48), // Pour garder la même hauteur
            ),
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment(String code, double totalAmount) async {
    try {
      print("Début du processus de paiement");
      final success =
          await ref.read(bookingProvider.notifier).processPayment(ref);
      print("Paiement traité, succès: $success");

      if (!mounted) return;

      if (success) {
        final bookingState = ref.read(bookingProvider);
        final bookingReference = bookingState.bookingReference;
        print("Référence de réservation: $bookingReference");

        if (bookingReference == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur: Référence de réservation non trouvée'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        // Générer et sauvegarder les tickets ici
        final ticketsNotifier = ref.read(ticketsProvider.notifier);
        final ticketsGenerated =
            await ticketsNotifier.generateTicketsAfterPayment(code);
        print("Tickets générés et sauvegardés: $ticketsGenerated");

        // Navigation vers l'écran de succès
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              bookingReference: bookingReference,
            ),
          ),
        );
      } else {
        // Afficher le dialogue d'erreur
        _showErrorDialog(
          'Le paiement a échoué. Vous pourrez réessayer depuis votre historique de réservations.',
        );
      }
    } catch (e) {
      print("Erreur dans _handlePayment: $e");
      if (!mounted) return;
      _showErrorDialog(
        'Une erreur est survenue. Vous pourrez réessayer depuis votre historique de réservations.',
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            SizedBox(width: 8),
            Text('Erreur de paiement'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text(
              'Vous retrouverez votre réservation dans votre historique.',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BookingState state) {
    final bus = state.selectedBus!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête du résumé
            const Text(
              'Résumé de la commande',
              style: TextStyle(
                fontSize: 18,
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
            // Nouveau widget pour la saisie du code promo
            const PromoCodeInput(),
            const SizedBox(height: 16),
            // Nouveau widget pour le résumé des prix
            PriceSummaryWidget(
              onPromoCodeRemoved: () {
                ref.read(priceCalculatorProvider.notifier).removePromoCode();
              },
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
          icon: 'assets/images/paiement/OM.png',
          description: 'Paiement via Orange Money',
        ),
        const SizedBox(height: 12),
        _buildPaymentMethodCard(
          method: PaymentMethod.mtnMoney,
          title: 'MTN Mobile Money',
          icon: 'assets/images/paiement/momo.jpg',
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
              child: Image.asset(
                icon,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.payment,
                  color: isSelected ? AppColors.primary : AppColors.textLight,
                ),
              ),
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
}
