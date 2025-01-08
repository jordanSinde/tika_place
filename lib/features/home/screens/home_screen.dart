import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';

// lib/features/home/screens/home_screen.dart

import '../../auth/providers/auth_provider.dart';
import '../widgets/bus_booking/bus_booking_view.dart';
import '../widgets/hotel_booking/hotel_booking_view.dart';
import '../widgets/apartment_booking/apartment_booking_view.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Explore',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            onPressed: () {
              // TODO: Implement notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Les notifications seront bientôt disponibles!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabItem(
                    icon: Icons.directions_bus_rounded,
                    label: 'Bus',
                    isSelected: selectedTab == 0,
                    onTap: () {
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildTabItem(
                    icon: Icons.hotel_rounded,
                    label: 'Hôtels',
                    isSelected: selectedTab == 1,
                    onTap: () {
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildTabItem(
                    icon: Icons.apartment_rounded,
                    label: 'Appartements',
                    isSelected: selectedTab == 2,
                    onTap: () {
                      _pageController.animateToPage(
                        2,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                ref.read(selectedTabProvider.notifier).state = index;
              },
              children: const [
                // Vue de réservation de bus
                BusBookingView(),

                // Vue de réservation d'hôtels
                HotelBookingView(),

                // Vue de réservation d'appartements
                ApartmentBookingView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(destinationsProvider.notifier).loadDestinations(),
    );
  }

  void _onDestinationTap(Destination destination) {
    ref.read(destinationsProvider.notifier).selectDestination(destination);
    context.go('/home/destination/${destination.id}');
  }

  Widget _buildDestinationsList() {
    final destinations = ref.watch(destinationsProvider).destinations;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: destinations.length,
        itemBuilder: (context, index) {
          return AnimatedDestinationCard(
            key: ValueKey(destinations[index].id),
            destination: destinations[index],
            onTap: () => _onDestinationTap(destinations[index]),
            isLarge: true,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final destinationsState = ref.watch(destinationsProvider);

    return Scaffold(
      //key: _scaffoldKey,
      backgroundColor: AppColors.background,
      //drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Discover',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: destinationsState.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(destinationsProvider.notifier)
                    .loadDestinations();
              },
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //const SizedBox(height: 16),
                      //_buildHeader(),
                      //const TravelHeadingSection(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 0, 24),
                        child: Text(
                          'Popular Travel Destinations',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Booking Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Section carte interactive
                      const Padding(
                        padding: EdgeInsets.only(top: 24, bottom: 12),
                        child: InteractiveGlobe(
                          locations: [
                            MapLocation(
                              name: 'Yaoundé',
                              position: Offset(100, 120),
                              color: AppColors.primary,
                            ),
                            MapLocation(
                              name: 'Douala',
                              position: Offset(280, 140),
                              color: AppColors.secondary,
                            ),
                            MapLocation(
                              name: 'Garoua',
                              position: Offset(150, 120),
                              color: AppColors.secondary,
                            ),
                            MapLocation(
                              name: 'Kribi',
                              position: Offset(200, 90),
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),

                      // Section destinations en vedette
                      /*if (destinationsState.featuredDestinations.isNotEmpty)
                        FeaturedDestinations(
                          destinations: destinationsState.featuredDestinations,
                          onDestinationTap: _onDestinationTap,
                        ),

                      // Section destinations populaires
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Titre',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            _buildDestinationsList(),
                          ],
                        ),
                      ),*/

                      // Nouvelles sections
                      //const LatestFlightDeals(),
                      //const SizedBox(height: 24),
                      const ContactSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 40,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.menu,
              size: 36,
            ),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
    );
  }
}
*/