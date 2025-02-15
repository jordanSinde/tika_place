// lib/features/bus_booking/screens/payment_step.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tika_place/features/bus_booking/models/booking_model.dart';

import '../../../core/config/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/services/notification_service.dart';
import '../providers/booking_provider.dart';
import '../providers/price_calculator_provider.dart';
import '../providers/reservation_provider.dart';
import '../providers/reservation_state_notifier.dart';
import '../services/validation_service.dart';
import '../widgets/price_summary_widget.dart';
import '../widgets/promo_code_input.dart';
import 'payment_success_screen.dart';
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
  bool _isProcessing = false;
  late final Timer _checkTimer;

  @override
  void initState() {
    super.initState();
    _initializeReservation();
    // Vérifier la disponibilité toutes les minutes
    _checkTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkAvailabilityAndTimeout(),
    );
  }

  @override
  void dispose() {
    _checkTimer.cancel();
    super.dispose();
  }

  Future<void> _initializeReservation() async {
    final bookingState = ref.read(bookingProvider);
    if (bookingState.selectedBus == null) return;

    // Vérifier s'il n'y a pas déjà une réservation en cours
    final hasDuplicate = await ref
        .read(centralReservationProvider.notifier)
        .checkDuplicateReservation(
          ref.read(authProvider).user!.id,
          bookingState.selectedBus!.id,
        );

    if (hasDuplicate) {
      if (mounted) {
        _showErrorDialog(
          'Une réservation est déjà en cours pour ce voyage',
          isDuplicate: true,
        );
      }
      return;
    }

    // Valider les données
    final reservation = TicketReservation(
        // ... création de la réservation
        );

    if (!validationService.validateReservationData(reservation)) {
      if (mounted) {
        _showErrorDialog('Données de réservation invalides');
      }
      return;
    }

    try {
      // Créer la réservation
      await ref.read(reservationProvider.notifier).createReservation(
            bus: bookingState.selectedBus!,
            passengers: bookingState.passengers,
            totalAmount: ref.read(priceCalculatorProvider).total,
          );
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erreur lors de la création de la réservation: $e');
      }
    }
  }

  Future<void> _checkAvailabilityAndTimeout() async {
    final reservation = ref.read(reservationProvider).currentReservation;
    if (reservation == null) return;

    // Vérifier la disponibilité
    final isAvailable = await ref
        .read(centralReservationProvider.notifier)
        ._checkSeatAvailability(
          reservation.bus.id,
          reservation.passengers.length,
        );

    if (!isAvailable) {
      if (mounted) {
        _showErrorDialog(
          'Les places ne sont plus disponibles',
          isAvailability: true,
        );
      }
      return;
    }

    // Vérifier le timeout
    if (reservation.timeUntilExpiration.inMinutes <= 5) {
      await notificationService.notifyPaymentReminder(
        reservationId: reservation.id,
        expiresAt: reservation.expiresAt,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final priceState = ref.watch(priceCalculatorProvider);
    final reservationState = ref.watch(reservationProvider);
    final currentReservation = reservationState.currentReservation;

    if (currentReservation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentReservation.isExpired) {
      return _buildExpiredReservation();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderSummary(currentReservation),
          const SizedBox(height: 24),
          _buildPaymentSection(currentReservation, priceState.total),
          if (reservationState.error != null)
            _buildErrorMessage(reservationState.error!),
          const SizedBox(height: 32),
          _buildBackButton(),
          if (currentReservation.timeUntilExpiration.inMinutes <= 5)
            _buildExpirationWarning(currentReservation.timeUntilExpiration),
        ],
      ),
    );
  }

  Future<void> _handlePayment(String code) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    final reservationState = ref.read(reservationProvider);
    final currentReservation = reservationState.currentReservation;

    try {
      if (currentReservation == null) {
        throw Exception('Réservation non trouvée');
      }

      // Valider le paiement
      if (!validationService.validatePaymentCode(code, _selectedMethod!)) {
        throw Exception('Code de paiement invalide');
      }

      // Vérifier le nombre de tentatives
      if (!await ref
          .read(centralReservationProvider.notifier)
          .validatePaymentAttempt(currentReservation.id)) {
        throw Exception('Nombre maximum de tentatives atteint');
      }

      // Traiter le paiement
      final success =
          await ref.read(reservationProvider.notifier).handlePaymentAttempt(
                reservationId: currentReservation.id,
                method: _selectedMethod!,
                phoneNumber: _phoneController.text,
                code: code,
              );

      if (!mounted) return;

      if (success) {
        // Rediriger vers l'écran de succès
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              bookingReference: currentReservation.id,
            ),
          ),
        );
      } else {
        _showErrorDialog(
          'Le paiement a échoué. Vous pourrez réessayer depuis votre historique de réservations.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showErrorDialog(
    String message, {
    bool isDuplicate = false,
    bool isAvailability = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isDuplicate
                  ? Icons.copy
                  : isAvailability
                      ? Icons.event_busy
                      : Icons.error_outline,
              color: AppColors.error,
            ),
            const SizedBox(width: 8),
            const Text('Erreur'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (isDuplicate || isAvailability) ...[
              const SizedBox(height: 16),
              const Text(
                'Vous serez redirigé vers l\'écran précédent',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isDuplicate || isAvailability) {
                widget.onPrevious();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ... (reste du code existant pour le build)

  Widget _buildOrderSummary(TicketReservation reservation) {
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
              '${reservation.bus.departureCity} → ${reservation.bus.arrivalCity}',
            ),
            _buildSummaryRow(
              'Date',
              DateFormat('dd MMM yyyy HH:mm')
                  .format(reservation.bus.departureTime),
            ),
            _buildSummaryRow(
              'Passagers',
              '${reservation.passengers.length} personne(s)',
            ),
            const Divider(height: 32),
            const PromoCodeInput(),
            const SizedBox(height: 16),
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

  Widget _buildPaymentSection(
      TicketReservation reservation, double totalAmount) {
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
        Column(
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
        ),
        if (_selectedMethod != null) ...[
          const SizedBox(height: 24),
          PaymentCodeForm(
            paymentMethod: _selectedMethod!,
            onCodeSubmitted: (code) => _handlePayment(code),
            onClose: () {
              setState(() {
                _selectedMethod = null;
              });
            },
            reservation: reservation,
          ),
        ],
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
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiredReservation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer_off,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Réservation expirée',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Le délai de paiement a expiré. Veuillez effectuer une nouvelle réservation.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onPrevious,
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpirationWarning(Duration timeLeft) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, color: AppColors.warning, size: 16),
          const SizedBox(width: 8),
          Text(
            'Expire dans ${timeLeft.inMinutes}:${(timeLeft.inSeconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isProcessing ? null : widget.onPrevious,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppColors.primary),
        ),
        child: const Text('Retour'),
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
}

//V2
/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/theme/app_colors.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../providers/reservation_provider.dart';
import '../providers/price_calculator_provider.dart';
import '../providers/ticket_provider.dart';
import '../widgets/price_summary_widget.dart';
import '../widgets/promo_code_input.dart';
import 'payment_success_screen.dart';
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
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeReservation();
  }

  Future<void> _initializeReservation() async {
    final bookingState = ref.read(bookingProvider);
    if (bookingState.selectedBus != null) {
      try {
        // Créer la réservation avec statut PENDING
        final reservation =
            await ref.read(reservationProvider.notifier).createReservation(
                  bus: bookingState.selectedBus!,
                  passengers: bookingState.passengers
                      .map((p) => PassengerInfo(
                            firstName: p.firstName,
                            lastName: p.lastName,
                            phoneNumber: p.phoneNumber,
                            cniNumber: p.cniNumber,
                            isMainPassenger: p.isMainPassenger,
                          ))
                      .toList(),
                  totalAmount: ref.read(priceCalculatorProvider).total,
                  promoCode: ref.read(priceCalculatorProvider).appliedPromoCode,
                  discountAmount: ref.read(priceCalculatorProvider).discount,
                );

        if (reservation == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erreur lors de la création de la réservation'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _handlePayment(String paymentCode) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    final reservationState = ref.read(reservationProvider);
    final currentReservation = reservationState.currentReservation;

    try {
      if (currentReservation == null) {
        throw Exception('Réservation non trouvée');
      }

      if (currentReservation.isExpired) {
        throw Exception('La réservation a expiré');
      }

      // Traiter le paiement
      final success =
          await ref.read(reservationProvider.notifier).handlePaymentAttempt(
                reservationId: currentReservation.id,
                method: _selectedMethod!,
                phoneNumber: phoneNumber,
                paymentCode: paymentCode,
              );

      if (!mounted) return;

      if (success) {
        // Générer les tickets
        await ref.read(ticketsProvider.notifier).generateTicketsAfterPayment(
              currentReservation.id,
            );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              bookingReference: currentReservation.id,
            ),
          ),
        );
      } else {
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
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
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
              style: TextStyle(color: AppColors.textLight, fontSize: 12),
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

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final priceState = ref.watch(priceCalculatorProvider);
    final reservationState = ref.watch(reservationProvider);
    final currentReservation = reservationState.currentReservation;

    if (currentReservation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentReservation.isExpired) {
      return _buildExpiredReservation();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderSummary(currentReservation),
          const SizedBox(height: 24),
          _buildPaymentSection(currentReservation, priceState.total),
          if (reservationState.error != null)
            _buildErrorMessage(reservationState.error!),
          const SizedBox(height: 32),
          _buildBackButton(),
          if (currentReservation.timeUntilExpiration.inMinutes <= 5)
            _buildExpirationWarning(currentReservation.timeUntilExpiration),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(TicketReservation reservation) {
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
              '${reservation.bus.departureCity} → ${reservation.bus.arrivalCity}',
            ),
            _buildSummaryRow(
              'Date',
              DateFormat('dd MMM yyyy HH:mm')
                  .format(reservation.bus.departureTime),
            ),
            _buildSummaryRow(
              'Passagers',
              '${reservation.passengers.length} personne(s)',
            ),
            const Divider(height: 32),
            const PromoCodeInput(),
            const SizedBox(height: 16),
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

  Widget _buildPaymentSection(
      TicketReservation reservation, double totalAmount) {
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
        Column(
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
        ),
        if (_selectedMethod != null) ...[
          const SizedBox(height: 24),
          PaymentCodeForm(
            paymentMethod: _selectedMethod!,
            onCodeSubmitted: (code) => _handlePayment(code),
            onClose: () {
              setState(() {
                _selectedMethod = null;
              });
            },
            reservation: reservation,
          ),
        ],
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
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiredReservation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer_off,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Réservation expirée',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Le délai de paiement a expiré. Veuillez effectuer une nouvelle réservation.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onPrevious,
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpirationWarning(Duration timeLeft) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, color: AppColors.warning, size: 16),
          const SizedBox(width: 8),
          Text(
            'Expire dans ${timeLeft.inMinutes}:${(timeLeft.inSeconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isProcessing ? null : widget.onPrevious,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppColors.primary),
        ),
        child: const Text('Retour'),
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
}*/

//V1

/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tika_place/features/bus_booking/models/booking_model.dart';
import '../../../../../core/config/theme/app_colors.dart';
import '../providers/booking_provider.dart';
import '../providers/price_calculator_provider.dart';
import '../providers/reservation_provider.dart';
import '../widgets/price_summary_widget.dart';
import '../widgets/promo_code_input.dart';
import 'payment_success_screen.dart';
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
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
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
    final reservationState = ref.watch(reservationProvider);
    final currentReservation = reservationState.currentReservation;

    // Si pas de réservation, créons-en une
    if (currentReservation == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeReservation();
      });

      // Afficher un indicateur de chargement en attendant
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (currentReservation.status == BookingStatus.expired) {
      return _buildExpiredReservation();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderSummary(bookingState),
          const SizedBox(height: 24),
          _buildPaymentSection(bookingState, priceState.total),
          if (bookingState.error != null)
            _buildErrorMessage(bookingState.error!),
          const SizedBox(height: 32),
          _buildBackButton(bookingState.isLoading),
        ],
      ),
    );
  }

  Future<void> _initializeReservation() async {
    try {
      final bookingState = ref.read(bookingProvider);
      if (bookingState.selectedBus != null) {
        await ref.read(reservationProvider.notifier).createReservation(
              bus: bookingState.selectedBus!,
              passengers: bookingState.passengers
                  .map((p) => PassengerInfo(
                        firstName: p.firstName,
                        lastName: p.lastName,
                        phoneNumber: p.phoneNumber,
                        cniNumber: p.cniNumber,
                        isMainPassenger: p.isMainPassenger,
                      ))
                  .toList(),
              totalAmount: bookingState.totalAmount!,
              promoCode: ref.read(priceCalculatorProvider).appliedPromoCode,
              discountAmount: ref.read(priceCalculatorProvider).discount,
            );

        // Recalculer les prix
        ref
            .read(priceCalculatorProvider.notifier)
            .calculatePrice(bookingState.totalAmount!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildExpiredReservation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer_off,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Réservation expirée',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Le délai de paiement a expiré. Veuillez effectuer une nouvelle réservation.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onPrevious,
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(BookingState bookingState, double totalAmount) {
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
        _buildPaymentMethods(),
        if (_selectedMethod != null) ...[
          const SizedBox(height: 24),
          PaymentCodeForm(
            paymentMethod: _selectedMethod!,
            onCodeSubmitted: (code) => _handlePayment(code, totalAmount),
            onClose: () {
              setState(() {
                _selectedMethod = null;
              });
              ref.read(bookingProvider.notifier).updatePaymentMethod(null);
            },
          ),
        ],
      ],
    );
  }

  Future<void> _handlePayment(String code, double totalAmount) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    final reservationState = ref.read(reservationProvider);
    final currentReservation = reservationState.currentReservation;

    try {
      if (currentReservation == null) {
        throw Exception('Réservation non trouvée');
      }

      if (currentReservation.isExpired) {
        throw Exception('La réservation a expiré');
      }

      final success =
          await ref.read(bookingProvider.notifier).processPayment(ref);

      if (!mounted) return;

      if (success) {
        final bookingReference = ref.read(bookingProvider).bookingReference;

        if (bookingReference != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                bookingReference: bookingReference,
              ),
            ),
          );
        }
      } else {
        _showErrorDialog(
          'Le paiement a échoué. Vous pourrez réessayer depuis votre historique de réservations.',
        );
      }
    } catch (e) {
      print("Erreur dans _handlePayment: $e");

      if (currentReservation != null) {
        await ref.read(reservationProvider.notifier).recordPaymentFailure(
              currentReservation.id,
              e.toString(),
              _selectedMethod.toString(),
            );
      }

      if (!mounted) return;
      _showErrorDialog(
        'Une erreur est survenue. Vous pourrez réessayer depuis votre historique de réservations.',
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
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
            const PromoCodeInput(),
            const SizedBox(height: 16),
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

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : widget.onPrevious,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppColors.primary),
        ),
        child: const Text('Retour'),
      ),
    );
  }
}
*/