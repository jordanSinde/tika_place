// lib/features/bus_booking/widgets/active_tickets_widget.dart
/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tika_place/features/bus_booking/providers/ticket_model.dart';
import 'package:tika_place/features/home/models/bus_mock_data.dart';
import '../../../core/config/theme/app_colors.dart';
import 'package:intl/intl.dart';

import 'providers/ticket_provider.dart';

class ActiveTicketsWidget extends ConsumerWidget {
  const ActiveTicketsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingTickets =
        ref.watch(ticketsProvider.notifier).getUpcomingTickets();

    if (upcomingTickets.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Voyages à venir',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigator.pushNamed(context, '/tickets');
                  // TODO: Implémenter la navigation vers la liste complète
                },
                child: const Text('Voir tout'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: upcomingTickets.length,
            itemBuilder: (context, index) {
              final ticket = upcomingTickets[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketDetailsScreen(ticket: ticket),
                    ),
                  );
                },
                child: Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.directions_bus,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ticket.bus.company,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd MMM yyyy')
                                          .format(ticket.bus.departureTime),
                                      style: TextStyle(
                                        color: AppColors.textPrimary
                                            .withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  ticket.formattedSeatNumber,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildLocationInfo(
                                        'Départ',
                                        ticket.bus.departureCity,
                                        DateFormat('HH:mm')
                                            .format(ticket.bus.departureTime),
                                        Icons.departure_board,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildLocationInfo(
                                        'Arrivée',
                                        ticket.bus.arrivalCity,
                                        DateFormat('HH:mm')
                                            .format(ticket.bus.arrivalTime),
                                        Icons.location_on,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Bus N° ${ticket.bus.registrationNumber}',
                                      style: TextStyle(
                                        color: AppColors.textLight
                                            .withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        ticket.bus.busClass.label,
                                        style: const TextStyle(
                                          color: AppColors.secondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(
    String label,
    String city,
    String time,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textLight.withOpacity(0.7),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.directions_bus_outlined,
              size: 48,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun voyage à venir',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Planifiez votre prochain voyage dès maintenant',
              style: TextStyle(
                color: AppColors.textLight.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Navigator.pushNamed(context, '/bus-search');
                // TODO: Implémenter la navigation vers la recherche
              },
              icon: const Icon(Icons.search),
              label: const Text('Rechercher un voyage'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/