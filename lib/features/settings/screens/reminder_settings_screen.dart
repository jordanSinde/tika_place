//lib/features/bus_booking/screens/settings/reminder_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../bus_booking/services/trip_reminder_service.dart';
import '../../common/widgets/buttons/primary_button.dart';
import '../../notifications/services/notification_service.dart';

class ReminderSettingsScreen extends ConsumerStatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  ConsumerState<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState
    extends ConsumerState<ReminderSettingsScreen> {
  bool _isLoading = false;
  bool _notificationsEnabled = false;
  bool _dayBeforeEnabled = true;
  bool _morningOfEnabled = true;
  bool _twoHoursEnabled = true;
  TimeOfDay _morningReminderTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final hasPermission =
          await tripReminderService.checkNotificationPermissions();
      setState(() {
        _notificationsEnabled = hasPermission;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rappels de voyage'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationToggle(),
                  if (_notificationsEnabled) ...[
                    const SizedBox(height: 24),
                    _buildReminderSettings(),
                    const SizedBox(height: 24),
                    _buildMorningTimeSettings(),
                    const SizedBox(height: 32),
                    _buildTestButton(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationToggle() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        value: _notificationsEnabled,
        onChanged: _toggleNotifications,
        title: const Text(
          'Activer les notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _notificationsEnabled
              ? 'Vous recevrez des rappels pour vos voyages'
              : 'Activez les notifications pour recevoir des rappels',
          style: TextStyle(
            color: AppColors.textLight.withOpacity(0.7),
          ),
        ),
        secondary: Icon(
          _notificationsEnabled
              ? Icons.notifications_active
              : Icons.notifications_off,
          color:
              _notificationsEnabled ? AppColors.success : AppColors.textLight,
        ),
      ),
    );
  }

  Widget _buildReminderSettings() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildReminderToggle(
            'Rappel la veille',
            'Notification 24h avant le départ',
            _dayBeforeEnabled,
            (value) => setState(() => _dayBeforeEnabled = value),
          ),
          const Divider(),
          _buildReminderToggle(
            'Rappel le matin',
            'Notification le jour du départ',
            _morningOfEnabled,
            (value) => setState(() => _morningOfEnabled = value),
          ),
          const Divider(),
          _buildReminderToggle(
            'Dernier rappel',
            'Notification 2h avant le départ',
            _twoHoursEnabled,
            (value) => setState(() => _twoHoursEnabled = value),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderToggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: _notificationsEnabled ? onChanged : null,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textLight.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildMorningTimeSettings() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        enabled: _notificationsEnabled && _morningOfEnabled,
        onTap: () => _selectMorningTime(context),
        title: const Text(
          'Heure du rappel matinal',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Notification envoyée à ${_morningReminderTime.format(context)}',
          style: TextStyle(
            color: AppColors.textLight.withOpacity(0.7),
          ),
        ),
        trailing: const Icon(Icons.access_time),
      ),
    );
  }

  Widget _buildTestButton() {
    return PrimaryButton(
      text: 'Tester les notifications',
      icon: Icons.notification_add,
      onPressed: () {
        // Fonction synchrone qui encapsule l'appel asynchrone
        if (_notificationsEnabled) {
          _sendTestNotification();
        }
      },
      isLoading: _isLoading, // Ajoutons l'indicateur de chargement
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _isLoading = true);

    try {
      if (value) {
        final hasPermission =
            await tripReminderService.checkNotificationPermissions();
        setState(() {
          _notificationsEnabled = hasPermission;
        });

        if (!hasPermission && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Veuillez activer les notifications dans les paramètres'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } else {
        setState(() {
          _notificationsEnabled = false;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectMorningTime(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _morningReminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        _morningReminderTime = selectedTime;
      });
    }
  }

  Future<void> _sendTestNotification() async {
    setState(() => _isLoading = true);

    try {
      await notificationService.showBookingConfirmationNotification(
        title: 'Test de notification',
        body: 'Ceci est une notification test pour les rappels de voyage.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification test envoyée'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'envoi de la notification'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
