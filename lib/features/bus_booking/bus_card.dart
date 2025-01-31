// lib/features/bus_booking/widgets/bus_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/config/theme/app_colors.dart';
import '../home/models/bus_mock_data.dart';

class BusCard extends StatelessWidget {
  final Bus bus;
  final VoidCallback onBookingPressed;

  const BusCard({
    super.key,
    required this.bus,
    required this.onBookingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildMobileLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image et badges
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    size: 48,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 24,
              left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  bus.busClass.label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Positioned(
              top: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_seat, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      bus.totalSeats.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Contenu
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bus de l\'agence ${bus.company}',
                style: const TextStyle(color: AppColors.textLight),
              ),
              const SizedBox(height: 8),
              _buildAmenities(),
              const SizedBox(height: 16),

              // Date
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${DateFormat('HH:mm dd MMM').format(bus.departureTime)} - ${DateFormat('HH:mm dd MMM').format(bus.arrivalTime)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Détails
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Lieu de départ',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: Text(
                      bus.agencyLocation,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.directions, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Trajet',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: Text(
                      '${bus.departureCity} - ${bus.arrivalCity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Footer
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${NumberFormat('#,###').format(bus.price)} FCFA',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        const Text(
                          'Par siège',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                bus.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: onBookingPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Reserver',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Dans la classe BusCard, ajoutez les deux nouvelles méthodes pour gérer les commodités
  Widget _buildAmenities() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildAmenityChip(
          availableIcon: Icons.ac_unit,
          unavailableIcon: Icons.ac_unit_outlined,
          label: 'Clim',
          isAvailable: bus.amenities.hasAirConditioning,
        ),
        _buildAmenityChip(
          availableIcon: Icons.wc,
          unavailableIcon: Icons.no_adult_content_outlined,
          label: 'WC',
          isAvailable: bus.amenities.hasToilet,
        ),
        _buildAmenityChip(
          availableIcon: Icons.restaurant,
          unavailableIcon: Icons.no_meals_outlined,
          label: 'Repas',
          isAvailable: bus.amenities.hasLunch,
        ),
        _buildAmenityChip(
          availableIcon: Icons.wifi,
          unavailableIcon: Icons.wifi_off,
          label: 'WiFi',
          isAvailable: bus.amenities.hasWifi,
        ),
        _buildAmenityChip(
          availableIcon: Icons.usb,
          unavailableIcon: Icons.usb_off,
          label: 'USB',
          isAvailable: bus.amenities.hasUSBCharging,
        ),
      ],
    );
  }

  Widget _buildAmenityChip({
    required IconData availableIcon,
    required IconData unavailableIcon,
    required String label,
    required bool isAvailable,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable
            ? AppColors.success.withOpacity(0.1)
            : AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? availableIcon : unavailableIcon,
            size: 16,
            color: isAvailable ? AppColors.success : AppColors.textLight,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isAvailable ? AppColors.success : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
