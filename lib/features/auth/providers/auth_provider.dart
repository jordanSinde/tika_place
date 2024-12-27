import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_state.dart';
import '../../../core/utils/mocks/user_mock.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() => const AuthState();

  void setRedirectPath(String path) {
    state = state.copyWith(redirectPath: path);
  }

  void clearRedirectPath() {
    state = state.copyWith(redirectPath: null);
  }

  Future<void> signIn(String email, String password) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await UserMock.mockSignIn(email, password);
      state = AuthState(user: user, redirectPath: state.redirectPath);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Modifier la méthode signUp de manière similaire
  Future<void> signUp(Map<String, dynamic> userData) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await UserMock.mockSignUp(userData);
      state = AuthState(user: user, redirectPath: state.redirectPath);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void signOut() {
    state = const AuthState();
  }
}
