import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_assets.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/parallax_globe.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeAndNavigate();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _fadeController.forward();
  }

  // Dans _initializeAndNavigate de splash_screen.dart
  Future<void> _initializeAndNavigate() async {
    // Réduire le délai d'attente à 2 secondes
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authNotifier = ref.read(authProvider.notifier);
    final isAuthenticated = ref.read(authProvider).isAuthenticated;
    final isVerifyingPhone = authNotifier.isVerifyingPhone;

    // Si une vérification de téléphone est en cours
    if (isVerifyingPhone) {
      // Rediriger vers la page de vérification OTP
      if (context.mounted) {
        context.go('/verify-otp', extra: {
          'phoneNumber': authNotifier.currentPhoneNumber,
          'isLogin': true, // ou false selon le contexte
        });
      }
      return;
    }

    // Navigation normale pour les autres cas
    if (mounted) {
      if (isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }
  /*Future<void> _initializeAndNavigate() async {
    // Réduire le délai d'attente à 2 secondes au lieu de 4
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authNotifier = ref.read(authProvider.notifier);
    final isAuthenticated = ref.read(authProvider).isAuthenticated;
    final isVerifyingPhone = authNotifier.isVerifyingPhone;

    // Si une vérification de téléphone est en cours, ne rien faire
    if (isVerifyingPhone) {
      // Retourner à la page précédente au lieu de rester sur le splash screen
      if (context.mounted) {
        context.pop();
      }
      return;
    }

    // Navigation normale pour les autres cas
    if (mounted) {
      if (isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withBlue(150),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Image.asset(
                        AppAssets.logoPath,
                        height: 120,
                        width: 120,
                      ),
                      const SizedBox(height: 60),
                      // Globe avec effet parallax
                      const ParallaxGlobe(),
                      const SizedBox(height: 60),
                      // Indicateur de chargement
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ],
                  ),
                ),
              ),
              // Version en bas
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Center(
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}
