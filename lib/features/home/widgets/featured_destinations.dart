import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../../../core/config/theme/app_colors.dart';

class FeaturedDestinations extends StatelessWidget {
  final List<Destination> destinations;
  final Function(Destination) onDestinationTap;

  const FeaturedDestinations({
    super.key,
    required this.destinations,
    required this.onDestinationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: destinations.length,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemBuilder: (context, index) {
          final destination = destinations[index];
          final isLarge = index == 1; // Le deuxième élément sera plus grand

          return GestureDetector(
            onTap: () => onDestinationTap(destination),
            child: Container(
              width: isLarge ? 180 : 140,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(destination.imageUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.city,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destination.country,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
