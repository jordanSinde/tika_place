// lib/features/bus_booking/screens/bus_booking_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tika_place/features/home/widgets/bus_booking/mock_data.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../models/bus_mock_data.dart';
import 'bus_card.dart';
import 'bus_filter_panel.dart';
import 'bus_sort_option.dart';
import 'bus_sort_selector.dart';

class BusBookingListScreen extends ConsumerStatefulWidget {
  final BusSearchFilters initialFilters;

  const BusBookingListScreen({
    super.key,
    required this.initialFilters,
  });

  @override
  ConsumerState<BusBookingListScreen> createState() =>
      _BusBookingListScreenState();
}

// Dans BusBookingListScreen, ajoutez ces éléments

class _BusBookingListScreenState extends ConsumerState<BusBookingListScreen> {
  late BusSearchFilters _currentFilters;
  late BusSortOption _currentSortOption;
  bool _isFilterExpanded = false;
  bool _isLoading = false;
  List<Bus> _buses = [];

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters;
    _currentSortOption = BusSortOption.departureTimeAsc;
    _loadBuses();
  }

  List<Bus> _sortBuses(List<Bus> buses) {
    final sortedBuses = List<Bus>.from(buses);
    sortedBuses.sort(_currentSortOption.compare);
    return sortedBuses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tickets disponibles'),
            if (_currentFilters.departureCity != null &&
                _currentFilters.arrivalCity != null)
              Text(
                '${_currentFilters.departureCity} → ${_currentFilters.arrivalCity}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFilterExpanded ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Panneau de filtres extensible
            if (_isFilterExpanded)
              Container(
                constraints:
                    const BoxConstraints(maxHeight: 500), // Hauteur max
                child: SingleChildScrollView(
                  child: BusFilterPanel(
                    initialFilters: _currentFilters,
                    onFiltersChanged: _onFiltersChanged,
                    agencies: agencesList,
                  ),
                ),
              ),

            // Sélecteur de tri
            BusSortSelector(
              selectedOption: _currentSortOption,
              onSortChanged: (newOption) {
                setState(() {
                  _currentSortOption = newOption;
                  _buses = _sortBuses(_buses);
                });
              },
            ),

            // Liste des bus
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadBuses,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buses.isEmpty
                        ? _buildEmptyState()
                        : Scrollbar(
                            child: ListView.builder(
                              // Changé separated par builder
                              padding: const EdgeInsets.all(16),
                              itemCount: _buses.length,
                              itemBuilder: (context, index) {
                                final bus = _buses[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: BusCard(
                                    key: ValueKey(
                                        bus.id), // Ajout d'une key unique
                                    bus: bus,
                                    onBookingPressed: () => _handleBooking(bus),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onFiltersChanged(BusSearchFilters newFilters) {
    setState(() {
      _currentFilters = newFilters;
    });
    _loadBuses();
  }

  // Dans la classe _BusBookingListScreenState, ajoutez ces méthodes :

  Widget _buildEmptyState() {
    // Obtenir les prochains bus disponibles pour ce trajet
    final nextAvailableBuses = _findNextAvailableBuses();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.bus_alert_rounded,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun bus disponible pour cet horaire',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          if (nextAvailableBuses.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Voici les prochains trajets disponibles :',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLight,
                  ),
            ),
            const SizedBox(height: 16),
            ...nextAvailableBuses.map((bus) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: BusCard(
                    bus: bus,
                    onBookingPressed: () => _handleBooking(bus),
                  ),
                )),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Essayez de modifier vos critères de recherche ou sélectionnez une autre date',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLight,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isFilterExpanded = true;
                });
              },
              icon: const Icon(Icons.filter_list),
              label: const Text('Modifier les filtres'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Bus> _findNextAvailableBuses() {
    if (_currentFilters.departureCity == null ||
        _currentFilters.arrivalCity == null) {
      return [];
    }

    // Générer tous les bus
    final allBuses = generateMockBuses();

    // Filtrer les bus pour le même trajet
    final samePath = allBuses
        .where((bus) =>
            bus.departureCity == _currentFilters.departureCity &&
            bus.arrivalCity == _currentFilters.arrivalCity &&
            bus.availableSeats > 0)
        .toList();

    // Si une date est sélectionnée, trouver les prochains bus après cette date
    if (_currentFilters.departureDate != null) {
      final selectedDateTime = DateTime(
        _currentFilters.departureDate!.year,
        _currentFilters.departureDate!.month,
        _currentFilters.departureDate!.day,
        _currentFilters.departureTime?.hour ?? 0,
        _currentFilters.departureTime?.minute ?? 0,
      );

      samePath.sort((a, b) {
        final aDiff = a.departureTime.difference(selectedDateTime).abs();
        final bDiff = b.departureTime.difference(selectedDateTime).abs();
        return aDiff.compareTo(bDiff);
      });
    }

    // Retourner les 3 prochains bus disponibles
    return samePath.take(3).toList();
  }

  void _handleBooking(Bus bus) {
    // Afficher une boîte de dialogue de confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation de réservation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${bus.company} - ${bus.busClass.label}'),
            const SizedBox(height: 8),
            Text(
              '${bus.departureCity} → ${bus.arrivalCity}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Départ : ${DateFormat('dd/MM/yyyy HH:mm').format(bus.departureTime)}',
            ),
            const SizedBox(height: 16),
            Text(
              'Prix : ${NumberFormat('#,###').format(bus.price)} FCFA',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Naviguer vers le formulaire de réservation
              _showBookingForm(bus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showBookingForm(Bus bus) {
    // Implémenter le formulaire de réservation
    // Cette méthode pourrait naviguer vers une nouvelle page
    // ou afficher un bottom sheet avec le formulaire
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de réservation à venir'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  // Dans BusBookingListScreen, remplacez la méthode _filterBuses par :

  List<Bus> _filterBuses(BusSearchFilters filters) {
    // Générer les données mockées une seule fois
    final allBuses = generateMockBuses().where((bus) => bus.isValid()).toList();

    return allBuses.where((bus) {
      // Filtrer par ville de départ et d'arrivée
      if (filters.departureCity != null &&
          bus.departureCity != filters.departureCity) {
        return false;
      }
      if (filters.arrivalCity != null &&
          bus.arrivalCity != filters.arrivalCity) {
        return false;
      }

      // Filtrer par date de départ
      if (filters.departureDate != null) {
        final sameDay = bus.departureTime.year == filters.departureDate!.year &&
            bus.departureTime.month == filters.departureDate!.month &&
            bus.departureTime.day == filters.departureDate!.day;
        if (!sameDay) return false;
      }

      // Filtrer par heure de départ
      if (filters.departureTime != null) {
        final busHour = TimeOfDay.fromDateTime(bus.departureTime);
        final diff = (busHour.hour * 60 + busHour.minute) -
            (filters.departureTime!.hour * 60 + filters.departureTime!.minute);
        // Accepter les bus dans un intervalle de ±2 heures
        if (diff.abs() > 120) return false;
      }

      // Filtrer par classe de bus
      if (filters.busClass != null && bus.busClass != filters.busClass) {
        return false;
      }

      // Filtrer par plage de prix
      if (filters.priceRange != null) {
        if (bus.price < filters.priceRange!.start ||
            bus.price > filters.priceRange!.end) {
          return false;
        }
      }

      // Filtrer par commodités requises
      if (filters.requiredAmenities != null) {
        if (filters.requiredAmenities!.hasAirConditioning &&
            !bus.amenities.hasAirConditioning) return false;
        if (filters.requiredAmenities!.hasToilet && !bus.amenities.hasToilet) {
          return false;
        }
        if (filters.requiredAmenities!.hasLunch && !bus.amenities.hasLunch) {
          return false;
        }
        if (filters.requiredAmenities!.hasWifi && !bus.amenities.hasWifi) {
          return false;
        }
        if (filters.requiredAmenities!.hasUSBCharging &&
            !bus.amenities.hasUSBCharging) return false;
      }

      // Filtrer par compagnie
      if (filters.company != null && bus.company != filters.company) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> _loadBuses() async {
    setState(() => _isLoading = true);

    try {
      // Simuler un chargement asynchrone
      await Future.delayed(const Duration(seconds: 1));

      final filteredBuses = _filterBuses(_currentFilters);
      setState(() {
        _buses = _sortBuses(filteredBuses);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Gérer l'erreur (afficher un message, etc.)
    }
  }
}
