// lib/features/auth/screens/manage_sessions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';
import '../models/device_session.dart';
import '../providers/session_provider.dart';

class ManageSessionsScreen extends ConsumerStatefulWidget {
  const ManageSessionsScreen({super.key});

  @override
  ConsumerState<ManageSessionsScreen> createState() =>
      _ManageSessionsScreenState();
}

class _ManageSessionsScreenState extends ConsumerState<ManageSessionsScreen> {
  Future<void> _handleRevokeSession(String sessionId) async {
    try {
      await ref.read(sessionSecurityProvider).revokeSession(sessionId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session revoked successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleRevokeAllOtherSessions() async {
    try {
      final currentSession = ref.read(currentSessionProvider);
      if (currentSession == null) return;

      await ref
          .read(sessionSecurityProvider)
          .revokeAllOtherSessions(currentSession.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All other sessions have been revoked'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSessionItem(DeviceSession session) {
    final isCurrentSession =
        session.id == ref.watch(currentSessionProvider)?.id;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.devices),
        title: Text(
          session.deviceName,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last active: ${_formatDate(session.lastActivityAt)}',
              style: theme.textTheme.bodySmall,
            ),
            if (isCurrentSession)
              Text(
                'Current Session',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: !isCurrentSession
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _handleRevokeSession(session.id),
              )
            : null,
      ),
    );
  }

  String _formatDate(DateTime date) {
    // TODO: Utiliser un package de formatage de date plus sophistiqué
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(activeSessionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Active Sessions'),
        actions: [
          TextButton(
            onPressed: _handleRevokeAllOtherSessions,
            child: const Text('Revoke All'),
          ),
        ],
      ),
      body: sessions.when(
        data: (sessionsList) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Your account is currently signed in on these devices:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            ...sessionsList.map(_buildSessionItem),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
