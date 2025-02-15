// lib/features/bus_booking/widgets/reservation_list_widget.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme/app_colors.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../providers/reservation_provider.dart';
import '../providers/reservation_state_notifier.dart';

class ReservationListWidget extends ConsumerWidget {
  final List<TicketReservation> reservations;
  final VoidCallback? onRetryPayment;
  final bool showDividers;

  const ReservationListWidget({
    super.key,
    required this.reservations,
    this.onRetryPayment,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écouter l'état central pour les mises à jour en temps réel
    final centralState = ref.watch(centralReservationProvider);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reservations.length,
      separatorBuilder: (context, index) =>
          showDividers ? const Divider(height: 1) : const SizedBox.shrink(),
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        // Obtenir les données d'état supplémentaires
        final isAvailable = centralState.seatsAvailability[reservation.id];
        final paymentAttempts =
            centralState.paymentAttempts[reservation.id] ?? 0;

        return ReservationListItem(
          reservation: reservation,
          isAvailable: isAvailable,
          paymentAttempts: paymentAttempts,
          onRetryPayment: onRetryPayment,
        );
      },
    );
  }
}

class ReservationListItem extends ConsumerStatefulWidget {
  final TicketReservation reservation;
  final bool? isAvailable;
  final int paymentAttempts;
  final VoidCallback? onRetryPayment;

  const ReservationListItem({
    super.key,
    required this.reservation,
    this.isAvailable,
    required this.paymentAttempts,
    this.onRetryPayment,
  });

  @override
  ConsumerState<ReservationListItem> createState() =>
      _ReservationListItemState();
}

class _ReservationListItemState extends ConsumerState<ReservationListItem> {
  Timer? _expirationTimer;
  Duration _timeLeft = Duration.zero;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _startExpirationTimer();
  }

  @override
  void dispose() {
    _expirationTimer?.cancel();
    super.dispose();
  }

  void _startExpirationTimer() {
    if (widget.reservation.status == BookingStatus.pending &&
        !widget.reservation.isExpired) {
      _updateTimeLeft();
      _expirationTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _updateTimeLeft(),
      );
    }
  }

  void _updateTimeLeft() {
    setState(() {
      _timeLeft = widget.reservation.timeUntilExpiration;
      if (_timeLeft.inSeconds <= 0) {
        _expirationTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildStatusHeader(),
          _buildReservationDetails(context),
          if (_shouldShowActions()) _buildActionButtons(context),
        ],
      ),
    );
  }

  bool _shouldShowActions() {
    return widget.reservation.status == BookingStatus.pending &&
        !widget.reservation.isExpired;
  }

  Widget _buildActionButtons(BuildContext context) {
    if (widget.reservation.status == BookingStatus.pending &&
        !widget.reservation.isExpired) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showCancellationDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                child: const Text('Annuler'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.onRetryPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Payer'),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          ReservationStatusIndicator(
            status: widget.reservation.status,
            isAvailable: widget.isAvailable,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_shouldShowTimeout())
                  Text(
                    'Expire dans ${_formatDuration(_timeLeft)}',
                    style: TextStyle(
                      color: _timeLeft.inMinutes <= 5
                          ? AppColors.error
                          : AppColors.warning,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.paymentAttempts > 0)
            Tooltip(
              message: 'Tentatives: ${widget.paymentAttempts}/3',
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.paymentAttempts}/3',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ... Autres méthodes de construction d'UI ...

  Color _getStatusColor() {
    if (widget.reservation.isExpired &&
        widget.reservation.status == BookingStatus.pending) {
      return AppColors.textLight;
    }
    switch (widget.reservation.status) {
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.confirmed:
      case BookingStatus.paid:
        return AppColors.success;
      case BookingStatus.cancelled:
      case BookingStatus.failed:
        return AppColors.error;
      case BookingStatus.expired:
        return AppColors.textLight;
    }
  }

  String _getStatusText() {
    if (widget.reservation.isExpired &&
        widget.reservation.status == BookingStatus.pending) {
      return 'Expirée';
    }
    switch (widget.reservation.status) {
      case BookingStatus.pending:
        return 'En attente de paiement';
      case BookingStatus.confirmed:
        return 'Confirmée';
      case BookingStatus.paid:
        return 'Payée';
      case BookingStatus.cancelled:
        return 'Annulée';
      case BookingStatus.failed:
        return 'Échec';
      case BookingStatus.expired:
        return 'Expirée';
    }
  }

  Widget _buildReservationDetails(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.reservation.bus.departureCity} → ${widget.reservation.bus.arrivalCity}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(widget.reservation.bus.departureTime),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.reservation.totalAmount.toStringAsFixed(0)} FCFA',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.reservation.discountAmount != null &&
                      widget.reservation.discountAmount! > 0)
                    Text(
                      '- ${widget.reservation.discountAmount!.toStringAsFixed(0)} FCFA',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.reservation.passengers.length} ${widget.reservation.passengers.length > 1 ? 'passagers' : 'passager'}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          ...widget.reservation.passengers.map((passenger) => Text(
                '${passenger.firstName} ${passenger.lastName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                ),
              )),
          if (_shouldShowTimeout())
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expire dans ${_formatTimeRemaining()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
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
              _handleCancellation(); // Ajout de cet appel
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

  Future<void> _handleCancellation() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      await ref
          .read(reservationProvider.notifier)
          .cancelReservation(widget.reservation.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation annulée avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'annulation: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeRemaining() {
    if (widget.reservation.status != BookingStatus.pending ||
        widget.reservation.isExpired) {
      return '';
    }

    final remaining = widget.reservation.timeUntilExpiration;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  bool _shouldShowTimeout() {
    return widget.reservation.status == BookingStatus.pending &&
        !widget.reservation.isExpired;
  }
}

// Nouveau widget pour l'indicateur de statut
class ReservationStatusIndicator extends StatelessWidget {
  final BookingStatus status;
  final bool? isAvailable;

  const ReservationStatusIndicator({
    super.key,
    required this.status,
    this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(
          _getStatusIcon(),
          color: _getStatusColor(),
          size: 24,
        ),
        if (isAvailable == false)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.warning,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (status) {
      case BookingStatus.pending:
        return Icons.pending;
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.expired:
        return Icons.timer_off;
      case BookingStatus.failed:
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor() {
    if (isAvailable == false) return AppColors.error;

    switch (status) {
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.confirmed:
        return AppColors.success;
      case BookingStatus.cancelled:
      case BookingStatus.failed:
        return AppColors.error;
      case BookingStatus.expired:
        return AppColors.textLight;
      default:
        return AppColors.primary;
    }
  }

  //sssssssssssssssssssssssssssss
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';
import '../models/booking_model.dart';
import '../paiement/payment_step.dart';
import '../paiement/payment_success_screen.dart';
import '../providers/booking_provider.dart';
import '../providers/reservation_provider.dart';
import 'payment_history_dialog.dart';

class ReservationListWidget extends ConsumerWidget {
  final List<TicketReservation> reservations;
  final VoidCallback? onRetryPayment;
  final bool showDividers;

  const ReservationListWidget({
    super.key,
    required this.reservations,
    this.onRetryPayment,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reservations.length,
      separatorBuilder: (context, index) =>
          showDividers ? const Divider(height: 1) : const SizedBox.shrink(),
      itemBuilder: (context, index) {
        return ReservationCard(
          reservation: reservations[index],
          onRetryPayment: onRetryPayment,
        );
      },
    );
  }
}

class ReservationCard extends ConsumerStatefulWidget {
  final TicketReservation reservation;
  final VoidCallback? onRetryPayment;

  const ReservationCard({
    super.key,
    required this.reservation,
    this.onRetryPayment,
  });

  @override
  ConsumerState<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends ConsumerState<ReservationCard> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: _handleReservationTap,
        child: Column(
          children: [
            _buildStatusHeader(),
            _buildReservationDetails(context),
            if (_shouldShowPaymentHistory())
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildPaymentHistoryButton(),
                  ],
                ),
              ),
            if (_shouldShowAction()) _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  void _handleReservationTap() async {
    setState(() => _isProcessing = true);
    try {
      switch (widget.reservation.status) {
        case BookingStatus.pending:
          if (!widget.reservation.isExpired) {
            // Rediriger vers PaymentStep
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentStep(
                  onPrevious: () => Navigator.pop(context),
                ),
              ),
            );
          }
          break;
        case BookingStatus.confirmed:
          // Rediriger vers PaymentSuccessScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                bookingReference: widget.reservation.id,
              ),
            ),
          );
          break;
        case BookingStatus.cancelled:
          _showCancellationDetails(context);
          break;
        default:
          break;
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusText(),
            style: TextStyle(
              color: _getStatusColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (widget.reservation.isExpired &&
              widget.reservation.status == BookingStatus.pending)
            const Icon(
              Icons.timer_off,
              color: AppColors.error,
              size: 20,
            ),
        ],
      ),
    );
  }

  // ... Autres méthodes de construction d'UI existantes ...

  Future<void> _handleCancellation() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      await ref
          .read(reservationProvider.notifier)
          .cancelReservation(widget.reservation.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation annulée avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'annulation: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _showPaymentHistoryDialog() async {
    final paymentHistory = await ref
        .read(reservationProvider.notifier)
        .getPaymentHistory(widget.reservation.id);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => PaymentHistoryDialog(
        paymentHistory: paymentHistory,
      ),
    );
  }

  Widget _buildPaymentHistoryButton() {
    return IconButton(
      icon: const Icon(Icons.history),
      onPressed: _showPaymentHistoryDialog,
      tooltip: 'Historique des paiements',
    );
  }

  bool _shouldShowPaymentHistory() {
    return widget.reservation.status != BookingStatus.pending ||
        (widget.reservation.paymentHistory?.isNotEmpty ?? false);
  }

  bool _shouldShowAction() {
    return widget.reservation.status == BookingStatus.pending &&
        !widget.reservation.isExpired;
  }

  Color _getStatusColor() {
    if (widget.reservation.isExpired &&
        widget.reservation.status == BookingStatus.pending) {
      return AppColors.textLight;
    }
    switch (widget.reservation.status) {
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.confirmed:
      case BookingStatus.paid:
        return AppColors.success;
      case BookingStatus.cancelled:
      case BookingStatus.failed:
        return AppColors.error;
      case BookingStatus.expired:
        return AppColors.textLight;
    }
  }

  IconData _getStatusIcon() {
    if (widget.reservation.isExpired &&
        widget.reservation.status == BookingStatus.pending) {
      return Icons.timer_off;
    }
    switch (widget.reservation.status) {
      case BookingStatus.pending:
        return Icons.pending;
      case BookingStatus.confirmed:
      case BookingStatus.paid:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.failed:
        return Icons.error;
      case BookingStatus.expired:
        return Icons.timer_off;
    }
  }

  String _getStatusText() {
    if (widget.reservation.isExpired &&
        widget.reservation.status == BookingStatus.pending) {
      return 'Expirée';
    }
    switch (widget.reservation.status) {
      case BookingStatus.pending:
        return 'En attente de paiement';
      case BookingStatus.confirmed:
        return 'Confirmée';
      case BookingStatus.paid:
        return 'Payée';
      case BookingStatus.cancelled:
        return 'Annulée';
      case BookingStatus.failed:
        return 'Échec';
      case BookingStatus.expired:
        return 'Expirée';
    }
  }

  // ... Autres méthodes utilitaires existantes ...
  Widget _buildReservationDetails(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.reservation.bus.departureCity} → ${widget.reservation.bus.arrivalCity}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(widget.reservation.bus.departureTime),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.reservation.totalAmount.toStringAsFixed(0)} FCFA',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.reservation.discountAmount != null &&
                      widget.reservation.discountAmount! > 0)
                    Text(
                      '- ${widget.reservation.discountAmount!.toStringAsFixed(0)} FCFA',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.reservation.passengers.length} ${widget.reservation.passengers.length > 1 ? 'passagers' : 'passager'}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          ...widget.reservation.passengers.map((passenger) => Text(
                '${passenger.firstName} ${passenger.lastName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                ),
              )),
          if (_shouldShowTimeout())
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expire dans ${_formatTimeRemaining()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (widget.reservation.status == BookingStatus.pending &&
        !widget.reservation.isExpired) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showCancellationDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                child: const Text('Annuler'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.onRetryPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Payer'),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showCancellationDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: _getStatusColor(),
            ),
            const SizedBox(width: 8),
            const Text('Détails de l\'annulation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Raison: ${widget.reservation.cancellationReason ?? 'Non spécifiée'}'),
            const SizedBox(height: 8),
            Text('Date: ${_formatDateTime(widget.reservation.createdAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
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
              _handleCancellation(); // Ajout de cet appel
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeRemaining() {
    if (widget.reservation.status != BookingStatus.pending ||
        widget.reservation.isExpired) {
      return '';
    }

    final remaining = widget.reservation.timeUntilExpiration;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  bool _shouldShowTimeout() {
    return widget.reservation.status == BookingStatus.pending &&
        !widget.reservation.isExpired;
  }
}*/
