//lib/features/bus_booking/screens/booking/payment_screen.dart
/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/config/theme/app_colors.dart';
import '../../providers/booking_provider.dart';
import '../models/payment_error.dart';
import '../payment_success_screen.dart';
import '../widgets/payment_code_form.dart';
import '../widgets/payment_session_timer.dart';

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
  bool _isProcessing = false;
  PaymentError? _lastError;

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final attempts = ref.watch(paymentAttemptsProvider.notifier);

    if (!attempts.canAttemptPayment(widget.bookingReference)) {
      return _buildMaxAttemptsReached(
          attempts.getRemainingAttempts(widget.bookingReference));
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paiement'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _onWillPop().then((canPop) {
              if (canPop) Navigator.pop(context);
            }),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timer en haut de l'écran
            Container(
              color: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: PaymentSessionTimer(
                onTimeout: () {
                  if (!mounted) return;
                  // Enregistrer la tentative
                  ref
                      .read(paymentAttemptsProvider.notifier)
                      .recordAttempt(widget.bookingReference);
                  // Afficher le dialogue d'expiration
                  _showErrorDialog(PaymentError.timeout());
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAmountCard(),
                    const SizedBox(height: 24),
                    if (bookingState.paymentMethod != null)
                      PaymentCodeForm(
                        paymentMethod: bookingState.paymentMethod!,
                        onCodeSubmitted: _handlePaymentCode,
                        onClose: () {
                          ref
                              .read(bookingProvider.notifier)
                              .updatePaymentMethod(null);
                        },
                      ),
                    if (_lastError != null)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _lastError!.message,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_lastError!.canRetry) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tentatives restantes : ${attempts.getRemainingAttempts(widget.bookingReference)}',
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (bookingState.paymentMethod == null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildPaymentMethods(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaxAttemptsReached(int remainingAttempts) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'Nombre maximum de tentatives atteint',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Vous pourrez réessayer dans 24 heures.\nVotre réservation reste disponible dans votre historique.',
                style: TextStyle(
                  color: AppColors.textLight.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Retourner à l\'historique'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePaymentCode(String code) async {
    setState(() {
      _isProcessing = true;
      _lastError = null;
    });

    try {
      // Enregistrer la tentative de paiement
      ref
          .read(paymentAttemptsProvider.notifier)
          .recordAttempt(widget.bookingReference);

      // Simuler la vérification du paiement
      await Future.delayed(const Duration(seconds: 2));

      // Simuler un succès aléatoire
      if (DateTime.now().millisecond % 3 == 0) {
        throw PaymentError.invalidCode();
      }

      if (!mounted) return;

      // Si le paiement réussit, naviguer vers l'écran de succès
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            bookingReference: widget.bookingReference,
          ),
        ),
      );
    } on PaymentError catch (e) {
      setState(() => _lastError = e);
      _showErrorDialog(e);
    } catch (e) {
      setState(() => _lastError = PaymentError.unknown(e.toString()));
      _showErrorDialog(_lastError!);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showErrorDialog(PaymentError error) {
    final attempts = ref.read(paymentAttemptsProvider.notifier);
    final remaining = attempts.getRemainingAttempts(widget.bookingReference);

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
            Text(error.userMessage),
            if (error.canRetry) ...[
              const SizedBox(height: 8),
              Text(
                'Tentatives restantes aujourd\'hui : $remaining',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Vous pourrez réessayer le paiement depuis votre historique de réservations.',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (error.canRetry && remaining > 0)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Réessayer'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Annuler le paiement'),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_isProcessing) return false;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le paiement ?'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler ce paiement ? '
          'Vous pourrez toujours payer plus tard depuis votre historique de réservations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuer le paiement'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  Widget _buildAmountCard() {
    return Card(
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Choisissez un mode de paiement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildPaymentMethodButton(
          method: PaymentMethod.orangeMoney,
          title: 'Orange Money',
          color: const Color(0xFFFF6600),
        ),
        const SizedBox(height: 8),
        _buildPaymentMethodButton(
          method: PaymentMethod.mtnMoney,
          title: 'MTN Mobile Money',
          color: const Color(0xFFFFCC00),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodButton({
    required PaymentMethod method,
    required String title,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: _isProcessing
          ? null
          : () {
              ref.read(bookingProvider.notifier).updatePaymentMethod(method);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(title),
    );
  }
}*/



/*
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
}*/
