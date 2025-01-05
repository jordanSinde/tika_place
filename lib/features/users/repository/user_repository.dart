import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/exceptions/repository_exception.dart';
import '../../auth/models/user.dart';

class UserRepository {
  final SharedPreferences _prefs;
  static const String _userKey = 'local_user_data';
  static const String _usersKey =
      'local_users'; // Pour simuler une base de données locale

  UserRepository(this._prefs);

  // Récupérer un utilisateur par email (simulation de base de données)
  Future<User?> getUserByEmail(String email) async {
    try {
      final usersJson = _prefs.getString(_usersKey);
      if (usersJson == null) return null;

      final users = (jsonDecode(usersJson) as List)
          .map((userJson) => User.fromJson(userJson))
          .toList();

      return users.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw const RepositoryException.notFound(),
      );
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException.unknown(e.toString());
    }
  }

  // Sauvegarder un utilisateur
  Future<void> saveUser(User user) async {
    try {
      // Récupérer la liste existante des utilisateurs
      final usersJson = _prefs.getString(_usersKey);
      List<User> users = [];

      if (usersJson != null) {
        users = (jsonDecode(usersJson) as List)
            .map((userJson) => User.fromJson(userJson))
            .toList();
      }

      // Vérifier si l'email existe déjà
      if (users.any((u) => u.email.toLowerCase() == user.email.toLowerCase())) {
        throw const RepositoryException.alreadyExists();
      }

      // Ajouter le nouvel utilisateur
      users.add(user);

      // Sauvegarder la liste mise à jour
      await _prefs.setString(
          _usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));

      // Sauvegarder l'utilisateur courant
      await _prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException.unknown(e.toString());
    }
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser(User user) async {
    try {
      final usersJson = _prefs.getString(_usersKey);
      if (usersJson == null) throw const RepositoryException.notFound();

      List<User> users = (jsonDecode(usersJson) as List)
          .map((userJson) => User.fromJson(userJson))
          .toList();

      final index = users.indexWhere((u) => u.id == user.id);
      if (index == -1) throw const RepositoryException.notFound();

      users[index] = user;
      await _prefs.setString(
          _usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));

      // Mettre à jour l'utilisateur courant si c'est le même
      final currentUserJson = _prefs.getString(_userKey);
      if (currentUserJson != null) {
        final currentUser = User.fromJson(jsonDecode(currentUserJson));
        if (currentUser.id == user.id) {
          await _prefs.setString(_userKey, jsonEncode(user.toJson()));
        }
      }
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException.unknown(e.toString());
    }
  }

  // Supprimer un utilisateur
  Future<void> deleteUser(String userId) async {
    try {
      final usersJson = _prefs.getString(_usersKey);
      if (usersJson == null) return;

      List<User> users = (jsonDecode(usersJson) as List)
          .map((userJson) => User.fromJson(userJson))
          .toList();

      users.removeWhere((user) => user.id == userId);
      await _prefs.setString(
          _usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));

      // Supprimer l'utilisateur courant si c'est le même
      final currentUserJson = _prefs.getString(_userKey);
      if (currentUserJson != null) {
        final currentUser = User.fromJson(jsonDecode(currentUserJson));
        if (currentUser.id == userId) {
          await clearLocalUser();
        }
      }
    } catch (e) {
      throw RepositoryException.unknown(e.toString());
    }
  }

  // Récupérer l'utilisateur courant
  Future<User?> getCurrentUser() async {
    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  // Effacer l'utilisateur courant
  Future<void> clearLocalUser() async {
    await _prefs.remove(_userKey);
  }
}
