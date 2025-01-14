import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tika_place/core/config/constants.dart';
import '../../../core/config/theme/app_colors.dart';

// lib/features/home/screens/home_screen.dart

import '../../auth/providers/auth_provider.dart';
import '../widgets/bus_booking/bus_booking_view.dart';
import '../widgets/contact_section.dart';
import '../widgets/custom_carroussel.dart';
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
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
          'Tika Place',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            onPressed: () {
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
      body: SingleChildScrollView(
        // Ajout du SingleChildScrollView pour permettre le défilement
        child: Column(
          children: [
            // Carrousel
            const CustomCarousel(),

            // TabBar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              //padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    const SizedBox(width: 6),
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
                    const SizedBox(width: 6),
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

            // Contenu des pages dans un container avec hauteur fixe
            SizedBox(
              height: 400,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  ref.read(selectedTabProvider.notifier).state = index;
                },
                children: const [
                  BusBookingView(),
                  HotelBookingView(),
                  ApartmentBookingView(),
                ],
              ),
            ),

            // Section Contact
            const SizedBox(height: 12), // Espacement avant la section contact
            const ContactSection(),
            const SizedBox(height: 12), // Espacement après la section contact
          ],
        ),
      ),
    );
  }
}
