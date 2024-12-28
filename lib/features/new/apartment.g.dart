// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apartment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApartmentImpl _$$ApartmentImplFromJson(Map<String, dynamic> json) =>
    _$ApartmentImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
      city: json['city'] as String,
      district: json['district'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      numberOfRooms: (json['numberOfRooms'] as num).toInt(),
      surfaceArea: (json['surfaceArea'] as num).toDouble(),
      isFurnished: json['isFurnished'] as bool,
      amenities:
          (json['amenities'] as List<dynamic>).map((e) => e as String).toList(),
      nearbyFacilities: (json['nearbyFacilities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      ownerId: json['ownerId'] as String?,
      ownerName: json['ownerName'] as String?,
      ownerPhone: json['ownerPhone'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );

Map<String, dynamic> _$$ApartmentImplToJson(_$ApartmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'monthlyPrice': instance.monthlyPrice,
      'city': instance.city,
      'district': instance.district,
      'images': instance.images,
      'numberOfRooms': instance.numberOfRooms,
      'surfaceArea': instance.surfaceArea,
      'isFurnished': instance.isFurnished,
      'amenities': instance.amenities,
      'nearbyFacilities': instance.nearbyFacilities,
      'ownerId': instance.ownerId,
      'ownerName': instance.ownerName,
      'ownerPhone': instance.ownerPhone,
      'isAvailable': instance.isAvailable,
    };
