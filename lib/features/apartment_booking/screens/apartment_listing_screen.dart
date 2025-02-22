// lib/features/apartment_booking/screens/apartment_listing_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';
import '../models/apartment_mock_data.dart';
import '../widgets/apartment_card.dart';
import '../widgets/apartment_filter_panel.dart';
import '../models/apartment_filters.dart';
import '../data/mock_data.dart';

final selectedSortOptionProvider = StateProvider<ApartmentSortOption>(
  (ref) => ApartmentSortOption.priceAsc,
);

class ApartmentListingScreen extends ConsumerStatefulWidget {
  final ApartmentSearchFilters initialFilters;

  const ApartmentListingScreen({
    super.key,
    required this.initialFilters,
  });

  @override
  ConsumerState<ApartmentListingScreen> createState() =>
      _ApartmentListingScreenState();
}

class _ApartmentListingScreenState
    extends ConsumerState<ApartmentListingScreen> {
  late ApartmentSearchFilters _currentFilters;
  List<Apartment> _apartments = [];
  bool _isLoading = false;
  bool _isFilterPanelExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters;
    _loadApartments();
  }

  Future<void> _loadApartments() async {
    setState(() => _isLoading = true);

    try {
      // Simuler un chargement asynchrone
      await Future.delayed(const Duration(seconds: 1));

      // Générer des données mockées
      final allApartments = generateApartments();

      // Appliquer les filtres
      var filteredApartments = allApartments.where((apartment) {
        // Filtre par ville
        if (_currentFilters.city != null &&
            apartment.city != _currentFilters.city) {
          return false;
        }

        // Filtre par quartier
        if (_currentFilters.neighborhood != null &&
            apartment.neighborhood != _currentFilters.neighborhood) {
          return false;
        }

        // Filtre par type
        if (_currentFilters.type != null &&
            apartment.type != _currentFilters.type) {
          return false;
        }

        // Filtre par durée de location
        if (_currentFilters.duration != null &&
            apartment.duration != _currentFilters.duration) {
          return false;
        }

        // Filtre par prix
        if (_currentFilters.priceRange != null) {
          if (apartment.price < _currentFilters.priceRange!.start ||
              apartment.price > _currentFilters.priceRange!.end) {
            return false;
          }
        }

        // Filtre par nombre de chambres
        if (_currentFilters.minBedrooms != null &&
            apartment.bedrooms < _currentFilters.minBedrooms!) {
          return false;
        }

        // Filtre par nombre de salles de bain
        if (_currentFilters.minBathrooms != null &&
            apartment.bathrooms < _currentFilters.minBathrooms!) {
          return false;
        }

        // Filtre par surface
        if (_currentFilters.minSurface != null &&
            apartment.surface < _currentFilters.minSurface!) {
          return false;
        }

        // Filtre par équipements
        if (_currentFilters.requiredAmenities != null) {
          final required = _currentFilters.requiredAmenities!;
          final available = apartment.amenities;

          if (required.hasWifi && !available.contains('Wifi haut débit')) {
            return false;
          }
          if (required.hasAirConditioning &&
              !available.contains('Climatisation')) return false;
          if (required.hasParking && !available.contains('Parking sécurisé')) {
            return false;
          }
          if (required.hasPool && !available.contains('Piscine')) return false;
          if (required.hasGym && !available.contains('Salle de sport')) {
            return false;
          }
          if (required.hasSecurity && !available.contains('Sécurité 24/7')) {
            return false;
          }
          if (required.hasFurnished && !available.contains('Meublé')) {
            return false;
          }
          if (required.hasWaterHeater && !available.contains('Chauffe-eau')) {
            return false;
          }
        }

        // Filtre par animaux acceptés
        if (_currentFilters.petsAllowed != null &&
            apartment.petsAllowed != _currentFilters.petsAllowed) {
          return false;
        }

        // Filtre par distance du centre
        if (_currentFilters.maxDistanceToCenter != null &&
            apartment.distanceToCenter > _currentFilters.maxDistanceToCenter!) {
          return false;
        }

        return true;
      }).toList();

      // Appliquer le tri
      final sortOption = ref.read(selectedSortOptionProvider);
      filteredApartments.sort((a, b) => sortOption.compare(a, b));

      setState(() {
        _apartments = filteredApartments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors du chargement des appartements'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Appartements disponibles'),
            if (_currentFilters.city != null)
              Text(
                _currentFilters.city!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isFilterPanelExpanded
                ? Icons.filter_list_off
                : Icons.filter_list),
            onPressed: () {
              setState(() {
                _isFilterPanelExpanded = !_isFilterPanelExpanded;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Panneau de filtres extensible
          if (_isFilterPanelExpanded)
            Container(
              constraints: const BoxConstraints(maxHeight: 500),
              child: SingleChildScrollView(
                child: ApartmentFilterPanel(
                  initialFilters: _currentFilters,
                  onFiltersChanged: (newFilters) {
                    setState(() {
                      _currentFilters = newFilters;
                    });
                    _loadApartments();
                  },
                ),
              ),
            ),

          // Sélecteur de tri
          _buildSortSelector(),

          // Liste des appartements
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadApartments,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _apartments.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _apartments.length,
                          itemBuilder: (context, index) {
                            final apartment = _apartments[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ApartmentCard(
                                apartment: apartment,
                                onTap: () => _showApartmentDetails(apartment),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortSelector() {
    final sortOption = ref.watch(selectedSortOptionProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.sort, color: AppColors.textLight),
          const SizedBox(width: 8),
          const Text('Trier par :'),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<ApartmentSortOption>(
              value: sortOption,
              isExpanded: true,
              items: ApartmentSortOption.values.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option.label),
                );
              }).toList(),
              onChanged: (newOption) {
                if (newOption != null) {
                  ref.read(selectedSortOptionProvider.notifier).state =
                      newOption;
                  _loadApartments();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.house_outlined,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun appartement ne correspond à vos critères',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textLight,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres de recherche',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isFilterPanelExpanded = true;
              });
            },
            icon: const Icon(Icons.filter_list),
            label: const Text('Modifier les filtres'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showApartmentDetails(Apartment apartment) {
    // TODO: Implémenter la navigation vers la page de détails
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fonctionnalité à venir'),
        content: const Text('La page de détails sera bientôt disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
