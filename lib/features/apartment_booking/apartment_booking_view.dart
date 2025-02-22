// lib/features/home/widgets/apartment_booking/apartment_booking_view.dart

// lib/features/apartment_booking/screens/apartment_booking_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';
import 'data/mock_data.dart';
import 'models/apartment_filters.dart';
import 'widgets/apartment_card.dart';

class ApartmentBookingView extends ConsumerStatefulWidget {
  const ApartmentBookingView({super.key});

  @override
  ConsumerState<ApartmentBookingView> createState() =>
      _ApartmentBookingViewState();
}

class _ApartmentBookingViewState extends ConsumerState<ApartmentBookingView> {
  List<Apartment> _featuredApartments = [];
  final List<String> _cities = cities;

  @override
  void initState() {
    super.initState();
    // Charger quelques appartements pour la présentation
    _featuredApartments = generateApartments(count: 5);
  }

  void _handleSearch(ApartmentSearchFilters filters) {
    context.go('/apartments/list', extra: {'filters': filters});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trouvez votre appartement idéal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Formulaire de recherche rapide
                _buildQuickSearchForm(),
              ],
            ),
          ),

          // Section des appartements en vedette
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Appartements en vedette',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          _handleSearch(const ApartmentSearchFilters()),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 340,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _featuredApartments.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 16),
                        child: ApartmentCard(
                          apartment: _featuredApartments[index],
                          onTap: () =>
                              _showApartmentDetails(_featuredApartments[index]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Section des villes populaires
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Villes populaires',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPopularCities(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSearchForm() {
    String? selectedCity;
    return Column(
      children: [
        // Sélecteur de ville
        DropdownButtonFormField<String>(
          value: selectedCity,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Sélectionnez une ville',
            prefixIcon: const Icon(Icons.location_city),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: _cities.map((city) {
            return DropdownMenuItem(
              value: city,
              child: Text(city),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCity = value;
            });
          },
        ),
        const SizedBox(height: 16),

        // Bouton de recherche
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (selectedCity != null) {
                _handleSearch(ApartmentSearchFilters(
                  city: selectedCity,
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez sélectionner une ville'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Rechercher',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularCities() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: _cities.map((city) {
        return InkWell(
          onTap: () => _handleSearch(ApartmentSearchFilters(city: city)),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage('assets/images/cities/$city.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Center(
              child: Text(
                city,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showApartmentDetails(Apartment apartment) {
    // TODO: Implémenter la navigation vers les détails
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Détails de l\'appartement à venir'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
/*
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/theme/app_colors.dart';
import '../home/models/apartment_mock_data.dart';
import 'apartment_search_card.dart';
import 'booking_form_field.dart';

final selectedApartmentFiltersProvider =
    StateProvider<Set<String>>((ref) => {});

class ApartmentBookingView extends ConsumerStatefulWidget {
  const ApartmentBookingView({super.key});

  @override
  ConsumerState<ApartmentBookingView> createState() =>
      _ApartmentBookingViewState();
}

class _ApartmentBookingViewState extends ConsumerState<ApartmentBookingView> {
  final List<String> _filters = [
    'Wifi',
    'Climatisation',
    'Parking',
    'Sécurité',
    'Meublé',
    'Balcon',
  ];

  List<Apartment> _filteredApartments = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredApartments = mockApartments;
  }

  void _handleSearch(Map<String, dynamic> searchParams) {
    setState(() => _isSearching = true);

    // Simuler une recherche asynchrone
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _filteredApartments = mockApartments.where((apartment) {
          final isInPriceRange =
              apartment.price >= searchParams['priceRange'].start &&
                  apartment.price <= searchParams['priceRange'].end;
          final isInCity = apartment.location.toLowerCase().contains(
                searchParams['city'].toString().toLowerCase(),
              );
          final hasEnoughBedrooms =
              apartment.bedrooms >= searchParams['bedrooms'];
          final hasEnoughSurface =
              apartment.surface >= searchParams['minSurface'];
          final matchesRentalType =
              apartment.rentalType == searchParams['rentalType'];
          final hasSelectedAmenities = ref
              .read(selectedApartmentFiltersProvider)
              .every((filter) => apartment.amenities.contains(filter));

          return isInPriceRange &&
              isInCity &&
              hasEnoughBedrooms &&
              hasEnoughSurface &&
              matchesRentalType &&
              hasSelectedAmenities;
        }).toList();

        _isSearching = false;
      });

      _showSearchResults();
    });
  }

  void _showSearchResults() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (_isSearching)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_filteredApartments.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Aucun appartement ne correspond à vos critères',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredApartments.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) => _buildApartmentCard(
                      _filteredApartments[index],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.all(8),
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }

// Fonction pour optimiser l'URL de l'image (exemple avec Cloudinary)
  String _getOptimizedImageUrl(String originalUrl) {
    // Si vous utilisez un service comme Cloudinary, vous pouvez ajouter
    // des paramètres pour optimiser l'image
    // Exemple : w_800,f_auto,q_auto
    if (originalUrl.contains('cloudinary')) {
      return originalUrl.replaceAll('/upload/', '/upload/w_800,f_auto,q_auto/');
    }
    return originalUrl;
  }

  Widget _buildApartmentCard(Apartment apartment) {
    return InkWell(
      onTap: () => _showApartmentDetails(apartment),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: _getOptimizedImageUrl(apartment.images[0]),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildImagePlaceholder(),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
                memCacheHeight: 400, // Optimise la mémoire cache
                maxHeightDiskCache: 400, // Optimise le cache disque
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              apartment.title,
                              style: const TextStyle(
                                fontSize: 18,
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
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    apartment.location,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${apartment.price.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            apartment.rentalType == RentalType.shortTerm
                                ? '/ nuit'
                                : '/ mois',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            apartment.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' (${apartment.reviews})',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildFeatureIndicator(
                            icon: Icons.king_bed_outlined,
                            value: apartment.bedrooms.toString(),
                          ),
                          const SizedBox(width: 16),
                          _buildFeatureIndicator(
                            icon: Icons.bathtub_outlined,
                            value: apartment.bathrooms.toString(),
                          ),
                          const SizedBox(width: 16),
                          _buildFeatureIndicator(
                            icon: Icons.square_foot,
                            value: '${apartment.surface}m²',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIndicator({
    required IconData icon,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showApartmentDetails(Apartment apartment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: apartment.images.length,
                  itemBuilder: (context, index) => Image.network(
                    apartment.images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                apartment.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      apartment.location,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                apartment.rating.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFeature(
                          icon: Icons.king_bed_outlined,
                          value: '${apartment.bedrooms}',
                          label: 'Chambres',
                        ),
                        _buildFeature(
                          icon: Icons.bathtub_outlined,
                          value: '${apartment.bathrooms}',
                          label: 'SdB',
                        ),
                        _buildFeature(
                          icon: Icons.square_foot,
                          value: '${apartment.surface}m²',
                          label: 'Surface',
                        ),
                        _buildFeature(
                          icon: Icons.timer_outlined,
                          value: apartment.rentalType.label,
                          label: 'Location',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      apartment.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Équipements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: apartment.amenities
                          .map((amenity) => Chip(
                                label: Text(amenity),
                                backgroundColor: AppColors.inputBackground,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Propriétaire',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(apartment.ownerAvatar),
                        radius: 24,
                      ),
                      title: Text(
                        apartment.ownerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${apartment.reviews} avis',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'La messagerie sera bientôt disponible!'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${apartment.price.toStringAsFixed(0)} FCFA',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                apartment.rentalType == RentalType.shortTerm
                                    ? '/ nuit'
                                    : '/ mois',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showBookingConfirmation(apartment);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Réserver'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Important !
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _filters.map((filter) {
              final isSelected =
                  ref.watch(selectedApartmentFiltersProvider).contains(filter);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    final filters = ref.read(selectedApartmentFiltersProvider);
                    if (selected) {
                      ref
                          .read(selectedApartmentFiltersProvider.notifier)
                          .state = {...filters, filter};
                    } else {
                      ref
                          .read(selectedApartmentFiltersProvider.notifier)
                          .state = filters.where((f) => f != filter).toSet();
                    }
                  },
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        ApartmentSearchCard(onSearch: _handleSearch),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'En Vedette',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: mockApartments
                      .take(3)
                      .map((apartment) => Container(
                            width: 300,
                            margin: const EdgeInsets.only(right: 16),
                            child: _buildApartmentCard(apartment),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBookingConfirmation(Apartment apartment) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final dateController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la réservation'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                apartment.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              BookingFormField(
                controller: nameController,
                label: 'Nom complet',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              BookingFormField(
                controller: phoneController,
                label: 'Numéro de téléphone',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer votre numéro';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              BookingFormField(
                controller: dateController,
                label: 'Date d\'entrée',
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    dateController.text =
                        '${date.day}/${date.month}/${date.year}';
                  }
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez sélectionner une date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              BookingFormField(
                controller: durationController,
                label: apartment.rentalType == RentalType.shortTerm
                    ? 'Nombre de nuits'
                    : 'Nombre de mois',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer la durée';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Prix : ${apartment.price.toStringAsFixed(0)} FCFA${apartment.rentalType == RentalType.shortTerm ? ' / nuit' : ' / mois'}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Réservation confirmée ! Un agent vous contactera bientôt.'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
*/