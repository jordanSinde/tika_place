//lib/features/auth/models/user.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum AuthProvider { email, google, facebook, phone }

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String firstName,
    String? lastName,
    String? phoneNumber,
    String? hashedPassword,
    String? profilePicture,
    int? cniNumber,
    required AuthProvider provider,
    required bool isEmailVerified,
    String? country,
    String? language,
    @Default(false) bool hasCompletedProfile,
    DateTime? lastLoginAt,
    required DateTime createdAt,
    DateTime? updatedAt,
    // Nouvelle propriété uniquement pour les contacts
    @Default([]) List<Contact> contacts, // Pour les proches
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

@freezed
class Contact with _$Contact {
  const factory Contact({
    required String id,
    required String firstName,
    String? lastName,
    required String phoneNumber,
    String? relationship, // ex: family, friend, etc.
  }) = _Contact;

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);
}
