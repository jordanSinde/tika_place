// lib/features/onboarding/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';
import '../provider/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/images/onboarding_carroussel/bus_travel1.png',
      title: 'Réservation de Bus',
      description:
          'Réservez facilement vos billets de bus et voyagez en toute tranquillité à travers le Cameroun.',
      backgroundColor: AppColors.primary.withOpacity(0.1),
    ),
    OnboardingPage(
      image:
          'assets/images/onboarding_carroussel/hotel_booking1.png', //assets\images\onboarding_carroussel
      title: 'Hébergement',
      description:
          'Trouvez l\'hôtel ou l\'appartement idéal pour votre séjour, avec des options pour tous les budgets.',
      backgroundColor: AppColors.secondary.withOpacity(0.1),
    ),
    OnboardingPage(
      image: 'assets/images/onboarding_carroussel/online_payment1.png',
      title: 'Paiement Sécurisé',
      description:
          'Payez en toute sécurité avec Mobile Money, Orange Money ou carte bancaire.',
      backgroundColor: AppColors.success.withOpacity(0.1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pages d'onboarding
          PageView.builder(
            controller: _pageController,
            onPageChanged: (value) => setState(() => _currentPage = value),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Container(
                width:
                    double.infinity, // Défini explicitement la largeur (here)
                height: double.infinity, // Défini explicitement la hauteur
                color: page.backgroundColor,
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Image.asset(
                            page.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                page.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                page.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Indicateurs de page
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 10,
                  width: _currentPage == index ? 25 : 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),

          // Boutons de navigation
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text(
                      'Précédent',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  )
                else
                  const SizedBox(width: 80),
                Container(
                  // Wrap the ElevatedButton in a Container with constraints
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        try {
                          // Utiliser le nouveau NotifierProvider
                          await ref
                              .read(onboardingCompletedProvider.notifier)
                              .completeOnboarding();

                          if (context.mounted) {
                            context.go('/login');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Erreur lors de la finalisation: ${e.toString()}')),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Commencer'
                          : 'Suivant',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String description;
  final Color backgroundColor;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    required this.backgroundColor,
  });
}
