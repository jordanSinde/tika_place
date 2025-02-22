// lib/features/bus_booking/widgets/reservation_list_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tika_place/features/home/models/bus_mock_data.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../providers/reservation_provider.dart';
import '../../../core/config/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../paiement/payment_step.dart';
import '../paiement/payment_success_screen.dart';
import 'error_boundary_widget.dart';

class ReservationListWidget extends ConsumerWidget {
  final bool showOnlyActive;
  final int? limit;
  final Function(Map<BookingStatus, int> counts)? onStatusCountChanged;
  final String? showOnly;

  const ReservationListWidget({
    super.key,
    this.showOnlyActive = false,
    this.limit,
    this.onStatusCountChanged,
    this.showOnly,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationState = ref.watch(reservationProvider);
    final reservations = _getFilteredReservations(ref);

    if (reservationState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reservations.isEmpty) {
      return _buildEmptyState();
    }

    // Calculate status counts but don't call the callback directly during build
    if (onStatusCountChanged != null) {
      // Use post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final counts = _calculateStatusCounts(ref);
        onStatusCountChanged!(counts);
      });
    }

    // If limit is set, only show that many items
    final displayReservations = limit != null && reservations.length > limit!
        ? reservations.sublist(0, limit)
        : reservations;

    return Column(
      children: [
        ListView.builder(
          itemCount: displayReservations.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return ErrorBoundaryWidget(
              child: _ReservationCard(
                reservation: displayReservations[index],
                onTap: () => _handleReservationTap(
                    context, displayReservations[index], ref),
              ),
            );
          },
        ),

        // Show "See all" button if limited
        if (limit != null && reservations.length > limit!)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: InkWell(
              onTap: () => _navigateToAllReservations(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Voir toutes les réservations (${reservations.length})',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Map<BookingStatus, int> _calculateStatusCounts(WidgetRef ref) {
    final reservations = ref.read(reservationProvider).reservations;
    final Map<BookingStatus, int> counts = {};

    for (final status in BookingStatus.values) {
      counts[status] = reservations.where((r) => r.status == status).length;
    }

    return counts;
  }

  List<TicketReservation> _getFilteredReservations(WidgetRef ref) {
    if (showOnly != null) {
      // Show only the specific reservation if ID is provided
      final allReservations = ref.read(reservationProvider).reservations;
      final matches = allReservations.where((r) => r.id == showOnly).toList();
      return matches;
    }

    if (showOnlyActive) {
      return ref.read(reservationProvider.notifier).getActiveReservations();
    }

    final allReservations = ref.read(reservationProvider).reservations;
    // Sort by creation date, newest first
    return List.from(allReservations)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _navigateToAllReservations(BuildContext context) {
    // Navigate to all reservations screen
    context.push('/reservations/bus');
  }

// Update the _handleReservationTap method in ReservationListWidget
  void _handleReservationTap(
    BuildContext context,
    TicketReservation reservation,
    WidgetRef ref,
  ) {
    switch (reservation.status) {
      case BookingStatus.pending:
        _navigateToPayment(context, reservation, ref);
        break;
      case BookingStatus.confirmed:
      case BookingStatus.paid:
        _navigateToTickets(context, reservation);
        break;
      case BookingStatus.cancelled:
        _showCancellationDetails(context, reservation);
        break;
      case BookingStatus.expired:
        _showExpirationDetails(context, reservation);
        break;
      case BookingStatus.failed:
        _showFailureDetails(context, reservation, ref);
        break;
    }
  }

  void _navigateToPayment(
    BuildContext context,
    TicketReservation reservation,
    WidgetRef ref,
  ) {
    // Set up booking state from reservation
    final bookingNotifier = ref.read(bookingProvider.notifier);
    // Reset current state
    bookingNotifier.reset();

    // Initialize with reservation data
    bookingNotifier.initializeBooking(
      reservation.bus,
      ref.read(authProvider).user!,
    );

    // Update booking reference to match reservation
    bookingNotifier.updateBookingReference(reservation.id);

    // Navigate to payment step
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentStep(
          onPrevious: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _navigateToTickets(BuildContext context, TicketReservation reservation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(
          bookingReference: reservation.id,
        ),
      ),
    );
  }

  void _showCancellationDetails(
      BuildContext context, TicketReservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel, color: _getStatusColor(BookingStatus.cancelled)),
            const SizedBox(width: 8),
            const Text('Réservation annulée'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plus de sièges disponibles',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Désolé, le bus ${reservation.bus.departureCity} → ${reservation.bus.arrivalCity} '
              'n\'a plus de places disponibles pour la date sélectionnée.',
            ),
            const SizedBox(height: 16),
            Text(
              'Date d\'annulation: ${DateFormat('dd/MM/yyyy HH:mm').format(reservation.expiresAt)}',
              style: const TextStyle(color: AppColors.textLight, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/bus-search');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Chercher un autre bus'),
          ),
        ],
      ),
    );
  }

  void _showExpirationDetails(
      BuildContext context, TicketReservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.timer_off,
                color: _getStatusColor(BookingStatus.expired)),
            const SizedBox(width: 8),
            const Text('Réservation expirée'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Délai de paiement dépassé',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre réservation pour ${reservation.bus.departureCity} → ${reservation.bus.arrivalCity} '
              'a expiré car le paiement n\'a pas été effectué dans le délai imparti.',
            ),
            const SizedBox(height: 16),
            Text(
              'Expirée le: ${DateFormat('dd/MM/yyyy HH:mm').format(reservation.expiresAt)}',
              style: const TextStyle(color: AppColors.textLight, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/bus-search');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Réserver à nouveau'),
          ),
        ],
      ),
    );
  }

  void _showFailureDetails(
      BuildContext context, TicketReservation reservation, WidgetRef ref) {
    final lastPaymentAttempt = reservation.lastPaymentAttempt;
    final errorMessage = lastPaymentAttempt?.errorMessage ??
        'Le paiement a échoué. Vous pouvez réessayer.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline,
                color: _getStatusColor(BookingStatus.failed)),
            const SizedBox(width: 8),
            const Text('Paiement échoué'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              errorMessage,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            if (lastPaymentAttempt != null)
              Text(
                'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(lastPaymentAttempt.timestamp)}',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToPayment(context, reservation, ref);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Réessayer le paiement'),
          ),
        ],
      ),
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
  final VoidCallback onTap;

  const _ReservationCard({
    required this.reservation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      elevation: 2,
      shadowColor: _getStatusColor(reservation.status).withOpacity(0.2),
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
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
                    _buildTimeInfo(),
                    if (reservation.status == BookingStatus.pending)
                      _buildExpirationTimer(),
                    const SizedBox(height: 8),
                    _buildPassengerInfo(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getStatusColor(reservation.status).withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(),
            color: _getStatusColor(reservation.status),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            reservation.statusText,
            style: TextStyle(
              color: _getStatusColor(reservation.status),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            'Réf: ${_formatReference(reservation.id)}',
            style: TextStyle(
              color: AppColors.textLight.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: AppColors.textLight.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  String _formatReference(String ref) {
    if (ref.length > 10) {
      return '${ref.substring(0, 4)}...${ref.substring(ref.length - 4)}';
    }
    return ref;
  }

  Widget _buildTripInfo() {
    final departure = reservation.bus.departureTime;
    final arrival = reservation.bus.arrivalTime;
    final duration = arrival.difference(departure);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bus company logo/placeholder
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              reservation.bus.company.substring(0, 1),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Trip details
        Expanded(
          child: Column(
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
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$hours h ${minutes > 0 ? '$minutes min' : ''}",
                style: TextStyle(
                  color: AppColors.textLight.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Price
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

  Widget _buildTimeInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildTimeColumn(
            label: 'Départ',
            time: DateFormat('HH:mm').format(reservation.bus.departureTime),
            date: DateFormat('EEE, dd MMM', 'fr_FR')
                .format(reservation.bus.departureTime),
            icon: Icons.departure_board,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColors.textLight.withOpacity(0.5),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 1,
                      color: AppColors.divider,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildTimeColumn(
            label: 'Arrivée',
            time: DateFormat('HH:mm').format(reservation.bus.arrivalTime),
            date: DateFormat('EEE, dd MMM', 'fr_FR')
                .format(reservation.bus.arrivalTime),
            icon: Icons.location_on,
            alignment: CrossAxisAlignment.end,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn({
    required String label,
    required String time,
    required String date,
    required IconData icon,
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textLight.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          date,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textLight.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildExpirationTimer() {
    final isExpiringSoon = reservation.timeUntilExpiration.inMinutes < 5;

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (isExpiringSoon ? AppColors.error : AppColors.warning)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isExpiringSoon ? AppColors.error : AppColors.warning)
              .withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer,
            color: isExpiringSoon ? AppColors.error : AppColors.warning,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isExpiringSoon
                  ? "Expire bientôt (${reservation.formattedTimeUntilExpiration})"
                  : "Expire dans ${reservation.formattedTimeUntilExpiration}",
              style: TextStyle(
                color: isExpiringSoon ? AppColors.error : AppColors.warning,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.people,
            color: AppColors.primary,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "${reservation.totalPassengers} ${reservation.totalPassengers > 1 ? 'passagers' : 'passager'}",
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        _buildActionButton(),
      ],
    );
  }

  Widget _buildActionButton() {
    switch (reservation.status) {
      case BookingStatus.pending:
        return ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.payment, size: 16),
          label: const Text('Payer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: const TextStyle(fontSize: 13),
          ),
        );
      case BookingStatus.confirmed:
      case BookingStatus.paid:
        return OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.receipt_long, size: 16),
          label: const Text('Tickets'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.success,
            side: const BorderSide(color: AppColors.success),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: const TextStyle(fontSize: 13),
          ),
        );
      case BookingStatus.cancelled:
        return TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.info_outline, size: 16),
          label: const Text('Détails'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textLight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: const TextStyle(fontSize: 13),
          ),
        );
      case BookingStatus.expired:
        return OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Réserver'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.secondary,
            side: const BorderSide(color: AppColors.secondary),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: const TextStyle(fontSize: 13),
          ),
        );
      case BookingStatus.failed:
        return ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Réessayer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: const TextStyle(fontSize: 13),
          ),
        );
    }
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
        return Icons.error_outline;
    }
  }

  Color _getBorderColor() {
    if (reservation.status == BookingStatus.pending) {
      return _getStatusColor(reservation.status).withOpacity(0.3);
    }
    return AppColors.divider;
  }
}

// Helper function to get status color
Color _getStatusColor(BookingStatus status) {
  switch (status) {
    case BookingStatus.confirmed:
    case BookingStatus.paid:
      return AppColors.success;
    case BookingStatus.pending:
      return AppColors.warning;
    case BookingStatus.cancelled:
    case BookingStatus.failed:
      return AppColors.error;
    case BookingStatus.expired:
      return AppColors.textLight;
  }
}
