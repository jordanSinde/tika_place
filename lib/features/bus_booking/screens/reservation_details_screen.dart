// lib/features/bus_booking/screens/reservation_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../providers/reservation_provider.dart';
import '../widgets/reservation_list_widget.dart';
import '../../../core/config/theme/app_colors.dart';

// Status count provider
final statusCountsProvider =
    StateProvider.family<Map<BookingStatus, int>, String?>((ref, type) {
  return {};
});

// Filtered reservations provider to memoize results
final filteredReservationsProvider =
    Provider.family<List<TicketReservation>, FilterParams>((ref, params) {
  final reservations = ref.watch(reservationProvider).reservations;
  return _getFilteredReservations(reservations, params.type, params.status);
});

// Helper class for filter parameters
class FilterParams {
  final String? type;
  final BookingStatus? status;

  const FilterParams({
    this.type,
    this.status,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterParams && type == other.type && status == other.status;

  @override
  int get hashCode => type.hashCode ^ status.hashCode;
}

// Helper function to get filtered reservations (moved outside the class)
List<TicketReservation> _getFilteredReservations(
  List<TicketReservation> reservations,
  String? type,
  BookingStatus? selectedStatus,
) {
  // First filter by type if specified
  var filtered = reservations;
  if (type == 'bus') {
    filtered = reservations
        .where((r) => true)
        .toList(); // For now, all are bus reservations
  } else if (type == 'hotels') {
    filtered = reservations
        .where((r) => false)
        .toList(); // Placeholder for future hotel reservations
  } else if (type == 'apartments') {
    filtered = reservations
        .where((r) => false)
        .toList(); // Placeholder for future apartment reservations
  }

  // Then filter by status if selected
  if (selectedStatus != null) {
    filtered = filtered.where((r) => r.status == selectedStatus).toList();
  }

  // Sort by creation date, newest first
  filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return filtered;
}

// Helper function to calculate status counts from reservations
Map<BookingStatus, int> _calculateStatusCounts(
    List<TicketReservation> reservations, String? type) {
  // Filter by type first
  var filtered = reservations;
  if (type == 'bus') {
    filtered = reservations.where((r) => true).toList(); // All are bus for now
  } else if (type == 'hotels' || type == 'apartments') {
    filtered = []; // No hotels/apartments yet
  }

  // Count by status
  final Map<BookingStatus, int> counts = {};
  for (final status in BookingStatus.values) {
    counts[status] = filtered.where((r) => r.status == status).length;
  }

  return counts;
}

class ReservationDetailsScreen extends ConsumerStatefulWidget {
  final String? type; // 'bus', 'hotels', 'apartments'

  const ReservationDetailsScreen({
    super.key,
    this.type,
  });

  @override
  ConsumerState<ReservationDetailsScreen> createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState
    extends ConsumerState<ReservationDetailsScreen> {
  BookingStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    // Initial load - use post-frame callback to avoid build-time setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateStatusCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type ?? 'bus';
    final title = _getTitle(type);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterChips(),
        ),
      ),
      body: _buildContent(),
    );
  }

  String _getTitle(String type) {
    switch (type) {
      case 'hotels':
        return 'Réservations d\'hôtels';
      case 'apartments':
        return 'Réservations d\'appartements';
      case 'bus':
      default:
        return 'Réservations de bus';
    }
  }

  Widget _buildFilterChips() {
    // Watch status counts provider
    final statusCounts = ref.watch(statusCountsProvider(widget.type));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatusChip(null, 'Tous'),
            ...BookingStatus.values.map((status) {
              final count = statusCounts[status] ?? 0;
              return _buildStatusChip(status, _getStatusText(status),
                  count: count);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus? status, String label,
      {int count = 0}) {
    final isSelected = _selectedStatus == status;
    final hasItems = count > 0 || status == null;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (status != null && count > 0)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : _getStatusColor(status),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? _getStatusColor(status) : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.grey[100],
        selectedColor: status != null
            ? _getStatusColor(status).withOpacity(0.8)
            : AppColors.primary,
        checkmarkColor: Colors.white,
        onSelected: hasItems
            ? (selected) {
                setState(() {
                  _selectedStatus = selected ? status : null;
                });
              }
            : null,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : hasItems
                  ? status != null
                      ? _getStatusColor(status)
                      : AppColors.primary
                  : AppColors.textLight.withOpacity(0.5),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        disabledColor: Colors.grey[100]!.withOpacity(0.5),
        avatar: status != null
            ? Icon(
                _getStatusIcon(status),
                color: isSelected ? Colors.white : _getStatusColor(status),
                size: 16,
              )
            : null,
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: _ReservationsListContainer(
              type: widget.type,
              selectedStatus: _selectedStatus,
              onUpdateStatusCounts: _updateStatusCounts,
            ),
          ),
        ),
      ],
    );
  }

  void _updateStatusCounts() {
    final reservations = ref.read(reservationProvider).reservations;
    final counts = _calculateStatusCounts(reservations, widget.type);
    ref.read(statusCountsProvider(widget.type).notifier).state = counts;
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Confirmée';
      case BookingStatus.paid:
        return 'Payée';
      case BookingStatus.pending:
        return 'En attente';
      case BookingStatus.cancelled:
        return 'Annulée';
      case BookingStatus.expired:
        return 'Expirée';
      case BookingStatus.failed:
        return 'Échouée';
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.paid:
        return Icons.monetization_on;
      case BookingStatus.pending:
        return Icons.pending;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.expired:
        return Icons.timer_off;
      case BookingStatus.failed:
        return Icons.error_outline;
    }
  }
}

// Extracted component for reservation list to follow Builder pattern
class _ReservationsListContainer extends ConsumerWidget {
  final String? type;
  final BookingStatus? selectedStatus;
  final VoidCallback onUpdateStatusCounts;

  const _ReservationsListContainer({
    required this.type,
    this.selectedStatus,
    required this.onUpdateStatusCounts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the filteredReservationsProvider to get memoized results
    final filterParams = FilterParams(type: type, status: selectedStatus);
    final allReservations =
        ref.watch(filteredReservationsProvider(filterParams));
    final isLoading = ref.watch(reservationProvider).isLoading;

    // Update status counts after build
    if (ref.read(reservationProvider).reservations.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onUpdateStatusCounts();
      });
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (allReservations.isEmpty) {
      return _buildEmptyState(selectedStatus);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${allReservations.length} ${allReservations.length > 1 ? 'réservations' : 'réservation'}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 16),
        ...allReservations.map((reservation) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ReservationListWidget(
              showOnly: reservation.id,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(BookingStatus? status) {
    String message;
    if (status != null) {
      message = 'Aucune réservation avec le statut "${_getStatusText(status)}"';
    } else {
      message = 'Aucune réservation disponible';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (status != null)
            TextButton.icon(
              onPressed: () {}, // This would be handled by parent
              icon: const Icon(Icons.filter_list_off),
              label: const Text('Effacer le filtre'),
            ),
        ],
      ),
    );
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Confirmée';
      case BookingStatus.paid:
        return 'Payée';
      case BookingStatus.pending:
        return 'En attente';
      case BookingStatus.cancelled:
        return 'Annulée';
      case BookingStatus.expired:
        return 'Expirée';
      case BookingStatus.failed:
        return 'Échouée';
    }
  }
}

// Global helper function for status colors
Color _getStatusColor(BookingStatus status) {
  switch (status) {
    case BookingStatus.confirmed:
    case BookingStatus.paid:
      return AppColors.success;
    case BookingStatus.pending:
      return AppColors.warning;
    case BookingStatus.cancelled:
    case BookingStatus.failed:
      return AppColors.error;
    case BookingStatus.expired:
      return AppColors.textLight;
  }
}

/*
class ReservationDetailsScreen extends ConsumerStatefulWidget {
  final String? type; // 'bus', 'hotels', 'apartments'

  const ReservationDetailsScreen({
    super.key,
    this.type,
  });

  @override
  ConsumerState<ReservationDetailsScreen> createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState
    extends ConsumerState<ReservationDetailsScreen> {
  BookingStatus? _selectedStatus;
  final Map<BookingStatus, int> _statusCounts = {};

  @override
  Widget build(BuildContext context) {
    final type = widget.type ?? 'bus';
    final title = _getTitle(type);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterChips(),
        ),
      ),
      body: _buildContent(),
    );
  }

  String _getTitle(String type) {
    switch (type) {
      case 'hotels':
        return 'Réservations d\'hôtels';
      case 'apartments':
        return 'Réservations d\'appartements';
      case 'bus':
      default:
        return 'Réservations de bus';
    }
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatusChip(null, 'Tous'),
            ...BookingStatus.values.map((status) {
              final count = _statusCounts[status] ?? 0;
              return _buildStatusChip(status, _getStatusText(status),
                  count: count);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus? status, String label,
      {int count = 0}) {
    final isSelected = _selectedStatus == status;
    final hasItems = count > 0 || status == null;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (status != null && count > 0)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : _getStatusColor(status),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? _getStatusColor(status) : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.grey[100],
        selectedColor: status != null
            ? _getStatusColor(status).withOpacity(0.8)
            : AppColors.primary,
        checkmarkColor: Colors.white,
        onSelected: hasItems
            ? (selected) {
                setState(() {
                  _selectedStatus = selected ? status : null;
                });
              }
            : null,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : hasItems
                  ? status != null
                      ? _getStatusColor(status)
                      : AppColors.primary
                  : AppColors.textLight.withOpacity(0.5),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        disabledColor: Colors.grey[100]!.withOpacity(0.5),
        avatar: status != null
            ? Icon(
                _getStatusIcon(status),
                color: isSelected ? Colors.white : _getStatusColor(status),
                size: 16,
              )
            : null,
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: _buildFilteredReservations(),
          ),
        ),
      ],
    );
  }

  Widget _buildFilteredReservations() {
    return Consumer(
      builder: (context, ref, child) {
        final reservationState = ref.watch(reservationProvider);

        if (reservationState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final allReservations = _getFilteredReservations(
          reservationState.reservations,
        );

        // Update status counts using post-frame callback
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateStatusCounts(reservationState.reservations);
          });
        }

        if (allReservations.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${allReservations.length} ${allReservations.length > 1 ? 'réservations' : 'réservation'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 16),
            ...allReservations.map((reservation) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ReservationListWidget(
                  showOnly: reservation.id,
                ),
              );
            }),
          ],
        );
      },
    );
  }

  /* Widget _buildFilteredReservations() {
    return Consumer(
      builder: (context, ref, child) {
        final reservationState = ref.watch(reservationProvider);

        if (reservationState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final allReservations = _getFilteredReservations(
          reservationState.reservations,
        );

        // Update status counts
        _updateStatusCounts(reservationState.reservations);

        if (allReservations.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${allReservations.length} ${allReservations.length > 1 ? 'réservations' : 'réservation'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 16),
            ...allReservations.map((reservation) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ReservationListWidget(
                  showOnly: reservation.id,
                ),
              );
            }),
          ],
        );
      },
    );
  }*/

  List<TicketReservation> _getFilteredReservations(
    List<TicketReservation> reservations,
  ) {
    // First filter by type if specified
    var filtered = reservations;
    if (widget.type == 'bus') {
      filtered = reservations
          .where((r) => true)
          .toList(); // For now, all are bus reservations
    } else {
      // For hotels/apartments, we'd filter by type when those are implemented
      filtered = [];
    }

    // Then filter by status if selected
    if (_selectedStatus != null) {
      filtered = filtered.where((r) => r.status == _selectedStatus).toList();
    }

    // Sort by creation date, newest first
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  void _updateStatusCounts(List<TicketReservation> reservations) {
    var filtered = reservations;
    if (widget.type == 'bus') {
      filtered =
          reservations.where((r) => true).toList(); // For now, all are bus
    } else {
      filtered = [];
    }

    final Map<BookingStatus, int> counts = {};
    for (final status in BookingStatus.values) {
      counts[status] = filtered.where((r) => r.status == status).length;
    }

    setState(() {
      _statusCounts.clear();
      _statusCounts.addAll(counts);
    });
  }

  Widget _buildEmptyState() {
    String message;
    if (_selectedStatus != null) {
      message =
          'Aucune réservation avec le statut "${_getStatusText(_selectedStatus!)}"';
    } else {
      message = 'Aucune réservation disponible';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (_selectedStatus != null)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedStatus = null;
                });
              },
              icon: const Icon(Icons.filter_list_off),
              label: const Text('Effacer le filtre'),
            ),
        ],
      ),
    );
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Confirmée';
      case BookingStatus.paid:
        return 'Payée';
      case BookingStatus.pending:
        return 'En attente';
      case BookingStatus.cancelled:
        return 'Annulée';
      case BookingStatus.expired:
        return 'Expirée';
      case BookingStatus.failed:
        return 'Échouée';
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.paid:
        return Icons.monetization_on;
      case BookingStatus.pending:
        return Icons.pending;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.expired:
        return Icons.timer_off;
      case BookingStatus.failed:
        return Icons.error_outline;
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
      case BookingStatus.paid:
        return AppColors.success;
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.cancelled:
      case BookingStatus.failed:
        return AppColors.error;
      case BookingStatus.expired:
        return AppColors.textLight;
    }
  }
}
*/