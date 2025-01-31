// lib/features/bus_booking/screens/booking/steps/payment/payment_progress_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/config/theme/app_colors.dart';
import '../../providers/booking_provider.dart';
import '../services/mobile_money_service.dart';

class PaymentProgressDialog extends ConsumerStatefulWidget {
  final String transactionReference;
  final PaymentMethod paymentMethod;
  final VoidCallback onSuccess;
  final VoidCallback onFailure;

  const PaymentProgressDialog({
    super.key,
    required this.transactionReference,
    required this.paymentMethod,
    required this.onSuccess,
    required this.onFailure,
  });

  @override
  ConsumerState<PaymentProgressDialog> createState() =>
      _PaymentProgressDialogState();
}

class _PaymentProgressDialogState extends ConsumerState<PaymentProgressDialog> {
  late Stream<TransactionStatus> _statusStream;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _statusStream =
        mobileMoneyService.monitorTransaction(widget.transactionReference);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            StreamBuilder<TransactionStatus>(
              stream: _statusStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                if (!snapshot.hasData) {
                  return _buildInitialState();
                }

                final status = snapshot.data!;
                if (status.isSuccess && !_isCompleted) {
                  _isCompleted = true;
                  Future.delayed(const Duration(seconds: 2), () {
                    widget.onSuccess();
                  });
                  return _buildSuccessState();
                }

                if (!status.isSuccess &&
                    status.message?.contains('expiré') == true) {
                  Future.delayed(const Duration(seconds: 2), () {
                    widget.onFailure();
                  });
                  return _buildTimeoutState();
                }

                return _buildPendingState(status);
              },
            ),
            const SizedBox(height: 24),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isOrangeMoney = widget.paymentMethod == PaymentMethod.orangeMoney;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isOrangeMoney
                ? const Color(0xFFFF6600)
                : const Color(0xFFFFCC00),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.payment,
            color: isOrangeMoney ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOrangeMoney ? 'Orange Money' : 'MTN Mobile Money',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Transaction en cours',
                style: TextStyle(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInitialState() {
    return const Column(
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text(
          'Initialisation de la transaction...',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPendingState(TransactionStatus status) {
    return Column(
      children: [
        const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(),
        ),
        const SizedBox(height: 16),
        Text(
          status.message ?? 'En attente de confirmation...',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Veuillez valider la transaction sur votre téléphone',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Paiement effectué avec succès !',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeoutState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.timer_off,
            color: AppColors.error,
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Le délai de paiement a expiré',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Veuillez réessayer',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Une erreur est survenue:\n$error',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onFailure();
            },
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}
