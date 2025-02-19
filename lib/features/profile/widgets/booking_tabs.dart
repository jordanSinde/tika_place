// lib/features/profile/widgets/booking_tabs.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../bus_booking/widgets/reservation_list_widget.dart';
import 'package:go_router/go_router.dart';
import '../../bus_booking/providers/booking_provider.dart';

class BookingTabs extends ConsumerStatefulWidget {
  const BookingTabs({super.key});

  @override
  ConsumerState<BookingTabs> createState() => _BookingTabsState();
}

class _BookingTabsState extends ConsumerState<BookingTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, Map<BookingStatus, int>> _statusCounts = {
    'Bus': {},
    'Hôtels': {},
    'Appartements': {},
  };

  final List<TabItem> _tabs = const [
    TabItem(
      label: 'Bus',
      icon: Icons.directions_bus_outlined,
      activeIcon: Icons.directions_bus,
      route: '/reservations/bus',
    ),
    TabItem(
      label: 'Hôtels',
      icon: Icons.hotel_outlined,
      activeIcon: Icons.hotel,
      route: '/reservations/hotels',
    ),
    TabItem(
      label: 'Appartements',
      icon: Icons.apartment_outlined,
      activeIcon: Icons.apartment,
      route: '/reservations/apartments',
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

  // Handle status count updates
  void _handleStatusCountUpdate(
      String tabLabel, Map<BookingStatus, int> counts) {
    if (mounted) {
      setState(() {
        _statusCounts[tabLabel] = counts;
      });
    }
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
              _buildSeeAllButton(),
            ],
          ),
          const SizedBox(height: 20),
          // Tab container
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
                  final count = _getTotalCount(tab.label);

                  return Tab(
                    height: 46,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 90,
                      ),
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
                          if (count > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textLight.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                count.toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
            height: 430,
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) => _buildTabContent(tab)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeeAllButton() {
    final currentTab = _tabs[_tabController.index];
    return TextButton.icon(
      onPressed: () => _navigateToAllReservations(currentTab),
      icon: const Icon(Icons.list, size: 16),
      label: const Text('Voir tout'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _navigateToAllReservations(TabItem tab) {
    context.push(tab.route);
  }

  Widget _buildTabContent(TabItem tab) {
    if (tab.label == 'Bus') {
      return ReservationListWidget(
        limit: 3,
        onStatusCountChanged: (counts) {
          _handleStatusCountUpdate(tab.label, counts);
        },
      );
    }
    // For other tabs, show empty state
    return _buildEmptyState(tab);
  }

  int _getTotalCount(String tabLabel) {
    final counts = _statusCounts[tabLabel];
    if (counts == null || counts.isEmpty) return 0;

    return counts.values.fold(0, (sum, count) => sum + count);
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
              onPressed: () => _navigateToSearch(tab),
              icon: const Icon(Icons.search),
              label: Text(
                'Rechercher des ${tab.label.toLowerCase()} ',
                maxLines: 1,
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

  void _navigateToSearch(TabItem tab) {
    switch (tab.label) {
      case 'Bus':
        context.push('/bus-search');
        break;
      case 'Hôtels':
        context.push('/hotel-search');
        break;
      case 'Appartements':
        context.push('/apartment-search');
        break;
    }
  }
}

class TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
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
  final Map<String, Map<BookingStatus, int>> _statusCounts = {
    'Bus': {},
    'Hôtels': {},
    'Appartements': {},
  };

  final List<TabItem> _tabs = const [
    TabItem(
      label: 'Bus',
      icon: Icons.directions_bus_outlined,
      activeIcon: Icons.directions_bus,
      route: '/reservations/bus',
    ),
    TabItem(
      label: 'Hôtels',
      icon: Icons.hotel_outlined,
      activeIcon: Icons.hotel,
      route: '/reservations/hotels',
    ),
    TabItem(
      label: 'Appartements',
      icon: Icons.apartment_outlined,
      activeIcon: Icons.apartment,
      route: '/reservations/apartments',
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
              _buildSeeAllButton(),
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
                  final count = _getTotalCount(tab.label);

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
                          if (count > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textLight.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                count.toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
            height: 430, // Fixed height to control layout
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) => _buildTabContent(tab)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeeAllButton() {
    final currentTab = _tabs[_tabController.index];
    return TextButton.icon(
      onPressed: () => _navigateToAllReservations(currentTab),
      icon: const Icon(Icons.list, size: 16),
      label: const Text('Voir tout'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _navigateToAllReservations(TabItem tab) {
    context.push(tab.route);
  }

  Widget _buildTabContent(TabItem tab) {
    if (tab.label == 'Bus') {
      return ReservationListWidget(
        limit: 3, // Limit to 3 items
        onStatusCountChanged: (status, {required int count}) {
          setState(() {
            _statusCounts[tab.label]![status] = count;
          });
        },
      );
    }
    // For other tabs, show empty state for now
    return _buildEmptyState(tab);
  }

  int _getTotalCount(String tabLabel) {
    final counts = _statusCounts[tabLabel];
    if (counts == null || counts.isEmpty) return 0;

    return counts.values.fold(0, (sum, count) => sum + count);
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
              onPressed: () => _navigateToSearch(tab),
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

  void _navigateToSearch(TabItem tab) {
    switch (tab.label) {
      case 'Bus':
        context.push('/bus-search');
        break;
      case 'Hôtels':
        context.push('/hotel-search');
        break;
      case 'Appartements':
        context.push('/apartment-search');
        break;
    }
  }
}

class TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}
*/