//lib/features/bus_booking/screens/booking/payment_success_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../common/widgets/buttons/primary_button.dart';
import '../providers/booking_provider.dart';
import '../providers/ticket_model.dart';
import '../providers/ticket_provider.dart';
import '../services/ticket_download_service.dart';
import '../services/ticket_local_persistence_service.dart';
import '../services/trip_reminder_service.dart';
import '../widgets/ticket_viewer.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  final String bookingReference;

  const PaymentSuccessScreen({
    super.key,
    required this.bookingReference,
  });

  @override
  ConsumerState<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen> {
  bool _isLoadingTickets = true;
  bool _isProcessing = false;
  List<ExtendedTicket> _tickets = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _processBooking());
  }

  Future<void> _processBooking() async {
    print("Début de _processBooking");
    setState(() => _isLoadingTickets = true);
    try {
      print(
          "Passagers dans booking: ${ref.read(bookingProvider).passengers.length}");
      print("BookingReference: ${widget.bookingReference}");

      // Récupérer l'état directement du provider
      final ticketsState = ref.read(ticketsProvider);
      print(
          "État actuel du TicketsProvider: ${ticketsState.tickets.length} tickets");

      // Récupérer les tickets depuis le stockage local
      _tickets = await ref
          .read(ticketsProvider.notifier)
          .getTicketsForBooking(widget.bookingReference);
      print("Tickets récupérés: ${_tickets.length}");

      if (_tickets.isEmpty) {
        print(
            "Aucun ticket trouvé pour la référence ${widget.bookingReference}");
        // Vérifier dans la base de données SQLite directement
        final dbTickets = await ticketLocalPersistenceService
            .getTicketsByBookingReference(widget.bookingReference);
        print("Tickets dans la base SQLite: ${dbTickets.length}");
      }

      // Programmer les rappels pour chaque ticket
      for (final ticket in _tickets) {
        await tripReminderService.scheduleReminders(ticket);
      }
    } catch (e, stackTrace) {
      print("Erreur dans _processBooking: $e");
      print("StackTrace: $stackTrace");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingTickets = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoadingTickets
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSuccessHeader(),
                    const SizedBox(height: 32),
                    ..._tickets.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Billet ${entry.key + 1}/${_tickets.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ),
                            TicketViewer(
                              ticket: entry.value,
                              onDownload: () => _handleDownload(entry.value),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 64,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Réservation confirmée !',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Votre réservation a été effectuée avec succès.\nVoici vos billets :',
          style: TextStyle(
            color: AppColors.textLight.withOpacity(0.7),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          text: _tickets.length > 1
              ? 'Télécharger tous les billets'
              : 'Télécharger le billet',
          icon: Icons.download,
          isLoading: _isProcessing,
          onPressed: _handleDownloadAll,
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: _isProcessing
              ? null
              : () {
                  context.go('/home');
                },
          icon: const Icon(Icons.home),
          label: const Text('Retour à l\'accueil'),
        ),
      ],
    );
  }

  Future<void> _handleDownload(ExtendedTicket ticket) async {
    setState(() => _isProcessing = true);
    try {
      // Vérifier si le ticket est déjà téléchargé
      final existingPath =
          await ticketDownloadService.getExistingTicketPath(ticket.id);
      String filePath;

      if (existingPath != null) {
        filePath = existingPath;
      } else {
        filePath = await ticketDownloadService.generateTicketPDF(ticket);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Billet téléchargé dans : $filePath'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du téléchargement'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleDownloadAll() async {
    setState(() => _isProcessing = true);
    try {
      final paths =
          await ticketDownloadService.generateMultipleTicketsPDF(_tickets);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              paths.length > 1
                  ? '${paths.length} billets téléchargés avec succès'
                  : 'Billet téléchargé avec succès',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du téléchargement des billets'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    // Nettoyer les anciens tickets PDF si nécessaire
    ticketDownloadService.cleanOldTickets();
    super.dispose();
  }
}
