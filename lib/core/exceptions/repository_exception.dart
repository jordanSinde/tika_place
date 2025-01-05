import 'package:freezed_annotation/freezed_annotation.dart';

part 'repository_exception.freezed.dart';

@freezed
class RepositoryException with _$RepositoryException implements Exception {
  const factory RepositoryException.notFound() = NotFound;
  const factory RepositoryException.alreadyExists() = AlreadyExists;
  const factory RepositoryException.serverError() = ServerError;
  const factory RepositoryException.networkError() = NetworkError;
  const factory RepositoryException.unknown(String error) = Unknown;

  const RepositoryException._();

  String get message {
    return when(
      notFound: () => 'The requested resource was not found.',
      alreadyExists: () => 'This resource already exists.',
      serverError: () => 'A server error occurred.',
      networkError: () =>
          'A network error occurred. Please check your connection.',
      unknown: (error) => 'An unknown error occurred: $error',
    );
  }
}
