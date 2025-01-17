// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      hashedPassword: json['hashedPassword'] as String?,
      profilePicture: json['profilePicture'] as String?,
      provider: $enumDecode(_$AuthProviderEnumMap, json['provider']),
      isEmailVerified: json['isEmailVerified'] as bool,
      country: json['country'] as String?,
      language: json['language'] as String?,
      hasCompletedProfile: json['hasCompletedProfile'] as bool? ?? false,
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phoneNumber': instance.phoneNumber,
      'hashedPassword': instance.hashedPassword,
      'profilePicture': instance.profilePicture,
      'provider': _$AuthProviderEnumMap[instance.provider]!,
      'isEmailVerified': instance.isEmailVerified,
      'country': instance.country,
      'language': instance.language,
      'hasCompletedProfile': instance.hasCompletedProfile,
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$AuthProviderEnumMap = {
  AuthProvider.email: 'email',
  AuthProvider.google: 'google',
  AuthProvider.facebook: 'facebook',
};
