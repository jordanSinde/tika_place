import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/exceptions/auth_exception.dart';
import '../models/user.dart';

class SecureStorageService {
  final SharedPreferences _prefs;
  static const String _usersKey = 'local_users';
  static const String _currentUserKey = 'current_user';

  SecureStorageService(this._prefs);

  // Hacher le mot de passe de manière sécurisée
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Stocker un nouvel utilisateur
  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    try {
      // Récupérer les utilisateurs existants
      final users = await _getUsers();

      // Vérifier si l'email existe déjà
      if (users.any((u) =>
          u.email.toLowerCase() ==
          userData['email'].toString().toLowerCase())) {
        throw const AuthException.emailAlreadyInUse();
      }

      // Créer le nouvel utilisateur avec mot de passe haché
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: userData['email'],
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        phoneNumber: userData['phoneNumber'],
        hashedPassword: _hashPassword(userData['password']),
        provider: AuthProvider.email,
        isEmailVerified: false,
        country: userData['country'],
        language: userData['language'],
        createdAt: DateTime.now(),
      );

      // Ajouter le nouvel utilisateur à la liste
      users.add(newUser);
      await _saveUsers(users);

      // Retourner l'utilisateur sans le mot de passe haché
      return newUser.copyWith(hashedPassword: null);
    } catch (e) {
      throw AuthException.unknown(e.toString());
    }
  }

  // Vérifier les identifiants
  Future<UserModel> verifyCredentials(String email, String password) async {
    try {
      final users = await _getUsers();
      final hashedPassword = _hashPassword(password);

      final user = users.firstWhere(
        (u) =>
            u.email.toLowerCase() == email.toLowerCase() &&
            u.hashedPassword == hashedPassword,
        orElse: () => throw const AuthException.invalidCredentials(),
      );

      return user.copyWith(hashedPassword: null);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException.unknown(e.toString());
    }
  }

  // Mettre à jour un utilisateur
  Future<UserModel> updateUser(UserModel updatedUser) async {
    try {
      final users = await _getUsers();
      final index = users.indexWhere((u) => u.id == updatedUser.id);

      if (index == -1) {
        throw const AuthException.userNotFound();
      }

      // Conserver le mot de passe haché existant
      final existingUser = users[index];
      final userToSave = updatedUser.copyWith(
        hashedPassword: existingUser.hashedPassword,
      );

      users[index] = userToSave;
      await _saveUsers(users);

      return updatedUser;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException.unknown(e.toString());
    }
  }

  // Récupérer tous les utilisateurs
  Future<List<UserModel>> _getUsers() async {
    final usersJson = _prefs.getString(_usersKey);
    if (usersJson == null) return [];

    try {
      final usersList = jsonDecode(usersJson) as List;
      return usersList.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Sauvegarder la liste des utilisateurs
  Future<void> _saveUsers(List<UserModel> users) async {
    final usersJson = jsonEncode(users.map((u) => u.toJson()).toList());
    await _prefs.setString(_usersKey, usersJson);
  }

  // Gérer la session courante
  Future<void> setCurrentUser(UserModel user) async {
    await _prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
  }

  Future<void> clearCurrentUser() async {
    await _prefs.remove(_currentUserKey);
  }

  Future<UserModel?> getCurrentUser() async {
    final userJson = _prefs.getString(_currentUserKey);
    if (userJson == null) return null;

    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (e) {
      await clearCurrentUser();
      return null;
    }
  }
}
