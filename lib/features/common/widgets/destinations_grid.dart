import 'package:flutter/material.dart';

import '../../home/models/destination.dart';
import 'destinations_card.dart';

class DestinationsGrid extends StatelessWidget {
  final List<Destination> destinations;
  final void Function(Destination) onDestinationTap;

  const DestinationsGrid({
    super.key,
    required this.destinations,
    required this.onDestinationTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final destination = destinations[index];
        return DestinationCard(
          destination: destination,
          onTap: () => onDestinationTap(destination),
        );
      },
    );
  }
}
