// lib/features/bus_booking/screens/booking/steps/trip_summary_step.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/config/theme/app_colors.dart';
import '../../home/models/bus_and_utility_models.dart';
import '../bus_amnities_row.dart';

class TripSummaryStep extends StatelessWidget {
  final Bus bus;
  final VoidCallback onNext;

  const TripSummaryStep({
    super.key,
    required this.bus,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Détails du voyage'),
          _buildTripCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Commodités disponibles'),
          const SizedBox(height: 8),
          BusAmenitiesRow(amenities: bus.amenities),
          const SizedBox(height: 24),
          _buildSectionTitle('Informations importantes'),
          _buildImportantInfo(),
          const SizedBox(height: 32),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTripCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bus.company,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    bus.busClass.label,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTripDetail(
              'Départ',
              bus.departureCity,
              DateFormat('dd MMM yyyy HH:mm').format(bus.departureTime),
              bus.agencyLocation,
            ),
            const SizedBox(height: 16),
            _buildTripDetail(
              'Arrivée',
              bus.arrivalCity,
              DateFormat('dd MMM yyyy HH:mm').format(bus.arrivalTime),
              'Gare routière',
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Numéro du bus',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bus.registrationNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Prix par siège',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormat('#,###').format(bus.price)} FCFA',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetail(
    String label,
    String city,
    String datetime,
    String location,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            label == 'Départ' ? Icons.departure_board : Icons.location_on,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                city,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                datetime,
                style: const TextStyle(color: AppColors.textLight),
              ),
              Text(
                location,
                style: const TextStyle(color: AppColors.textLight),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImportantInfo() {
    return Card(
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoItem(
              Icons.access_time,
              'Arrivez 30 minutes avant le départ',
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              Icons.credit_card,
              'Une pièce d\'identité valide est requise',
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              Icons.luggage,
              'Un bagage en soute gratuit (max 20kg)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Continuer',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
