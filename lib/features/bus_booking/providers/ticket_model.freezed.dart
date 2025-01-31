// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ticket_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExtendedTicket _$ExtendedTicketFromJson(Map<String, dynamic> json) {
  return _ExtendedTicket.fromJson(json);
}

/// @nodoc
mixin _$ExtendedTicket {
  String get id => throw _privateConstructorUsedError;
  Bus get bus => throw _privateConstructorUsedError;
  String get passengerName => throw _privateConstructorUsedError;
  String get phoneNumber => throw _privateConstructorUsedError;
  DateTime get purchaseDate => throw _privateConstructorUsedError;
  double get totalPrice => throw _privateConstructorUsedError;
  String get seatNumber => throw _privateConstructorUsedError;
  String get qrCode => throw _privateConstructorUsedError;
  String get bookingReference => throw _privateConstructorUsedError;
  PaymentMethod get paymentMethod => throw _privateConstructorUsedError;
  BookingStatus get status => throw _privateConstructorUsedError;
  String? get cniNumber =>
      throw _privateConstructorUsedError; // Informations supplémentaires pour la gestion
  DateTime? get validationDate => throw _privateConstructorUsedError;
  String? get validatedBy => throw _privateConstructorUsedError;
  bool? get isUsed => throw _privateConstructorUsedError;
  String? get transactionId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExtendedTicketCopyWith<ExtendedTicket> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExtendedTicketCopyWith<$Res> {
  factory $ExtendedTicketCopyWith(
          ExtendedTicket value, $Res Function(ExtendedTicket) then) =
      _$ExtendedTicketCopyWithImpl<$Res, ExtendedTicket>;
  @useResult
  $Res call(
      {String id,
      Bus bus,
      String passengerName,
      String phoneNumber,
      DateTime purchaseDate,
      double totalPrice,
      String seatNumber,
      String qrCode,
      String bookingReference,
      PaymentMethod paymentMethod,
      BookingStatus status,
      String? cniNumber,
      DateTime? validationDate,
      String? validatedBy,
      bool? isUsed,
      String? transactionId});
}

/// @nodoc
class _$ExtendedTicketCopyWithImpl<$Res, $Val extends ExtendedTicket>
    implements $ExtendedTicketCopyWith<$Res> {
  _$ExtendedTicketCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bus = null,
    Object? passengerName = null,
    Object? phoneNumber = null,
    Object? purchaseDate = null,
    Object? totalPrice = null,
    Object? seatNumber = null,
    Object? qrCode = null,
    Object? bookingReference = null,
    Object? paymentMethod = null,
    Object? status = null,
    Object? cniNumber = freezed,
    Object? validationDate = freezed,
    Object? validatedBy = freezed,
    Object? isUsed = freezed,
    Object? transactionId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bus: null == bus
          ? _value.bus
          : bus // ignore: cast_nullable_to_non_nullable
              as Bus,
      passengerName: null == passengerName
          ? _value.passengerName
          : passengerName // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      purchaseDate: null == purchaseDate
          ? _value.purchaseDate
          : purchaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      seatNumber: null == seatNumber
          ? _value.seatNumber
          : seatNumber // ignore: cast_nullable_to_non_nullable
              as String,
      qrCode: null == qrCode
          ? _value.qrCode
          : qrCode // ignore: cast_nullable_to_non_nullable
              as String,
      bookingReference: null == bookingReference
          ? _value.bookingReference
          : bookingReference // ignore: cast_nullable_to_non_nullable
              as String,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      cniNumber: freezed == cniNumber
          ? _value.cniNumber
          : cniNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      validationDate: freezed == validationDate
          ? _value.validationDate
          : validationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      validatedBy: freezed == validatedBy
          ? _value.validatedBy
          : validatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      isUsed: freezed == isUsed
          ? _value.isUsed
          : isUsed // ignore: cast_nullable_to_non_nullable
              as bool?,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExtendedTicketImplCopyWith<$Res>
    implements $ExtendedTicketCopyWith<$Res> {
  factory _$$ExtendedTicketImplCopyWith(_$ExtendedTicketImpl value,
          $Res Function(_$ExtendedTicketImpl) then) =
      __$$ExtendedTicketImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      Bus bus,
      String passengerName,
      String phoneNumber,
      DateTime purchaseDate,
      double totalPrice,
      String seatNumber,
      String qrCode,
      String bookingReference,
      PaymentMethod paymentMethod,
      BookingStatus status,
      String? cniNumber,
      DateTime? validationDate,
      String? validatedBy,
      bool? isUsed,
      String? transactionId});
}

/// @nodoc
class __$$ExtendedTicketImplCopyWithImpl<$Res>
    extends _$ExtendedTicketCopyWithImpl<$Res, _$ExtendedTicketImpl>
    implements _$$ExtendedTicketImplCopyWith<$Res> {
  __$$ExtendedTicketImplCopyWithImpl(
      _$ExtendedTicketImpl _value, $Res Function(_$ExtendedTicketImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bus = null,
    Object? passengerName = null,
    Object? phoneNumber = null,
    Object? purchaseDate = null,
    Object? totalPrice = null,
    Object? seatNumber = null,
    Object? qrCode = null,
    Object? bookingReference = null,
    Object? paymentMethod = null,
    Object? status = null,
    Object? cniNumber = freezed,
    Object? validationDate = freezed,
    Object? validatedBy = freezed,
    Object? isUsed = freezed,
    Object? transactionId = freezed,
  }) {
    return _then(_$ExtendedTicketImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bus: null == bus
          ? _value.bus
          : bus // ignore: cast_nullable_to_non_nullable
              as Bus,
      passengerName: null == passengerName
          ? _value.passengerName
          : passengerName // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      purchaseDate: null == purchaseDate
          ? _value.purchaseDate
          : purchaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      seatNumber: null == seatNumber
          ? _value.seatNumber
          : seatNumber // ignore: cast_nullable_to_non_nullable
              as String,
      qrCode: null == qrCode
          ? _value.qrCode
          : qrCode // ignore: cast_nullable_to_non_nullable
              as String,
      bookingReference: null == bookingReference
          ? _value.bookingReference
          : bookingReference // ignore: cast_nullable_to_non_nullable
              as String,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      cniNumber: freezed == cniNumber
          ? _value.cniNumber
          : cniNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      validationDate: freezed == validationDate
          ? _value.validationDate
          : validationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      validatedBy: freezed == validatedBy
          ? _value.validatedBy
          : validatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      isUsed: freezed == isUsed
          ? _value.isUsed
          : isUsed // ignore: cast_nullable_to_non_nullable
              as bool?,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExtendedTicketImpl implements _ExtendedTicket {
  const _$ExtendedTicketImpl(
      {required this.id,
      required this.bus,
      required this.passengerName,
      required this.phoneNumber,
      required this.purchaseDate,
      required this.totalPrice,
      required this.seatNumber,
      required this.qrCode,
      required this.bookingReference,
      required this.paymentMethod,
      required this.status,
      this.cniNumber,
      this.validationDate,
      this.validatedBy,
      this.isUsed,
      this.transactionId});

  factory _$ExtendedTicketImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExtendedTicketImplFromJson(json);

  @override
  final String id;
  @override
  final Bus bus;
  @override
  final String passengerName;
  @override
  final String phoneNumber;
  @override
  final DateTime purchaseDate;
  @override
  final double totalPrice;
  @override
  final String seatNumber;
  @override
  final String qrCode;
  @override
  final String bookingReference;
  @override
  final PaymentMethod paymentMethod;
  @override
  final BookingStatus status;
  @override
  final String? cniNumber;
// Informations supplémentaires pour la gestion
  @override
  final DateTime? validationDate;
  @override
  final String? validatedBy;
  @override
  final bool? isUsed;
  @override
  final String? transactionId;

  @override
  String toString() {
    return 'ExtendedTicket(id: $id, bus: $bus, passengerName: $passengerName, phoneNumber: $phoneNumber, purchaseDate: $purchaseDate, totalPrice: $totalPrice, seatNumber: $seatNumber, qrCode: $qrCode, bookingReference: $bookingReference, paymentMethod: $paymentMethod, status: $status, cniNumber: $cniNumber, validationDate: $validationDate, validatedBy: $validatedBy, isUsed: $isUsed, transactionId: $transactionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExtendedTicketImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bus, bus) || other.bus == bus) &&
            (identical(other.passengerName, passengerName) ||
                other.passengerName == passengerName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.seatNumber, seatNumber) ||
                other.seatNumber == seatNumber) &&
            (identical(other.qrCode, qrCode) || other.qrCode == qrCode) &&
            (identical(other.bookingReference, bookingReference) ||
                other.bookingReference == bookingReference) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.cniNumber, cniNumber) ||
                other.cniNumber == cniNumber) &&
            (identical(other.validationDate, validationDate) ||
                other.validationDate == validationDate) &&
            (identical(other.validatedBy, validatedBy) ||
                other.validatedBy == validatedBy) &&
            (identical(other.isUsed, isUsed) || other.isUsed == isUsed) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      bus,
      passengerName,
      phoneNumber,
      purchaseDate,
      totalPrice,
      seatNumber,
      qrCode,
      bookingReference,
      paymentMethod,
      status,
      cniNumber,
      validationDate,
      validatedBy,
      isUsed,
      transactionId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExtendedTicketImplCopyWith<_$ExtendedTicketImpl> get copyWith =>
      __$$ExtendedTicketImplCopyWithImpl<_$ExtendedTicketImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExtendedTicketImplToJson(
      this,
    );
  }
}

abstract class _ExtendedTicket implements ExtendedTicket {
  const factory _ExtendedTicket(
      {required final String id,
      required final Bus bus,
      required final String passengerName,
      required final String phoneNumber,
      required final DateTime purchaseDate,
      required final double totalPrice,
      required final String seatNumber,
      required final String qrCode,
      required final String bookingReference,
      required final PaymentMethod paymentMethod,
      required final BookingStatus status,
      final String? cniNumber,
      final DateTime? validationDate,
      final String? validatedBy,
      final bool? isUsed,
      final String? transactionId}) = _$ExtendedTicketImpl;

  factory _ExtendedTicket.fromJson(Map<String, dynamic> json) =
      _$ExtendedTicketImpl.fromJson;

  @override
  String get id;
  @override
  Bus get bus;
  @override
  String get passengerName;
  @override
  String get phoneNumber;
  @override
  DateTime get purchaseDate;
  @override
  double get totalPrice;
  @override
  String get seatNumber;
  @override
  String get qrCode;
  @override
  String get bookingReference;
  @override
  PaymentMethod get paymentMethod;
  @override
  BookingStatus get status;
  @override
  String? get cniNumber;
  @override // Informations supplémentaires pour la gestion
  DateTime? get validationDate;
  @override
  String? get validatedBy;
  @override
  bool? get isUsed;
  @override
  String? get transactionId;
  @override
  @JsonKey(ignore: true)
  _$$ExtendedTicketImplCopyWith<_$ExtendedTicketImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
