//lib/features/auth/models/user.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum AuthProvider { email, google, facebook }

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String firstName,
    String? lastName,
    String? phoneNumber,
    String? hashedPassword, // Nouveau champ pour le mot de passe haché
    String? profilePicture,
    required AuthProvider provider,
    required bool isEmailVerified,
    String? country,
    String? language,
    @Default(false) bool hasCompletedProfile,
    DateTime? lastLoginAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
