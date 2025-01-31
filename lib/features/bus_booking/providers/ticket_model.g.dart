// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExtendedTicketImpl _$$ExtendedTicketImplFromJson(Map<String, dynamic> json) =>
    _$ExtendedTicketImpl(
      id: json['id'] as String,
      bus: Bus.fromJson(json['bus'] as Map<String, dynamic>),
      passengerName: json['passengerName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      seatNumber: json['seatNumber'] as String,
      qrCode: json['qrCode'] as String,
      bookingReference: json['bookingReference'] as String,
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      cniNumber: json['cniNumber'] as String?,
      validationDate: json['validationDate'] == null
          ? null
          : DateTime.parse(json['validationDate'] as String),
      validatedBy: json['validatedBy'] as String?,
      isUsed: json['isUsed'] as bool?,
      transactionId: json['transactionId'] as String?,
    );

Map<String, dynamic> _$$ExtendedTicketImplToJson(
        _$ExtendedTicketImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bus': instance.bus,
      'passengerName': instance.passengerName,
      'phoneNumber': instance.phoneNumber,
      'purchaseDate': instance.purchaseDate.toIso8601String(),
      'totalPrice': instance.totalPrice,
      'seatNumber': instance.seatNumber,
      'qrCode': instance.qrCode,
      'bookingReference': instance.bookingReference,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'cniNumber': instance.cniNumber,
      'validationDate': instance.validationDate?.toIso8601String(),
      'validatedBy': instance.validatedBy,
      'isUsed': instance.isUsed,
      'transactionId': instance.transactionId,
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.orangeMoney: 'orangeMoney',
  PaymentMethod.mtnMoney: 'mtnMoney',
};

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.paid: 'paid',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.failed: 'failed',
};
