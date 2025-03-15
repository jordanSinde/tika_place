import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/theme/app_colors.dart';
import '../../../core/utils/snack_bar_utils.dart';
import '../data/hotels_mock_data.dart';
import '../models/models.dart';
import 'hotel_detail_screen.dart';

class HotelListScreen extends StatefulWidget {
  final HotelSearchFilters initialFilters;

  const HotelListScreen({
    super.key,
    required this.initialFilters,
  });

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  late HotelSearchFilters _currentFilters;
  HotelSortOption _currentSortOption = HotelSortOption.recommended;
  bool _isFilterExpanded = false;
  bool _isLoading = false;
  List<Hotel> _hotels = [];

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters;
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    setState(() => _isLoading = true);

    try {
      // Simuler un chargement asynchrone
      await Future.delayed(const Duration(seconds: 1));

      final allHotels = generateMockHotels();
      final filteredHotels = _filterHotels(allHotels);

      setState(() {
        _hotels = _sortHotels(filteredHotels);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Gérer l'erreur
    }
  }

  List<Hotel> _filterHotels(List<Hotel> hotels) {
    // Filtrage souple - la ville est le seul critère strict
    return hotels.where((hotel) {
      // Vérifier la ville (critère strict)
      if (_currentFilters.city != null && hotel.city != _currentFilters.city) {
        return false;
      }

      // Filtrage souple pour les autres critères
      int matchScore = 0;
      int possibleMatches = 0;

      // Vérifier le pays
      if (_currentFilters.country != null) {
        possibleMatches++;
        if (hotel.country == _currentFilters.country) {
          matchScore++;
        }
      }

      // Vérifier la catégorie d'étoiles
      if (_currentFilters.minStars != null) {
        possibleMatches++;
        if (hotel.starsCount >= _currentFilters.minStars!) {
          matchScore++;
        }
      }

      // Vérifier la note minimale
      if (_currentFilters.minRating != null) {
        possibleMatches++;
        if (hotel.rating >= _currentFilters.minRating!) {
          matchScore++;
        }
      }

      // Vérifier la disponibilité des chambres pour les dates demandées
      if (_currentFilters.checkInDate != null &&
          _currentFilters.checkOutDate != null) {
        possibleMatches++;

        // Récupérer les chambres disponibles
        final availableRooms = hotel.getAvailableRooms(
            _currentFilters.checkInDate!,
            _currentFilters.checkOutDate!,
            _currentFilters.adults,
            _currentFilters.children,
            _currentFilters.rooms);

        if (availableRooms.isNotEmpty) {
          matchScore++;
        }
      }

      // Vérifier les commodités requises
      if (_currentFilters.requiredAmenities != null) {
        final requiredAmenities = _currentFilters.requiredAmenities!;
        final hotelAmenities = hotel.amenities;

        // Critères de commodités
        if (requiredAmenities.hasWifi) {
          possibleMatches++;
          if (hotelAmenities.hasWifi) matchScore++;
        }
        if (requiredAmenities.hasPool) {
          possibleMatches++;
          if (hotelAmenities.hasPool) matchScore++;
        }
        // ... autres commodités
      }

      // Calculer le score de correspondance (0 à 100%)
      final matchPercentage =
          possibleMatches > 0 ? (matchScore / possibleMatches) * 100 : 100;

      // Accepter tous les hôtels qui ont au moins 30% de correspondance
      return matchPercentage >= 30;
    }).toList();
  }

  List<Hotel> _sortHotels(List<Hotel> hotels) {
    final sortedHotels = List<Hotel>.from(hotels);

    switch (_currentSortOption) {
      case HotelSortOption.priceAsc:
        sortedHotels.sort((a, b) {
          final aPrice = a.rooms
              .map((r) => r.pricePerNight)
              .reduce((min, p) => p < min ? p : min);
          final bPrice = b.rooms
              .map((r) => r.pricePerNight)
              .reduce((min, p) => p < min ? p : min);
          return aPrice.compareTo(bPrice);
        });
        break;
      case HotelSortOption.priceDesc:
        sortedHotels.sort((a, b) {
          final aPrice = a.rooms
              .map((r) => r.pricePerNight)
              .reduce((min, p) => p < min ? p : min);
          final bPrice = b.rooms
              .map((r) => r.pricePerNight)
              .reduce((min, p) => p < min ? p : min);
          return bPrice.compareTo(aPrice);
        });
        break;
      case HotelSortOption.ratingDesc:
        sortedHotels.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case HotelSortOption.starsDesc:
        sortedHotels.sort((a, b) => b.starsCount.compareTo(a.starsCount));
        break;
      case HotelSortOption.recommended:
      default:
        // Trier par score de correspondance (calculé à partir des filtres)
        // Puis par note, puis par étoiles
        sortedHotels.sort((a, b) {
          // Calculer le score de correspondance
          int aScore = _calculateMatchScore(a);
          int bScore = _calculateMatchScore(b);

          if (aScore != bScore) {
            return bScore.compareTo(aScore);
          }

          // Si même score, comparer par note
          if (a.rating != b.rating) {
            return b.rating.compareTo(a.rating);
          }

          // Si même note, comparer par étoiles
          return b.starsCount.compareTo(a.starsCount);
        });
        break;
    }

    return sortedHotels;
  }

  int _calculateMatchScore(Hotel hotel) {
    // On pourrait implémenter un algorithme plus sophistiqué ici
    int score = 0;

    // Bonus pour les étoiles
    score += hotel.starsCount * 2;

    // Bonus pour la note
    score += (hotel.rating * 5).round();

    // Bonus pour les chambres disponibles adaptées aux critères
    if (_currentFilters.checkInDate != null &&
        _currentFilters.checkOutDate != null) {
      final availableRooms = hotel.getAvailableRooms(
          _currentFilters.checkInDate!,
          _currentFilters.checkOutDate!,
          _currentFilters.adults,
          _currentFilters.children,
          _currentFilters.rooms);

      score += availableRooms.length * 3;
    }

    return score;
  }

  // Reste du code pour l'UI de la liste d'hôtels
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
            const Text('Hôtels disponibles'),
            if (_currentFilters.city != null)
              Text(
                '${_currentFilters.country != null ? "${_currentFilters.country} - " : ""}${_currentFilters.city}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (_currentFilters.checkInDate != null &&
                _currentFilters.checkOutDate != null)
              Text(
                '${DateFormat('dd/MM/yyyy').format(_currentFilters.checkInDate!)} - ${DateFormat('dd/MM/yyyy').format(_currentFilters.checkOutDate!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
                _isFilterExpanded ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Panneau de filtres extensible
          if (_isFilterExpanded)
            Container(
              constraints: const BoxConstraints(maxHeight: 500),
              child: SingleChildScrollView(
                child: HotelFilterPanel(
                  initialFilters: _currentFilters,
                  onFiltersChanged: (newFilters) {
                    setState(() {
                      _currentFilters = newFilters;
                    });
                    _loadHotels();
                  },
                ),
              ),
            ),

          // Sélecteur de tri
          HotelSortSelector(
            selectedOption: _currentSortOption,
            onSortChanged: (option) {
              setState(() {
                _currentSortOption = option;
                _hotels = _sortHotels(_hotels);
              });
            },
          ),

          // Nombre de résultats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_hotels.length} résultat${_hotels.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Liste des hôtels
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hotels.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _hotels.length,
                        itemBuilder: (context, index) {
                          final hotel = _hotels[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: HotelCard(
                              hotel: hotel,
                              checkInDate: _currentFilters.checkInDate,
                              checkOutDate: _currentFilters.checkOutDate,
                              adults: _currentFilters.adults,
                              children: _currentFilters.children,
                              rooms: _currentFilters.rooms,
                              onPressed: () =>
                                  SnackbarUtils.showComingSoonMessage(
                                      context), //_showHotelDetails(hotel),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    // Code pour afficher un message quand aucun hôtel n'est trouvé
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hotel, size: 64, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(
            'Aucun hôtel ne correspond à vos critères',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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
            ),
          ),
        ],
      ),
    );
  }

  void _showHotelDetails(Hotel hotel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HotelDetailsScreen(
          hotel: hotel,
          initialCheckInDate: _currentFilters.checkInDate,
          initialCheckOutDate: _currentFilters.checkOutDate,
          initialAdults: _currentFilters.adults,
          initialChildren: _currentFilters.children,
          initialRooms: _currentFilters.rooms,
        ),
      ),
    );
  }
}

enum HotelSortOption {
  recommended('Recommandés'),
  priceAsc('Prix croissant'),
  priceDesc('Prix décroissant'),
  ratingDesc('Mieux notés'),
  starsDesc('Plus d\'étoiles');

  final String label;
  const HotelSortOption(this.label);
}

// Composant de carte d'hôtel pour la liste
class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int adults;
  final int children;
  final int rooms;
  final VoidCallback onPressed;

  const HotelCard({
    super.key,
    required this.hotel,
    this.checkInDate,
    this.checkOutDate,
    this.adults = 1,
    this.children = 0,
    this.rooms = 1,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Vérifier si nous avons des chambres disponibles pour la période
    final hasDateRange = checkInDate != null && checkOutDate != null;
    final availableRooms = hasDateRange
        ? hotel.getAvailableRooms(
            checkInDate!,
            checkOutDate!,
            adults,
            children,
            rooms,
          )
        : [];

    // Obtenir le prix le plus bas parmi les chambres disponibles
    final lowestPrice = hasDateRange && availableRooms.isNotEmpty
        ? availableRooms
            .map((r) => r.pricePerNight)
            .reduce((min, p) => p < min ? p : min)
        : hotel.rooms
            .map((r) => r.pricePerNight)
            .reduce((min, p) => p < min ? p : min);

    // Calculer le prix total pour la période
    final days =
        hasDateRange ? checkOutDate!.difference(checkInDate!).inDays : 1;
    final totalPrice = lowestPrice * days;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image with placeholder
                    Image.network(
                      hotel.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.background,
                        child: const Icon(
                          Icons.hotel,
                          size: 48,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    // Badges
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _buildBadge(
                        text: '${hotel.starsCount} ★',
                        color: Colors.white.withOpacity(0.9),
                        textColor: AppColors.primary,
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _buildBadge(
                        text: '${hotel.rating}',
                        icon: Icons.star,
                        color: AppColors.secondary.withOpacity(0.9),
                        textColor: Colors.white,
                      ),
                    ),
                    // Availability badge
                    if (hasDateRange)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: _buildBadge(
                          text: availableRooms.isNotEmpty
                              ? 'Disponible'
                              : 'Indisponible',
                          icon: availableRooms.isNotEmpty
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: availableRooms.isNotEmpty
                              ? Colors.green.withOpacity(0.9)
                              : Colors.red.withOpacity(0.9),
                          textColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${hotel.address}, ${hotel.city}, ${hotel.country}',
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildAmenityChips(hotel.amenities),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${NumberFormat('#,###').format(totalPrice)} FCFA',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        Text(
                          'pour $days ${days > 1 ? 'nuits' : 'nuit'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Voir détails',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required String text,
    IconData? icon,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChips(HotelAmenities amenities) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (amenities.hasWifi) _buildAmenityChip(Icons.wifi, 'WiFi'),
        if (amenities.hasPool) _buildAmenityChip(Icons.pool, 'Piscine'),
        if (amenities.hasRestaurant)
          _buildAmenityChip(Icons.restaurant, 'Restaurant'),
        if (amenities.hasParking)
          _buildAmenityChip(Icons.local_parking, 'Parking'),
      ],
    );
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Sélecteur de tri
class HotelSortSelector extends StatelessWidget {
  final HotelSortOption selectedOption;
  final Function(HotelSortOption) onSortChanged;

  const HotelSortSelector({
    super.key,
    required this.selectedOption,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Row(
            children: [
              const Icon(Icons.sort, color: AppColors.textLight),
              const SizedBox(width: 8),
              Text(
                'Trier par',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          trailing: PopupMenuButton<HotelSortOption>(
            initialValue: selectedOption,
            onSelected: onSortChanged,
            itemBuilder: (context) => HotelSortOption.values
                .map((option) => _buildSortMenuItem(context, option))
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedOption.label,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  PopupMenuItem<HotelSortOption> _buildSortMenuItem(
    BuildContext context,
    HotelSortOption option,
  ) {
    IconData getIconForOption() {
      switch (option) {
        case HotelSortOption.recommended:
          return Icons.thumb_up;
        case HotelSortOption.priceAsc:
          return Icons.arrow_upward;
        case HotelSortOption.priceDesc:
          return Icons.arrow_downward;
        case HotelSortOption.ratingDesc:
          return Icons.star;
        case HotelSortOption.starsDesc:
          return Icons.hotel_class;
      }
    }

    return PopupMenuItem<HotelSortOption>(
      value: option,
      child: Row(
        children: [
          Icon(
            getIconForOption(),
            color: selectedOption == option ? AppColors.secondary : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            option.label,
            style: TextStyle(
              color: selectedOption == option ? AppColors.secondary : null,
              fontWeight: selectedOption == option ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}

// Panneau de filtre pour les hôtels
class HotelFilterPanel extends StatefulWidget {
  final HotelSearchFilters initialFilters;
  final Function(HotelSearchFilters) onFiltersChanged;

  const HotelFilterPanel({
    super.key,
    required this.initialFilters,
    required this.onFiltersChanged,
  });

  @override
  State<HotelFilterPanel> createState() => _HotelFilterPanelState();
}

class _HotelFilterPanelState extends State<HotelFilterPanel> {
  late HotelSearchFilters _filters;
  late RangeValues _priceRange;
  int? _minStars;
  double? _minRating;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _adults = 1;
  int _children = 0;
  int _rooms = 1;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _priceRange = _filters.priceRange ?? const RangeValues(5000, 100000);
    _minStars = _filters.minStars;
    _minRating = _filters.minRating;
    _checkInDate = _filters.checkInDate;
    _checkOutDate = _filters.checkOutDate;
    _adults = _filters.adults;
    _children = _filters.children;
    _rooms = _filters.rooms;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Prix
          _buildSectionTitle('Prix par nuit (FCFA)'),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${NumberFormat('#,###').format(_priceRange.start.round())} FCFA',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  Text(
                    '${NumberFormat('#,###').format(_priceRange.end.round())} FCFA',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
              RangeSlider(
                values: _priceRange,
                min: 5000,
                max: 100000,
                divisions: 19,
                labels: RangeLabels(
                  '${_priceRange.start.round()} FCFA',
                  '${_priceRange.end.round()} FCFA',
                ),
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
                activeColor: AppColors.success,
                inactiveColor: AppColors.background,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Étoiles
          _buildSectionTitle('Catégorie d\'hôtel'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [1, 2, 3, 4, 5].map((stars) {
              return FilterChip(
                label: Text('$stars★'),
                selected: _minStars == stars,
                onSelected: (selected) {
                  setState(() {
                    _minStars = selected ? stars : null;
                  });
                },
                selectedColor: AppColors.success,
                backgroundColor: AppColors.background,
                labelStyle: TextStyle(
                  color: _minStars == stars
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Note minimale
          _buildSectionTitle('Note minimale'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [7.0, 8.0, 9.0].map((rating) {
              return FilterChip(
                label: Text('$rating+'),
                selected: _minRating == rating,
                onSelected: (selected) {
                  setState(() {
                    _minRating = selected ? rating : null;
                  });
                },
                selectedColor: AppColors.success,
                backgroundColor: AppColors.background,
                labelStyle: TextStyle(
                  color: _minRating == rating
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Dates de séjour
          _buildSectionTitle('Dates de séjour'),
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  label: 'Arrivée',
                  date: _checkInDate,
                  onDateSelected: (date) {
                    setState(() {
                      _checkInDate = date;
                      // Mettre à jour la date de départ si nécessaire
                      if (_checkOutDate != null &&
                          _checkOutDate!.isBefore(_checkInDate!)) {
                        _checkOutDate =
                            _checkInDate!.add(const Duration(days: 1));
                      }
                    });
                  },
                  minDate: DateTime.now(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateSelector(
                  label: 'Départ',
                  date: _checkOutDate,
                  onDateSelected: (date) {
                    setState(() {
                      _checkOutDate = date;
                    });
                  },
                  minDate: _checkInDate?.add(const Duration(days: 1)) ??
                      DateTime.now().add(const Duration(days: 1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Voyageurs et chambres
          _buildSectionTitle('Voyageurs et chambres'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Adultes
                _buildCounter(
                  icon: Icons.person,
                  label: 'Adultes',
                  value: _adults,
                  onDecrement: _adults > 1
                      ? () {
                          setState(() {
                            _adults--;
                          });
                        }
                      : null,
                  onIncrement: () {
                    setState(() {
                      _adults++;
                    });
                  },
                ),
                const Divider(height: 24),

                // Enfants
                _buildCounter(
                  icon: Icons.child_care,
                  label: 'Enfants',
                  value: _children,
                  onDecrement: _children > 0
                      ? () {
                          setState(() {
                            _children--;
                          });
                        }
                      : null,
                  onIncrement: () {
                    setState(() {
                      _children++;
                    });
                  },
                ),
                const Divider(height: 24),

                // Chambres
                _buildCounter(
                  icon: Icons.hotel,
                  label: 'Chambres',
                  value: _rooms,
                  onDecrement: _rooms > 1
                      ? () {
                          setState(() {
                            _rooms--;
                          });
                        }
                      : null,
                  onIncrement: () {
                    setState(() {
                      _rooms++;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Commodités
          _buildSectionTitle('Commodités'),
          _buildAmenitiesFilter(),
          const SizedBox(height: 24),

          // Bouton Appliquer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final updatedFilters = HotelSearchFilters(
                  country: _filters.country,
                  city: _filters.city,
                  checkInDate: _checkInDate,
                  checkOutDate: _checkOutDate,
                  adults: _adults,
                  children: _children,
                  rooms: _rooms,
                  priceRange: _priceRange,
                  minStars: _minStars,
                  minRating: _minRating,
                  requiredAmenities: _filters.requiredAmenities,
                );

                widget.onFiltersChanged(updatedFilters);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Appliquer les filtres',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required Function(DateTime) onDateSelected,
    required DateTime minDate,
  }) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: date ?? minDate,
          firstDate: minDate,
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  onSurface: AppColors.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: 12),
                Text(
                  date != null ? dateFormat.format(date) : 'Sélectionner',
                  style: TextStyle(
                    color: date != null
                        ? AppColors.textPrimary
                        : AppColors.textLight.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounter({
    required IconData icon,
    required String label,
    required int value,
    required VoidCallback? onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textLight),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_circle_outline),
          color: onDecrement != null ? AppColors.primary : AppColors.textLight,
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add_circle_outline),
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildAmenitiesFilter() {
    final currentAmenities =
        _filters.requiredAmenities ?? const HotelAmenities();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildAmenityChip(
          'Wifi',
          Icons.wifi,
          currentAmenities.hasWifi,
          (selected) => _updateAmenities(hasWifi: selected),
        ),
        _buildAmenityChip(
          'Piscine',
          Icons.pool,
          currentAmenities.hasPool,
          (selected) => _updateAmenities(hasPool: selected),
        ),
        _buildAmenityChip(
          'Restaurant',
          Icons.restaurant,
          currentAmenities.hasRestaurant,
          (selected) => _updateAmenities(hasRestaurant: selected),
        ),
        _buildAmenityChip(
          'Parking',
          Icons.local_parking,
          currentAmenities.hasParking,
          (selected) => _updateAmenities(hasParking: selected),
        ),
        _buildAmenityChip(
          'Spa',
          Icons.spa,
          currentAmenities.hasSpa,
          (selected) => _updateAmenities(hasSpa: selected),
        ),
        _buildAmenityChip(
          'Fitness',
          Icons.fitness_center,
          currentAmenities.hasFitnessCenter,
          (selected) => _updateAmenities(hasFitnessCenter: selected),
        ),
        _buildAmenityChip(
          'Clim',
          Icons.ac_unit,
          currentAmenities.hasAirConditioning,
          (selected) => _updateAmenities(hasAirConditioning: selected),
        ),
      ],
    );
  }

  Widget _buildAmenityChip(
    String label,
    IconData icon,
    bool selected,
    Function(bool) onSelected,
  ) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected ? Colors.white : AppColors.textLight,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.success,
      backgroundColor: AppColors.background,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  void _updateAmenities({
    bool? hasWifi,
    bool? hasPool,
    bool? hasRestaurant,
    bool? hasFitnessCenter,
    bool? hasSpa,
    bool? hasRoomService,
    bool? hasAirConditioning,
    bool? hasParking,
  }) {
    final currentAmenities =
        _filters.requiredAmenities ?? const HotelAmenities();

    final newAmenities = HotelAmenities(
      hasWifi: hasWifi ?? currentAmenities.hasWifi,
      hasPool: hasPool ?? currentAmenities.hasPool,
      hasRestaurant: hasRestaurant ?? currentAmenities.hasRestaurant,
      hasFitnessCenter: hasFitnessCenter ?? currentAmenities.hasFitnessCenter,
      hasSpa: hasSpa ?? currentAmenities.hasSpa,
      hasRoomService: hasRoomService ?? currentAmenities.hasRoomService,
      hasAirConditioning:
          hasAirConditioning ?? currentAmenities.hasAirConditioning,
      hasParking: hasParking ?? currentAmenities.hasParking,
    );

    setState(() {
      _filters = _filters.copyWith(requiredAmenities: newAmenities);
    });
  }
}
