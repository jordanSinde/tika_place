// lib/features/bus_booking/widgets/reservation_list_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tika_place/features/home/models/bus_mock_data.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../providers/reservation_provider.dart';
import '../../../core/config/theme/app_colors.dart';

class ReservationListWidget extends ConsumerWidget {
  final bool showOnlyActive;
  final VoidCallback? onRetryPayment;

  const ReservationListWidget({
    super.key,
    this.showOnlyActive = false,
    this.onRetryPayment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationState = ref.watch(reservationProvider);
    final reservations = showOnlyActive
        ? ref.read(reservationProvider.notifier).getActiveReservations()
        : reservationState.reservations;

    if (reservationState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reservations.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: reservations.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return _ReservationCard(
          reservation: reservations[index],
          onRetryPayment: onRetryPayment,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: AppColors.textLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune réservation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos réservations apparaîtront ici',
            style: TextStyle(
              color: AppColors.textLight.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final TicketReservation reservation;
  final VoidCallback? onRetryPayment;

  const _ReservationCard({
    required this.reservation,
    this.onRetryPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // En-tête avec statut
          _buildHeader(),

          // Détails de la réservation
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTripInfo(),
                const Divider(height: 24),
                _buildPassengerInfo(),
                if (reservation.status == BookingStatus.pending)
                  _buildExpirationTimer(),
                const SizedBox(height: 16),
                _buildActionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    Color statusColor;
    switch (reservation.status) {
      case BookingStatus.paid:
      case BookingStatus.confirmed:
        statusColor = AppColors.success;
        break;
      case BookingStatus.pending:
        statusColor = AppColors.warning;
        break;
      case BookingStatus.cancelled:
      case BookingStatus.expired:
      case BookingStatus.failed:
        statusColor = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(),
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            reservation.statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            'Réf: ${reservation.id}',
            style: TextStyle(
              color: AppColors.textLight.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfo() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${reservation.bus.departureCity} → ${reservation.bus.arrivalCity}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${reservation.bus.company} • ${reservation.bus.busClass.label}",
              style: TextStyle(
                color: AppColors.textLight.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${reservation.finalAmount.toStringAsFixed(0)} FCFA",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            if (reservation.actualDiscountAmount > 0)
              Text(
                "- ${reservation.actualDiscountAmount.toStringAsFixed(0)} FCFA",
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPassengerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${reservation.totalPassengers} ${reservation.totalPassengers > 1 ? 'passagers' : 'passager'}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        ...reservation.passengers.map((passenger) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                "${passenger.firstName} ${passenger.lastName}",
                style: TextStyle(
                  color: AppColors.textLight.withOpacity(0.7),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildExpirationTimer() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer,
            color: AppColors.warning,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            "Expire dans ${reservation.formattedTimeUntilExpiration}",
            style: const TextStyle(
              color: AppColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (reservation.status == BookingStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showCancellationDialog(context),
              child: const Text('Annuler'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: onRetryPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Payer'),
            ),
          ),
        ],
      );
    }

    if (reservation.status == BookingStatus.confirmed) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // Naviguer vers l'écran des tickets
            },
            icon: const Icon(Icons.receipt_long),
            label: const Text('Voir les tickets'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  IconData _getStatusIcon() {
    switch (reservation.status) {
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.paid:
        return Icons.monetization_on;
      case BookingStatus.pending:
        return Icons.pending;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.expired:
        return Icons.timer_off;
      case BookingStatus.failed:
        return Icons.error;
    }
  }

  Future<void> _showCancellationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation ?'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette réservation ? '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non, garder'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implémenter l'annulation
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }
}
