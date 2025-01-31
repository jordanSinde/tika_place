// lib/features/home/widgets/custom_carousel.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tika_place/core/config/theme/app_colors.dart';

class CarouselItem {
  final String title;
  final String subtitle;
  final String buttonText;
  final String description;
  final String imagePath;
  final VoidCallback onButtonPressed;

  CarouselItem({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.description,
    required this.imagePath,
    required this.onButtonPressed,
  });
}

class CustomCarousel extends StatefulWidget {
  const CustomCarousel({super.key});

  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<CarouselItem> items = [
    CarouselItem(
      title: 'Réservez',
      subtitle: ' des chambres d\'hôtels',
      buttonText: 'Voir les offres',
      description: 'Trouvez votre chambre idéale au Cameroun.',
      imagePath: 'assets/images/hotel/hotel-detail-1.png',
      onButtonPressed: () {},
    ),
    CarouselItem(
      title: 'Réservez',
      subtitle: ' un ticket de bus express',
      buttonText: 'Voir les trajets',
      description: 'Voyagez sereinement à travers le pays.',
      imagePath:
          'assets/images/hotel/hotel-detail-1.png', //'assets/images/onboarding_carroussel/bus_travel2-min.jpg',
      onButtonPressed: () {},
    ),
    CarouselItem(
      title: 'Location',
      subtitle: ' appartements courte/longue durée',
      buttonText: 'Voir les biens',
      description: 'L\'appartement parfait pour votre séjour.',
      imagePath: 'assets/images/images/achievement-image.png',
      onButtonPressed: () {},
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        final nextPage = (_currentPage + 1) % items.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  //
  void _goToBusList() {
    context.go('/bus-list');
  }

//

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calcul d'une hauteur adaptative basée sur la taille de l'écran
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = screenHeight * 0.25; // 25% de la hauteur de l'écran

    return Container(
      height: carouselHeight, // Hauteur adaptative au lieu de 360 fixe
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    Image.asset(
                      item.imagePath,
                      fit: BoxFit.cover,
                    ),
                    // Overlay gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16.0), // Padding réduit
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  item.subtitle,
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  softWrap: true,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12, // Taille réduite
                            ),
                            maxLines: 2, // Limite le nombre de lignes
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12), // Espacement réduit
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ElevatedButton(
                              onPressed: item.onButtonPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16, // Padding réduit
                                  vertical: 8, // Padding réduit
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                item.buttonText,
                                style: const TextStyle(
                                    fontSize: 12), // Taille réduite
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            // Indicators
            Positioned(
              bottom: 8, // Position ajustée
              right: 8, // Position ajustée
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentPage == index ? 16 : 6, // Taille réduite
                    height: 6, // Taille réduite
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.secondary
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
