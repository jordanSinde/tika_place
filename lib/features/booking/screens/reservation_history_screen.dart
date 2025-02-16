// lib/features/common/screens/reservation_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tika_place/features/home/models/bus_mock_data.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../bus_booking/paiement/payment_success_screen.dart';
import '../../bus_booking/paiement/screens/payment_screen.dart';
import '../models/base_reservation.dart';
import '../providers/reservation_provider.dart';

class ReservationHistoryScreen extends ConsumerStatefulWidget {
  const ReservationHistoryScreen({super.key});

  @override
  ConsumerState<ReservationHistoryScreen> createState() =>
      _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState
    extends ConsumerState<ReservationHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des réservations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bus'),
            Tab(text: 'Hôtels'),
            Tab(text: 'Appartements'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ReservationListView(type: ReservationType.bus),
          _ReservationListView(type: ReservationType.hotel),
          _ReservationListView(type: ReservationType.apartment),
        ],
      ),
    );
  }
}

class _ReservationListView extends ConsumerWidget {
  final ReservationType type;

  const _ReservationListView({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationState = ref.watch(reservationProvider);
    final reservations = reservationState.getReservationsByType(type);

    if (reservationState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reservations.isEmpty) {
      return _buildEmptyState(context, type);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return _ReservationCard(
          reservation: reservation,
          onTap: () => _handleReservationTap(context, reservation),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, ReservationType type) {
    final searchText = switch (type) {
      ReservationType.bus => 'Rechercher un bus',
      ReservationType.hotel => 'Rechercher un hôtel',
      ReservationType.apartment => 'Rechercher un appartement',
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            switch (type) {
              ReservationType.bus => Icons.directions_bus_outlined,
              ReservationType.hotel => Icons.hotel_outlined,
              ReservationType.apartment => Icons.apartment_outlined,
            },
            size: 64,
            color: AppColors.textLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune réservation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez à explorer nos offres',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigation vers la recherche appropriée
              Navigator.pushNamed(
                  context, '/${type.toString().split('.').last}-search');
            },
            icon: const Icon(Icons.search),
            label: Text(searchText),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReservationTap(
      BuildContext context, BaseReservation reservation) async {
    switch (reservation.status) {
      case ReservationStatus.pending:
        // Rediriger vers l'écran de paiement
        if (reservation is BusReservation) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentScreen(
                amount: reservation.base.amount,
                bookingReference: reservation.base.id,
              ),
            ),
          );
        }
        break;

      case ReservationStatus.confirmed:
      case ReservationStatus.paid:
        // Rediriger vers l'écran de succès pour revoir/télécharger les billets
        if (reservation is BusReservation) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                bookingReference: reservation.base.id,
              ),
            ),
          );
        }
        break;

      case ReservationStatus.cancelled:
        // Afficher un message expliquant la raison de l'annulation
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Réservation annulée'),
            content: Text(reservation.base.cancellationReason ??
                'Cette réservation a été annulée.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        break;

      default:
        // Pour les autres statuts, juste afficher les détails
        break;
    }
  }
}

class _ReservationCard extends StatelessWidget {
  final BaseReservation reservation;
  final VoidCallback onTap;

  const _ReservationCard({
    required this.reservation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: reservation.status.color.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(),
            color: reservation.status.color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            reservation.status.label,
            style: TextStyle(
              color: reservation.status.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            'Réf: ${reservation.id.substring(0, 8)}',
            style: TextStyle(
              color: AppColors.textLight.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (reservation.type) {
      case ReservationType.bus:
        return _buildBusContent(reservation as BusReservation);
      case ReservationType.hotel:
        return _buildHotelContent(reservation as HotelReservation);
      case ReservationType.apartment:
        return _buildApartmentContent(reservation as ApartmentReservation);
    }
  }

  Widget _buildBusContent(BusReservation busReservation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${busReservation.bus.departureCity} → ${busReservation.bus.arrivalCity}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${busReservation.bus.company} • ${busReservation.bus.busClass.label}",
                    style: TextStyle(
                      color: AppColors.textLight.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${busReservation.base.amount.toStringAsFixed(0)} FCFA",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                if (busReservation.discountAmount != null)
                  Text(
                    "- ${busReservation.discountAmount!.toStringAsFixed(0)} FCFA",
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd MMM yyyy • HH:mm')
                  .format(busReservation.bus.departureTime),
              style: const TextStyle(
                color: AppColors.textLight,
              ),
            ),
            Text(
              "${busReservation.passengers.length} passager(s)",
              style: const TextStyle(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        if (reservation.status == ReservationStatus.pending &&
            reservation.createdAt
                .add(const Duration(minutes: 30))
                .isAfter(DateTime.now()))
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildExpirationTimer(reservation.createdAt),
          ),
      ],
    );
  }

  Widget _buildHotelContent(HotelReservation hotelReservation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hôtel ${hotelReservation.hotelId}", // À remplacer par le vrai nom
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Du ${DateFormat('dd MMM').format(hotelReservation.checkIn)}",
                  style: const TextStyle(color: AppColors.textLight),
                ),
                Text(
                  "Au ${DateFormat('dd MMM yyyy').format(hotelReservation.checkOut)}",
                  style: const TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
            Text(
              "${hotelReservation.base.amount.toStringAsFixed(0)} FCFA",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApartmentContent(ApartmentReservation apartmentReservation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Appartement ${apartmentReservation.apartmentId}", // À remplacer par le vrai nom
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Du ${DateFormat('dd MMM').format(apartmentReservation.startDate)}",
                  style: const TextStyle(color: AppColors.textLight),
                ),
                Text(
                  "Au ${DateFormat('dd MMM yyyy').format(apartmentReservation.endDate)}",
                  style: const TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
            Text(
              "${apartmentReservation.base.amount.toStringAsFixed(0)} FCFA",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpirationTimer(DateTime createdAt) {
    return StreamBuilder<Duration>(
      stream: Stream.periodic(const Duration(seconds: 1), (x) {
        final expiration = createdAt.add(const Duration(minutes: 30));
        return expiration.difference(DateTime.now());
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isNegative) {
          return const SizedBox.shrink();
        }

        final duration = snapshot.data!;
        final minutes = duration.inMinutes;
        final seconds = duration.inSeconds % 60;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer,
                size: 16,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              Text(
                'Expire dans $minutes:${seconds.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getStatusIcon() {
    switch (reservation.status) {
      case ReservationStatus.confirmed:
        return Icons.check_circle;
      case ReservationStatus.paid:
        return Icons.monetization_on;
      case ReservationStatus.pending:
        return Icons.pending;
      case ReservationStatus.cancelled:
        return Icons.cancel;
      case ReservationStatus.expired:
        return Icons.timer_off;
      case ReservationStatus.failed:
        return Icons.error;
    }
  }
}
