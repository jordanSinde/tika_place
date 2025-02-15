// lib/features/bus_booking/widgets/ticket_viewer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tika_place/features/home/models/bus_and_utility_models.dart';

import '../../../core/config/theme/app_colors.dart';
import '../providers/booking_provider.dart';
import '../providers/reservation_state_notifier.dart';
import '../providers/ticket_model.dart';

class TicketViewer extends ConsumerWidget {
  final ExtendedTicket ticket;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;
  final bool showValidationStatus;

  const TicketViewer({
    super.key,
    required this.ticket,
    this.onDownload,
    this.onShare,
    this.showValidationStatus = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écouter l'état central pour les mises à jour de statut
    final centralState = ref.watch(centralReservationProvider);
    final isAvailable = centralState.seatsAvailability[ticket.bookingReference];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildHeader(isAvailable),
          _buildBody(context),
          if (onDownload != null || onShare != null) _buildActions(),
          if (showValidationStatus) _buildValidationStatus(context),
        ],
      ),
    );
  }

  Widget _buildHeader(bool? isAvailable) {
    final statusColor = _getStatusColor(isAvailable);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(isAvailable),
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.bus.company,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _getStatusText(isAvailable),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _buildSeatIndicator(),
        ],
      ),
    );
  }

  Widget _buildSeatIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(null),
          width: 1,
        ),
      ),
      child: Text(
        ticket.formattedSeatNumber,
        style: TextStyle(
          color: _getStatusColor(null),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(bool? isAvailable) {
    if (isAvailable == false) return AppColors.error;

    if (ticket.isValid) {
      return AppColors.success;
    } else if (ticket.isExpired) {
      return AppColors.textLight;
    } else if (ticket.status == BookingStatus.cancelled) {
      return AppColors.error;
    }
    return AppColors.warning;
  }

  IconData _getStatusIcon(bool? isAvailable) {
    if (isAvailable == false) return Icons.event_busy;

    if (ticket.isValid) {
      return Icons.check_circle;
    } else if (ticket.isExpired) {
      return Icons.access_time;
    } else if (ticket.status == BookingStatus.cancelled) {
      return Icons.cancel;
    }
    return Icons.warning;
  }

  String _getStatusText(bool? isAvailable) {
    if (isAvailable == false) return 'Places non disponibles';

    if (ticket.isValid) {
      return 'Ticket valide';
    } else if (ticket.isExpired) {
      return 'Expiré';
    } else if (ticket.status == BookingStatus.cancelled) {
      return 'Annulé';
    }
    return 'En attente';
  }

  Widget _buildValidationStatus(BuildContext context) {
    if (!ticket.isValid) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            ticket.isUsed == true ? Icons.check_circle : Icons.timer,
            color:
                ticket.isUsed == true ? AppColors.success : AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ticket.isUsed == true
                  ? 'Validé le ${_formatDate(ticket.validationDate!)}'
                  : 'En attente de validation',
              style: TextStyle(
                color: ticket.isUsed == true
                    ? AppColors.success
                    : AppColors.warning,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy à HH:mm').format(date);
  }

  // ... (reste du code existant pour _buildBody et _buildActions)
  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTripInfo(context),
          const Divider(height: 32),
          _buildPassengerInfo(),
          const SizedBox(height: 24),
          _buildQRCode(),
          if (!ticket.isValid)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _getInvalidityReason(),
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTripInfo(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildLocationInfo(
                'Départ',
                ticket.bus.departureCity,
                DateFormat('HH:mm').format(ticket.bus.departureTime),
                DateFormat('dd MMM yyyy').format(ticket.bus.departureTime),
                Icons.departure_board,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildLocationInfo(
                'Arrivée',
                ticket.bus.arrivalCity,
                DateFormat('HH:mm').format(ticket.bus.arrivalTime),
                DateFormat('dd MMM yyyy').format(ticket.bus.arrivalTime),
                Icons.location_on,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bus N° ${ticket.bus.registrationNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ticket.bus.busClass.label,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(
    String label,
    String city,
    String time,
    String date,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                city,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          date,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow('Passager', ticket.passengerName),
          if (ticket.phoneNumber.isNotEmpty)
            _buildInfoRow('Téléphone', ticket.phoneNumber),
          if (ticket.cniNumber != null) _buildInfoRow('CNI', ticket.cniNumber!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textLight,
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

  Widget _buildQRCode() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          QrImageView(
            data: ticket.qrCode,
            version: QrVersions.auto,
            size: 150.0,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            'Ref: ${ticket.bookingReference}',
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (onShare != null)
            IconButton(
              onPressed: onShare,
              icon: const Icon(Icons.share),
              tooltip: 'Partager',
            ),
          if (onDownload != null) ...[
            if (onShare != null) const SizedBox(width: 16),
            IconButton(
              onPressed: onDownload,
              icon: const Icon(Icons.download),
              tooltip: 'Télécharger',
            ),
          ],
        ],
      ),
    );
  }

  String _getInvalidityReason() {
    if (ticket.isExpired) {
      return 'Ce ticket a expiré. La date de voyage est passée.';
    } else if (ticket.status == BookingStatus.cancelled) {
      return 'Ce ticket a été annulé.';
    } else if (ticket.isUsed!) {
      return 'Ce ticket a déjà été utilisé le ${DateFormat('dd/MM/yyyy à HH:mm').format(ticket.validationDate!)}';
    }
    return 'Ce ticket n\'est pas valide.';
  }
}

/*
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tika_place/features/home/models/bus_and_utility_models.dart';
import '../../../core/config/theme/app_colors.dart';
import '../providers/booking_provider.dart';
import '../providers/ticket_model.dart';

class TicketViewer extends ConsumerWidget {
  final ExtendedTicket ticket;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;

  const TicketViewer({
    super.key,
    required this.ticket,
    this.onDownload,
    this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildBody(context),
          if (onDownload != null || onShare != null) _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.bus.company,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              ticket.formattedSeatNumber,
              style: TextStyle(
                color: _getStatusColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTripInfo(context),
          const Divider(height: 32),
          _buildPassengerInfo(),
          const SizedBox(height: 24),
          _buildQRCode(),
          if (!ticket.isValid)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _getInvalidityReason(),
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTripInfo(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildLocationInfo(
                'Départ',
                ticket.bus.departureCity,
                DateFormat('HH:mm').format(ticket.bus.departureTime),
                DateFormat('dd MMM yyyy').format(ticket.bus.departureTime),
                Icons.departure_board,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildLocationInfo(
                'Arrivée',
                ticket.bus.arrivalCity,
                DateFormat('HH:mm').format(ticket.bus.arrivalTime),
                DateFormat('dd MMM yyyy').format(ticket.bus.arrivalTime),
                Icons.location_on,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bus N° ${ticket.bus.registrationNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ticket.bus.busClass.label,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(
    String label,
    String city,
    String time,
    String date,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                city,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          date,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow('Passager', ticket.passengerName),
          if (ticket.phoneNumber.isNotEmpty)
            _buildInfoRow('Téléphone', ticket.phoneNumber),
          if (ticket.cniNumber != null) _buildInfoRow('CNI', ticket.cniNumber!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textLight,
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

  Widget _buildQRCode() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          QrImageView(
            data: ticket.qrCode,
            version: QrVersions.auto,
            size: 150.0,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            'Ref: ${ticket.bookingReference}',
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (onShare != null)
            IconButton(
              onPressed: onShare,
              icon: const Icon(Icons.share),
              tooltip: 'Partager',
            ),
          if (onDownload != null) ...[
            if (onShare != null) const SizedBox(width: 16),
            IconButton(
              onPressed: onDownload,
              icon: const Icon(Icons.download),
              tooltip: 'Télécharger',
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (ticket.isValid) {
      return AppColors.success;
    } else if (ticket.isExpired) {
      return AppColors.textLight;
    } else if (ticket.status == BookingStatus.cancelled) {
      return AppColors.error;
    }
    return AppColors.warning;
  }

  IconData _getStatusIcon() {
    if (ticket.isValid) {
      return Icons.check_circle;
    } else if (ticket.isExpired) {
      return Icons.access_time;
    } else if (ticket.status == BookingStatus.cancelled) {
      return Icons.cancel;
    }
    return Icons.warning;
  }

  String _getStatusText() {
    if (ticket.isValid) {
      return 'Ticket valide';
    } else if (ticket.isExpired) {
      return 'Expiré';
    } else if (ticket.status == BookingStatus.cancelled) {
      return 'Annulé';
    }
    return 'En attente';
  }

  String _getInvalidityReason() {
    if (ticket.isExpired) {
      return 'Ce ticket a expiré. La date de voyage est passée.';
    } else if (ticket.status == BookingStatus.cancelled) {
      return 'Ce ticket a été annulé.';
    } else if (ticket.isUsed!) {
      return 'Ce ticket a déjà été utilisé le ${DateFormat('dd/MM/yyyy à HH:mm').format(ticket.validationDate!)}';
    }
    return 'Ce ticket n\'est pas valide.';
  }
}*/
