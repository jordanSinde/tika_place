//lib/features/bus_booking/screens/booking/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../common/widgets/buttons/primary_button.dart';
import '../providers/booking_provider.dart';
import 'mobile_money_payment.dart';
import 'services/mobile_money_service.dart';
import 'widgets/payment_progress_dialog.dart';
import 'widgets/transaction_receipt.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final double amount;
  final String bookingReference;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.bookingReference,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethod? _selectedMethod;
  bool _isLoading = false;
  bool _showReceipt = false;
  Map<String, dynamic>? _receiptData;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paiement'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _confirmCancel(context),
          ),
        ),
        body: _showReceipt
            ? _buildReceipt()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAmountCard(),
                    const SizedBox(height: 24),
                    _buildPaymentMethods(),
                    if (_selectedMethod != null) ...[
                      const SizedBox(height: 24),
                      MobileMoneyPayment(
                        method: _selectedMethod!,
                        amount: widget.amount,
                        onPhoneSubmitted: _handlePayment,
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Montant à payer',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.amount.toStringAsFixed(0)} FCFA',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Référence: ${widget.bookingReference}',
              style: TextStyle(
                color: AppColors.textLight.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mode de paiement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildPaymentMethodTile(
                PaymentMethod.orangeMoney,
                'Orange Money',
                'assets/icons/orange_money.png',
                'Payer avec Orange Money',
              ),
              const Divider(height: 1),
              _buildPaymentMethodTile(
                PaymentMethod.mtnMoney,
                'MTN Mobile Money',
                'assets/icons/mtn_momo.png',
                'Payer avec MTN Mobile Money',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(
    PaymentMethod method,
    String title,
    String iconPath,
    String description,
  ) {
    final isSelected = _selectedMethod == method;
    final isOrangeMoney = method == PaymentMethod.orangeMoney;

    return RadioListTile<PaymentMethod>(
      value: method,
      groupValue: _selectedMethod,
      onChanged: (value) {
        setState(() {
          _selectedMethod = value;
        });
      },
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isOrangeMoney
                  ? const Color(0xFFFF6600).withOpacity(0.1)
                  : const Color(0xFFFFCC00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              iconPath,
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.payment,
                color: isOrangeMoney
                    ? const Color(0xFFFF6600)
                    : const Color(0xFFFFCC00),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          color: AppColors.textLight.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      activeColor:
          isOrangeMoney ? const Color(0xFFFF6600) : const Color(0xFFFFCC00),
    );
  }

  Widget _buildReceipt() {
    if (_receiptData == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TransactionReceipt(
            receiptData: _receiptData!,
            paymentMethod: _selectedMethod!,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Terminer',
            onPressed: () {
              Navigator.of(context).popUntil(
                (route) => route.isFirst,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment(String phoneNumber) async {
    setState(() => _isLoading = true);

    try {
      // Initier le paiement
      final transaction = await mobileMoneyService.initiatePayment(
        method: _selectedMethod!,
        phoneNumber: phoneNumber,
        amount: widget.amount,
        description: 'Réservation de bus - ${widget.bookingReference}',
      );

      if (!mounted) return;

      // Afficher le dialogue de progression
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PaymentProgressDialog(
          transactionReference: transaction.reference,
          paymentMethod: _selectedMethod!,
          onSuccess: () async {
            // Récupérer le reçu
            _receiptData = await mobileMoneyService.getTransactionReceipt(
              transaction.reference,
            );

            if (mounted) {
              // Fermer le dialogue
              Navigator.of(context).pop();
              // Afficher le reçu
              setState(() {
                _showReceipt = true;
              });
            }
          },
          onFailure: () {
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Le paiement a échoué. Veuillez réessayer.'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isLoading) {
      return await _confirmCancel(context);
    }
    return false;
  }

  Future<bool> _confirmCancel(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le paiement ?'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler ce paiement ? Votre réservation sera perdue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non, continuer'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
