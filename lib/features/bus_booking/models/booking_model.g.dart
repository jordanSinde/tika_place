// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TicketReservationImpl _$$TicketReservationImplFromJson(
        Map<String, dynamic> json) =>
    _$TicketReservationImpl(
      id: json['id'] as String,
      bus: Bus.fromJson(json['bus'] as Map<String, dynamic>),
      passengers: (json['passengers'] as List<dynamic>)
          .map((e) => PassengerInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      userId: json['userId'] as String,
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
      cancellationReason: json['cancellationReason'] as String?,
      isArchived: json['isArchived'] as bool? ?? false,
    );

Map<String, dynamic> _$$TicketReservationImplToJson(
        _$TicketReservationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bus': instance.bus,
      'passengers': instance.passengers,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'totalAmount': instance.totalAmount,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'userId': instance.userId,
      'appliedPromoCode': instance.appliedPromoCode,
      'discountAmount': instance.discountAmount,
      'lastPaymentAttempt': instance.lastPaymentAttempt,
      'paymentHistory': instance.paymentHistory,
      'cancellationReason': instance.cancellationReason,
      'isArchived': instance.isArchived,
    };

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.paid: 'paid',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.expired: 'expired',
  BookingStatus.failed: 'failed',
};

_$PassengerInfoImpl _$$PassengerInfoImplFromJson(Map<String, dynamic> json) =>
    _$PassengerInfoImpl(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      cniNumber: (json['cniNumber'] as num?)?.toInt(),
      isMainPassenger: json['isMainPassenger'] as bool,
      seatNumber: json['seatNumber'] as String?,
    );

Map<String, dynamic> _$$PassengerInfoImplToJson(_$PassengerInfoImpl instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phoneNumber': instance.phoneNumber,
      'cniNumber': instance.cniNumber,
      'isMainPassenger': instance.isMainPassenger,
      'seatNumber': instance.seatNumber,
    };

_$PaymentAttemptImpl _$$PaymentAttemptImplFromJson(Map<String, dynamic> json) =>
    _$PaymentAttemptImpl(
      timestamp: DateTime.parse(json['timestamp'] as String),
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      errorMessage: json['errorMessage'] as String?,
      transactionId: json['transactionId'] as String?,
      amountPaid: (json['amountPaid'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$PaymentAttemptImplToJson(
        _$PaymentAttemptImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'paymentMethod': instance.paymentMethod,
      'status': instance.status,
      'errorMessage': instance.errorMessage,
      'transactionId': instance.transactionId,
      'amountPaid': instance.amountPaid,
    };
