// lib/features/bus_booking/widgets/payment_session_timer.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme/app_colors.dart';

class PaymentSessionTimer extends ConsumerStatefulWidget {
  final VoidCallback onTimeout;
  final int durationInMinutes;

  const PaymentSessionTimer({
    super.key,
    required this.onTimeout,
    this.durationInMinutes = 5,
  });

  @override
  ConsumerState<PaymentSessionTimer> createState() =>
      _PaymentSessionTimerState();
}

class _PaymentSessionTimerState extends ConsumerState<PaymentSessionTimer> {
  Timer? _timer;
  late int _remainingSeconds;
  bool _isWarning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationInMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          // Activer l'avertissement à 1 minute de la fin
          if (_remainingSeconds == 60) {
            _showWarning();
          }
        } else {
          _timer?.cancel();
          widget.onTimeout();
        }
      });
    });
  }

  void _showWarning() {
    setState(() => _isWarning = true);
    // Afficher une notification d'avertissement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plus qu\'une minute pour finaliser votre paiement !'),
        backgroundColor: AppColors.warning,
        duration: Duration(seconds: 5),
      ),
    );
  }

  String get _formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = _isWarning ? AppColors.error : AppColors.textLight;
    if (_remainingSeconds < 30) {
      textColor = AppColors.error;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer,
          size: 16,
          color: textColor,
        ),
        const SizedBox(width: 4),
        Text(
          'Temps restant: $_formattedTime',
          style: TextStyle(
            color: textColor,
            fontWeight: _isWarning ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// Provider pour gérer les tentatives de paiement
final paymentAttemptsProvider =
    StateProvider<Map<String, List<DateTime>>>((ref) => {});

// Extension pour gérer les tentatives de paiement
extension PaymentAttemptsX on StateController<Map<String, List<DateTime>>> {
  bool canAttemptPayment(String bookingReference) {
    final attempts = state[bookingReference] ?? [];
    if (attempts.isEmpty) return true;

    // Limiter à 3 tentatives par jour
    final today = DateTime.now();
    final attemptsToday = attempts.where((date) {
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).length;

    return attemptsToday < 3;
  }

  void recordAttempt(String bookingReference) {
    final attempts = state[bookingReference] ?? [];
    state = {
      ...state,
      bookingReference: [...attempts, DateTime.now()],
    };
  }

  int getRemainingAttempts(String bookingReference) {
    final attempts = state[bookingReference] ?? [];
    final today = DateTime.now();
    final attemptsToday = attempts.where((date) {
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).length;

    return 3 - attemptsToday;
  }
}
