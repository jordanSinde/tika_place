// lib/features/bus_booking/screens/reservation_history_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../providers/reservation_state_notifier.dart';
import 'reservation_list_widget.dart';

class ReservationHistoryScreen extends ConsumerStatefulWidget {
  const ReservationHistoryScreen({super.key});

  @override
  ConsumerState<ReservationHistoryScreen> createState() =>
      _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState
    extends ConsumerState<ReservationHistoryScreen> {
  final _searchController = TextEditingController();
  ReservationFilter _currentFilter = ReservationFilter.all;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    // Charger les réservations
    await _loadReservations();

    // Mettre en place un rafraîchissement périodique
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkAndUpdateStatuses(),
    );
  }

  Future<void> _loadReservations() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId != null) {
      await ref
          .read(centralReservationProvider.notifier)
          .loadUserReservations(userId);
    }
  }

  Future<void> _checkAndUpdateStatuses() async {
    // Vérifier et mettre à jour les statuts via le provider central
    await ref
        .read(centralReservationProvider.notifier)
        ._checkAvailabilityAndExpiration();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Écouter l'état central pour les mises à jour
    final centralState = ref.watch(centralReservationProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadReservations,
        child: centralState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(centralState),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Historique des réservations'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(CentralReservationState state) {
    final filteredReservations = _getFilteredReservations(state);

    if (filteredReservations.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: filteredReservations.length,
      itemBuilder: (context, index) {
        final reservation = filteredReservations[index];
        return ReservationCard(
          reservation: reservation,
          onRetryPayment: () => _handleRetryPayment(reservation),
          onCancel: () => _handleCancellation(reservation),
          // Nouvelles propriétés pour la gestion des statuts
          availabilityStatus: state.seatsAvailability[reservation.id],
          paymentAttempts: state.paymentAttempts[reservation.id] ?? 0,
        );
      },
    );
  }

  Future<void> _handleRetryPayment(TicketReservation reservation) async {
    // Vérifier la disponibilité avant de permettre le paiement
    final isAvailable = await ref
        .read(centralReservationProvider.notifier)
        ._checkSeatAvailability(
          reservation.bus.id,
          reservation.passengers.length,
        );

    if (!isAvailable) {
      if (mounted) {
        _showErrorDialog(
          'Places non disponibles',
          'Les places ne sont plus disponibles pour cette réservation.',
        );
      }
      return;
    }

    // Vérifier le nombre de tentatives
    if (!await ref
        .read(centralReservationProvider.notifier)
        .validatePaymentAttempt(reservation.id)) {
      if (mounted) {
        _showErrorDialog(
          'Limite atteinte',
          'Vous avez atteint le nombre maximum de tentatives de paiement pour aujourd\'hui.',
        );
      }
      return;
    }

    // Naviguer vers l'écran de paiement
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentStep(
            onPrevious: () => Navigator.pop(context),
            reservation: reservation,
          ),
        ),
      );
    }
  }

  Future<void> _handleCancellation(TicketReservation reservation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer l\'annulation'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette réservation ? '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(centralReservationProvider.notifier)._cancelReservation(
              reservation.id,
              'Annulé par l\'utilisateur',
              true,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Réservation annulée avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog(
            'Erreur',
            'Une erreur est survenue lors de l\'annulation.',
          );
        }
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  List<TicketReservation> _getFilteredReservations(
      CentralReservationState state) {
    return state.reservations.where((reservation) {
      // Filtre par statut
      if (_currentFilter != ReservationFilter.all) {
        if (!_matchesStatusFilter(reservation.status)) {
          return false;
        }
      }

      // Filtre par recherche
      if (_searchController.text.isNotEmpty) {
        return _matchesSearchCriteria(reservation);
      }

      return true;
    }).toList();
  }

  bool _matchesStatusFilter(BookingStatus status) {
    switch (_currentFilter) {
      case ReservationFilter.pending:
        return status == BookingStatus.pending;
      case ReservationFilter.confirmed:
        return status == BookingStatus.confirmed;
      case ReservationFilter.cancelled:
        return status == BookingStatus.cancelled ||
            status == BookingStatus.expired;
      default:
        return true;
    }
  }

  bool _matchesSearchCriteria(TicketReservation reservation) {
    final query = _searchController.text.toLowerCase();

    // Recherche dans différents champs
    return reservation.bus.departureCity.toLowerCase().contains(query) ||
        reservation.bus.arrivalCity.toLowerCase().contains(query) ||
        reservation.id.toLowerCase().contains(query) ||
        reservation.passengers.any((passenger) =>
            '${passenger.firstName} ${passenger.lastName}'
                .toLowerCase()
                .contains(query));
  }

  // ... (autres méthodes existantes pour les widgets UI)
}


/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../providers/reservation_provider.dart';
import 'reservation_list_widget.dart';

enum ReservationFilter {
  all,
  pending,
  confirmed,
  cancelled;

  String get label {
    switch (this) {
      case ReservationFilter.all:
        return 'Toutes';
      case ReservationFilter.pending:
        return 'En attente';
      case ReservationFilter.confirmed:
        return 'Confirmées';
      case ReservationFilter.cancelled:
        return 'Annulées';
    }
  }

  Color get color {
    switch (this) {
      case ReservationFilter.all:
        return AppColors.primary;
      case ReservationFilter.pending:
        return AppColors.warning;
      case ReservationFilter.confirmed:
        return AppColors.success;
      case ReservationFilter.cancelled:
        return AppColors.error;
    }
  }
}

class ReservationHistoryScreen extends ConsumerStatefulWidget {
  const ReservationHistoryScreen({super.key});

  @override
  ConsumerState<ReservationHistoryScreen> createState() =>
      _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState
    extends ConsumerState<ReservationHistoryScreen> {
  ReservationFilter _currentFilter = ReservationFilter.all;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reservationState = ref.watch(reservationProvider);
    final filteredReservations = _getFilteredReservations(reservationState);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des réservations'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              _buildSearchBar(),
              _buildFilterChips(),
            ],
          ),
        ),
      ),
      body: reservationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredReservations.isEmpty
              ? _buildEmptyState()
              : _buildReservationsList(filteredReservations),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher une réservation...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ReservationFilter.values.map((filter) {
          final isSelected = _currentFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _currentFilter = selected ? filter : ReservationFilter.all;
                });
              },
              backgroundColor: filter.color.withOpacity(0.1),
              selectedColor: filter.color.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? filter.color : AppColors.textLight,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              checkmarkColor: filter.color,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReservationsList(List<TicketReservation> reservations) {
    // Grouper les réservations par mois
    final groupedReservations = <String, List<TicketReservation>>{};
    for (final reservation in reservations) {
      final monthYear =
          '${reservation.createdAt.month}/${reservation.createdAt.year}';
      groupedReservations.putIfAbsent(monthYear, () => []).add(reservation);
    }

    return ListView.builder(
      itemCount: groupedReservations.length,
      itemBuilder: (context, index) {
        final monthYear = groupedReservations.keys.elementAt(index);
        final monthReservations = groupedReservations[monthYear]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _formatMonthYear(monthYear),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
            ),
            ReservationListWidget(
              reservations: monthReservations,
              onRetryPayment: () {
                // Gérer la reprise du paiement
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String message = 'Aucune réservation trouvée';
    if (_searchQuery.isNotEmpty) {
      message = 'Aucune réservation ne correspond à votre recherche';
    } else if (_currentFilter != ReservationFilter.all) {
      message = 'Aucune réservation ${_currentFilter.label.toLowerCase()}';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.textLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos réservations apparaîtront ici',
            style: TextStyle(
              color: AppColors.textLight.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  List<TicketReservation> _getFilteredReservations(ReservationState state) {
    return state.reservations.where((reservation) {
      // Filtre par statut
      if (_currentFilter != ReservationFilter.all) {
        switch (_currentFilter) {
          case ReservationFilter.pending:
            if (reservation.status != BookingStatus.pending) return false;
            break;
          case ReservationFilter.confirmed:
            if (reservation.status != BookingStatus.confirmed) return false;
            break;
          case ReservationFilter.cancelled:
            if (reservation.status != BookingStatus.cancelled &&
                reservation.status != BookingStatus.expired) return false;
            break;
          default:
            break;
        }
      }

      // Filtre par recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesDestination =
            reservation.bus.arrivalCity.toLowerCase().contains(query);
        final matchesOrigin =
            reservation.bus.departureCity.toLowerCase().contains(query);
        final matchesReference = reservation.id.toLowerCase().contains(query);
        final matchesPassenger = reservation.passengers.any((passenger) =>
            '${passenger.firstName} ${passenger.lastName}'
                .toLowerCase()
                .contains(query));

        return matchesDestination ||
            matchesOrigin ||
            matchesReference ||
            matchesPassenger;
      }

      return true;
    }).toList();
  }

  String _formatMonthYear(String monthYear) {
    final parts = monthYear.split('/');
    final month = int.parse(parts[0]);
    final year = parts[1];

    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];

    return '${months[month - 1]} $year';
  }
}
*/