import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/firebase_auth_service.dart';
import 'auth_state.dart';

part 'auth_provider.g.dart';

@riverpod
FirebaseAuthService firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuthService();
}

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
      // Écouter les changements d'état d'authentification
      ref.listen(firebaseAuthProvider, (previous, next) {
        // Utiliser un StreamSubscription pour pouvoir l'annuler plus tard
        final subscription = next.authStateChanges().listen((user) {
          state = state.copyWith(
            user: user,
            isLoading: false,
            error: null,
          );
        });

        // Annuler la subscription quand le provider est disposé
        ref.onDispose(() {
          subscription.cancel();
        });
      });

      final user = await ref.read(firebaseAuthProvider).getCurrentUser();
      state = AuthState(user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Connexion avec email/mot de passe
  Future<void> signInWithEmail(String email, String password) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await ref.read(firebaseAuthProvider).signInWithEmail(
            email,
            password,
          );
      state = AuthState(user: user, redirectPath: state.redirectPath);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Connexion avec Google
  Future<void> signInWithGoogle() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await ref.read(firebaseAuthProvider).signInWithGoogle();
      state = AuthState(user: user, redirectPath: state.redirectPath);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Connexion avec Facebook
  Future<void> signInWithFacebook() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await ref.read(firebaseAuthProvider).signInWithFacebook();
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
      final user = await ref.read(firebaseAuthProvider).signUpWithEmail(
            email: userData['email'] as String,
            password: userData['password'] as String,
            firstName: userData['firstName'] as String,
            lastName: userData['lastName'] as String?,
            phoneNumber: userData['phoneNumber'] as String?,
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
    await ref.read(firebaseAuthProvider).signOut();
    state = const AuthState();
  }

  // Mise à jour du profil
  Future<void> updateProfile(Map<String, dynamic> userData) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedUser = await ref.read(firebaseAuthProvider).updateProfile(
            userId: state.user!.id,
            firstName: userData['firstName'] as String?,
            lastName: userData['lastName'] as String?,
            phoneNumber: userData['phoneNumber'] as String?,
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
      await ref.read(firebaseAuthProvider).changePassword(
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

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(firebaseAuthProvider).resetPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Vérifier l'email
  Future<void> verifyEmail() async {
    if (state.user == null || state.user!.isEmailVerified) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      // La logique de vérification d'email est gérée par Firebase
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Mettre à jour le chemin de redirection
  void setRedirectPath(String? path) {
    if (path == null || path.isEmpty) return;
    state = state.copyWith(redirectPath: path);
  }

  // Effacer le chemin de redirection
  void clearRedirectPath() {
    state = state.copyWith(redirectPath: null);
  }

  // Effacer l'erreur
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}
