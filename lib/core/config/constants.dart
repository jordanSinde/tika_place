abstract class AppConstants {
  // Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String globePath = 'assets/images/images/map.png';
  static const String planePath = 'assets/images/banner/plane.png';

  // Navigation
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 3);

  // Animations
  static const Duration buttonAnimationDuration = Duration(milliseconds: 200);
  static const Duration globeAnimationDuration = Duration(seconds: 10);

  // Validation
  static const int minPasswordLength = 6;
  static const int phoneNumberLength = 10;

  // Layout
  static const double drawerWidth = 300;
  static const double cardBorderRadius = 20;
  static const double buttonBorderRadius = 12;
  static const double inputBorderRadius = 12;

  // Mock Data Delays (pour simuler des appels API)
  static const Duration mockApiDelay = Duration(milliseconds: 800);
}
