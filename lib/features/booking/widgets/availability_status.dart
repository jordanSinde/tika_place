// lib/features/bus_booking/widgets/availability_status.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';
import '../services/availability_service.dart';
import '../providers/availability_provider.dart';

class AvailabilityStatus extends ConsumerWidget {
  final String reservationId;
  final int seatsNeeded;
  final bool showCount;

  const AvailabilityStatus({
    super.key,
    required this.reservationId,
    required this.seatsNeeded,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availability =
        ref.watch(reservationAvailabilityProvider(reservationId));

    if (availability == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(availability.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(availability.status),
            size: 16,
            color: _getBackgroundColor(availability.status),
          ),
          const SizedBox(width: 8),
          Text(
            _getMessage(availability),
            style: TextStyle(
              color: _getBackgroundColor(availability.status),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (showCount && availability.availableCount != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getBackgroundColor(availability.status),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${availability.availableCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return AppColors.success;
      case AvailabilityStatus.partiallyAvailable:
        return AppColors.warning;
      case AvailabilityStatus.unavailable:
        return AppColors.error;
      case AvailabilityStatus.unknown:
        return AppColors.textLight;
    }
  }

  IconData _getIcon(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return Icons.check_circle;
      case AvailabilityStatus.partiallyAvailable:
        return Icons.warning;
      case AvailabilityStatus.unavailable:
        return Icons.error;
      case AvailabilityStatus.unknown:
        return Icons.help;
    }
  }

  String _getMessage(AvailabilityResult result) {
    return switch (result.status) {
      AvailabilityStatus.available => 'Places disponibles',
      AvailabilityStatus.partiallyAvailable => 'Places limitées',
      AvailabilityStatus.unavailable => 'Plus de places disponibles',
      AvailabilityStatus.unknown => 'Statut inconnu',
    };
  }
}

// Widget pour montrer les mises à jour en temps réel
class LiveAvailabilityStatus extends ConsumerStatefulWidget {
  final String reservationId;
  final int seatsNeeded;
  final bool showCount;

  const LiveAvailabilityStatus({
    super.key,
    required this.reservationId,
    required this.seatsNeeded,
    this.showCount = true,
  });

  @override
  ConsumerState<LiveAvailabilityStatus> createState() =>
      _LiveAvailabilityStatusState();
}

class _LiveAvailabilityStatusState
    extends ConsumerState<LiveAvailabilityStatus> {
  @override
  void initState() {
    super.initState();
    // Démarrer le monitoring en temps réel
    ref.read(availabilityProvider.notifier).startMonitoring(
          widget.reservationId,
          widget.seatsNeeded,
        );
  }

  @override
  void dispose() {
    // Arrêter le monitoring
    ref.read(availabilityProvider.notifier).stopMonitoring(
          widget.reservationId,
        );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AvailabilityStatus(
      reservationId: widget.reservationId,
      seatsNeeded: widget.seatsNeeded,
      showCount: widget.showCount,
    );
  }
}
