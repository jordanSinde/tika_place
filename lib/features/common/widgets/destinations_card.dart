import 'package:flutter/material.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../home/models/destination.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;
  final bool isLarge;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
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
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.asset(
                destination.imageUrl,
                height: isLarge ? 200 : 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        destination.city,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (destination.price != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '\$${destination.price}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        destination.country,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textLight,
                            ),
                      ),
                      const SizedBox(width: 16),
                      if (destination.hasHotels) ...[
                        const Icon(
                          Icons.hotel_outlined,
                          size: 16,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Hotels',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textLight,
                                  ),
                        ),
                      ],
                    ],
                  ),
                  if (isLarge && destination.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      destination.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
