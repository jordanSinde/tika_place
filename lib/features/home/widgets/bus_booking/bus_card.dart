// lib/features/bus_booking/widgets/bus_card.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../models/bus_mock_data.dart';

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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // En-tête avec classe et agence
          _buildHeader(context),

          // Corps de la carte
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations principales
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBusIcon(),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMainInfo(context)),
                  ],
                ),
                const Divider(
                  height: 24,
                  color: AppColors.textLight,
                ),
                _buildAmenities(),
                const SizedBox(height: 16),
                _buildBookingSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildStandingBadge(),
              const SizedBox(width: 12),
              _buildRegistrationNumber(),
            ],
          ),
          _buildAgencyInfo(),
        ],
      ),
    );
  }

  Widget _buildStandingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        bus.busClass.label,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRegistrationNumber() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        bus.registrationNumber,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAgencyInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          bus.company,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          bus.agencyLocation,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBusIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const FaIcon(
        FontAwesomeIcons.busSimple,
        size: 32,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildMainInfo(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildJourneyTimes(timeFormat),
        const SizedBox(height: 12),
        _buildSeatsInfo(),
        const SizedBox(height: 8),
        _buildRating(),
      ],
    );
  }

  Widget _buildJourneyTimes(DateFormat timeFormat) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeInfo(
                icon: Icons.departure_board,
                time: timeFormat.format(bus.departureTime),
                label: bus.departureCity,
                color: AppColors.primary,
              ),
              Container(
                margin: const EdgeInsets.only(left: 12),
                width: 1,
                height: 20,
                color: Colors.grey[300],
              ),
              _buildTimeInfo(
                icon: Icons.location_on,
                time: timeFormat.format(bus.arrivalTime),
                label: bus.arrivalCity,
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_calculateDuration()} h',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfo({
    required IconData icon,
    required String time,
    required String label,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatsInfo() {
    final availabilityColor =
        bus.availableSeats > 0 ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: availabilityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_seat, size: 16, color: availabilityColor),
          const SizedBox(width: 6),
          Text(
            '${bus.availableSeats}/${bus.totalSeats} places',
            style: TextStyle(
              color: availabilityColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 16),
        const SizedBox(width: 4),
        Text(
          bus.rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${bus.reviews} avis)',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenities() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildAmenityChip(
          icon: FontAwesomeIcons.wind,
          label: 'Climatisation',
          isAvailable: bus.amenities.hasAirConditioning,
        ),
        _buildAmenityChip(
          icon: FontAwesomeIcons.toilet,
          label: 'Toilettes',
          isAvailable: bus.amenities.hasToilet,
        ),
        _buildAmenityChip(
          icon: FontAwesomeIcons.utensils,
          label: 'Repas',
          isAvailable: bus.amenities.hasLunch,
        ),
        _buildAmenityChip(
          icon: FontAwesomeIcons.wineGlass,
          label: 'Boissons',
          isAvailable: bus.amenities.hasDrinks,
        ),
        _buildAmenityChip(
          icon: FontAwesomeIcons.wifi,
          label: 'WiFi',
          isAvailable: bus.amenities.hasWifi,
        ),
      ],
    );
  }

  Widget _buildAmenityChip({
    required IconData icon,
    required String label,
    required bool isAvailable,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            isAvailable ? AppColors.primary.withOpacity(0.1) : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            icon,
            size: 12,
            color: isAvailable ? AppColors.primary : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isAvailable ? AppColors.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Prix et note
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${NumberFormat('#,###').format(bus.price)} FCFA',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(bus.rating.toStringAsFixed(1)),
                  Text(' (${bus.reviews} avis)'),
                ],
              ),
            ],
          ),

          // Bouton de réservation
          SizedBox(
            // Ajout d'une contrainte de largeur
            width: 165, // Largeur fixe pour le bouton
            child: ElevatedButton(
              onPressed: bus.availableSeats > 0 ? onBookingPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centre le contenu
                children: [
                  Icon(Icons.confirmation_number_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('Réserver'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDuration() {
    final duration = bus.arrivalTime.difference(bus.departureTime);
    return (duration.inMinutes / 60).toStringAsFixed(1);
  }
}
