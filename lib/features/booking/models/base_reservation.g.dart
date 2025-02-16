// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BaseReservationImpl _$$BaseReservationImplFromJson(
        Map<String, dynamic> json) =>
    _$BaseReservationImpl(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      type: $enumDecode(_$ReservationTypeEnumMap, json['type']),
      status: $enumDecode(_$ReservationStatusEnumMap, json['status']),
      amount: (json['amount'] as num).toDouble(),
      userId: json['userId'] as String,
      paymentId: json['paymentId'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      isArchived: json['isArchived'] as bool? ?? false,
    );

Map<String, dynamic> _$$BaseReservationImplToJson(
        _$BaseReservationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'type': _$ReservationTypeEnumMap[instance.type]!,
      'status': _$ReservationStatusEnumMap[instance.status]!,
      'amount': instance.amount,
      'userId': instance.userId,
      'paymentId': instance.paymentId,
      'cancellationReason': instance.cancellationReason,
      'isArchived': instance.isArchived,
    };

const _$ReservationTypeEnumMap = {
  ReservationType.bus: 'bus',
  ReservationType.hotel: 'hotel',
  ReservationType.apartment: 'apartment',
};

const _$ReservationStatusEnumMap = {
  ReservationStatus.pending: 'pending',
  ReservationStatus.confirmed: 'confirmed',
  ReservationStatus.paid: 'paid',
  ReservationStatus.cancelled: 'cancelled',
  ReservationStatus.expired: 'expired',
  ReservationStatus.failed: 'failed',
};

_$BusReservationImpl _$$BusReservationImplFromJson(Map<String, dynamic> json) =>
    _$BusReservationImpl(
      base: BaseReservation.fromJson(json['base'] as Map<String, dynamic>),
      bus: Bus.fromJson(json['bus'] as Map<String, dynamic>),
      passengers: (json['passengers'] as List<dynamic>)
          .map((e) => PassengerInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      appliedPromoCode: json['appliedPromoCode'] == null
          ? null
          : PromoCode.fromJson(
              json['appliedPromoCode'] as Map<String, dynamic>),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      lastPaymentAttempt: json['lastPaymentAttempt'] == null
          ? null
          : PaymentAttempt.fromJson(
              json['lastPaymentAttempt'] as Map<String, dynamic>),
      paymentHistory: (json['paymentHistory'] as List<dynamic>?)
          ?.map((e) => PaymentAttempt.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$BusReservationImplToJson(
        _$BusReservationImpl instance) =>
    <String, dynamic>{
      'base': instance.base,
      'bus': instance.bus,
      'passengers': instance.passengers,
      'appliedPromoCode': instance.appliedPromoCode,
      'discountAmount': instance.discountAmount,
      'lastPaymentAttempt': instance.lastPaymentAttempt,
      'paymentHistory': instance.paymentHistory,
    };

_$HotelReservationImpl _$$HotelReservationImplFromJson(
        Map<String, dynamic> json) =>
    _$HotelReservationImpl(
      base: BaseReservation.fromJson(json['base'] as Map<String, dynamic>),
      hotelId: json['hotelId'] as String,
      roomId: json['roomId'] as String,
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: DateTime.parse(json['checkOut'] as String),
      guests: (json['guests'] as num).toInt(),
      specialRequests: json['specialRequests'] as String?,
    );

Map<String, dynamic> _$$HotelReservationImplToJson(
        _$HotelReservationImpl instance) =>
    <String, dynamic>{
      'base': instance.base,
      'hotelId': instance.hotelId,
      'roomId': instance.roomId,
      'checkIn': instance.checkIn.toIso8601String(),
      'checkOut': instance.checkOut.toIso8601String(),
      'guests': instance.guests,
      'specialRequests': instance.specialRequests,
    };

_$ApartmentReservationImpl _$$ApartmentReservationImplFromJson(
        Map<String, dynamic> json) =>
    _$ApartmentReservationImpl(
      base: BaseReservation.fromJson(json['base'] as Map<String, dynamic>),
      apartmentId: json['apartmentId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      guests: (json['guests'] as num).toInt(),
      specialRequests: json['specialRequests'] as String?,
    );

Map<String, dynamic> _$$ApartmentReservationImplToJson(
        _$ApartmentReservationImpl instance) =>
    <String, dynamic>{
      'base': instance.base,
      'apartmentId': instance.apartmentId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'guests': instance.guests,
      'specialRequests': instance.specialRequests,
    };
