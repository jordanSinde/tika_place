// lib/features/bus_booking/screens/booking/steps/payment_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/config/theme/app_colors.dart';
import '../providers/price_calculator_provider.dart';
import '../services/reservation_service.dart';
import '../widgets/price_summary_widget.dart';
import '../widgets/promo_code_input.dart';
import '../providers/booking_provider.dart';
import 'mobile_money_form.dart';
import 'payment_success_screen.dart';
import 'utils/payment_verification.dart';

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
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _initializePrice();
    _initializePayment();
  }

  void _initializePrice() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingState = ref.read(bookingProvider);
      if (bookingState.totalAmount != null) {
        ref
            .read(priceCalculatorProvider.notifier)
            .calculatePrice(bookingState.totalAmount!);
      }
    });
  }

  Future<void> _initializePayment() async {
    // Verify Phase 1 implementation on debug mode
    assert(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await PaymentVerification.verifyPhase1Complete(ref);
      });
      return true;
    }());
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

          // Show payment form if method is selected
          if (_selectedMethod != null) ...[
            const SizedBox(height: 24),
            _buildPaymentForm(),
          ],

          // Error display
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

          // Verification buttons (only in debug mode)
          if (true) // Replace with !kReleaseMode when ready for production
            _buildVerificationButtons(),

          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  print('\nStarting Payment Flow Verification...');
                  ref
                      .read(bookingProvider.notifier)
                      .verifyPhase1_1Implementation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                child: const Text('Verify Phase 1.1 Implementation'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  print('\nStarting Phone Validation Verification...');
                  await ref
                      .read(bookingProvider.notifier)
                      .verifyPhase1_2Implementation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Verify Phase 1.2 Implementation'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Back button
          OutlinedButton(
            onPressed: _isProcessingPayment ? null : widget.onPrevious,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Retour'),
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
              'Passagers',
              '${state.passengers.length} personne(s)',
            ),
            const Divider(height: 32),

            // Promo code input
            const PromoCodeInput(),
            const SizedBox(height: 16),

            // Price summary
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
      onTap: _isProcessingPayment
          ? null
          : () async {
              print(
                  '💳 PAYMENT FLOW: Payment method selected - ${method.toString()}');
              setState(() {
                _selectedMethod = method;
              });
              ref.read(bookingProvider.notifier).updatePaymentMethod(method);
              // Create reservation when selecting payment method
              await _handlePaymentInitiation();
              print('💳 PAYMENT FLOW: UI Updated with selected method');
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
              onChanged: _isProcessingPayment
                  ? null
                  : (PaymentMethod? value) {
                      setState(() {
                        _selectedMethod = value;
                      });
                      if (value != null) {
                        ref
                            .read(bookingProvider.notifier)
                            .updatePaymentMethod(value);
                      }
                    },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    final priceState = ref.watch(priceCalculatorProvider);

    return MobileMoneyForm(
      paymentMethod: _selectedMethod!,
      amount: priceState.total,
      onCodeSubmitted: (code) async {
        PaymentVerification.logPhase("1", "Payment Process", "Started");
        setState(() => _isProcessingPayment = true);
        try {
          PaymentVerification.logPhase(
              "1", "Payment Validation", "In Progress");
          final success =
              await ref.read(bookingProvider.notifier).processPayment(ref);
          print(success
              ? '✅ PAYMENT STEP: Payment successful'
              : '❌ PAYMENT STEP: Payment failed');

          if (!mounted) return;

          if (success) {
            final bookingState = ref.read(bookingProvider);
            if (bookingState.bookingReference == null) {
              print('❌ PAYMENT STEP: Missing booking reference');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Erreur: Référence de réservation non trouvée'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            print('✅ PAYMENT STEP: Navigating to success screen');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => PaymentSuccessScreen(
                  bookingReference: bookingState.bookingReference!,
                ),
              ),
            );
          } else {
            print('❌ PAYMENT STEP: Showing error dialog');
            _showErrorDialog(
              'Le paiement a échoué. Vous pourrez réessayer depuis votre historique de réservations.',
            );
          }
        } catch (e) {
          PaymentVerification.logError("1", "Payment error: $e");
          print('❌ PAYMENT STEP: Payment error: $e');
          if (!mounted) return;
          _showErrorDialog(
            'Une erreur est survenue. Vous pourrez réessayer depuis votre historique de réservations.',
          );
        } finally {
          if (mounted) {
            setState(() => _isProcessingPayment = false);
          }
        }
      },
      onCancel: () {
        print('🔄 PAYMENT STEP: Payment form cancelled');
        setState(() {
          _selectedMethod = null;
        });
        ref.read(bookingProvider.notifier).updatePaymentMethod(null);
      },
    );
  }

  Future<void> _handlePaymentInitiation() async {
    setState(() => _isProcessingPayment = true);

    try {
      print('🚀 PAYMENT: Initiating payment process');

      // Create reservation first
      final reservation = await reservationService.createReservation(ref);

      // Update booking reference
      ref.read(bookingProvider.notifier).updateBookingReference(reservation.id);

      print('✅ PAYMENT: Reservation created, proceeding to payment');
    } catch (e) {
      print('❌ PAYMENT: Initiation failed - $e');
      _showErrorDialog(
        'Une erreur est survenue lors de l\'initialisation du paiement. '
        'Veuillez réessayer.',
      );
    } finally {
      setState(() => _isProcessingPayment = false);
    }
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

  Widget _buildVerificationButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            print('\nStarting Payment Flow Verification...');
            await PaymentVerification.verifyPhase1Complete(ref);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
          ),
          child: const Text('Verify Phase 1 Implementation'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            print('\nTesting Individual Components...');
            await Future.wait([
              PaymentVerification.verifyPaymentMethodSelection(ref),
              PaymentVerification.verifyPhoneValidation(ref),
              PaymentVerification.verifyPaymentCodeFlow(ref),
            ]);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: const Text('Test Individual Components'),
        ),
      ],
    );
  }
}



/*
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
*/