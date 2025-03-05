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

import 'package:intl/intl.dart';

// Ajoutez cet enum pour définir des options de tri supplémentaires
enum ApartmentSortOption {
  priceAsc('Prix croissant'),
  priceDesc('Prix décroissant'),
  surfaceAsc('Surface croissante'),
  surfaceDesc('Surface décroissante'),
  ratingDesc('Mieux notés'),
  availabilityAsc('Disponibilité'); // Nouvelle option

  final String label;
  const ApartmentSortOption(this.label);
}

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

    // Si des dates sont définies et que l'option de tri est par disponibilité,
    // trier d'abord par disponibilité puis par date de disponibilité
    if (_currentSortOption == ApartmentSortOption.availabilityAsc &&
        _currentFilters.startDate != null) {
      sortedApartments.sort((a, b) {
        // On affiche d'abord les appartements disponibles
        final aAvailable = a.isAvailableForPeriod(
            _currentFilters.startDate!, _currentFilters.endDate!);
        final bAvailable = b.isAvailableForPeriod(
            _currentFilters.startDate!, _currentFilters.endDate!);

        if (aAvailable != bAvailable) {
          return aAvailable ? -1 : 1;
        }

        // Pour les appartements indisponibles, on trie par date de disponibilité
        if (!aAvailable && !bAvailable) {
          final aNextDate =
              a.getNextAvailableDateAfter(_currentFilters.startDate!);
          final bNextDate =
              b.getNextAvailableDateAfter(_currentFilters.startDate!);

          if (aNextDate != null && bNextDate != null) {
            return aNextDate.compareTo(bNextDate);
          }

          if (aNextDate == null) return 1;
          if (bNextDate == null) return -1;
        }

        // Par défaut, on trie par prix
        return a.pricePerDay.compareTo(b.pricePerDay);
      });

      return sortedApartments;
    }

    // Pour les autres options de tri
    sortedApartments.sort((a, b) {
      switch (_currentSortOption) {
        case ApartmentSortOption.priceAsc:
          return a.pricePerDay.compareTo(b.pricePerDay);
        case ApartmentSortOption.priceDesc:
          return b.pricePerDay.compareTo(a.pricePerDay);
        case ApartmentSortOption.surfaceAsc:
          return a.surface.compareTo(b.surface);
        case ApartmentSortOption.surfaceDesc:
          return b.surface.compareTo(a.surface);
        case ApartmentSortOption.ratingDesc:
          return b.rating.compareTo(a.rating);
        default:
          return a.pricePerDay.compareTo(b.pricePerDay);
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

  List<Apartment> _filterApartments(List<Apartment> apartments) {
    // Éviter le traitement multiple des mêmes appartements
    final uniqueApartments = {...apartments}.toList();

    // Ajoutez ce code au début de _filterApartments pour voir la plage de prix réelle
    final allPrices = uniqueApartments.map((a) => a.pricePerDay).toList();
    allPrices.sort();

    // Préparer une liste pour collecter les résultats filtrés
    final filteredApartments = <Apartment>[];

    for (final apartment in uniqueApartments) {
      bool passes = true;

      // Filtrer par ville (inchangé car c'est un critère fondamental)
      if (_currentFilters.city != null &&
          apartment.city != _currentFilters.city) {
        passes = false;
      }

      // Filtrer par quartier (inchangé car c'est un critère fondamental)
      if (passes &&
          _currentFilters.district != null &&
          apartment.district != _currentFilters.district) {
        passes = false;
      }

      // Filtrer par classe (inchangé car c'est une caractéristique fondamentale)
      if (passes &&
          _currentFilters.apartmentClass != null &&
          apartment.apartmentClass != _currentFilters.apartmentClass) {
        passes = false;
      }

      // Filtrer par plage de prix avec une marge de tolérance beaucoup plus large (±50%)
      if (passes && _currentFilters.priceRange != null) {
        final minPrice =
            _currentFilters.priceRange!.start * 0.5; // 50% de marge en dessous
        final maxPrice =
            _currentFilters.priceRange!.end * 1.5; // 50% de marge au-dessus

        if (apartment.pricePerDay < minPrice ||
            apartment.pricePerDay > maxPrice) {
          passes = false;
        }
      }

      // Filtrer par surface minimale avec une marge de tolérance de 20%
      if (passes &&
          _currentFilters.minSurface != null &&
          _currentFilters.minSurface! > 0) {
        final minSurfaceWithTolerance = _currentFilters.minSurface! * 0.8;
        if (apartment.surface < minSurfaceWithTolerance) {
          passes = false;
        }
      }

      // Filtrer par nombre minimum de chambres (permettre -1 chambre de tolérance)
      if (passes &&
          _currentFilters.minBedrooms != null &&
          _currentFilters.minBedrooms! > 1) {
        if (apartment.bedrooms < (_currentFilters.minBedrooms! - 1)) {
          passes = false;
        }
      }

      // Filtrer par disponibilité - avec une vérification de dates valides
      if (passes &&
          _currentFilters.startDate != null &&
          _currentFilters.endDate != null &&
          _currentFilters.showOnlyAvailable) {
        final today = DateTime.now();
        final validStartDate = _currentFilters.startDate!
            .isAfter(today.subtract(const Duration(days: 1)));
        final validEndDate =
            _currentFilters.endDate!.isAfter(_currentFilters.startDate!);

        if (validStartDate && validEndDate) {
          if (!apartment.isAvailableForPeriod(
              _currentFilters.startDate!, _currentFilters.endDate!)) {
            passes = false;
          }
        }
      }

      // Filtrer par commodités - assoupli pour exiger moins de commodités
      if (passes && _currentFilters.requiredAmenities != null) {
        final required = _currentFilters.requiredAmenities!;
        final amenities = apartment.amenities;

        // Compter combien de commodités requises sont absentes
        int missingAmenities = 0;

        if (required.hasWifi && !amenities.hasWifi) missingAmenities++;
        if (required.hasAirConditioning && !amenities.hasAirConditioning) {
          missingAmenities++;
        }
        if (required.hasParking && !amenities.hasParking) missingAmenities++;
        if (required.hasSecurity && !amenities.hasSecurity) missingAmenities++;
        if (required.hasPool && !amenities.hasPool) missingAmenities++;
        if (required.hasGym && !amenities.hasGym) missingAmenities++;
        if (required.hasBalcony && !amenities.hasBalcony) missingAmenities++;
        if (required.hasFurnished && !amenities.hasFurnished) {
          missingAmenities++;
        }

        // Tolérer jusqu'à 2 commodités manquantes
        if (missingAmenities > 2) {
          passes = false;
        }
      }

      if (passes) {
        filteredApartments.add(apartment);
      }
    }

    return filteredApartments;
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
            if (_currentFilters.startDate != null &&
                _currentFilters.endDate != null)
              Text(
                '${DateFormat('dd/MM/yyyy').format(_currentFilters.startDate!)} - ${DateFormat('dd/MM/yyyy').format(_currentFilters.endDate!)}',
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

            // Affichage du nombre de résultats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_apartments.length} résultat${_apartments.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  // Option pour afficher uniquement les disponibles
                  if (_currentFilters.startDate != null &&
                      _currentFilters.endDate != null)
                    Row(
                      children: [
                        const Text(
                          'Disponibles uniquement',
                          style: TextStyle(fontSize: 14),
                        ),
                        Switch(
                          value: _currentFilters.showOnlyAvailable,
                          onChanged: (value) {
                            setState(() {
                              _currentFilters = _currentFilters.copyWith(
                                showOnlyAvailable: value,
                              );
                            });
                            _loadApartments();
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                ],
              ),
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
                                    checkStartDate: _currentFilters.startDate,
                                    checkEndDate: _currentFilters.endDate,
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
    // Créer des filtres plus souples pour les suggestions
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
      showOnlyAvailable: false, // Inclure aussi les indisponibles
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
            if (apartment.pricePerDay < relaxedFilters.priceRange!.start ||
                apartment.pricePerDay > relaxedFilters.priceRange!.end) {
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
          if (_currentFilters.showOnlyAvailable &&
              _currentFilters.startDate != null &&
              _currentFilters.endDate != null) ...[
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _currentFilters = _currentFilters.copyWith(
                    showOnlyAvailable: false,
                  );
                });
                _loadApartments();
              },
              icon: const Icon(Icons.search),
              label: const Text('Voir aussi les appartements indisponibles'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
          ],
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
                    checkStartDate: _currentFilters.startDate,
                    checkEndDate: _currentFilters.endDate,
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

  void _showApartmentDetails(Apartment apartment) {
    // Naviguer vers l'écran de détails avec les dates sélectionnées
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ApartmentDetailsScreen(
          apartment: apartment,
          initialStartDate: _currentFilters.startDate,
          initialEndDate: _currentFilters.endDate,
        ),
      ),
    );
  }
}
