// lib/features/home/widgets/bus_booking/bus_booking_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../models/bus_mock_data.dart';
import 'bus_search_card.dart';
import 'package:go_router/go_router.dart';

enum BusClass { economy, business, vip }

// lib/features/bus_booking/screens/bus_booking_view.dart

class BusBookingView extends ConsumerWidget {
  const BusBookingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Formulaire de recherche
          BusSearchCard(
            onSearch: (searchParams) {
              // Créer les filtres à partir des paramètres de recherche
              final filters = BusSearchFilters(
                departureCity: searchParams['departureCity'] as String?,
                arrivalCity: searchParams['arrivalCity'] as String?,
                departureDate: searchParams['date'] as DateTime?,
                departureTime: searchParams['time'] as TimeOfDay?,
              );

              // Naviguer vers la liste des bus avec les filtres
              context.go('/bus-list', extra: {'filters': filters});
            },
          ),

          // Section des trajets populaires
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trajets populaires',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildPopularRoutes(),
              ],
            ),
          ),

          // Informations supplémentaires
          _buildInfoSection(context),
        ],
      ),
    );
  }

  Widget _buildPopularRoutes() {
    return Column(
      children: [
        _buildPopularRouteCard(
          departureCity: 'Douala',
          arrivalCity: 'Yaoundé',
          duration: '4h',
          minPrice: 6000,
        ),
        const SizedBox(height: 12),
        _buildPopularRouteCard(
          departureCity: 'Yaoundé',
          arrivalCity: 'Bafoussam',
          duration: '5h',
          minPrice: 7000,
        ),
        const SizedBox(height: 12),
        _buildPopularRouteCard(
          departureCity: 'Douala',
          arrivalCity: 'Kribi',
          duration: '3h',
          minPrice: 5000,
        ),
      ],
    );
  }

  Widget _buildPopularRouteCard({
    required String departureCity,
    required String arrivalCity,
    required String duration,
    required int minPrice,
  }) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          // Naviguer vers la liste des bus avec les filtres préremplis
          final filters = BusSearchFilters(
            departureCity: departureCity,
            arrivalCity: arrivalCity,
          );
          context.go('/bus-list', extra: {'filters': filters});
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          departureCity,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      height: 20,
                      width: 1,
                      color: AppColors.divider,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          arrivalCity,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: AppColors.divider,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'À partir de',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '$minPrice FCFA',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations importantes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.info_outline,
            text: 'Arrivez 30 minutes avant le départ',
          ),
          _buildInfoItem(
            icon: Icons.card_membership,
            text: 'Une pièce d\'identité est requise',
          ),
          _buildInfoItem(
            icon: Icons.luggage,
            text: 'Un bagage en soute gratuit',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/*

class BusBookingView extends ConsumerStatefulWidget {
  const BusBookingView({super.key});

  @override
  ConsumerState<BusBookingView> createState() => _BusBookingViewState();
}

class _BusBookingViewState extends ConsumerState<BusBookingView> {
  List<Bus> _filteredBuses = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredBuses = mockBuses;
  }

  void _handleSearch(Map<String, dynamic> searchParams) {
    setState(() => _isSearching = true);

    // Simuler une recherche asynchrone
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _filteredBuses = mockBuses.where((bus) {
          return bus.departureCity.toLowerCase() ==
                  searchParams['departureCity'].toString().toLowerCase() &&
              bus.arrivalCity.toLowerCase() ==
                  searchParams['arrivalCity'].toString().toLowerCase();
        }).toList();
        _isSearching = false;
      });

      _showBusResults();
    });
  }

  Widget _buildSeatLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.primary,
              width: color == Colors.white ? 1 : 0,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildPopularRouteCard({
    required String departure,
    required String arrival,
    required String duration,
    required String price,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      departure,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  height: 20,
                  width: 1,
                  color: AppColors.divider,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      arrival,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: AppColors.divider,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$price FCFA',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    duration,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBusResults() {
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Text(
                  'Résultats disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_isSearching)
                const Center(child: CircularProgressIndicator())
              else if (_filteredBuses.isEmpty)
                const Center(
                  child: Text('Aucun bus disponible pour cet itinéraire'),
                )
              else
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredBuses.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => _showSeatSelection(_filteredBuses[index]),
                      child: _buildBusCard(_filteredBuses[index]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusCard(Bus bus) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bus.company,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  bus.busClass.label,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationInfo(
                      time: bus.departureTime,
                      city: bus.departureCity,
                      isStart: true,
                    ),
                    const SizedBox(height: 16),
                    _buildLocationInfo(
                      time: bus.arrivalTime,
                      city: bus.arrivalCity,
                      isStart: false,
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: AppColors.divider,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${bus.price.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${bus.availableSeats} places',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        bus.rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (bus.amenities.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: bus.amenities
                  .map((amenity) => Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Row(
                          children: [
                            Icon(
                              _getAmenityIcon(amenity),
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              amenity,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'climatisation':
        return Icons.ac_unit;
      case 'usb':
        return Icons.usb;
      case 'collation':
        return Icons.restaurant;
      default:
        return Icons.check_circle;
    }
  }

  Widget _buildLocationInfo({
    required DateTime time,
    required String city,
    required bool isStart,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isStart ? AppColors.primary : AppColors.secondary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isStart ? Icons.trip_origin : Icons.location_on,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              city,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            Text(
              '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Continue with _showSeatSelection, _showBookingForm, and _showTicketConfirmation methods..
  void _showSeatSelection(Bus bus) {
    final seats = generateMockSeats(45, bus.availableSeats);
    final List<int> selectedSeats = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          initialChildSize: 0.8,
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Sélection des sièges',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSeatLegend('Disponible', Colors.white),
                          _buildSeatLegend('Sélectionné', AppColors.primary),
                          _buildSeatLegend('Occupé', Colors.grey[300]!),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: seats.length,
                    itemBuilder: (context, index) {
                      final seat = seats[index];
                      final isSelected = selectedSeats.contains(seat.number);
                      return GestureDetector(
                        onTap: seat.isAvailable
                            ? () {
                                setState(() {
                                  if (isSelected) {
                                    selectedSeats.remove(seat.number);
                                  } else {
                                    selectedSeats.add(seat.number);
                                  }
                                });
                              }
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: !seat.isAvailable
                                ? Colors.grey[300]
                                : isSelected
                                    ? AppColors.primary
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: seat.isAvailable
                                  ? AppColors.primary
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  seat.number.toString(),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (seat.isWindow)
                                  Icon(
                                    Icons.window,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${selectedSeats.length} sièges sélectionnés',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${(bus.price * selectedSeats.length).toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: selectedSeats.isEmpty
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  _showBookingForm(bus, selectedSeats);
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Continuer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBookingForm(Bus bus, List<int> selectedSeats) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Finaliser la réservation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
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
                      CustomTextField(
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
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total à payer',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${(bus.price * selectedSeats.length).toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            Navigator.pop(context);
                            _showTicketConfirmation(
                              Ticket(
                                id: 'TK-${DateTime.now().millisecondsSinceEpoch}',
                                bus: bus,
                                seatNumbers: selectedSeats,
                                passengerName: nameController.text,
                                phoneNumber: phoneController.text,
                                purchaseDate: DateTime.now(),
                                totalPrice: bus.price * selectedSeats.length,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Confirmer la réservation'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTicketConfirmation(Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.primary,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Réservation confirmée!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'N° de ticket: ${ticket.id}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                // Simuler l'envoi d'un SMS
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le ticket a été envoyé par SMS'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              },
              child: const Text('Voir mon ticket'),
            ),
          ],
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
        // Bus Search Card
        BusSearchCard(onSearch: _handleSearch),

        // Popular Routes Section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trajets populaires',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildPopularRouteCard(
                departure: 'Douala',
                arrival: 'Yaoundé',
                duration: '4h',
                price: '6,000',
              ),
              const SizedBox(height: 12),
              _buildPopularRouteCard(
                departure: 'Yaoundé',
                arrival: 'Bafoussam',
                duration: '5h',
                price: '7,000',
              ),
              const SizedBox(height: 12),
              _buildPopularRouteCard(
                departure: 'Douala',
                arrival: 'Kribi',
                duration: '3h',
                price: '5,000',
              ),
            ],
          ),
        ),
      ],
    );
  }
}*/
