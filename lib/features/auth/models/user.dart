// lib/features/auth/models/user.dart
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
    // Utilisation de Passenger au lieu de Contact
    @Default([]) List<Passenger> savedPassengers, // Renommé pour plus de clarté
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

// Extension de la classe Passenger pour inclure les fonctionnalités de Contact
class Passenger {
  final String id; // Ajout de l'id pour la persistance
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final int? cniNumber;
  final bool isMainPassenger;
  final String? relationship; // Ajout de la relation depuis Contact

  Passenger({
    String? id, // Optionnel avec valeur par défaut
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.cniNumber,
    this.isMainPassenger = false,
    this.relationship,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Passenger copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    int? cniNumber,
    bool? isMainPassenger,
    String? relationship,
  }) {
    return Passenger(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      cniNumber: cniNumber ?? this.cniNumber,
      isMainPassenger: isMainPassenger ?? this.isMainPassenger,
      relationship: relationship ?? this.relationship,
    );
  }

  // Conversion depuis/vers JSON
  factory Passenger.fromJson(Map<String, dynamic> json) => Passenger(
        id: json['id'] as String?,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        phoneNumber: json['phoneNumber'] as String?,
        cniNumber: json['cniNumber'] as int?,
        isMainPassenger: json['isMainPassenger'] as bool? ?? false,
        relationship: json['relationship'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'cniNumber': cniNumber,
        'isMainPassenger': isMainPassenger,
        'relationship': relationship,
      };
}
