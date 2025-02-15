// lib/features/bus_booking/widgets/payment_code_form.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../notifications/services/notification_service.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/reservation_state_notifier.dart';
import '../../services/validation_service.dart';
import '../services/mobile_money_service.dart';

class PaymentCodeForm extends ConsumerStatefulWidget {
  final PaymentMethod paymentMethod;
  final Function(String) onCodeSubmitted;
  final VoidCallback onClose;
  final TicketReservation reservation;

  const PaymentCodeForm({
    super.key,
    required this.paymentMethod,
    required this.onCodeSubmitted,
    required this.onClose,
    required this.reservation,
  });

  @override
  ConsumerState<PaymentCodeForm> createState() => _PaymentCodeFormState();
}

class _PaymentCodeFormState extends ConsumerState<PaymentCodeForm> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isRequestingCode = false;
  bool _isVerifyingCode = false;
  bool _codeRequested = false;
  String? _phoneError;
  String? _codeError;
  Timer? _expirationTimer;
  Timer? _countdownTimer;
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    _startExpirationCheck();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _expirationTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startExpirationCheck() {
    final timeUntilExpiration = widget.reservation.timeUntilExpiration;
    if (timeUntilExpiration.inSeconds > 0) {
      _expirationTimer = Timer(timeUntilExpiration, () {
        if (mounted) {
          widget.onClose();
          // Notifier l'expiration via le service de notification
          notificationService.notifyReservationStatusChange(
            reservationId: widget.reservation.id,
            oldStatus: BookingStatus.pending,
            newStatus: BookingStatus.expired,
          );
        }
      });
    }
  }

  Future<void> _requestCode() async {
    if (_isRequestingCode) return;

    // Valider le numéro de téléphone
    if (!validationService.validatePaymentMethod(
      widget.paymentMethod,
      _phoneController.text,
    )) {
      _showError('Numéro de téléphone invalide');
      return;
    }

    // Vérifier les tentatives via le provider central
    if (!await ref
        .read(centralReservationProvider.notifier)
        .validatePaymentAttempt(widget.reservation.id)) {
      _showError('Nombre maximum de tentatives atteint pour aujourd\'hui');
      return;
    }

    setState(() => _isRequestingCode = true);

    try {
      // Initier le paiement via le provider central
      final response = await mobileMoneyService.initiatePayment(
        method: widget.paymentMethod,
        phoneNumber: _phoneController.text,
        amount: widget.reservation.totalAmount,
        reservationId: widget.reservation.id,
      );

      if (response.isSuccess) {
        setState(() => _codeRequested = true);
        _startResendCodeCountdown();
        _showSuccess('Code envoyé ! Vérifiez vos messages.');
      } else {
        _showError(response.message ?? 'Erreur lors de l\'envoi du code');
      }
    } catch (e) {
      _showError('Une erreur est survenue. Veuillez réessayer.');
    } finally {
      setState(() => _isRequestingCode = false);
    }
  }

  void _startResendCodeCountdown() {
    setState(() => _countdown = 60);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    // Valider le code de paiement
    if (!validationService.validatePaymentCode(
      _codeController.text,
      widget.paymentMethod,
    )) {
      _showError('Code de paiement invalide');
      return;
    }

    setState(() => _isVerifyingCode = true);

    try {
      await widget.onCodeSubmitted(_codeController.text);
    } catch (e) {
      _showError('Code invalide. Veuillez réessayer.');
    } finally {
      setState(() => _isVerifyingCode = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Écouter l'état central pour les mises à jour
    final centralState = ref.watch(centralReservationProvider);
    final currentReservation = centralState.reservations
        .firstWhere((r) => r.id == widget.reservation.id);

    if (currentReservation.status != BookingStatus.pending) {
      return _buildStatusChangedMessage(currentReservation.status);
    }

    if (currentReservation.isExpired) {
      return _buildExpirationMessage();
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildFormContent(),
          _buildExpirationWarning(currentReservation.timeUntilExpiration),
        ],
      ),
    );
  }

  Widget _buildStatusChangedMessage(BookingStatus status) {
    IconData icon;
    String message;
    Color color;

    switch (status) {
      case BookingStatus.confirmed:
        icon = Icons.check_circle;
        message = 'Paiement confirmé';
        color = AppColors.success;
        break;
      case BookingStatus.cancelled:
        icon = Icons.cancel;
        message = 'Réservation annulée';
        color = AppColors.error;
        break;
      default:
        icon = Icons.info;
        message = 'Statut mis à jour';
        color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
            ),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // ... (reste du code pour les autres widgets)

  Widget _buildHeader() {
    final isOrangeMoney = widget.paymentMethod == PaymentMethod.orangeMoney;
    final providerColor =
        isOrangeMoney ? const Color(0xFFFF6600) : const Color(0xFFFFCC00);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: providerColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.payment, color: providerColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOrangeMoney ? 'Orange Money' : 'MTN Mobile Money',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  'Un code de paiement sera envoyé par SMS',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    final isOrangeMoney = widget.paymentMethod == PaymentMethod.orangeMoney;
    final providerColor =
        isOrangeMoney ? const Color(0xFFFF6600) : const Color(0xFFFFCC00);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _phoneController,
            enabled: !_codeRequested,
            decoration: InputDecoration(
              labelText: 'Numéro de téléphone',
              hintText: isOrangeMoney ? '6XX XXX XXX' : '65X XXX XXX',
              prefixIcon: const Icon(Icons.phone),
              errorText: _phoneError,
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
          ),
          if (!_codeRequested) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isRequestingCode ? null : _requestCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: providerColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isRequestingCode
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Recevoir le code'),
            ),
          ],
          if (_codeRequested) ...[
            const SizedBox(height: 24),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Code de paiement',
                prefixIcon: const Icon(Icons.lock),
                errorText: _codeError,
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le code reçu';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isVerifyingCode ? null : _verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: providerColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isVerifyingCode
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Valider le paiement'),
            ),
            if (_countdown > 0) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Renvoyer le code dans ${_countdown}s',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ),
            ] else if (_codeRequested) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _requestCode,
                child: const Text('Renvoyer le code'),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildExpirationMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.timer_off, color: AppColors.error),
          const SizedBox(height: 8),
          const Text(
            'Session expirée',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Veuillez recommencer la réservation',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpirationWarning(Duration timeLeft) {
    return Container(
      padding: const EdgeInsets.all(8),
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
}



//V2
/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../services/mobile_money_service.dart';

class PaymentCodeForm extends ConsumerStatefulWidget {
  final PaymentMethod paymentMethod;
  final Function(String) onCodeSubmitted;
  final VoidCallback onClose;
  final TicketReservation reservation;

  const PaymentCodeForm({
    super.key,
    required this.paymentMethod,
    required this.onCodeSubmitted,
    required this.onClose,
    required this.reservation,
  });

  @override
  ConsumerState<PaymentCodeForm> createState() => _PaymentCodeFormState();
}

class _PaymentCodeFormState extends ConsumerState<PaymentCodeForm> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isRequestingCode = false;
  bool _isVerifyingCode = false;
  String? _phoneError;
  String? _codeError;
  bool _codeRequested = false;
  Timer? _expirationTimer;
  Timer? _countdownTimer;
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    _startExpirationCheck();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _expirationTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startExpirationCheck() {
    if (!widget.reservation.isExpired) {
      final timeUntilExpiration = widget.reservation.timeUntilExpiration;
      if (timeUntilExpiration.inSeconds > 0) {
        _expirationTimer = Timer(timeUntilExpiration, () {
          if (mounted) {
            widget.onClose();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('La session de paiement a expiré'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        });
      }
    }
  }

  void _startResendCodeCountdown() {
    setState(() => _countdown = 60); // 60 secondes avant de pouvoir renvoyer
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _requestCode() async {
    if (_isRequestingCode) return;
    if (widget.reservation.isExpired) {
      setState(() {
        _phoneError = 'La réservation a expiré';
      });
      return;
    }

    if (_phoneController.text.isEmpty) {
      setState(() {
        _phoneError = 'Veuillez entrer votre numéro de téléphone';
      });
      return;
    }

    setState(() {
      _isRequestingCode = true;
      _phoneError = null;
    });

    try {
      // Vérifier le format du numéro
      final isValid = await mobileMoneyService.verifyPhoneNumber(
        method: widget.paymentMethod,
        phoneNumber: _phoneController.text,
      );

      if (!mounted) return;

      if (isValid) {
        // Initier le paiement
        final response = await mobileMoneyService.initiatePayment(
          method: widget.paymentMethod,
          phoneNumber: _phoneController.text,
          amount: widget.reservation.totalAmount,
          description: 'Paiement billet de bus',
        );

        if (response.isSuccess) {
          setState(() {
            _codeRequested = true;
            _phoneError = null;
          });

          _startResendCodeCountdown();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Code envoyé ! Vérifiez vos messages.'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } else {
          setState(() {
            _phoneError = response.message ?? 'Erreur lors de l\'envoi du code';
          });
        }
      } else {
        setState(() {
          _phoneError = 'Numéro de téléphone invalide';
        });
      }
    } catch (e) {
      setState(() {
        _phoneError = 'Une erreur est survenue. Veuillez réessayer.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingCode = false;
        });
      }
    }
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.reservation.isExpired) {
      setState(() {
        _codeError = 'La réservation a expiré';
      });
      return;
    }

    setState(() {
      _isVerifyingCode = true;
      _codeError = null;
    });

    try {
      await widget.onCodeSubmitted(_codeController.text);
    } catch (e) {
      if (mounted) {
        setState(() {
          _codeError = 'Code invalide. Veuillez réessayer.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingCode = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reservation.isExpired) {
      return _buildExpirationMessage();
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildFormContent(),
          if (!_codeRequested &&
              widget.reservation.timeUntilExpiration.inMinutes <= 5)
            _buildExpirationWarning(widget.reservation.timeUntilExpiration),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isOrangeMoney = widget.paymentMethod == PaymentMethod.orangeMoney;
    final providerColor =
        isOrangeMoney ? const Color(0xFFFF6600) : const Color(0xFFFFCC00);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: providerColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.payment, color: providerColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOrangeMoney ? 'Orange Money' : 'MTN Mobile Money',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  'Un code de paiement sera envoyé par SMS',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    final isOrangeMoney = widget.paymentMethod == PaymentMethod.orangeMoney;
    final providerColor =
        isOrangeMoney ? const Color(0xFFFF6600) : const Color(0xFFFFCC00);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _phoneController,
            enabled: !_codeRequested,
            decoration: InputDecoration(
              labelText: 'Numéro de téléphone',
              hintText: isOrangeMoney ? '6XX XXX XXX' : '65X XXX XXX',
              prefixIcon: const Icon(Icons.phone),
              errorText: _phoneError,
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
          ),
          if (!_codeRequested) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isRequestingCode ? null : _requestCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: providerColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isRequestingCode
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Recevoir le code'),
            ),
          ],
          if (_codeRequested) ...[
            const SizedBox(height: 24),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Code de paiement',
                prefixIcon: const Icon(Icons.lock),
                errorText: _codeError,
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le code reçu';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isVerifyingCode ? null : _verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: providerColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isVerifyingCode
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Valider le paiement'),
            ),
            if (_countdown > 0) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Renvoyer le code dans ${_countdown}s',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ),
            ] else if (_codeRequested) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _requestCode,
                child: const Text('Renvoyer le code'),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildExpirationMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.timer_off, color: AppColors.error),
          const SizedBox(height: 8),
          const Text(
            'Session expirée',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Veuillez recommencer la réservation',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpirationWarning(Duration timeLeft) {
    return Container(
      padding: const EdgeInsets.all(8),
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
}*/


//V1
/*
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tika_place/features/bus_booking/models/booking_model.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../providers/booking_provider.dart';
import '../../providers/price_calculator_provider.dart';
import '../../providers/reservation_provider.dart';
import '../services/mobile_money_service.dart';

class PaymentCodeForm extends ConsumerStatefulWidget {
  final PaymentMethod paymentMethod;
  final Function(String) onCodeSubmitted;
  final VoidCallback onClose;

  const PaymentCodeForm({
    super.key,
    required this.paymentMethod,
    required this.onCodeSubmitted,
    required this.onClose,
  });

  @override
  ConsumerState<PaymentCodeForm> createState() => _PaymentCodeFormState();
}

class _PaymentCodeFormState extends ConsumerState<PaymentCodeForm> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isRequestingCode = false;
  bool _isVerifyingCode = false;
  String? _phoneError;
  String? _codeError;
  bool _codeRequested = false;
  Timer? _expirationTimer;

  @override
  void initState() {
    super.initState();
    _startExpirationCheck();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _expirationTimer?.cancel();
    super.dispose();
  }

  void _startExpirationCheck() {
    final reservation = ref.read(reservationProvider).currentReservation;
    if (reservation != null && !reservation.isExpired) {
      final timeUntilExpiration = reservation.timeUntilExpiration;
      if (timeUntilExpiration.inSeconds > 0) {
        _expirationTimer = Timer(timeUntilExpiration, () {
          if (mounted) {
            widget.onClose();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('La session de paiement a expiré'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        });
      }
    }
  }

  Future<void> _requestCode() async {
    final reservation = ref.read(reservationProvider).currentReservation;
    if (reservation == null || reservation.isExpired) {
      setState(() {
        _phoneError = 'La réservation a expiré';
      });
      return;
    }

    if (_phoneController.text.isEmpty) {
      setState(() {
        _phoneError = 'Veuillez entrer votre numéro de téléphone';
      });
      return;
    }

    setState(() {
      _isRequestingCode = true;
      _phoneError = null;
    });

    try {
      final isValid = await mobileMoneyService.verifyPhoneNumber(
        method: widget.paymentMethod,
        phoneNumber: _phoneController.text,
      );

      if (!mounted) return;

      if (isValid) {
        final price = ref.read(priceCalculatorProvider).total;
        final response = await mobileMoneyService.initiatePayment(
          method: widget.paymentMethod,
          phoneNumber: _phoneController.text,
          amount: price,
          description: 'Paiement billet de bus',
        );

        if (response.isSuccess) {
          setState(() {
            _codeRequested = true;
            _phoneError = null;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Code envoyé ! Vérifiez vos messages.'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } else {
          setState(() {
            _phoneError = response.message ?? 'Erreur lors de l\'envoi du code';
          });
        }
      } else {
        setState(() {
          _phoneError = 'Numéro de téléphone invalide';
        });
      }
    } catch (e) {
      setState(() {
        _phoneError = 'Une erreur est survenue. Veuillez réessayer.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingCode = false;
        });
      }
    }
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    final reservation = ref.read(reservationProvider).currentReservation;
    if (reservation == null || reservation.isExpired) {
      setState(() {
        _codeError = 'La réservation a expiré';
      });
      return;
    }

    setState(() {
      _isVerifyingCode = true;
      _codeError = null;
    });

    try {
      // Vérifier d'abord le code avec le service
      final verificationResult =
          await mobileMoneyService.checkTransactionStatus(
        _codeController.text,
      );

      if (!verificationResult.isSuccess) {
        throw Exception(verificationResult.message ?? 'Code invalide');
      }

      // Si la vérification réussit, soumettre le code
      await widget.onCodeSubmitted(_codeController.text);
    } catch (e) {
      if (mounted) {
        setState(() {
          _codeError = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingCode = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOrangeMoney = widget.paymentMethod == PaymentMethod.orangeMoney;
    final providerColor =
        isOrangeMoney ? const Color(0xFFFF6600) : const Color(0xFFFFCC00);

    final reservation = ref.watch(reservationProvider).currentReservation;
    if (reservation == null || reservation.isExpired) {
      return _buildExpirationMessage();
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(isOrangeMoney, providerColor),
          _buildFormContent(isOrangeMoney, providerColor),
          if (!_codeRequested && reservation.timeUntilExpiration.inMinutes <= 5)
            _buildExpirationWarning(reservation.timeUntilExpiration),
        ],
      ),
    );
  }

  Widget _buildExpirationMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.timer_off, color: AppColors.error),
          const SizedBox(height: 8),
          const Text(
            'Session expirée',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Veuillez recommencer la réservation',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isOrangeMoney, Color providerColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: providerColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.payment, color: providerColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOrangeMoney ? 'Orange Money' : 'MTN Mobile Money',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Un code de paiement sera envoyé par SMS',
                  style: TextStyle(
                    color: AppColors.textLight.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(bool isOrangeMoney, Color providerColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Numéro de téléphone',
              hintText: isOrangeMoney ? '6XX XXX XXX' : '65X XXX XXX',
              prefixIcon: const Icon(Icons.phone),
              errorText: _phoneError,
              enabled: !_codeRequested,
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
          ),
          if (!_codeRequested) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isRequestingCode ? null : _requestCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: providerColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isRequestingCode
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Recevoir le code'),
            ),
          ],
          if (_codeRequested) ...[
            const SizedBox(height: 24),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Code de paiement',
                prefixIcon: const Icon(Icons.lock),
                errorText: _codeError,
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le code reçu';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isVerifyingCode ? null : _verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: providerColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isVerifyingCode
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Valider le paiement'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpirationWarning(Duration timeLeft) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
}
*/