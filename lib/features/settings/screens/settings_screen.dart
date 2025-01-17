// lib/features/settings/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';

class SettingItem {
  final String title;
  final IconData icon;
  final String? route;

  const SettingItem({
    required this.title,
    required this.icon,
    this.route,
  });
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const List<Map<String, List<SettingItem>>> settingsSections = [
    {
      'Account': [
        SettingItem(
          title: 'Edit profile',
          icon: Icons.person_outline,
          route: '/profile/edit',
        ),
        SettingItem(
          title: 'Security',
          icon: Icons.security_outlined,
        ),
        SettingItem(
          title: 'Notifications',
          icon: Icons.notifications_outlined,
        ),
        SettingItem(
          title: 'Privacy',
          icon: Icons.lock_outline,
        ),
      ],
    },
    {
      'Support & About': [
        /*SettingItem(
          title: 'My Subscription',
          icon: Icons.card_membership_outlined,
        ),*/
        SettingItem(
          title: 'Help & Support',
          icon: Icons.help_outline,
        ),
        SettingItem(
          title: 'Terms and Policies',
          icon: Icons.description_outlined,
        ),
      ],
    },
    {
      'Cache & cellular': [
        SettingItem(
          title: 'Free up space',
          icon: Icons.delete_outline,
        ),
        SettingItem(
          title: 'Data Saver',
          icon: Icons.data_saver_off_outlined,
        ),
      ],
    },
    {
      'Actions': [
        SettingItem(
          title: 'Report a problem',
          icon: Icons.flag_outlined,
        ),
        /*SettingItem(
          title: 'Add account',
          icon: Icons.person_add_outlined,
        ),*/
        SettingItem(
          title: 'Log out',
          icon: Icons.logout,
          route: '/login',
        ),
      ],
    },
  ];

  void _handleItemTap(BuildContext context, SettingItem item) {
    if (item.title == 'Log out') {
      // Gérer la déconnexion ici
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Aucune action disponible pour: ${item.title}'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: settingsSections.length,
        itemBuilder: (context, sectionIndex) {
          final section = settingsSections[sectionIndex];
          final title = section.keys.first;
          final items = section.values.first;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 0,
                    color: Colors.white,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item.icon,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textLight,
                            ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.textLight,
                      ),
                      onTap: () => _handleItemTap(context, item),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
