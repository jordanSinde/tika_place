import '../../../features/auth/models/user.dart';

abstract class UserMock {
  static const User demoUser = User(
    id: '1',
    email: 'john.doe@example.com',
    firstName: 'John',
    lastName: 'Doe',
    phoneNumber: '+1234567890',
    country: 'United States',
    language: 'English',
    profilePicture: 'assets/images/user/user-1.png',
  );

  static Duration mockAuthDelay = const Duration(milliseconds: 800);

  static Future<User> mockSignIn(String email, String password) async {
    await Future.delayed(mockAuthDelay);
    // Simuler une vérification
    if (email.isNotEmpty && password.length >= 6) {
      return demoUser;
    }
    throw Exception('Invalid credentials');
  }

  static Future<User> mockSignUp(Map<String, dynamic> userData) async {
    await Future.delayed(mockAuthDelay);
    return User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: userData['email'] as String,
      firstName: userData['firstName'] as String,
      lastName: userData['lastName'] as String?,
      phoneNumber: userData['phoneNumber'] as String?,
      country: userData['country'] as String?,
      language: userData['language'] as String?,
    );
  }
}
