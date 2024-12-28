// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_route.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BusRouteImpl _$$BusRouteImplFromJson(Map<String, dynamic> json) =>
    _$BusRouteImpl(
      id: json['id'] as String,
      departureCity: json['departureCity'] as String,
      arrivalCity: json['arrivalCity'] as String,
      departureTime: DateTime.parse(json['departureTime'] as String),
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      price: (json['price'] as num).toDouble(),
      busType: json['busType'] as String,
      availableSeats: (json['availableSeats'] as num).toInt(),
      hasAC: json['hasAC'] as bool? ?? false,
      hasWifi: json['hasWifi'] as bool? ?? false,
      companyName: json['companyName'] as String?,
      companyLogo: json['companyLogo'] as String?,
    );

Map<String, dynamic> _$$BusRouteImplToJson(_$BusRouteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'departureCity': instance.departureCity,
      'arrivalCity': instance.arrivalCity,
      'departureTime': instance.departureTime.toIso8601String(),
      'arrivalTime': instance.arrivalTime.toIso8601String(),
      'price': instance.price,
      'busType': instance.busType,
      'availableSeats': instance.availableSeats,
      'hasAC': instance.hasAC,
      'hasWifi': instance.hasWifi,
      'companyName': instance.companyName,
      'companyLogo': instance.companyLogo,
    };
