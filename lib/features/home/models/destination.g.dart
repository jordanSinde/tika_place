// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DestinationImpl _$$DestinationImplFromJson(Map<String, dynamic> json) =>
    _$DestinationImpl(
      id: json['id'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      imageUrl: json['imageUrl'] as String,
      price: json['price'] as String?,
      hasHotels: json['hasHotels'] as bool? ?? false,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$DestinationImplToJson(_$DestinationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'city': instance.city,
      'country': instance.country,
      'imageUrl': instance.imageUrl,
      'price': instance.price,
      'hasHotels': instance.hasHotels,
      'description': instance.description,
    };
