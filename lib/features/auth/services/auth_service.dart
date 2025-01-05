import 'package:uuid/uuid.dart';
import '../../../core/exceptions/auth_exception.dart';
import '../models/user.dart';
import 'secure_storage_service.dart';

class AuthService {
  final SecureStorageService _storage;
  final _uuid = const Uuid();

  AuthService(this._storage);

  // Connexion avec email/mot de passe
  Future<User> signInWithEmail(String email, String password) async {
    try {
      // Vérifier les identifiants
      final user = await _storage.verifyCredentials(email, password);

      // Mettre à jour la dernière connexion
      final updatedUser = user.copyWith(
        lastLoginAt: DateTime.now(),
      );
      await _storage.updateUser(updatedUser);

      // Sauvegarder la session
      await _storage.setCurrentUser(updatedUser);

      return updatedUser;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException.unknown(e.toString());
    }
  }

  // Inscription avec email/mot de passe
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
    String? phoneNumber,
    String? country,
    String? language,
  }) async {
    try {
      final userData = {
        'id': _uuid.v4(),
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'country': country,
        'language': language,
      };

      final user = await _storage.createUser(userData);
      await _storage.setCurrentUser(user);

      return user;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException.unknown(e.toString());
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _storage.clearCurrentUser();
  }

  // Vérifier si un utilisateur est connecté
  Future<User?> getCurrentUser() async {
    return _storage.getCurrentUser();
  }

  // Mettre à jour le profil utilisateur
  Future<User> updateUserProfile(
    User user, {
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? country,
    String? language,
  }) async {
    try {
      final updatedUser = user.copyWith(
        firstName: firstName ?? user.firstName,
        lastName: lastName ?? user.lastName,
        phoneNumber: phoneNumber ?? user.phoneNumber,
        country: country ?? user.country,
        language: language ?? user.language,
        updatedAt: DateTime.now(),
      );

      await _storage.updateUser(updatedUser);
      await _storage.setCurrentUser(updatedUser);

      return updatedUser;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException.unknown(e.toString());
    }
  }

  // Changer le mot de passe
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final currentUser = await _storage.getCurrentUser();
      if (currentUser == null) {
        throw const AuthException.userNotFound();
      }

      // Vérifier l'ancien mot de passe
      await _storage.verifyCredentials(currentUser.email, currentPassword);

      // Mettre à jour avec le nouveau mot de passe
      final userData = {
        ...currentUser.toJson(),
        'password': newPassword,
      };

      await _storage.updateUser(User.fromJson(userData));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException.unknown(e.toString());
    }
  }
}
