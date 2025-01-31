// lib/features/bus_booking/screens/tickets/ticket_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tika_place/features/home/models/bus_mock_data.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../common/widgets/buttons/primary_button.dart';
import 'providers/booking_provider.dart';
import 'providers/ticket_model.dart';
import 'providers/ticket_provider.dart';
import 'services/ticket_download_service.dart';
import 'services/ticket_share_service.dart';
import 'services/trip_reminder_service.dart';

class TicketDetailsScreen extends ConsumerStatefulWidget {
  final ExtendedTicket ticket;

  const TicketDetailsScreen({
    super.key,
    required this.ticket,
  });

  @override
  ConsumerState<TicketDetailsScreen> createState() =>
      _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends ConsumerState<TicketDetailsScreen> {
  bool _isLoading = false;
  bool _hasReminders = false;

  @override
  void initState() {
    super.initState();
    _checkRemindersStatus();
  }

  Future<void> _checkRemindersStatus() async {
    final hasPermission =
        await tripReminderService.checkNotificationPermissions();
    setState(() {
      _hasReminders = hasPermission;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Billet ${widget.ticket.formattedSeatNumber}',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          if (widget.ticket.isValid)
            IconButton(
              icon: Icon(
                _hasReminders
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: _hasReminders ? AppColors.success : AppColors.textLight,
              ),
              onPressed: _toggleReminders,
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _handleShare,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _handleDownload,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(),
                const SizedBox(height: 24),
                _buildTripDetails(),
                const SizedBox(height: 24),
                _buildPassengerDetails(),
                const SizedBox(height: 24),
                _buildQRCode(),
                const SizedBox(height: 24),
                _buildActions(),
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor(),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(),
                color: _getStatusColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (widget.ticket.isValid)
                    Text(
                      'Départ dans ${_getRemainingTime()}',
                      style: const TextStyle(
                        color: AppColors.textLight,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Détails du voyage',
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  'Compagnie',
                  widget.ticket.bus.company,
                  Icons.business,
                ),
                const Divider(),
                _buildInfoRow(
                  'Départ',
                  '${widget.ticket.bus.departureCity}\n${DateFormat('dd MMM yyyy HH:mm').format(widget.ticket.bus.departureTime)}',
                  Icons.departure_board,
                ),
                const Divider(),
                _buildInfoRow(
                  'Arrivée',
                  '${widget.ticket.bus.arrivalCity}\n${DateFormat('dd MMM yyyy HH:mm').format(widget.ticket.bus.arrivalTime)}',
                  Icons.location_on,
                ),
                const Divider(),
                _buildInfoRow(
                  'Bus',
                  'N° ${widget.ticket.bus.registrationNumber}',
                  Icons.directions_bus,
                ),
                _buildInfoRow(
                  'Classe',
                  widget.ticket.bus.busClass.label,
                  Icons.airline_seat_recline_normal,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations passager',
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  'Nom',
                  widget.ticket.passengerName,
                  Icons.person,
                ),
                if (widget.ticket.phoneNumber.isNotEmpty) ...[
                  const Divider(),
                  _buildInfoRow(
                    'Téléphone',
                    widget.ticket.phoneNumber,
                    Icons.phone,
                  ),
                ],
                if (widget.ticket.cniNumber != null) ...[
                  const Divider(),
                  _buildInfoRow(
                    'CNI',
                    widget.ticket.cniNumber!,
                    Icons.credit_card,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQRCode() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.memory(
              // Dans un cas réel, vous utiliseriez un vrai QR code
              _generateQRPlaceholder(),
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 8),
            Text(
              'Référence: ${widget.ticket.bookingReference}',
              style: const TextStyle(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    if (!widget.ticket.isValid) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          text: 'Annuler ce billet',
          onPressed: _handleCancellation,
          icon: Icons.cancel,
        ),
        if (widget.ticket.canBeRefunded) ...[
          const SizedBox(height: 8),
          Text(
            'Vous pouvez annuler ce billet jusqu\'à 24h avant le départ',
            style: TextStyle(
              color: AppColors.textLight.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (widget.ticket.isValid) {
      return AppColors.success;
    } else if (widget.ticket.status == BookingStatus.cancelled) {
      return AppColors.error;
    } else if (widget.ticket.isExpired) {
      return AppColors.textLight;
    }
    return AppColors.warning;
  }

  IconData _getStatusIcon() {
    if (widget.ticket.isValid) {
      return Icons.check_circle;
    } else if (widget.ticket.status == BookingStatus.cancelled) {
      return Icons.cancel;
    } else if (widget.ticket.isExpired) {
      return Icons.access_time;
    }
    return Icons.warning;
  }

  String _getStatusText() {
    if (widget.ticket.isValid) {
      return 'Ticket valide';
    } else if (widget.ticket.status == BookingStatus.cancelled) {
      return 'Ticket annulé';
    } else if (widget.ticket.isExpired) {
      return 'Ticket expiré';
    }
    return 'En attente';
  }

  String _getRemainingTime() {
    final now = DateTime.now();
    final departure = widget.ticket.bus.departureTime;
    final difference = departure.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    }
  }

  Future<void> _toggleReminders() async {
    setState(() => _isLoading = true);

    try {
      if (_hasReminders) {
        await tripReminderService.cancelReminders(widget.ticket.id);
      } else {
        final hasPermission =
            await tripReminderService.checkNotificationPermissions();
        if (hasPermission) {
          await tripReminderService.scheduleReminders(widget.ticket);
        }
      }

      setState(() {
        _hasReminders = !_hasReminders;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _hasReminders ? 'Rappels activés' : 'Rappels désactivés',
            ),
            backgroundColor:
                _hasReminders ? AppColors.success : AppColors.textLight,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la gestion des rappels'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleShare() async {
    setState(() => _isLoading = true);

    try {
      await ticketShareService.shareTicket(widget.ticket);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du partage du billet'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _handleDownload() async {
    setState(() => _isLoading = true);

    try {
      final filePath =
          await ticketDownloadService.generateTicketPDF(widget.ticket);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Billet téléchargé: $filePath'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du téléchargement du billet'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _handleCancellation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le billet ?'),
        content: Text(
          widget.ticket.canBeRefunded
              ? 'Voulez-vous vraiment annuler ce billet ? Le montant sera remboursé sur votre moyen de paiement.'
              : 'Voulez-vous vraiment annuler ce billet ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
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

    if (confirmed ?? false) {
      setState(() => _isLoading = true);

      try {
        await ref.read(ticketsProvider.notifier).cancelTicket(widget.ticket.id);

        // Annuler les rappels
        await tripReminderService.cancelReminders(widget.ticket.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Billet annulé avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(); // Retourner à l'écran précédent
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de l\'annulation du billet'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Uint8List _generateQRPlaceholder() {
    // Simuler un QR code pour l'exemple
    const size = 200;
    final bytes = Uint8List(size * size * 4);
    for (var i = 0; i < bytes.length; i += 4) {
      bytes[i] = 0; // R
      bytes[i + 1] = 0; // G
      bytes[i + 2] = 0; // B
      bytes[i + 3] = 255; // A
    }
    return bytes;
  }
}
