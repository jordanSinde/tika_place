// lib/features/apartment/screens/apartment_details_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/config/theme/app_colors.dart';
import '../booking_form_field.dart';
import '../models/apartment_mock_data.dart';

class ApartmentDetailsScreen extends StatefulWidget {
  final Apartment apartment;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const ApartmentDetailsScreen({
    super.key,
    required this.apartment,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<ApartmentDetailsScreen> createState() => _ApartmentDetailsScreenState();
}

class _ApartmentDetailsScreenState extends State<ApartmentDetailsScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  // Variables pour la sélection de date
  late DateTime? _startDate;
  late DateTime? _endDate;
  late bool _isAvailable;
  late DateTime? _nextAvailableDate;

  @override
  void initState() {
    super.initState();

    // Initialiser les dates
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;

    // Vérifier la disponibilité
    _updateAvailabilityInfo();
  }

  void _updateAvailabilityInfo() {
    if (_startDate != null && _endDate != null) {
      _isAvailable =
          widget.apartment.isAvailableForPeriod(_startDate!, _endDate!);
      if (!_isAvailable) {
        _nextAvailableDate =
            widget.apartment.getNextAvailableDateAfter(_startDate!);
      } else {
        _nextAvailableDate = null;
      }
    } else {
      _isAvailable = true;
      _nextAvailableDate = null;
    }
  }

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
                      const SizedBox(height: 16),

                      // Nouvelle section - Sélection de dates
                      _buildDateSelectionSection(),
                      const SizedBox(height: 16),

                      // Nouvelle section - Disponibilité
                      if (_startDate != null && _endDate != null)
                        _buildAvailabilitySection(),
                      const SizedBox(height: 24),

                      _buildFeatures(),
                      const SizedBox(height: 24),
                      _buildDescription(),
                      const SizedBox(height: 24),
                      _buildAmenities(),
                      const SizedBox(height: 24),

                      // Nouvelle section - Avis et commentaires
                      _buildReviewsSection(),
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
        onPressed: () => context.pop(),
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
                    '${widget.apartment.rating} (${widget.apartment.reviews.length} avis)',
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
              '${NumberFormat('#,###').format(widget.apartment.pricePerDay)} FCFA',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            Text(
              ' / jour',
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

  Widget _buildDateSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dates de séjour',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(
                label: 'Arrivée',
                date: _startDate,
                onDateSelected: (date) {
                  setState(() {
                    _startDate = date;

                    // Mettre à jour la date de fin si nécessaire
                    if (_endDate != null && _endDate!.isBefore(_startDate!)) {
                      _endDate = _startDate!.add(const Duration(days: 1));
                    }

                    _updateAvailabilityInfo();
                  });
                },
                minDate: DateTime.now(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateSelector(
                label: 'Départ',
                date: _endDate,
                onDateSelected: (date) {
                  setState(() {
                    _endDate = date;
                    _updateAvailabilityInfo();
                  });
                },
                minDate: _startDate?.add(const Duration(days: 1)) ??
                    DateTime.now().add(const Duration(days: 1)),
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildAvailabilitySection() {
    if (_startDate == null || _endDate == null) return const SizedBox.shrink();

    final days = _endDate!.difference(_startDate!).inDays;
    final totalPrice = widget.apartment.pricePerDay * days;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isAvailable
            ? AppColors.success.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isAvailable ? Icons.check_circle : Icons.cancel,
                color: _isAvailable ? AppColors.success : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                _isAvailable
                    ? 'Disponible pour vos dates'
                    : 'Non disponible pour vos dates',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isAvailable ? AppColors.success : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isAvailable) ...[
            Text(
              'Total pour $days ${days > 1 ? 'jours' : 'jour'}: ${NumberFormat('#,###').format(totalPrice)} FCFA',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else if (_nextAvailableDate != null) ...[
            Text(
              'Prochaine disponibilité: ${DateFormat('dd/MM/yyyy').format(_nextAvailableDate!)}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _startDate = _nextAvailableDate;
                  _endDate = _startDate!.add(Duration(days: days));
                  _updateAvailabilityInfo();
                });
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Réserver pour ces dates'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
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

  Widget _buildReviewsSection() {
    final reviews = widget.apartment.reviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Avis et commentaires',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
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
                    widget.apartment.rating.toString(),
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
        if (reviews.isEmpty)
          const Text(
            'Aucun avis pour le moment.',
            style: TextStyle(
              color: AppColors.textLight,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length > 3 ? 3 : reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return _buildReviewItem(review);
            },
          ),
        if (reviews.length > 3) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // Afficher tous les avis
              _showAllReviews();
            },
            child: Text(
              'Voir tous les ${reviews.length} avis',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewItem(ApartmentReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(review.userAvatar),
                radius: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(review.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      review.rating.toString(),
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showAllReviews() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tous les avis (${widget.apartment.reviews.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: widget.apartment.reviews.length,
                    itemBuilder: (context, index) {
                      return _buildReviewItem(widget.apartment.reviews[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
          /*IconButton(
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
          ),*/
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    // Prix total pour la période sélectionnée
    final String priceText;
    final String priceSubtext;
    final bool canBook = _isAvailable && _startDate != null && _endDate != null;

    if (_startDate != null && _endDate != null) {
      final days = _endDate!.difference(_startDate!).inDays;
      final totalPrice = widget.apartment.pricePerDay * days;

      priceText = '${NumberFormat('#,###').format(totalPrice)} FCFA';
      priceSubtext = 'pour $days ${days > 1 ? 'jours' : 'jour'}';
    } else {
      priceText =
          '${NumberFormat('#,###').format(widget.apartment.pricePerDay)} FCFA';
      priceSubtext = 'par jour';
    }

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
                  priceText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                Text(
                  priceSubtext,
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
              onPressed: canBook ? () => _showBookingDialog() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                disabledBackgroundColor: AppColors.background,
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
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner des dates de séjour'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final days = _endDate!.difference(_startDate!).inDays;
    final totalPrice = widget.apartment.pricePerDay * days;

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Détails de la réservation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Arrivée:'),
                        Text(
                          DateFormat('dd/MM/yyyy').format(_startDate!),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Départ:'),
                        Text(
                          DateFormat('dd/MM/yyyy').format(_endDate!),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Durée:'),
                        Text(
                          '$days ${days > 1 ? 'jours' : 'jour'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:'),
                        Text(
                          '${NumberFormat('#,###').format(totalPrice)} FCFA',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
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
    final days = _endDate!.difference(_startDate!).inDays;
    final totalPrice = widget.apartment.pricePerDay * days;

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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Récapitulatif de votre réservation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Appartement:'),
                      Flexible(
                        child: Text(
                          widget.apartment.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dates:'),
                      Text(
                        '${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Durée:'),
                      Text(
                        '$days ${days > 1 ? 'jours' : 'jour'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Montant total:'),
                      Text(
                        '${NumberFormat('#,###').format(totalPrice)} FCFA',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
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
