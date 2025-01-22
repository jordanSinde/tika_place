// lib/features/settings/screens/notifications_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';

// Provider pour stocker l'état des notifications
final notificationsSettingsProvider =
    StateNotifierProvider<NotificationsSettingsNotifier, Map<String, bool>>(
        (ref) {
  return NotificationsSettingsNotifier();
});

class NotificationsSettingsNotifier extends StateNotifier<Map<String, bool>> {
  NotificationsSettingsNotifier()
      : super({
          'push_enabled': true,
          'reservation_updates': true,
          'reservation_reminder': true,
          'promo_offers': false,
          'newsletter': false,
          'app_updates': true,
          'travel_tips': true,
          'price_alerts': false,
          'account_security': true,
        });

  void toggleSetting(String key) {
    state = {...state, key: !state[key]!};
  }
}

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationsSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildMainToggle(context, ref, settings),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Réservations',
              [
                NotificationOption(
                  title: 'Mises à jour des réservations',
                  subtitle: 'Statut, modifications et confirmations',
                  icon: Icons.calendar_today,
                  isEnabled: settings['reservation_updates']!,
                  onChanged: (value) => ref
                      .read(notificationsSettingsProvider.notifier)
                      .toggleSetting('reservation_updates'),
                ),
                NotificationOption(
                  title: 'Rappels',
                  subtitle: 'Rappels avant vos voyages et séjours',
                  icon: Icons.alarm,
                  isEnabled: settings['reservation_reminder']!,
                  onChanged: (value) => ref
                      .read(notificationsSettingsProvider.notifier)
                      .toggleSetting('reservation_reminder'),
                ),
              ],
            ),
            _buildSection(
              context,
              'Offres & Marketing',
              [
                NotificationOption(
                  title: 'Offres promotionnelles',
                  subtitle: 'Réductions et offres spéciales',
                  icon: Icons.local_offer,
                  isEnabled: settings['promo_offers']!,
                  onChanged: (value) => ref
                      .read(notificationsSettingsProvider.notifier)
                      .toggleSetting('promo_offers'),
                ),
                /*NotificationOption(
                  title: 'Newsletter',
                  subtitle: 'Actualités et nouveautés',
                  icon: Icons.mail,
                  isEnabled: settings['newsletter']!,
                  onChanged: (value) => ref
                      .read(notificationsSettingsProvider.notifier)
                      .toggleSetting('newsletter'),
                ),*/
              ],
            ),
            _buildSection(
              context,
              'Application & Sécurité',
              [
                NotificationOption(
                  title: 'Mises à jour de l\'application',
                  subtitle: 'Nouvelles fonctionnalités et améliorations',
                  icon: Icons.system_update,
                  isEnabled: settings['app_updates']!,
                  onChanged: (value) => ref
                      .read(notificationsSettingsProvider.notifier)
                      .toggleSetting('app_updates'),
                ),
                NotificationOption(
                  title: 'Alertes de prix',
                  subtitle: 'Notifications quand les prix changent',
                  icon: Icons.monetization_on,
                  isEnabled: settings['price_alerts']!,
                  onChanged: (value) => ref
                      .read(notificationsSettingsProvider.notifier)
                      .toggleSetting('price_alerts'),
                ),
                NotificationOption(
                  title: 'Sécurité du compte',
                  subtitle: 'Connexions et modifications importantes',
                  icon: Icons.security,
                  isEnabled: settings['account_security']!,
                  onChanged: (value) => ref
                      .read(notificationsSettingsProvider.notifier)
                      .toggleSetting('account_security'),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMainToggle(
      BuildContext context, WidgetRef ref, Map<String, bool> settings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Autoriser les notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Activez pour recevoir toutes les notifications',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings['push_enabled']!,
                onChanged: (value) => ref
                    .read(notificationsSettingsProvider.notifier)
                    .toggleSetting('push_enabled'),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<NotificationOption> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            separatorBuilder: (context, index) => const Divider(
              height: 0,
              color: Colors.white,
            ),
            itemBuilder: (context, index) => options[index],
          ),
        ),
      ],
    );
  }
}

class NotificationOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isEnabled;
  final Function(bool) onChanged;

  const NotificationOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.textLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isEnabled ? AppColors.primary : AppColors.textLight,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textLight,
            ),
      ),
      trailing: Switch(
        value: isEnabled,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}
