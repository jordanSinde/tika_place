//lib/features/bus_booking/screens/booking/payment_success_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../common/widgets/buttons/primary_button.dart';
import '../../common/widgets/inputs/custom_textfield.dart';
import '../providers/booking_provider.dart';
import '../providers/ticket_model.dart';
import '../providers/ticket_provider.dart';
import '../services/ticket_download_service.dart';
import '../services/ticket_share_service.dart';
import '../services/trip_reminder_service.dart';
import '../widgets/ticket_viewer.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  final String bookingReference;
  final bool showPaymentForm;

  const PaymentSuccessScreen({
    super.key,
    required this.bookingReference,
    this.showPaymentForm = false,
  });

  @override
  ConsumerState<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen> {
  bool _isLoadingTickets = true;
  bool _isProcessing = false;
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (!widget.showPaymentForm) {
      // Utiliser Future.microtask pour différer l'exécution
      Future.microtask(() => _processBooking());
    }
  }

  Future<void> _processBooking() async {
    setState(() => _isLoadingTickets = true);
    try {
      await ref
          .read(ticketsProvider.notifier)
          .generateTicketsAfterPayment(widget.bookingReference);

      final tickets = ref
          .read(ticketsProvider.notifier)
          .getTicketsForBooking(widget.bookingReference);

      for (final ticket in tickets) {
        await tripReminderService.scheduleReminders(ticket);
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
    } finally {
      if (mounted) {
        setState(() => _isLoadingTickets = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showPaymentForm) {
      return _buildPaymentForm();
    }

    final tickets = ref
        .watch(ticketsProvider.notifier)
        .getTicketsForBooking(widget.bookingReference);

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

                    // Liste des tickets avec numérotation
                    ...tickets.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Billet ${entry.key + 1}/${tickets.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ),
                            TicketViewer(
                              ticket: entry.value,
                              onDownload: () => _handleDownload(entry.value),
                              onShare: () => _handleShare(entry.value),
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

  Widget _buildPaymentForm() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation du paiement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Veuillez entrer vos informations de paiement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _phoneController,
                label: 'Numéro de téléphone',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un numéro de téléphone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _codeController,
                label: 'Code de paiement',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.lock,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le code de paiement';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isProcessing ? null : _handlePaymentConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirmer le paiement'),
              ),
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

  Future<void> _processPayment() async {
    try {
      final success = await ref.read(bookingProvider.notifier).processPayment();
      if (!mounted) return;

      if (success) {
        final bookingState = ref.read(bookingProvider);
        final bookingReference = bookingState.bookingReference;

        if (bookingReference == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur: Référence de réservation non trouvée'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du paiement: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handlePaymentConfirmation() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isProcessing = true);

      try {
        // Simuler le traitement du paiement
        //await Future.delayed(const Duration(seconds: 2));
        await ref.read(bookingProvider.notifier).processPayment();
        //if (!mounted) return;

        if (mounted) {
          // Assurons-nous que les tickets sont générés après le paiement
          await ref
              .read(ticketsProvider.notifier)
              .generateTicketsAfterPayment(widget.bookingReference);

          // Redirection vers l'écran de succès
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                bookingReference: widget.bookingReference,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors du paiement. Veuillez réessayer.'),
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
  }

  Widget _buildActionButtons() {
    final tickets = ref
        .read(ticketsProvider.notifier)
        .getTicketsForBooking(widget.bookingReference);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          text: tickets.length > 1
              ? 'Télécharger tous les billets'
              : 'Télécharger le billet',
          icon: Icons.download,
          isLoading: _isProcessing,
          onPressed: _handleDownloadAll,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _isProcessing ? null : _handleShareAll,
          icon: const Icon(Icons.share),
          label: Text(
            tickets.length > 1
                ? 'Partager tous les billets'
                : 'Partager le billet',
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: _isProcessing
              ? null
              : () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
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
      final filePath = await ticketDownloadService.generateTicketPDF(ticket);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Billet téléchargé dans : $filePath'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du téléchargement'),
            backgroundColor: AppColors.error,
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
      final tickets = ref
          .read(ticketsProvider.notifier)
          .getTicketsForBooking(widget.bookingReference);

      for (final ticket in tickets) {
        await ticketDownloadService.generateTicketPDF(ticket);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tickets.length > 1 ? 'Billets téléchargés' : 'Billet téléchargé',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du téléchargement'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleShare(ExtendedTicket ticket) async {
    setState(() => _isProcessing = true);
    try {
      await ticketShareService.shareTicket(ticket);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du partage'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleShareAll() async {
    setState(() => _isProcessing = true);
    try {
      final tickets = ref
          .read(ticketsProvider.notifier)
          .getTicketsForBooking(widget.bookingReference);
      await ticketShareService.shareMultipleTickets(tickets);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du partage'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}
