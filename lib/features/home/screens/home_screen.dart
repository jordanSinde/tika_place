import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/destinations_provider.dart';
import '../../common/widgets/drawers/custom_drawer.dart';
import '../models/destination.dart';
import '../widgets/animated_destination_card.dart';
import '../widgets/contact_section.dart';
import '../widgets/interactive_globe.dart';
import '../widgets/travel_heading_section.dart';
import '../widgets/featured_destinations.dart';
import '../../../core/config/theme/app_colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
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
    /*Navigator.pushNamed(
      context,
      '/destination-detail',
      arguments: destination,
    );*/
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
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/user/user-2.png'),
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: destinationsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(destinationsProvider.notifier)
                    .loadDestinations();
              },
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TravelHeadingSection(),

                    // Section carte interactive
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: InteractiveGlobe(
                        locations: [
                          MapLocation(
                            name: 'Paris',
                            position: Offset(100, 120),
                            color: AppColors.primary,
                          ),
                          MapLocation(
                            name: 'Dubai',
                            position: Offset(280, 140),
                            color: AppColors.secondary,
                          ),
                          MapLocation(
                            name: 'New York',
                            position: Offset(150, 120),
                            color: AppColors.secondary,
                          ),
                          MapLocation(
                            name: 'London',
                            position: Offset(200, 90),
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),

                    // Section destinations en vedette
                    if (destinationsState.featuredDestinations.isNotEmpty)
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
                            'Popular Global Travel\nDestinations',
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
                    ),

                    // Nouvelles sections
                    //const LatestFlightDeals(),
                    const SizedBox(height: 24),
                    const ContactSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
