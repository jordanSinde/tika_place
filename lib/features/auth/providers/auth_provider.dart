import 'dart:async';

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
  String? _verificationId;
  Timer? _resendTimer;
  int _resendCountdown = 0;

  bool _isVerifyingPhone = false;

  bool get isVerifyingPhone => _isVerifyingPhone;

  // ... autres méthodes existantes ...

  @override
  AuthState build() {
    _initializeAuth();
    ref.onDispose(() {
      _cancelResendTimer(); // Cette fonction sera appelée quand le provider sera disposé
    });
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

  // Mettre à jour pour la gestion de la vérification du téléphone
  // Nouvelle méthode pour mettre à jour les données en attente
  void updatePendingUserData(Map<String, dynamic> userData) {
    state = state.copyWith(pendingUserData: userData);
  }

  Future<void> startPhoneVerification(String phoneNumber) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      isPhoneVerificationInProgress: true,
      // Ne pas écraser pendingUserData ici
    );

    try {
      await ref.read(firebaseAuthProvider).verifyPhoneNumber(
            phoneNumber: phoneNumber,
            onCodeSent: (String verificationId) {
              _verificationId = verificationId;
              _startResendTimer();
              state = state.copyWith(
                isLoading: false,
                // Garder isPhoneVerificationInProgress à true
              );
            },
            onError: (String error) {
              state = state.copyWith(
                isLoading: false,
                error: error,
                isPhoneVerificationInProgress: false,
                pendingUserData: null,
              );
            },
            onCompleted: (String? userId) {
              state = state.copyWith(
                isLoading: false,
                isPhoneVerificationInProgress: false,
                pendingUserData: null,
              );
            },
          );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isPhoneVerificationInProgress: false,
        pendingUserData: null,
      );
    }
  }
  /*Future<void> startPhoneVerification(String phoneNumber,
      {Map<String, dynamic>? userData}) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      isPhoneVerificationInProgress: true,
      pendingUserData: userData,
    );

    try {
      await ref.read(firebaseAuthProvider).verifyPhoneNumber(
            phoneNumber: phoneNumber,
            onCodeSent: (String verificationId) {
              _verificationId = verificationId;
              _startResendTimer();
              state = state.copyWith(
                isLoading: false,
                // Garder isPhoneVerificationInProgress à true
              );
            },
            onError: (String error) {
              state = state.copyWith(
                isLoading: false,
                error: error,
                isPhoneVerificationInProgress: false,
                pendingUserData: null,
              );
            },
            onCompleted: (String? userId) {
              state = state.copyWith(
                isLoading: false,
                isPhoneVerificationInProgress: false,
                pendingUserData: null,
              );
            },
          );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isPhoneVerificationInProgress: false,
        pendingUserData: null,
      );
    }
  }*/

  // Méthode pour terminer la vérification
  void completePhoneVerification() {
    state = state.copyWith(
      isPhoneVerificationInProgress: false,
      pendingUserData: null,
    );
  }

  // Méthode pour annuler la vérification
  void cancelPhoneVerification() {
    state = state.copyWith(
      isPhoneVerificationInProgress: false,
      pendingUserData: null,
      error: null,
    );
  }

  // Vérifier le code OTP
  Future<void> verifyOTP({
    required String smsCode,
    String? firstName,
    String? lastName,
    required String phoneNumber,
  }) async {
    if (state.isLoading || _verificationId == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await ref.read(firebaseAuthProvider).verifyOTPAndSignIn(
            verificationId: _verificationId!,
            smsCode: smsCode,
            phoneNumber: phoneNumber,
            firstName: firstName ?? "",
            lastName: lastName ?? "",
          );

      _cancelResendTimer();
      state = AuthState(user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Gérer le timer pour le renvoi du code
  void _startResendTimer() {
    _resendCountdown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        _resendCountdown--;
      } else {
        timer.cancel();
      }
    });
  }

  // Annuler le timer
  void _cancelResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = null;
    _resendCountdown = 0;
  }

  // Obtenir le temps restant pour le renvoi
  int get resendCountdown => _resendCountdown;

  // Renvoyer le code OTP
  Future<void> resendOTP(String phoneNumber) async {
    if (state.isLoading || _resendCountdown > 0) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(firebaseAuthProvider).resendOTP(
            phoneNumber: phoneNumber,
            onCodeSent: (String verificationId) {
              _verificationId = verificationId;
              _startResendTimer();
              state = state.copyWith(isLoading: false);
            },
            onError: (String error) {
              state = state.copyWith(
                isLoading: false,
                error: error,
              );
            },
          );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    } finally {
      _isVerifyingPhone = false; // Fin de la vérification
    }
  }

  // Nettoyer les ressources quand le provider est disposé
  void dispose() {
    _cancelResendTimer();
  }
}
