// lib/features/apartment/screens/apartment_details_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/config/theme/app_colors.dart';
import '../booking_form_field.dart';
import '../models/apartment_mock_data.dart';

class ApartmentDetailsScreen extends StatefulWidget {
  final Apartment apartment;

  const ApartmentDetailsScreen({
    super.key,
    required this.apartment,
  });

  @override
  State<ApartmentDetailsScreen> createState() => _ApartmentDetailsScreenState();
}

class _ApartmentDetailsScreenState extends State<ApartmentDetailsScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar avec image
          _buildSliverAppBar(),

          // Contenu
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations principales
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainInfo(),
                      const SizedBox(height: 16),
                      _buildLocation(),
                      const SizedBox(height: 24),
                      _buildFeatures(),
                      const SizedBox(height: 24),
                      _buildDescription(),
                      const SizedBox(height: 24),
                      _buildAmenities(),
                      const SizedBox(height: 24),
                      _buildOwnerInfo(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Carrousel d'images
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: widget.apartment.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  widget.apartment.images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.background,
                    child: const Icon(
                      Icons.apartment,
                      size: 64,
                      color: AppColors.textLight,
                    ),
                  ),
                );
              },
            ),

            // Indicateurs de page
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.apartment.images.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? AppColors.primary
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Implémenter le partage
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            // Implémenter les favoris
          },
        ),
      ],
    );
  }

  Widget _buildMainInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.apartment.apartmentClass.label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.apartment.rating} (${widget.apartment.reviews} avis)',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.apartment.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${NumberFormat('#,###').format(widget.apartment.price)} FCFA',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            Text(
              widget.apartment.rentalType == RentalType.shortTerm
                  ? ' / nuit'
                  : ' / mois',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Localisation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${widget.apartment.address}, ${widget.apartment.district}, ${widget.apartment.city}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildFeature(
          icon: Icons.king_bed_outlined,
          value: widget.apartment.bedrooms.toString(),
          label: 'Chambres',
        ),
        _buildFeature(
          icon: Icons.bathtub_outlined,
          value: widget.apartment.bathrooms.toString(),
          label: 'Salles de bain',
        ),
        _buildFeature(
          icon: Icons.square_foot,
          value: '${widget.apartment.surface.round()}',
          label: 'm²',
        ),
      ],
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
            fontSize: 16,
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

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.apartment.description,
          style: TextStyle(
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Équipements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ApartmentAmenitiesList(amenities: widget.apartment.amenities),
      ],
    );
  }

  Widget _buildOwnerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.apartment.ownerAvatar),
            radius: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.apartment.ownerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Propriétaire',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Implémenter le chat
            },
            icon: const Icon(Icons.chat_bubble_outline),
            color: AppColors.primary,
          ),
          IconButton(
            onPressed: () {
              // Implémenter l'appel
              _showCallDialog();
            },
            icon: const Icon(Icons.phone),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${NumberFormat('#,###').format(widget.apartment.price)} FCFA',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                Text(
                  widget.apartment.rentalType == RentalType.shortTerm
                      ? 'par nuit'
                      : 'par mois',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed: () => _showBookingDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Réserver',
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

  void _showCallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacter le propriétaire'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Voulez-vous appeler ${widget.apartment.ownerName} ?'),
            const SizedBox(height: 8),
            Text(
              widget.apartment.ownerPhone,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
              // Implémenter l'appel téléphonique
              Navigator.pop(context);
            },
            child: const Text('Appeler'),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final startDateController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réserver cet appartement'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              BookingFormField(
                controller: startDateController,
                label: 'Date d\'entrée',
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: widget.apartment.availableFrom,
                    firstDate: widget.apartment.availableFrom,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    startDateController.text =
                        DateFormat('dd/MM/yyyy').format(date);
                  }
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez sélectionner une date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              BookingFormField(
                controller: durationController,
                label: widget.apartment.rentalType == RentalType.shortTerm
                    ? 'Nombre de nuits'
                    : 'Nombre de mois',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer la durée';
                  }
                  final duration = int.tryParse(value!);
                  if (duration == null || duration < 1) {
                    return 'Durée invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Prix total: ${NumberFormat('#,###').format(widget.apartment.price)} FCFA${widget.apartment.rentalType == RentalType.shortTerm ? ' / nuit' : ' / mois'}',
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
                _showBookingConfirmation();
              }
            },
            child: const Text('Réserver'),
          ),
        ],
      ),
    );
  }

  void _showBookingConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réservation confirmée !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Votre demande de réservation a été envoyée avec succès.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Le propriétaire ${widget.apartment.ownerName} vous contactera bientôt pour finaliser la réservation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Retourner à la liste des appartements
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Widget séparé pour afficher les commodités
class ApartmentAmenitiesList extends StatelessWidget {
  final ApartmentAmenities amenities;

  const ApartmentAmenitiesList({
    super.key,
    required this.amenities,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (amenities.hasWifi) _buildAmenityChip(Icons.wifi, 'WiFi'),
        if (amenities.hasAirConditioning)
          _buildAmenityChip(Icons.ac_unit, 'Climatisation'),
        if (amenities.hasParking)
          _buildAmenityChip(Icons.local_parking, 'Parking'),
        if (amenities.hasSecurity)
          _buildAmenityChip(Icons.security, 'Sécurité'),
        if (amenities.hasPool) _buildAmenityChip(Icons.pool, 'Piscine'),
        if (amenities.hasGym)
          _buildAmenityChip(Icons.fitness_center, 'Salle de sport'),
        if (amenities.hasBalcony) _buildAmenityChip(Icons.balcony, 'Balcon'),
        if (amenities.hasFurnished) _buildAmenityChip(Icons.chair, 'Meublé'),
        if (amenities.hasWaterHeater)
          _buildAmenityChip(Icons.hot_tub, 'Chauffe-eau'),
        if (amenities.hasGenerator)
          _buildAmenityChip(Icons.power, 'Groupe électrogène'),
        if (amenities.hasServiceRoom)
          _buildAmenityChip(Icons.room_service, 'Chambre de service'),
        if (amenities.hasGarden) _buildAmenityChip(Icons.grass, 'Jardin'),
      ],
    );
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
