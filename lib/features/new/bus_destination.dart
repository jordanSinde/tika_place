// bus_destinations_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';

class BusDestinationsScreen extends ConsumerWidget {
  const BusDestinationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destinations des Bus'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSearchSection(),
          const SizedBox(height: 24),
          _buildPopularRoutes(),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rechercher un trajet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildSearchField(
              icon: Icons.location_on_outlined,
              hint: 'Ville de départ',
            ),
            const SizedBox(height: 12),
            _buildSearchField(
              icon: Icons.location_on_outlined,
              hint: 'Ville d\'arrivée',
            ),
            const SizedBox(height: 12),
            _buildSearchField(
              icon: Icons.calendar_today_outlined,
              hint: 'Date de départ',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Rechercher'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField({
    required IconData icon,
    required String hint,
  }) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildPopularRoutes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trajets populaires',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildRouteCard(
          departure: 'Douala',
          arrival: 'Yaoundé',
          price: '5000',
          duration: '4h',
        ),
        _buildRouteCard(
          departure: 'Yaoundé',
          arrival: 'Bafoussam',
          price: '4500',
          duration: '5h',
        ),
        _buildRouteCard(
          departure: 'Douala',
          arrival: 'Kribi',
          price: '4000',
          duration: '3h',
        ),
      ],
    );
  }

  Widget _buildRouteCard({
    required String departure,
    required String arrival,
    required String price,
    required String duration,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Text(departure),
            const Icon(Icons.arrow_right_alt),
            Text(arrival),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(duration),
              const SizedBox(width: 16),
              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
              Text('$price FCFA'),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
