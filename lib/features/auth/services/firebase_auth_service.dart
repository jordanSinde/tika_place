import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../../core/exceptions/auth_exception.dart';
import '../models/user.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  FirebaseAuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  // Convertir un utilisateur Firebase en modèle User
  User _firebaseUserToUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      firstName: firebaseUser.displayName?.split(' ').first ?? '',
      lastName: (firebaseUser.displayName?.split(' ').length ?? 0) > 1
          ? firebaseUser.displayName?.split(' ').sublist(1).join(' ')
          : null,
      phoneNumber: firebaseUser.phoneNumber,
      profilePicture: firebaseUser.photoURL,
      provider: _getAuthProvider(firebaseUser.providerData),
      isEmailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
    );
  }

  // Déterminer le provider d'authentification
  AuthProvider _getAuthProvider(List<firebase_auth.UserInfo> providerData) {
    if (providerData.isEmpty) return AuthProvider.email;

    final providerId = providerData.first.providerId;
    switch (providerId) {
      case 'google.com':
        return AuthProvider.google;
      case 'facebook.com':
        return AuthProvider.facebook;
      default:
        return AuthProvider.email;
    }
  }

  // Gérer les erreurs Firebase
  AuthException _handleFirebaseAuthError(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return const AuthException.invalidEmail();
        case 'user-disabled':
          return const AuthException.userDisabled();
        case 'user-not-found':
          return const AuthException.userNotFound();
        case 'wrong-password':
          return const AuthException.wrongPassword();
        case 'email-already-in-use':
          return const AuthException.emailAlreadyInUse();
        case 'weak-password':
          return const AuthException.weakPassword();
        case 'operation-not-allowed':
          return const AuthException.operationNotAllowed();
        case 'network-request-failed':
          return const AuthException.networkError();
        default:
          return AuthException.unknown(
              error.message ?? 'Unknown error occurred');
      }
    }
    return AuthException.unknown(error.toString());
  }

  // Connexion avec email/mot de passe
  Future<User> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw const AuthException.unknown('User is null after sign in');
      }
      return _firebaseUserToUser(userCredential.user!);
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Inscription avec email/mot de passe
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw const AuthException.unknown('User is null after sign up');
      }

      // Mettre à jour le profil utilisateur
      await userCredential.user!
          .updateDisplayName('$firstName ${lastName ?? ''}');

      // Envoyer l'email de vérification
      await userCredential.user!.sendEmailVerification();

      return _firebaseUserToUser(userCredential.user!);
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Connexion avec Google
  Future<User> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException.operationNotAllowed();
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw const AuthException.unknown('User is null after Google sign in');
      }

      return _firebaseUserToUser(userCredential.user!);
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Connexion avec Facebook
  Future<User> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await _facebookAuth.login();

      switch (loginResult.status) {
        case LoginStatus.success:
          final accessToken = loginResult.accessToken?.token;
          if (accessToken == null) {
            throw const AuthException.unknown('Facebook access token is null');
          }

          // Obtenir les informations du profil Facebook
          final userData = await _facebookAuth.getUserData();

          // Créer les credentials Firebase
          final credential =
              firebase_auth.FacebookAuthProvider.credential(accessToken);
          final userCredential =
              await _firebaseAuth.signInWithCredential(credential);

          if (userCredential.user == null) {
            throw const AuthException.unknown(
                'User is null after Facebook sign in');
          }

          return _firebaseUserToUser(userCredential.user!);

        case LoginStatus.cancelled:
          throw const AuthException.operationNotAllowed();

        case LoginStatus.failed:
          throw AuthException.unknown(
              loginResult.message ?? 'Facebook login failed');

        default:
          throw const AuthException.unknown('Unknown Facebook login status');
      }
    } catch (e) {
      // Si l'erreur est déjà une AuthException, la propager
      if (e is AuthException) rethrow;

      // Sinon, la convertir en AuthException
      throw _handleFirebaseAuthError(e);
    }
  }

  // Envoyer le code OTP
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function(String?) onCompleted,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted:
            (firebase_auth.PhoneAuthCredential credential) async {
          // Auto-résolution sur Android
          try {
            final userCredential =
                await _firebaseAuth.signInWithCredential(credential);
            onCompleted(userCredential.user?.uid);
          } catch (e) {
            onError(_handleFirebaseAuthError(e).message);
          }
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          onError(_handleFirebaseAuthError(e).message);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout de la récupération automatique du code
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onError(_handleFirebaseAuthError(e).message);
    }
  }

  // Vérifier le code OTP et créer/mettre à jour l'utilisateur
  Future<User> verifyOTPAndSignIn({
    required String verificationId,
    required String smsCode,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      // Créer les credentials avec le code OTP
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Connecter l'utilisateur
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthException.unknown('User is null after phone auth');
      }

      // Mettre à jour le profil utilisateur
      await userCredential.user!.updateDisplayName('$firstName $lastName');

      // Créer l'objet User personnalisé
      return User(
        id: userCredential.user!.uid,
        email: '', // Le téléphone n'a pas d'email
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        provider: AuthProvider
            .email, // Vous pourriez vouloir ajouter un nouveau provider 'phone'
        isEmailVerified: true, // Pas besoin de vérification pour le téléphone
        hasCompletedProfile: true,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Renvoi du code OTP
  Future<void> resendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: onCodeSent,
        onError: onError,
        onCompleted: (_) {},
      );
    } catch (e) {
      onError(_handleFirebaseAuthError(e).message);
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      final provider =
          _getAuthProvider(_firebaseAuth.currentUser?.providerData ?? []);

      switch (provider) {
        case AuthProvider.google:
          await _googleSignIn.signOut();
          break;
        case AuthProvider.facebook:
          await _facebookAuth.logOut();
          break;
        default:
          break;
      }

      await _firebaseAuth.signOut();
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Obtenir l'utilisateur courant
  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return _firebaseUserToUser(firebaseUser);
  }

  // Mettre à jour le profil
  Future<User> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException.userNotFound();
      }

      if (firstName != null || lastName != null) {
        final newDisplayName = [
          firstName ?? user.displayName?.split(' ').first,
          lastName ?? user.displayName?.split(' ').sublist(1).join(' '),
        ].where((e) => e != null).join(' ');

        await user.updateDisplayName(newDisplayName);
      }

      if (phoneNumber != null) {
        await user.updatePhoneNumber(
            phoneNumber as firebase_auth.PhoneAuthCredential);
      }

      return _firebaseUserToUser(user);
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Changer le mot de passe
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException.userNotFound();
      }

      // Rééauthentifier l'utilisateur
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Changer le mot de passe
      await user.updatePassword(newPassword);
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Stream des changements d'authentification
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser == null ? null : _firebaseUserToUser(firebaseUser);
    });
  }
}
