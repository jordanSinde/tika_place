import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/config/theme/app_colors.dart';
import '../models/models.dart';

class HotelDetailsScreen extends StatefulWidget {
  final Hotel hotel;
  final DateTime? initialCheckInDate;
  final DateTime? initialCheckOutDate;
  final int initialAdults;
  final int initialChildren;
  final int initialRooms;

  const HotelDetailsScreen({
    super.key,
    required this.hotel,
    this.initialCheckInDate,
    this.initialCheckOutDate,
    this.initialAdults = 1,
    this.initialChildren = 0,
    this.initialRooms = 1,
  });

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  // Variables pour la sélection de date et occupants
  late DateTime? _checkInDate;
  late DateTime? _checkOutDate;
  late int _adults;
  late int _children;
  late int _rooms;

  // Liste des chambres disponibles
  List<HotelRoom> _availableRooms = [];
  HotelRoom? _selectedRoom;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialiser les dates et occupants
    _checkInDate = widget.initialCheckInDate;
    _checkOutDate = widget.initialCheckOutDate;
    _adults = widget.initialAdults;
    _children = widget.initialChildren;
    _rooms = widget.initialRooms;

    // Charger les chambres disponibles
    _updateAvailableRooms();
  }

  void _updateAvailableRooms() {
    if (_checkInDate != null && _checkOutDate != null) {
      _availableRooms = widget.hotel.getAvailableRooms(
        _checkInDate!,
        _checkOutDate!,
        _adults,
        _children,
        _rooms,
      );

      // Réinitialiser la chambre sélectionnée si elle n'est plus disponible
      if (_selectedRoom != null && !_availableRooms.contains(_selectedRoom)) {
        _selectedRoom = null;
      }
    } else {
      _availableRooms = [];
      _selectedRoom = null;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar avec carrousel d'images
          _buildSliverAppBar(),

          // Contenu
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textLight,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: 'Vue d\'ensemble'),
                      Tab(text: 'Chambres'),
                      Tab(text: 'Infos & Tarifs'),
                      Tab(text: 'Avis'),
                    ],
                  ),
                ),

                // Tab Content
                SizedBox(
                  height: 1000, // Hauteur fixe pour le contenu du TabBarView
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildRoomsTab(),
                      _buildInfoTab(),
                      _buildReviewsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedRoom != null ? _buildBottomBar() : null,
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
              itemCount: widget.hotel.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  widget.hotel.images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.background,
                    child: const Icon(
                      Icons.hotel,
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
                  widget.hotel.images.length,
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

  // Onglet Vue d'ensemble
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et étoiles
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.hotel.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      widget.hotel.rating.toString(),
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

          // Catégorie d'étoiles
          Row(
            children: [
              ...List.generate(
                widget.hotel.starsCount,
                (index) =>
                    const Icon(Icons.star, color: Colors.amber, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.hotel.starsCount} étoiles',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Localisation
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
                  '${widget.hotel.address}, ${widget.hotel.city}, ${widget.hotel.country}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Dates et occupants
          _buildDateAndOccupantsSelector(),
          const SizedBox(height: 24),

          // Description
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.hotel.description,
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Commodités principales
          const Text(
            'Équipements principaux',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAmenitiesGrid(widget.hotel.amenities),
          const SizedBox(height: 24),

          // Chambres disponibles
          const Text(
            'Chambres disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _availableRooms.isEmpty
              ? _buildNoRoomsAvailable()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      _availableRooms.length > 3 ? 3 : _availableRooms.length,
                  itemBuilder: (context, index) {
                    return _buildRoomCard(_availableRooms[index]);
                  },
                ),

          if (_availableRooms.length > 3)
            TextButton(
              onPressed: () {
                _tabController.animateTo(1); // Aller à l'onglet des chambres
              },
              child: const Text('Voir toutes les chambres'),
            ),
          const SizedBox(height: 24),

          // Lien vers les avis
          InkWell(
            onTap: () {
              _tabController.animateTo(3); // Aller à l'onglet des avis
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.hotel.rating} (${widget.hotel.reviews.length} avis)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  // Onglet des chambres
  Widget _buildRoomsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sélecteur de dates et occupants
          _buildDateAndOccupantsSelector(),
          const SizedBox(height: 24),

          // Liste des chambres disponibles
          _availableRooms.isEmpty
              ? _buildNoRoomsAvailable()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _availableRooms.length,
                  itemBuilder: (context, index) {
                    return _buildRoomCard(_availableRooms[index]);
                  },
                ),
        ],
      ),
    );
  }

  // Onglet Infos et tarifs
  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Check-in / Check-out times
          const Text(
            'Horaires',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.login,
            'Check-in',
            'À partir de ${widget.hotel.checkInTime}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.logout,
            'Check-out',
            'Jusqu\'à ${widget.hotel.checkOutTime}',
          ),
          const SizedBox(height: 24),

          // Règles de la maison
          const Text(
            'Règles de la maison',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.hotel.houseRules.map((rule) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rule,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),

          // Toutes les commodités
          const Text(
            'Tous les équipements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAmenitiesGrid(widget.hotel.amenities, showAll: true),
          const SizedBox(height: 24),

          // Politique tarifaire
          const Text(
            'Politique tarifaire',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Les tarifs affichés sont pour 1 nuit et par chambre. Ils comprennent la TVA locale et toutes les taxes (sauf taxes de séjour qui peuvent être demandées à l\'arrivée). Les tarifs peuvent changer en fonction des dates.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Onglet des avis
  Widget _buildReviewsTab() {
    final reviews = widget.hotel.reviews;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.hotel.rating.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < widget.hotel.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reviews.length} avis',
                      style: const TextStyle(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Liste des avis
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
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(review.userAvatar),
                            radius: 20,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                DateFormat('dd/MM/yyyy').format(review.date),
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  review.rating.toString(),
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
                      const SizedBox(height: 12),
                      Text(
                        review.comment,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDateAndOccupantsSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBackground),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dates et occupants',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Arrivée',
                  date: _checkInDate,
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _checkInDate ??
                          DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        _checkInDate = pickedDate;
                        if (_checkOutDate != null &&
                            _checkOutDate!.isBefore(_checkInDate!)) {
                          _checkOutDate =
                              _checkInDate!.add(const Duration(days: 1));
                        }
                        _updateAvailableRooms();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  label: 'Départ',
                  date: _checkOutDate,
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _checkOutDate ??
                          (_checkInDate?.add(const Duration(days: 1)) ??
                              DateTime.now().add(const Duration(days: 2))),
                      firstDate: _checkInDate?.add(const Duration(days: 1)) ??
                          DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        _checkOutDate = pickedDate;
                        _updateAvailableRooms();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOccupantField(
                  label: 'Adultes',
                  value: _adults,
                  icon: Icons.person,
                  onTap: () {
                    _showOccupantsDialog();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOccupantField(
                  label: 'Chambres',
                  value: _rooms,
                  icon: Icons.hotel,
                  onTap: () {
                    _showOccupantsDialog();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_checkInDate != null && _checkOutDate != null) {
                  setState(() {
                    _updateAvailableRooms();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez sélectionner des dates'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Appliquer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.inputBackground),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? DateFormat('dd/MM/yyyy').format(date)
                      : 'Sélectionner',
                  style: TextStyle(
                    fontWeight:
                        date != null ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupantField({
    required String label,
    required int value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.inputBackground),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOccupantsDialog() {
    int tempAdults = _adults;
    int tempChildren = _children;
    int tempRooms = _rooms;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Voyageurs et chambres'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Adultes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Adultes'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: tempAdults > 1
                                ? () {
                                    setDialogState(() {
                                      tempAdults--;
                                    });
                                  }
                                : null,
                            color: tempAdults > 1
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                          Text(
                            tempAdults.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setDialogState(() {
                                tempAdults++;
                              });
                            },
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Enfants
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Enfants'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: tempChildren > 0
                                ? () {
                                    setDialogState(() {
                                      tempChildren--;
                                    });
                                  }
                                : null,
                            color: tempChildren > 0
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                          Text(
                            tempChildren.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setDialogState(() {
                                tempChildren++;
                              });
                            },
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Chambres
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Chambres'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: tempRooms > 1
                                ? () {
                                    setDialogState(() {
                                      tempRooms--;
                                    });
                                  }
                                : null,
                            color:
                                tempRooms > 1 ? AppColors.primary : Colors.grey,
                          ),
                          Text(
                            tempRooms.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setDialogState(() {
                                tempRooms++;
                              });
                            },
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _adults = tempAdults;
                      _children = tempChildren;
                      _rooms = tempRooms;
                      _updateAvailableRooms();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Appliquer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNoRoomsAvailable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.hotel_outlined,
            color: Colors.red,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'Aucune chambre disponible pour ces dates et occupants',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Veuillez modifier vos critères de recherche',
            style: TextStyle(
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(HotelRoom room) {
    final isSelected = _selectedRoom?.id == room.id;
    final days = _checkInDate != null && _checkOutDate != null
        ? _checkOutDate!.difference(_checkInDate!).inDays
        : 1;
    final totalPrice = room.pricePerNight * days;

    return GestureDetector(
      onTap: () {
        _showRoomDetailsDialog(room);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBackground,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de la chambre
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      room.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.background,
                        child: const Icon(
                          Icons.hotel_outlined,
                          size: 48,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    // Badge de type de chambre
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          room.type.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre de la chambre
                  Text(
                    room.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Type de lit
                  Row(
                    children: [
                      const Icon(Icons.bed,
                          size: 16, color: AppColors.textLight),
                      const SizedBox(width: 8),
                      Text(
                        room.bedType,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Capacité
                  Row(
                    children: [
                      const Icon(Icons.person,
                          size: 16, color: AppColors.textLight),
                      const SizedBox(width: 8),
                      Text(
                        'Max ${room.maxAdults} adulte(s), ${room.maxChildren} enfant(s)',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Surface
                  Row(
                    children: [
                      const Icon(Icons.square_foot,
                          size: 16, color: AppColors.textLight),
                      const SizedBox(width: 8),
                      Text(
                        '${room.roomSize} m²',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Commodités principales
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (room.amenities.hasWifi) _buildFeatureChip('WiFi'),
                      if (room.amenities.hasTV) _buildFeatureChip('TV'),
                      if (room.amenities.hasAirConditioning)
                        _buildFeatureChip('Climatisation'),
                      if (room.amenities.hasPrivateBathroom)
                        _buildFeatureChip('Salle de bain privée'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Politique d'annulation
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: room.refundable
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          room.refundable ? Icons.check_circle : Icons.info,
                          color: room.refundable ? Colors.green : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            room.refundable
                                ? 'Annulation gratuite'
                                : 'Non remboursable',
                            style: TextStyle(
                              fontSize: 14,
                              color: room.refundable
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Prix et bouton de sélection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${NumberFormat('#,###').format(totalPrice)} FCFA',
                            style: const TextStyle(
                              fontSize: 18,
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
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (isSelected) {
                              _selectedRoom = null;
                            } else {
                              _selectedRoom = room;
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? AppColors.primary
                              : AppColors.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isSelected ? 'Sélectionné' : 'Sélectionner',
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
    );
  }

  Widget _buildFeatureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  void _showRoomDetailsDialog(HotelRoom room) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image en haut
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                room.images.first,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Informations principales
                  _buildInfoRow(Icons.bed, 'Type de lit', room.bedType),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.person, 'Capacité',
                      'Max ${room.maxAdults} adulte(s), ${room.maxChildren} enfant(s)'),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      Icons.square_foot, 'Surface', '${room.roomSize} m²'),
                  const SizedBox(height: 16),

                  // Commodités
                  const Text(
                    'Équipements et services',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRoomAmenitiesList(room.amenities),
                  const SizedBox(height: 16),

                  // Politique d'annulation
                  const Text(
                    'Politique d\'annulation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: room.refundable
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      room.cancellationPolicy,
                      style: TextStyle(
                        color: room.refundable ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Boutons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Fermer'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedRoom = room;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                    ),
                    child: const Text('Sélectionner'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildRoomAmenitiesList(RoomAmenities amenities) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (amenities.hasWifi) _buildAmenityItem(Icons.wifi, 'WiFi'),
        if (amenities.hasTV) _buildAmenityItem(Icons.tv, 'TV'),
        if (amenities.hasMinibar) _buildAmenityItem(Icons.local_bar, 'Minibar'),
        if (amenities.hasSafe) _buildAmenityItem(Icons.lock, 'Coffre-fort'),
        if (amenities.hasPrivateBathroom)
          _buildAmenityItem(Icons.bathtub, 'Salle de bain privée'),
        if (amenities.hasAirConditioning)
          _buildAmenityItem(Icons.ac_unit, 'Climatisation'),
        if (amenities.hasBalcony) _buildAmenityItem(Icons.balcony, 'Balcon'),
        if (amenities.hasSeaView)
          _buildAmenityItem(Icons.beach_access, 'Vue sur mer'),
        if (amenities.hasCityView)
          _buildAmenityItem(Icons.location_city, 'Vue sur ville'),
        if (amenities.hasWorkDesk)
          _buildAmenityItem(Icons.laptop, 'Bureau de travail'),
      ],
    );
  }

  Widget _buildAmenityItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildBottomBar() {
    if (_selectedRoom == null ||
        _checkInDate == null ||
        _checkOutDate == null) {
      return const SizedBox.shrink();
    }

    final days = _checkOutDate!.difference(_checkInDate!).inDays;
    final totalPrice = _selectedRoom!.pricePerNight * days;

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
                  '${NumberFormat('#,###').format(totalPrice)} FCFA',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                Text(
                  'pour $days ${days > 1 ? 'nuits' : 'nuit'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showBookingDialog();
              },
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

  void _showBookingDialog() {
    if (_selectedRoom == null ||
        _checkInDate == null ||
        _checkOutDate == null) {
      return;
    }

    final days = _checkOutDate!.difference(_checkInDate!).inDays;
    final totalPrice = _selectedRoom!.pricePerNight * days;

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réserver cette chambre'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom complet',
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Numéro de téléphone',
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
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
                          const Text('Hôtel:'),
                          Flexible(
                            child: Text(
                              widget.hotel.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Chambre:'),
                          Flexible(
                            child: Text(
                              _selectedRoom!.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Arrivée:'),
                          Text(
                            DateFormat('dd/MM/yyyy').format(_checkInDate!),
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
                            DateFormat('dd/MM/yyyy').format(_checkOutDate!),
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
                            '$days ${days > 1 ? 'nuits' : 'nuit'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Voyageurs:'),
                          Text(
                            '$_adults adulte(s), $_children enfant(s)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Chambres:'),
                          Text(
                            '$_rooms',
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: const Text('Réserver'),
          ),
        ],
      ),
    );
  }

  void _showBookingConfirmation() {
    if (_selectedRoom == null ||
        _checkInDate == null ||
        _checkOutDate == null) {
      return;
    }

    final days = _checkOutDate!.difference(_checkInDate!).inDays;
    final totalPrice = _selectedRoom!.pricePerNight * days;

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
              'Votre réservation a été confirmée et un e-mail de confirmation vous a été envoyé.',
              textAlign: TextAlign.center,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Hôtel:'),
                      Flexible(
                        child: Text(
                          widget.hotel.name,
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
                      const Text('Chambre:'),
                      Flexible(
                        child: Text(
                          _selectedRoom!.name,
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
                        '${DateFormat('dd/MM').format(_checkInDate!)} - ${DateFormat('dd/MM/yyyy').format(_checkOutDate!)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Montant:'),
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
              Navigator.pop(context); // Retour à la liste des hôtels
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesGrid(HotelAmenities amenities, {bool showAll = false}) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        if (amenities.hasWifi) _buildAmenityTile(Icons.wifi, 'WiFi'),
        if (amenities.hasPool) _buildAmenityTile(Icons.pool, 'Piscine'),
        if (amenities.hasRestaurant)
          _buildAmenityTile(Icons.restaurant, 'Restaurant'),
        if (amenities.hasFitnessCenter)
          _buildAmenityTile(Icons.fitness_center, 'Salle de sport'),
        if (showAll && amenities.hasSpa) _buildAmenityTile(Icons.spa, 'Spa'),
        if (amenities.hasParking)
          _buildAmenityTile(Icons.local_parking, 'Parking'),
        if (showAll && amenities.hasRoomService)
          _buildAmenityTile(Icons.room_service, 'Service en chambre'),
        if (amenities.hasAirConditioning)
          _buildAmenityTile(Icons.ac_unit, 'Climatisation'),
        if (showAll && amenities.hasConferenceRoom)
          _buildAmenityTile(Icons.business, 'Salles de conférence'),
        if (showAll && amenities.hasChildrenActivities)
          _buildAmenityTile(Icons.child_care, 'Activités enfants'),
        if (showAll && amenities.hasBusiness)
          _buildAmenityTile(Icons.business_center, 'Business center'),
        if (showAll && amenities.hasAccessibility)
          _buildAmenityTile(Icons.accessible, 'Accessibilité PMR'),
      ],
    );
  }

  Widget _buildAmenityTile(IconData icon, String label) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
