// lib/features/settings/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../auth/providers/auth_provider.dart';

class SettingItem {
  final String title;
  final IconData icon;
  final String? route;
  final String? actionUrl;
  final Color? iconColor;
  final String? subtitle;

  const SettingItem({
    required this.title,
    required this.icon,
    this.route,
    this.actionUrl,
    this.iconColor,
    this.subtitle,
  });
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String termsUrl = "https://www.mongodb.com/legal";

  static const List<Map<String, List<SettingItem>>> settingsSections = [
    {
      'Compte': [
        SettingItem(
          title: 'Modifier le Profile',
          icon: Icons.person_outline,
          route: '/edit-profile',
        ),
        /*SettingItem(
          title: 'Securité',
          icon: Icons.security_outlined,
        ),*/
        SettingItem(
          title: 'Notifications',
          icon: Icons.notifications_outlined,
          route: '/notifications-settings',
        ),
        /*SettingItem(
          title: 'Confidentialité',
          icon: Icons.lock_outline,
        ),*/
      ],
    },
    {
      'Contact': [
        SettingItem(
          title: 'WhatsApp',
          icon: FontAwesomeIcons.whatsapp,
          actionUrl: 'https://wa.me/237694679620',
          iconColor: Color(0xFF25D366),
          //subtitle: '+237 694 679 620',
        ),
        SettingItem(
          title: 'Appel direct',
          icon: Icons.phone,
          actionUrl: 'tel:+237694679620',
          iconColor: AppColors.primary,
          //subtitle: '+237 694 679 620',
        ),
        SettingItem(
          title: 'Email',
          icon: Icons.email,
          actionUrl:
              'mailto:ftgroupsarl@gmail.com?subject=Contact%20from%20App&body=Hello,',
          iconColor: AppColors.primary,
          //subtitle: 'eveiltechnologique100@gmail.com',
        ),
      ],
    },
    {
      'Support & A Propos': [
        /*SettingItem(
          title: 'Aide & Support',
          icon: Icons.help_outline,
        ),*/
        SettingItem(
          title: 'Conditions et politiques',
          icon: Icons.description_outlined,
          actionUrl: termsUrl,
        ),
      ],
    },
    {
      'Actions': [
        SettingItem(
          title: 'Reportter un problème',
          icon: Icons.flag_outlined,
          route: '/report-problem',
        ),
        SettingItem(
          title: 'Deconnexion',
          icon: Icons.logout,
          //route: '/login',
        ),
      ],
    },
  ];

  Future<void> _handleItemTap(
      BuildContext context, WidgetRef ref, SettingItem item) async {
    if (item.title == 'Deconnexion') {
      await ref.read(authProvider.notifier).signOut();
      if (context.mounted) {
        context.go('/login');
      }
      return;
    }

    if (item.actionUrl != null) {
      final uri = Uri.parse(item.actionUrl!);
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Impossible de lancer cette action'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      return;
    }
    if (item.route != null && context.mounted) {
      context.push(item.route!);
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aucune action disponible pour: ${item.title}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
                          color: (item.iconColor ?? AppColors.primary)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item.icon,
                          color: item.iconColor ?? AppColors.primary,
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
                      subtitle: item.subtitle != null
                          ? Text(
                              item.subtitle!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            )
                          : null,
                      trailing: Icon(
                        item.actionUrl != null
                            ? Icons.arrow_forward_ios
                            : Icons.chevron_right,
                        color: item.iconColor ?? AppColors.textLight,
                        size: 16,
                      ),
                      onTap: () => _handleItemTap(context, ref, item),
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
