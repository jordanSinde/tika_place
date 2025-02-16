// lib/features/bus_booking/screens/booking/steps/payment_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/config/theme/app_colors.dart';
import '../../booking/models/base_reservation.dart';
import '../../booking/providers/reservation_provider.dart';
import '../models/booking_model.dart';
import '../providers/price_calculator_provider.dart';
import '../widgets/price_summary_widget.dart';
import '../widgets/promo_code_input.dart';
import 'models/payment_error.dart';
import 'payment_success_screen.dart';
import '../providers/booking_provider.dart';
import 'widgets/payment_code_form.dart';
import 'widgets/payment_session_timer.dart';

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
  String? _reservationId;
  bool _isInitialized = false;
  PaymentMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _initializeReservation();
  }

  Future<void> _initializeReservation() async {
    if (_isInitialized) return;

    final bookingState = ref.read(bookingProvider);
    final priceState = ref.read(priceCalculatorProvider);

    try {
      // Créer une réservation en attente
      _reservationId =
          await ref.read(reservationProvider.notifier).createPendingReservation(
        type: ReservationType.bus,
        amount: priceState.total,
        details: {
          'bus': bookingState.selectedBus,
          'passengers': bookingState.passengers,
        },
      );

      setState(() => _isInitialized = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'initialisation de la réservation'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handlePayment(String code, double amount) async {
    if (_reservationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: Réservation non initialisée'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      // Enregistrer la tentative de paiement
      final attempt = PaymentAttempt(
        timestamp: DateTime.now(),
        status: 'pending',
        paymentMethod: _selectedMethod!.toString(),
        amountPaid: amount,
      );

      await ref.read(reservationProvider.notifier).addPaymentAttempt(
            _reservationId!,
            attempt,
          );

      // Simuler le processus de paiement
      await Future.delayed(const Duration(seconds: 2));

      // Simuler un succès aléatoire
      if (DateTime.now().millisecond % 3 == 0) {
        throw PaymentError.invalidCode();
      }

      // Mise à jour de la tentative de paiement avec succès
      final successAttempt = attempt.copyWith(
        status: 'success',
        amountPaid: amount,
      );

      await ref.read(reservationProvider.notifier).addPaymentAttempt(
            _reservationId!,
            successAttempt,
          );

      // Redirection vers l'écran de succès
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            bookingReference: _reservationId!,
          ),
        ),
      );
    } on PaymentError catch (e) {
      final failedAttempt = PaymentAttempt(
        timestamp: DateTime.now(),
        status: 'failed',
        paymentMethod: _selectedMethod!.toString(),
        errorMessage: e.message,
      );

      await ref.read(reservationProvider.notifier).addPaymentAttempt(
            _reservationId!,
            failedAttempt,
          );

      _showErrorDialog(e);
    } catch (e) {
      final failedAttempt = PaymentAttempt(
        timestamp: DateTime.now(),
        status: 'failed',
        paymentMethod: _selectedMethod!.toString(),
        errorMessage: e.toString(),
      );

      await ref.read(reservationProvider.notifier).addPaymentAttempt(
            _reservationId!,
            failedAttempt,
          );

      _showErrorDialog(PaymentError.unknown(e.toString()));
    }
  }

  void _showErrorDialog(PaymentError error) {
    final attempts = ref.read(paymentAttemptsProvider.notifier);
    final remaining = attempts.getRemainingAttempts(_reservationId!);

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

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final priceState = ref.watch(priceCalculatorProvider);

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

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
          if (_selectedMethod != null) ...[
            const SizedBox(height: 24),
            PaymentCodeForm(
              paymentMethod: _selectedMethod!,
              onCodeSubmitted: (code) => _handlePayment(code, priceState.total),
              onClose: () {
                setState(() {
                  _selectedMethod = null;
                });
              },
            ),
          ],
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: bookingState.isLoading ? null : widget.onPrevious,
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

  // Les méthodes _buildOrderSummary et _buildPaymentMethods restent identiques
  // ... [Code précédent pour ces méthodes]

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

/*
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
}*/
