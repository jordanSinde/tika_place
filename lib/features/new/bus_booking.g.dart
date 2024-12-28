// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BusBookingImpl _$$BusBookingImplFromJson(Map<String, dynamic> json) =>
    _$BusBookingImpl(
      id: json['id'] as String,
      routeId: json['routeId'] as String,
      userId: json['userId'] as String,
      numberOfPassengers: (json['numberOfPassengers'] as num).toInt(),
      hasExtraLuggage: json['hasExtraLuggage'] as bool,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      status: json['status'] as String? ?? 'pending',
      paymentId: json['paymentId'] as String?,
      qrCode: json['qrCode'] as String?,
    );

Map<String, dynamic> _$$BusBookingImplToJson(_$BusBookingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'routeId': instance.routeId,
      'userId': instance.userId,
      'numberOfPassengers': instance.numberOfPassengers,
      'hasExtraLuggage': instance.hasExtraLuggage,
      'totalAmount': instance.totalAmount,
      'bookingDate': instance.bookingDate.toIso8601String(),
      'status': instance.status,
      'paymentId': instance.paymentId,
      'qrCode': instance.qrCode,
    };
