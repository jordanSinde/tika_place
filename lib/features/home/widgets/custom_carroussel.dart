// lib/features/home/widgets/custom_carousel.dart

import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:tika_place/core/config/constants.dart';
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
  late final List<CarouselItem> items;

  final List<ImageProvider> _preloadedImages = [];

  Future<void> _preloadImages() async {
    for (var item in items) {
      final imageProvider = AssetImage(item.imagePath);
      _preloadedImages.add(imageProvider);
      // Précacher l'image
      await precacheImage(imageProvider, context);
    }
  }

  @override
  void initState() {
    _preloadImages();
    super.initState();
    items = [
      CarouselItem(
        title: 'Réservez votre',
        subtitle: 'chambre d\'hôtel',
        buttonText: 'Découvrez nos offres d\'hôtels',
        description:
            'Avec TIKA PLACE, trouvez et réservez la chambre d\'hôtel idéale partout au Cameroun en quelques clics.',
        imagePath:
            'assets/images/hotel/hotel-detail-1.png', //assets/images/onboarding_carroussel/hotel_booking2-min.jpg
        onButtonPressed: () {},
      ),
      CarouselItem(
        title: 'Réservez votre',
        subtitle: 'billet de bus',
        buttonText: 'Voir les trajets disponibles',
        description:
            'Voyagez en toute tranquillité avec nos partenaires de transport à travers le Cameroun.',
        imagePath:
            'assets/images/onboarding_carroussel/bus_travel2-min.jpg', //assets/images/onboarding_carroussel/bus_travel2-min.jpg
        onButtonPressed: () {},
      ),
      CarouselItem(
        title: 'Louez un',
        subtitle: 'appartement',
        buttonText: 'Découvrez nos appartements',
        description:
            'Trouvez l\'appartement qui vous convient pour vos séjours courts ou longs.',
        imagePath: 'assets/images/images/achievement-image.png',
        onButtonPressed: () {},
      ),
    ];

    // Auto-scroll
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        autoScroll();
      }
    });
  }

  void autoScroll() {
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        if (_currentPage < items.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        autoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 360,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Stack(
                children: [
                  // Image de fond optimisée
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: _preloadedImages.isNotEmpty
                            ? _preloadedImages[index]
                            : AssetImage(item.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Overlay pour l'assombrissement
                  Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  // Contenu
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: item.subtitle,
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: ' en ligne',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        /*Text(
                          item.subtitle,
                          style: TextStyle(
                            color: Colors.orange[400],
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'en ligne',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),*/
                        const SizedBox(height: 20),
                        Text(
                          item.description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ElevatedButton(
                            onPressed: item.onButtonPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadius),
                              ),
                            ),
                            child: Text(
                              item.buttonText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: DotsIndicator(
              dotsCount: items.length,
              position: _currentPage,
              decorator: DotsDecorator(
                activeColor: AppColors.secondary,
                color: Colors.white,
                size: const Size(8.0, 8.0),
                activeSize: const Size(20.0, 8.0),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
