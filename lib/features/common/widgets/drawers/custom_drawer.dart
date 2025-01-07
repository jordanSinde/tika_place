import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';

class DrawerMenuItem {
  final String title;
  final IconData icon;
  final String? route;
  final List<DrawerMenuItem>? subItems;

  const DrawerMenuItem({
    required this.title,
    required this.icon,
    this.route,
    this.subItems,
  });
}

final List<DrawerMenuItem> menuItems = [
  const DrawerMenuItem(
    title: 'Home',
    icon: Icons.home_outlined,
    route: '/home',
  ),
  const DrawerMenuItem(
    title: 'Bus',
    icon: Icons.directions_bus_outlined,
    subItems: [
      DrawerMenuItem(
        title: 'Destinations',
        icon: Icons.map_outlined,
        route: '/bus/destinations',
      ),
      DrawerMenuItem(
        title: 'Réserver un billet',
        icon: Icons.confirmation_number_outlined,
        route: '/bus/booking',
      ),
    ],
  ),
  const DrawerMenuItem(
    title: 'Appartements',
    icon: Icons.apartment_outlined,
    subItems: [
      DrawerMenuItem(
        title: 'Liste des appartements',
        icon: Icons.list_outlined,
        route: '/apartments/list',
      ),
      DrawerMenuItem(
        title: 'Réserver un appartement',
        icon: Icons.book_outlined,
        route: '/apartments/booking',
      ),
    ],
  ),
  const DrawerMenuItem(
    title: 'Hotels',
    icon: Icons.hotel_outlined,
    subItems: [
      DrawerMenuItem(
        title: 'Liste des hotels',
        icon: Icons.list_outlined,
        route: '/hotels/list',
      ),
      DrawerMenuItem(
        title: 'Chambres disponibles',
        icon: Icons.bed_outlined,
        route: '/hotels/rooms',
      ),
      DrawerMenuItem(
        title: 'Réserver une chambre',
        icon: Icons.book_outlined,
        route: '/hotels/booking',
      ),
    ],
  ),
];

final List<DrawerMenuItem> pageMenuItems = [
  const DrawerMenuItem(
    title: 'Pages',
    icon: Icons.apartment_outlined,
    subItems: [
      DrawerMenuItem(
        title: 'Connexion',
        icon: Icons.list_outlined,
        route: '/login',
      ),
      DrawerMenuItem(
        title: 'Inscription',
        icon: Icons.book_outlined,
        route: '/signup',
      ),
    ],
  ),
];

class CustomDrawer extends ConsumerStatefulWidget {
  const CustomDrawer({super.key});

  @override
  ConsumerState<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends ConsumerState<CustomDrawer> {
  final Set<String> _expandedItems = {};

  void _toggleExpanded(String title) {
    setState(() {
      if (_expandedItems.contains(title)) {
        _expandedItems.remove(title);
      } else {
        _expandedItems.add(title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Menu principal
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        final item = menuItems[index];
                        return _buildMenuItemWithSubItems(item);
                      },
                    ),
                    const Divider(color: AppColors.divider),
                    // Pages menu
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pageMenuItems
                          .length, // Changer menuItems en pageMenuItems
                      itemBuilder: (context, index) {
                        final item = pageMenuItems[index];
                        return _buildMenuItemWithSubItems(item);
                      },
                    ),
                    _buildSimpleMenuItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      onTap: () => context.go('/about'),
                    ),
                    _buildSimpleMenuItem(
                      icon: Icons.contact_support_outlined,
                      title: 'Contact',
                      onTap: () => context.go('/contact'),
                    ),
                  ],
                ),
              ),
            ),
            //const Spacer(),
            if (user != null)
              _buildMenuItem(
                const DrawerMenuItem(
                  title: 'Déconnexion',
                  icon: Icons.logout,
                  route: '/login',
                ),
                onTap: () {
                  ref.read(authProvider.notifier).signOut();
                  context.go('/login');
                },
              ),
            const SizedBox(height: 16),
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
          /*Image.asset(
            'assets/images/logo.png',
            height: 40,
          ),*/
          Text(
            userName,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemWithSubItems(DrawerMenuItem item) {
    final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;
    final isExpanded = _expandedItems.contains(item.title);

    return Column(
      children: [
        _buildMenuItem(
          item,
          showArrow: hasSubItems,
          isExpanded: isExpanded,
          onTap: () {
            if (hasSubItems) {
              _toggleExpanded(item.title);
            } else if (item.route != null) {
              context.go(item.route!);
              Navigator.pop(context);
            }
          },
        ),
        if (hasSubItems && isExpanded)
          ...item.subItems!.map((subItem) => Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: _buildMenuItem(
                  subItem,
                  onTap: () {
                    if (subItem.route != null) {
                      context.go(subItem.route!);
                      Navigator.pop(context);
                    }
                  },
                ),
              )),
      ],
    );
  }

  Widget _buildMenuItem(
    DrawerMenuItem item, {
    bool showArrow = false,
    bool isExpanded = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(item.icon, color: Colors.white),
      title: Text(
        item.title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: showArrow
          ? Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.primary,
              size: 24,
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSimpleMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showArrow = false,
  }) {
    return ListTile(
      leading: Container(
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary,
            width: 6,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
      ),
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
}
