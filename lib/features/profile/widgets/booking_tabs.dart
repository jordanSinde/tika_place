// lib/features/profile/widgets/booking_tabs.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tika_place/features/home/models/bus_mock_data.dart';

import '../../../core/config/theme/app_colors.dart';
import '../../booking/models/base_reservation.dart';
import '../../booking/providers/reservation_provider.dart';
import '../../booking/screens/reservation_history_screen.dart';
import '../../bus_booking/paiement/payment_success_screen.dart';
import '../../bus_booking/paiement/screens/payment_screen.dart';

class BookingTabs extends ConsumerStatefulWidget {
  const BookingTabs({super.key});

  @override
  ConsumerState<BookingTabs> createState() => _BookingTabsState();
}

class _BookingTabsState extends ConsumerState<BookingTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<TabItem> _tabs = const [
    TabItem(
      label: 'Bus',
      icon: Icons.directions_bus_outlined,
      activeIcon: Icons.directions_bus,
      type: ReservationType.bus,
    ),
    TabItem(
      label: 'Hôtels',
      icon: Icons.hotel_outlined,
      activeIcon: Icons.hotel,
      type: ReservationType.hotel,
    ),
    TabItem(
      label: 'Appartements',
      icon: Icons.apartment_outlined,
      activeIcon: Icons.apartment,
      type: ReservationType.apartment,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReservationHistoryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Vos réservations',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _navigateToHistory(context),
                icon: const Icon(Icons.history),
                label: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textLight,
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                tabs: _tabs.map((tab) {
                  final isSelected = _tabController.index == _tabs.indexOf(tab);
                  return Tab(
                    height: 46,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 90),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? tab.activeIcon : tab.icon,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tab.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tab) {
                    return _ReservationPreview(
                      type: tab.type,
                      onSeeAll: () => _navigateToHistory(context),
                    );
                  }).toList(),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white,
                        ],
                      ),
                    ),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () => _navigateToHistory(context),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Voir plus de réservations'),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final ReservationType type;

  const TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.type,
  });
}

class _ReservationPreview extends ConsumerWidget {
  final ReservationType type;
  final VoidCallback onSeeAll;

  const _ReservationPreview({
    required this.type,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservations = ref
        .watch(reservationProvider)
        .getReservationsByType(type)
        .where((r) => r.status.isActive)
        .take(3)
        .toList();

    if (reservations.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      itemCount: reservations.length,
      padding: const EdgeInsets.only(bottom: 80), // Pour le gradient
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return _ReservationCard(
          reservation: reservation,
          onTap: () => _handleReservationTap(context, reservation),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final searchText = switch (type) {
      ReservationType.bus => 'Rechercher un bus',
      ReservationType.hotel => 'Rechercher un hôtel',
      ReservationType.apartment => 'Rechercher un appartement',
    };

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            switch (type) {
              ReservationType.bus => Icons.directions_bus_outlined,
              ReservationType.hotel => Icons.hotel_outlined,
              ReservationType.apartment => Icons.apartment_outlined,
            },
            size: 48,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune réservation active',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez à explorer nos offres',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/${type.toString().split('.').last}-search',
              );
            },
            icon: const Icon(Icons.search),
            label: Text(searchText),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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

      default:
        // Pour les autres statuts, rediriger vers l'historique détaillé
        onSeeAll();
        break;
    }
  }
}

// Le widget _ReservationCard reste le même que dans ReservationHistoryScreen
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
/*
class BookingTabs extends ConsumerStatefulWidget {
  const BookingTabs({super.key});

  @override
  ConsumerState<BookingTabs> createState() => _BookingTabsState();
}

class _BookingTabsState extends ConsumerState<BookingTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<TabItem> _tabs = const [
    TabItem(
      label: 'Bus',
      icon: Icons.directions_bus_outlined,
      activeIcon: Icons.directions_bus,
    ),
    TabItem(
      label: 'Hôtels',
      icon: Icons.hotel_outlined,
      activeIcon: Icons.hotel,
    ),
    TabItem(
      label: 'Appartements',
      icon: Icons.apartment_outlined,
      activeIcon: Icons.apartment,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Vos réservations',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Voir toutes les réservations
                },
                child: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Conteneur des onglets avec contraintes
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                isScrollable: true, // Permet le défilement si nécessaire
                tabAlignment: TabAlignment.start,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textLight,
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                tabs: _tabs.map((tab) {
                  final isSelected = _tabController.index == _tabs.indexOf(tab);
                  return Tab(
                    height: 46,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 90, // Largeur minimale pour chaque onglet
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Important!
                        children: [
                          Icon(
                            isSelected ? tab.activeIcon : tab.icon,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tab.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) => _buildTabContent(tab)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(TabItem tab) {
    if (tab.label == 'Bus') {
      return const ReservationListWidget();
    }
    // Pour les autres onglets, garder l'état vide pour le moment
    return _buildEmptyState(tab);
  }

  Widget _buildEmptyState(TabItem tab) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tab.icon,
              size: 48,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune réservation ${tab.label.toLowerCase()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Commencez à explorer nos ${tab.label.toLowerCase()} '
              'pour planifier votre prochain voyage',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigation vers la page de recherche correspondante
              },
              icon: const Icon(Icons.search),
              label: Text(
                'Rechercher des ${tab.label.toLowerCase()} ',
                maxLines: 1, // Force le texte sur une seule ligne
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
