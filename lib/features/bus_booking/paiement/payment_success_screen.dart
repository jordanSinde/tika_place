// lib/features/bus_booking/screens/booking/steps/payment_success_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/config/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../home/models/bus_mock_data.dart';
import '../providers/booking_provider.dart';

class PaymentSuccessScreen extends ConsumerWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingProvider);
    final bus = bookingState.selectedBus!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Paiement effectué avec succès !',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Référence: ${bookingState.bookingReference}',
                style: const TextStyle(
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 32),

              // Billets
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bookingState.passengers.length,
                itemBuilder: (context, index) {
                  final passenger = bookingState.passengers[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildTicket(
                      context,
                      passenger: passenger,
                      bus: bus,
                      bookingReference: bookingState.bookingReference!,
                      index: index,
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implémenter le téléchargement des billets
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Téléchargement des billets...'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Télécharger'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(bookingProvider.notifier).reset();
                        context.go('/home');
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Accueil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicket(
    BuildContext context, {
    required Passenger passenger,
    required Bus bus,
    required String bookingReference,
    required int index,
  }) {
    final qrData = {
      'ref': bookingReference,
      'passenger': '${passenger.firstName} ${passenger.lastName}',
      'trip': '${bus.departureCity}-${bus.arrivalCity}',
      'date': DateFormat('yyyy-MM-dd').format(bus.departureTime),
      'seat': 'N°${index + 1}',
    };

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.confirmation_number,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'Billet de bus - Siège N°${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTicketRow(
                  'Passager',
                  '${passenger.firstName} ${passenger.lastName}',
                ),
                const Divider(height: 24),
                _buildTicketRow(
                  'Départ',
                  '${bus.departureCity}\n${DateFormat('dd MMM yyyy HH:mm').format(bus.departureTime)}',
                ),
                const Divider(height: 24),
                _buildTicketRow(
                  'Lieu',
                  bus.agencyLocation,
                ),
                const Divider(height: 24),
                _buildTicketRow(
                  'Arrivée',
                  '${bus.arrivalCity}\n${DateFormat('dd MMM yyyy HH:mm').format(bus.arrivalTime)}',
                ),
                const Divider(height: 24),
                _buildTicketRow(
                  'Compagnie',
                  bus.company,
                ),
                const Divider(height: 24),
                _buildTicketRow(
                  'Bus',
                  'N° ${bus.registrationNumber}',
                ),
                const SizedBox(height: 24),
                Center(
                  child: QrImageView(
                    data: qrData.toString(),
                    version: QrVersions.auto,
                    size: 150.0,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Référence: $bookingReference',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textLight,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
