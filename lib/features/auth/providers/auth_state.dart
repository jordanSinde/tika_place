import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/user.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    User? user,
    @Default(false) bool isLoading,
    String? error,
    String? redirectPath,
    // Nouveaux champs
    @Default(false) bool isPhoneVerificationInProgress,
    Map<String, dynamic>? pendingUserData,
  }) = _AuthState;

  const AuthState._();

  bool get isAuthenticated => user != null;
}
