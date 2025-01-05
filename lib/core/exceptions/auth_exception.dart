import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_exception.freezed.dart';

@freezed
class AuthException with _$AuthException implements Exception {
  const factory AuthException.invalidEmail() = InvalidEmail;
  const factory AuthException.userDisabled() = UserDisabled;
  const factory AuthException.userNotFound() = UserNotFound;
  const factory AuthException.wrongPassword() = WrongPassword;
  const factory AuthException.emailAlreadyInUse() = EmailAlreadyInUse;
  const factory AuthException.invalidCredentials() = InvalidCredentials;
  const factory AuthException.weakPassword() = WeakPassword;
  const factory AuthException.operationNotAllowed() = OperationNotAllowed;
  const factory AuthException.notImplemented() = NotImplemented;
  const factory AuthException.networkError() = NetworkError;
  const factory AuthException.unknown(String error) = Unknown;

  const AuthException._();

  String get message {
    return when(
      invalidEmail: () => 'The email address is invalid.',
      userDisabled: () => 'This user has been disabled.',
      userNotFound: () => 'No user found for this email.',
      wrongPassword: () => 'Wrong password provided.',
      emailAlreadyInUse: () => 'The email address is already in use.',
      invalidCredentials: () => 'Invalid credentials.',
      weakPassword: () => 'The password provided is too weak.',
      operationNotAllowed: () => 'This operation is not allowed.',
      notImplemented: () => 'This feature is not implemented yet.',
      networkError: () =>
          'A network error occurred. Please check your connection.',
      unknown: (error) => 'An unknown error occurred: $error',
    );
  }
}
