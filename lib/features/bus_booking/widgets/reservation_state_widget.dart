// lib/features/bus_booking/widgets/reservation_state_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tika_place/features/bus_booking/models/booking_model.dart';

import '../../../core/config/theme/app_colors.dart';
import '../providers/booking_provider.dart';
import '../providers/reservation_state_notifier.dart';

class ReservationStateWidget extends ConsumerWidget {
  final String reservationId;
  final Widget child;
  final Widget Function(Widget child, String error)? errorBuilder;
  final Widget Function(Widget child)? loadingBuilder;
  final Widget Function(Widget child, Duration timeLeft)? timeoutBuilder;

  const ReservationStateWidget({
    super.key,
    required this.reservationId,
    required this.child,
    this.errorBuilder,
    this.loadingBuilder,
    this.timeoutBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centralState = ref.watch(centralReservationProvider);

    final reservation = centralState.reservations.firstWhere(
      (r) => r.id == reservationId,
      orElse: () => throw Exception('Réservation non trouvée'),
    );

    if (centralState.isLoading) {
      return loadingBuilder?.call(child) ??
          Stack(
            children: [
              child,
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.7),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ],
          );
    }

    if (centralState.error != null) {
      return errorBuilder?.call(child, centralState.error!) ??
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(8),
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
                        centralState.error!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
    }

    if (reservation.status == BookingStatus.pending && !reservation.isExpired) {
      final timeLeft = reservation.timeUntilExpiration;
      if (timeLeft.inMinutes <= 5) {
        return timeoutBuilder?.call(child, timeLeft) ??
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                child,
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Attention !',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                            Text(
                              'Expire dans ${_formatDuration(timeLeft)}',
                              style: const TextStyle(
                                color: AppColors.warning,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
      }
    }

    // Vérifier la disponibilité des places
    final isAvailable = centralState.seatsAvailability[reservationId];
    if (isAvailable == false) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.event_busy, color: AppColors.error),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Places non disponibles',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return child;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// Extension pour faciliter l'utilisation
extension ReservationStateExtension on Widget {
  Widget withReservationState(
    String reservationId, {
    Widget Function(Widget child, String error)? errorBuilder,
    Widget Function(Widget child)? loadingBuilder,
    Widget Function(Widget child, Duration timeLeft)? timeoutBuilder,
  }) {
    return ReservationStateWidget(
      reservationId: reservationId,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      timeoutBuilder: timeoutBuilder,
      child: this,
    );
  }
}
