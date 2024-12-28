// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apartment_booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApartmentBookingImpl _$$ApartmentBookingImplFromJson(
        Map<String, dynamic> json) =>
    _$ApartmentBookingImpl(
      id: json['id'] as String,
      apartmentId: json['apartmentId'] as String,
      userId: json['userId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      durationInMonths: (json['durationInMonths'] as num).toInt(),
      monthlyRent: (json['monthlyRent'] as num).toDouble(),
      deposit: (json['deposit'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      paymentId: json['paymentId'] as String?,
      contractUrl: json['contractUrl'] as String?,
      tenantInfo: json['tenantInfo'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ApartmentBookingImplToJson(
        _$ApartmentBookingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'apartmentId': instance.apartmentId,
      'userId': instance.userId,
      'startDate': instance.startDate.toIso8601String(),
      'durationInMonths': instance.durationInMonths,
      'monthlyRent': instance.monthlyRent,
      'deposit': instance.deposit,
      'totalAmount': instance.totalAmount,
      'status': instance.status,
      'paymentId': instance.paymentId,
      'contractUrl': instance.contractUrl,
      'tenantInfo': instance.tenantInfo,
    };
