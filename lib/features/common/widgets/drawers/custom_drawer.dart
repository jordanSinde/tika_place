import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Container(
      width: 300,
      color: AppColors.drawerBackground,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildHeader(context, user?.firstName ?? 'Guest'),
            const SizedBox(height: 24),
            _buildMenuItem(
              icon: Icons.home_outlined,
              title: 'Home',
              onTap: () => _navigateToPage(context, '/'),
            ),
            _buildMenuItem(
              icon: Icons.flight_outlined,
              title: 'Flight',
              onTap: () => _navigateToPage(context, '/flight'),
              showArrow: true,
            ),
            _buildMenuItem(
              icon: Icons.directions_car_outlined,
              title: 'Car',
              onTap: () => _navigateToPage(context, '/car'),
              showArrow: true,
            ),
            _buildMenuItem(
              icon: Icons.hotel_outlined,
              title: 'Hotel',
              onTap: () => _navigateToPage(context, '/hotel'),
              showArrow: true,
            ),
            _buildMenuItem(
              icon: Icons.card_travel_outlined,
              title: 'Tour Package',
              onTap: () => _navigateToPage(context, '/tour'),
            ),
            const Divider(color: AppColors.divider),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () => _navigateToPage(context, '/about'),
            ),
            _buildMenuItem(
              icon: Icons.contact_support_outlined,
              title: 'Contact',
              onTap: () => _navigateToPage(context, '/contact'),
            ),
            const Spacer(),
            if (user != null)
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () {
                  ref.read(authProvider.notifier).signOut();
                  //Navigator.pushReplacementNamed(context, '/login');
                  context.goNamed('/login');
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
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
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showArrow = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: showArrow
          ? const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary,
              size: 16,
            )
          : null,
      onTap: onTap,
    );
  }

  void _navigateToPage(BuildContext context, String route) {
    Navigator.pop(context); // Ferme le drawer
    Navigator.pushNamed(context, route);
  }
}
