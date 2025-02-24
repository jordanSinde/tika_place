// lib/features/apartment/screens/apartment_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';
import '../models/apartment_mock_data.dart';
import '../widgets/apartment_card.dart';
import '../widgets/apartment_filter_panel.dart';
import '../widgets/apartment_sort_selector.dart';
import 'apartment_details_screen.dart';

class ApartmentListScreen extends ConsumerStatefulWidget {
  final ApartmentSearchFilters initialFilters;

  const ApartmentListScreen({
    super.key,
    required this.initialFilters,
  });

  @override
  ConsumerState<ApartmentListScreen> createState() =>
      _ApartmentListScreenState();
}

class _ApartmentListScreenState extends ConsumerState<ApartmentListScreen> {
  late ApartmentSearchFilters _currentFilters;
  late ApartmentSortOption _currentSortOption;
  bool _isFilterExpanded = false;
  bool _isLoading = false;
  List<Apartment> _apartments = [];

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters;
    _currentSortOption = ApartmentSortOption.priceAsc;
    _loadApartments();
  }

  List<Apartment> _sortApartments(List<Apartment> apartments) {
    final sortedApartments = List<Apartment>.from(apartments);
    sortedApartments.sort((a, b) {
      switch (_currentSortOption) {
        case ApartmentSortOption.priceAsc:
          return a.price.compareTo(b.price);
        case ApartmentSortOption.priceDesc:
          return b.price.compareTo(a.price);
        case ApartmentSortOption.surfaceAsc:
          return a.surface.compareTo(b.surface);
        case ApartmentSortOption.surfaceDesc:
          return b.surface.compareTo(a.surface);
        case ApartmentSortOption.ratingDesc:
          return b.rating.compareTo(a.rating);
      }
    });
    return sortedApartments;
  }

  Future<void> _loadApartments() async {
    setState(() => _isLoading = true);

    try {
      // Simuler un chargement asynchrone
      await Future.delayed(const Duration(seconds: 1));

      final allApartments = generateMockApartments();
      final filteredApartments = _filterApartments(allApartments);
      setState(() {
        _apartments = _sortApartments(filteredApartments);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Gérer l'erreur
    }
  }

  // Dans _filterApartments de ApartmentListScreen :

  List<Apartment> _filterApartments(List<Apartment> apartments) {
    // Éviter le traitement multiple des mêmes appartements
    final uniqueApartments = {...apartments}.toList();

    print('Total apartments before filtering: ${uniqueApartments.length}');
    print('Current filters: ${_currentFilters.toString()}');

    return uniqueApartments.where((apartment) {
      // Filtrer par ville
      if (_currentFilters.city != null &&
          apartment.city != _currentFilters.city) {
        return false;
      }

      // Filtrer par quartier
      if (_currentFilters.district != null &&
          apartment.district != _currentFilters.district) {
        return false;
      }

      // Filtrer par type de location
      if (_currentFilters.rentalType != null &&
          apartment.rentalType != _currentFilters.rentalType) {
        return false;
      }

      // Filtrer par classe
      if (_currentFilters.apartmentClass != null &&
          apartment.apartmentClass != _currentFilters.apartmentClass) {
        return false;
      }

      // Filtrer par plage de prix avec une marge de tolérance de 10%
      if (_currentFilters.priceRange != null) {
        final minPrice = _currentFilters.priceRange!.start * 0.9;
        final maxPrice = _currentFilters.priceRange!.end * 1.1;

        if (apartment.price < minPrice || apartment.price > maxPrice) {
          return false;
        }
      }

      // Filtrer par surface minimale avec marge de tolérance
      if (_currentFilters.minSurface != null &&
          _currentFilters.minSurface! > 0) {
        if (apartment.surface < (_currentFilters.minSurface! * 0.9)) {
          return false;
        }
      }

      // Filtrer par nombre minimum de chambres
      if (_currentFilters.minBedrooms != null &&
          _currentFilters.minBedrooms! > 0) {
        if (apartment.bedrooms < _currentFilters.minBedrooms!) {
          return false;
        }
      }

      // Filtrer par commodités
      if (_currentFilters.requiredAmenities != null) {
        final required = _currentFilters.requiredAmenities!;
        final amenities = apartment.amenities;

        if (required.hasWifi && !amenities.hasWifi) return false;
        if (required.hasAirConditioning && !amenities.hasAirConditioning) {
          return false;
        }
        if (required.hasParking && !amenities.hasParking) return false;
        if (required.hasSecurity && !amenities.hasSecurity) return false;
        if (required.hasPool && !amenities.hasPool) return false;
        if (required.hasGym && !amenities.hasGym) return false;
        if (required.hasBalcony && !amenities.hasBalcony) return false;
        if (required.hasFurnished && !amenities.hasFurnished) return false;
      }

      return true;
    }).toList();
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
            const Text('Appartements disponibles'),
            if (_currentFilters.city != null)
              Text(
                _currentFilters.district != null
                    ? '${_currentFilters.city} - ${_currentFilters.district}'
                    : _currentFilters.city!,
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
            ApartmentSortSelector(
              selectedOption: _currentSortOption,
              onSortChanged: (newOption) {
                setState(() {
                  _currentSortOption = newOption;
                  _apartments = _sortApartments(_apartments);
                });
              },
            ),

            // Liste des appartements
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadApartments,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _apartments.isEmpty
                        ? _buildEmptyState()
                        : Scrollbar(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _apartments.length,
                              itemBuilder: (context, index) {
                                final apartment = _apartments[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: ApartmentCard(
                                    key: ValueKey(apartment.id),
                                    apartment: apartment,
                                    onPressed: () =>
                                        _showApartmentDetails(apartment),
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

  List<Apartment> _findSimilarApartments(List<Apartment> allApartments) {
    // Créer des filtres plus souples
    final relaxedFilters = _currentFilters.copyWith(
      priceRange: _currentFilters.priceRange != null
          ? RangeValues(
              _currentFilters.priceRange!.start * 0.8,
              _currentFilters.priceRange!.end * 1.2,
            )
          : null,
      minSurface: _currentFilters.minSurface != null
          ? _currentFilters.minSurface! * 0.8
          : null,
      minBedrooms: _currentFilters.minBedrooms != null
          ? _currentFilters.minBedrooms! - 1
          : null,
      apartmentClass: null, // Ignorer la classe pour trouver plus de résultats
    );

    return allApartments
        .where((apartment) {
          // Garder la même ville si spécifiée
          if (relaxedFilters.city != null &&
              apartment.city != relaxedFilters.city) {
            return false;
          }

          // Vérifier le prix avec une marge de tolérance
          if (relaxedFilters.priceRange != null) {
            if (apartment.price < relaxedFilters.priceRange!.start ||
                apartment.price > relaxedFilters.priceRange!.end) {
              return false;
            }
          }

          // Vérifier la surface avec une marge de tolérance
          if (relaxedFilters.minSurface != null &&
              apartment.surface < relaxedFilters.minSurface!) {
            return false;
          }

          // Vérifier le nombre de chambres avec une marge de tolérance
          if (relaxedFilters.minBedrooms != null &&
              apartment.bedrooms < relaxedFilters.minBedrooms!) {
            return false;
          }

          return true;
        })
        .take(3)
        .toList(); // Limiter à 3 suggestions
  }

  Widget _buildEmptyState() {
    final allApartments = generateMockApartments();
    final similarApartments = _findSimilarApartments(allApartments);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.apartment_rounded,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun appartement ne correspond exactement à vos critères',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (similarApartments.isNotEmpty) ...[
            const Text(
              'Voici des suggestions similaires qui pourraient vous intéresser :',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ...similarApartments.map((apartment) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ApartmentCard(
                    apartment: apartment,
                    onPressed: () => _showApartmentDetails(apartment),
                  ),
                )),
          ] else ...[
            Text(
              'Essayez de modifier vos critères de recherche pour plus de résultats',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
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
      ),
    );
  }
  /*Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.apartment_rounded,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun appartement ne correspond à vos critères',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos critères de recherche pour plus de résultats',
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
      ),
    );
  }*/

  void _showApartmentDetails(Apartment apartment) {
    // Naviguer vers l'écran de détails de l'appartement
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ApartmentDetailsScreen(apartment: apartment),
      ),
    );
  }
}

// Enum pour les options de tri
enum ApartmentSortOption {
  priceAsc('Prix croissant'),
  priceDesc('Prix décroissant'),
  surfaceAsc('Surface croissante'),
  surfaceDesc('Surface décroissante'),
  ratingDesc('Mieux notés');

  final String label;
  const ApartmentSortOption(this.label);
}
