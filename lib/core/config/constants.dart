abstract class AppConstants {
  // Navigation
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 3);

  //Radius
  static const double borderRadius = 8.0;
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

  // Session
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Validation
  static const int maxPasswordLength = 30;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Messages d'erreur
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPassword =
      'Password must be at least 6 characters';
  static const String requiredField = 'This field is required';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String networkError = 'Please check your internet connection';
  static const String unknownError = 'An unexpected error occurred';

  // Données de test
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'password123';
}
