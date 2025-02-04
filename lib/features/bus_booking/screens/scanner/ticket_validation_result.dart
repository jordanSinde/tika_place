//lib/features/bus_booking/screens/scanner/ticket_validation_result.dart
/*
import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';
import 'package:intl/intl.dart';

class TicketValidationResult extends StatelessWidget {
  final bool isValid;
  final Map<String, dynamic> ticketData;

  const TicketValidationResult({
    super.key,
    required this.isValid,
    required this.ticketData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Scanner un autre billet'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _getStatusColor(),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Terminer'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    return isValid ? AppColors.success : AppColors.error;
  }

  String _getStatusDescription() {
    if (isValid) {
      final departure = ticketData['departure'] as Map<String, dynamic>;
      final departureTime = DateTime.parse(departure['time'] as String);
      
      final now = DateTime.now();
      if (departureTime.isBefore(now)) {
        return 'Ce billet est valide pour un voyage ayant déjà commencé';
      } else {
        return 'Ce billet est valide pour un prochain voyage';
      }
    } else {
      return 'Ce billet n\'est pas valide ou a déjà été utilisé';
    }
  }

  String _formatDateTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
}
d: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatusIcon(),
                    const SizedBox(height: 24),
                    _buildStatusText(),
                    const SizedBox(height: 32),
                    _buildTicketDetails(),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isValid ? Icons.check_circle : Icons.error,
        size: 80,
        color: _getStatusColor(),
      ),
    );
  }

  Widget _buildStatusText() {
    return Column(
      children: [
        Text(
          isValid ? 'Billet valide' : 'Billet invalide',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _getStatusDescription(),
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textLight.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTicketDetails() {
    final departure = ticketData['departure'] as Map<String, dynamic>;
    final arrival = ticketData['arrival'] as Map<String, dynamic>;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getStatusColor().withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              'Passager',
              ticketData['passenger'] as String,
              Icons.person,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Siège',
              ticketData['seat'] as String,
              Icons.airline_seat_recline_normal,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Départ',
              '${departure['city']} - ${_formatDateTime(departure['time'])}',
              Icons.departure_board,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Arrivée',
              '${arrival['city']} - ${_formatDateTime(arrival['time'])}',
              Icons.location_on,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Compagnie',
              ticketData['company'] as String,
              Icons.business,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Bus N°',
              ticketData['busNumber'] as String,
              Icons.directions_bus,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textLight.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            chil*/