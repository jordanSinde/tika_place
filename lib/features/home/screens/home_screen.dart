import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tika_place/core/config/constants.dart';
import '../../../core/config/theme/app_colors.dart';

// lib/features/home/screens/home_screen.dart

import '../../common/widgets/drawers/custom_drawer.dart';
import '../../bus_booking/bus_booking_view.dart';
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
  // ... votre _buildTabItem reste le même ...

  Widget _buildContent(int selectedTab) {
    switch (selectedTab) {
      case 0:
        return const BusBookingView();
      case 1:
        return const HotelBookingView();
      case 2:
        return const ApartmentBookingView();
      default:
        return const SizedBox.shrink();
    }
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
      drawer: const CustomDrawer(),
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
        ],
      ),
      body: ListView(
        children: [
          // Carousel
          const CustomCarousel(),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTabItem(
                    icon: Icons.directions_bus_rounded,
                    label: 'Bus',
                    isSelected: selectedTab == 0,
                    onTap: () {
                      ref.read(selectedTabProvider.notifier).state = 0;
                    },
                  ),
                  const SizedBox(width: 6),
                  _buildTabItem(
                    icon: Icons.hotel_rounded,
                    label: 'Hôtels',
                    isSelected: selectedTab == 1,
                    onTap: () {
                      ref.read(selectedTabProvider.notifier).state = 1;
                    },
                  ),
                  const SizedBox(width: 6),
                  _buildTabItem(
                    icon: Icons.apartment_rounded,
                    label: 'Appartements',
                    isSelected: selectedTab == 2,
                    onTap: () {
                      ref.read(selectedTabProvider.notifier).state = 2;
                    },
                  ),
                ],
              ),
            ),
          ),

          // Content
          _buildContent(selectedTab),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
