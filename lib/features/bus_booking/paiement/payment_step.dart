// lib/features/bus_booking/screens/booking/steps/payment_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tika_place/features/bus_booking/providers/booking_verification_extension.dart';
import '../../../../../core/config/theme/app_colors.dart';
import '../providers/price_calculator_provider.dart';
import '../widgets/price_summary_widget.dart';
import '../widgets/promo_code_input.dart';
import '../providers/booking_provider.dart';
import 'mobile_money_form.dart';
import 'models/payment_error.dart';
import 'payment_success_screen.dart';
import 'utils/payment_verification.dart';
import 'widgets/payment_error_dialog.dart';

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
    ref.watch(priceCalculatorProvider);

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
          if (true)
            // _buildVerificationButtons(),
//code de vérification des Phases 1 2 3 4
            /*Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  print('\nStarting Payment Flow Verification...');
                  ref
                      .read(bookingProvider.notifier)
                      .verifyPhase1_1Implementation(ref);
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
          ),*/

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
          : () {
              print(
                  '💳 PAYMENT FLOW: Payment method selected - ${method.toString()}');
              setState(() {
                _selectedMethod = method;
              });
              ref.read(bookingProvider.notifier).updatePaymentMethod(method);
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
        PaymentVerification.logPhase("3", "Payment Process", "Started");
        setState(() => _isProcessingPayment = true);
        try {
          PaymentVerification.logPhase(
              "3", "Payment Validation", "In Progress");

          // First, ensure reservation is created
          await ref.read(bookingProvider.notifier).initializePayment(ref);
// DIRECT SOLUTION: Check for forced failure code
          if (code == "FORCE_FAIL") {
            // Simulate a failed payment
            await Future.delayed(const Duration(seconds: 1));

            // Force payment failure through the proper method
            ref
                .read(bookingProvider.notifier)
                .forcePaymentFailure('Échec du paiement: fonds insuffisants');

            // Show error dialog
            if (mounted) {
              _showErrorWithType(PaymentErrorType.insufficientFunds,
                  'Le paiement a échoué: fonds insuffisants');
            }
            setState(() => _isProcessingPayment = false);
            return;
          }

//END FORCE_FAIL
          // Now process payment
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
              _showErrorWithType(PaymentErrorType.unknown,
                  'Erreur: Référence de réservation non trouvée');
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
            final errorMessage = ref.read(bookingProvider).error ??
                'Le paiement a échoué. Vous pourrez réessayer depuis votre historique de réservations.';
            print('❌ PAYMENT STEP: Showing error dialog');
            _showErrorWithType(_determineErrorType(errorMessage), errorMessage);
          }
        } catch (e) {
          PaymentVerification.logError("3", "Payment error: $e");
          print('❌ PAYMENT STEP: Payment error: $e');
          if (!mounted) return;
          _showErrorWithType(
            PaymentErrorType.unknown,
            'Une erreur est survenue. Vous pourrez réessayer depuis votre historique de réservations.',
            technicalDetails: e.toString(),
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

// Add helper method to determine error type
  PaymentErrorType _determineErrorType(String errorMessage) {
    if (errorMessage.contains('expiré')) {
      return PaymentErrorType.timeout;
    } else if (errorMessage.contains('code')) {
      return PaymentErrorType.invalidCode;
    } else if (errorMessage.contains('solde') ||
        errorMessage.contains('fonds')) {
      return PaymentErrorType.insufficientFunds;
    } else if (errorMessage.contains('réseau') ||
        errorMessage.contains('connexion')) {
      return PaymentErrorType.networkError;
    } else if (errorMessage.contains('annulé')) {
      return PaymentErrorType.cancelled;
    } else if (errorMessage.contains('téléphone')) {
      return PaymentErrorType.invalidPhone;
    }
    return PaymentErrorType.unknown;
  }

// New method to show error dialog with type
  void _showErrorWithType(PaymentErrorType type, String message,
      {String? technicalDetails}) {
    final error = PaymentError(
      type: type,
      message: message,
      technicalDetails: technicalDetails,
      canRetry: type != PaymentErrorType.cancelled,
    );

    showDialog(
      context: context,
      builder: (context) => PaymentErrorDialog(
        error: error,
        onClose: () => Navigator.pop(context),
        onRetry: type != PaymentErrorType.cancelled
            ? () {
                Navigator.pop(context);
                // Reset payment form state to allow retry
                setState(() {
                  _selectedMethod = null;
                });
              }
            : null,
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
        ElevatedButton(
          onPressed: () async {
            print('\nStarting Phase 3 Verification...');
            await ref
                .read(bookingProvider.notifier)
                .verifyPhase3Implementation(ref);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: const Text('Verify Phase 3 Implementation'),
        ),
      ],
    );
  }
}
