// lib/features/profile/widgets/booking_tabs.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tika_place/features/bus_booking/models/booking_model.dart';

import '../../../core/config/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../bus_booking/paiement/payment_step.dart';
import '../../bus_booking/providers/booking_provider.dart';
import '../../bus_booking/providers/reservation_provider.dart';
import '../../bus_booking/widgets/reservation_list_widget.dart';

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
      return Consumer(
        builder: (context, ref, child) {
          final reservationState = ref.watch(reservationProvider);

          if (reservationState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reservationState.error != null) {
            return Center(
              child: Text('Erreur: ${reservationState.error}'),
            );
          }

          return ReservationListWidget(
            reservations: reservationState.reservations,
            onRetryPayment: () async {
              final reservation = reservationState.currentReservation;
              if (reservation == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur: Réservation non trouvée'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              // Vérifier si la réservation est toujours valide
              if (reservation.isExpired) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Cette réservation a expiré. Veuillez effectuer une nouvelle réservation.'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              // Initialiser les données pour le paiement
              ref.read(bookingProvider.notifier).initializeBooking(
                    reservation.bus,
                    ref.read(authProvider).user!,
                  );

              // Naviguer vers l'écran de paiement
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentStep(
                      onPrevious: () => Navigator.pop(context),
                    ),
                  ),
                );
              }
            },
          );
        },
      );
    }
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

class TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
