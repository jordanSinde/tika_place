import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/shared_preferences_provider.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import 'auth_state.dart';

part 'auth_provider.g.dart';

// Provider pour le service de stockage sécurisé
@riverpod
SecureStorageService secureStorage(SecureStorageRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SecureStorageService(prefs);
}

// Provider pour le service d'authentification
@riverpod
AuthService authService(AuthServiceRef ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthService(storage);
}

// Provider principal d'authentification
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthState build() {
    _initializeAuth();
    return const AuthState();
  }

  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await ref.read(authServiceProvider).getCurrentUser();
      state = AuthState(user: user);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Connexion avec email/mot de passe
  Future<void> signInWithEmail(String email, String password) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final user =
          await ref.read(authServiceProvider).signInWithEmail(email, password);
      state = AuthState(user: user, redirectPath: state.redirectPath);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Inscription avec email/mot de passe
  Future<void> signUpWithEmail(Map<String, dynamic> userData) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await ref.read(authServiceProvider).signUpWithEmail(
            email: userData['email'] as String,
            password: userData['password'] as String,
            firstName: userData['firstName'] as String,
            lastName: userData['lastName'] as String?,
            phoneNumber: userData['phoneNumber'] as String?,
            country: userData['country'] as String?,
            language: userData['language'] as String?,
          );
      state = AuthState(user: user, redirectPath: state.redirectPath);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
    state = const AuthState();
  }

  // Mise à jour du profil
  Future<void> updateProfile(Map<String, dynamic> userData) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedUser = await ref.read(authServiceProvider).updateUserProfile(
            state.user!,
            firstName: userData['firstName'] as String?,
            lastName: userData['lastName'] as String?,
            phoneNumber: userData['phoneNumber'] as String?,
            country: userData['country'] as String?,
            language: userData['language'] as String?,
          );
      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Changement de mot de passe
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authServiceProvider).changePassword(
            currentPassword,
            newPassword,
          );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
