// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bus_booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BusBooking _$BusBookingFromJson(Map<String, dynamic> json) {
  return _BusBooking.fromJson(json);
}

/// @nodoc
mixin _$BusBooking {
  String get id => throw _privateConstructorUsedError;
  String get routeId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  int get numberOfPassengers => throw _privateConstructorUsedError;
  bool get hasExtraLuggage => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  DateTime get bookingDate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get paymentId => throw _privateConstructorUsedError;
  String? get qrCode => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BusBookingCopyWith<BusBooking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusBookingCopyWith<$Res> {
  factory $BusBookingCopyWith(
          BusBooking value, $Res Function(BusBooking) then) =
      _$BusBookingCopyWithImpl<$Res, BusBooking>;
  @useResult
  $Res call(
      {String id,
      String routeId,
      String userId,
      int numberOfPassengers,
      bool hasExtraLuggage,
      double totalAmount,
      DateTime bookingDate,
      String status,
      String? paymentId,
      String? qrCode});
}

/// @nodoc
class _$BusBookingCopyWithImpl<$Res, $Val extends BusBooking>
    implements $BusBookingCopyWith<$Res> {
  _$BusBookingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? routeId = null,
    Object? userId = null,
    Object? numberOfPassengers = null,
    Object? hasExtraLuggage = null,
    Object? totalAmount = null,
    Object? bookingDate = null,
    Object? status = null,
    Object? paymentId = freezed,
    Object? qrCode = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      routeId: null == routeId
          ? _value.routeId
          : routeId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      numberOfPassengers: null == numberOfPassengers
          ? _value.numberOfPassengers
          : numberOfPassengers // ignore: cast_nullable_to_non_nullable
              as int,
      hasExtraLuggage: null == hasExtraLuggage
          ? _value.hasExtraLuggage
          : hasExtraLuggage // ignore: cast_nullable_to_non_nullable
              as bool,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      bookingDate: null == bookingDate
          ? _value.bookingDate
          : bookingDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paymentId: freezed == paymentId
          ? _value.paymentId
          : paymentId // ignore: cast_nullable_to_non_nullable
              as String?,
      qrCode: freezed == qrCode
          ? _value.qrCode
          : qrCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BusBookingImplCopyWith<$Res>
    implements $BusBookingCopyWith<$Res> {
  factory _$$BusBookingImplCopyWith(
          _$BusBookingImpl value, $Res Function(_$BusBookingImpl) then) =
      __$$BusBookingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String routeId,
      String userId,
      int numberOfPassengers,
      bool hasExtraLuggage,
      double totalAmount,
      DateTime bookingDate,
      String status,
      String? paymentId,
      String? qrCode});
}

/// @nodoc
class __$$BusBookingImplCopyWithImpl<$Res>
    extends _$BusBookingCopyWithImpl<$Res, _$BusBookingImpl>
    implements _$$BusBookingImplCopyWith<$Res> {
  __$$BusBookingImplCopyWithImpl(
      _$BusBookingImpl _value, $Res Function(_$BusBookingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? routeId = null,
    Object? userId = null,
    Object? numberOfPassengers = null,
    Object? hasExtraLuggage = null,
    Object? totalAmount = null,
    Object? bookingDate = null,
    Object? status = null,
    Object? paymentId = freezed,
    Object? qrCode = freezed,
  }) {
    return _then(_$BusBookingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      routeId: null == routeId
          ? _value.routeId
          : routeId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      numberOfPassengers: null == numberOfPassengers
          ? _value.numberOfPassengers
          : numberOfPassengers // ignore: cast_nullable_to_non_nullable
              as int,
      hasExtraLuggage: null == hasExtraLuggage
          ? _value.hasExtraLuggage
          : hasExtraLuggage // ignore: cast_nullable_to_non_nullable
              as bool,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      bookingDate: null == bookingDate
          ? _value.bookingDate
          : bookingDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paymentId: freezed == paymentId
          ? _value.paymentId
          : paymentId // ignore: cast_nullable_to_non_nullable
              as String?,
      qrCode: freezed == qrCode
          ? _value.qrCode
          : qrCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BusBookingImpl implements _BusBooking {
  const _$BusBookingImpl(
      {required this.id,
      required this.routeId,
      required this.userId,
      required this.numberOfPassengers,
      required this.hasExtraLuggage,
      required this.totalAmount,
      required this.bookingDate,
      this.status = 'pending',
      this.paymentId,
      this.qrCode});

  factory _$BusBookingImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusBookingImplFromJson(json);

  @override
  final String id;
  @override
  final String routeId;
  @override
  final String userId;
  @override
  final int numberOfPassengers;
  @override
  final bool hasExtraLuggage;
  @override
  final double totalAmount;
  @override
  final DateTime bookingDate;
  @override
  @JsonKey()
  final String status;
  @override
  final String? paymentId;
  @override
  final String? qrCode;

  @override
  String toString() {
    return 'BusBooking(id: $id, routeId: $routeId, userId: $userId, numberOfPassengers: $numberOfPassengers, hasExtraLuggage: $hasExtraLuggage, totalAmount: $totalAmount, bookingDate: $bookingDate, status: $status, paymentId: $paymentId, qrCode: $qrCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusBookingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.routeId, routeId) || other.routeId == routeId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.numberOfPassengers, numberOfPassengers) ||
                other.numberOfPassengers == numberOfPassengers) &&
            (identical(other.hasExtraLuggage, hasExtraLuggage) ||
                other.hasExtraLuggage == hasExtraLuggage) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.bookingDate, bookingDate) ||
                other.bookingDate == bookingDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentId, paymentId) ||
                other.paymentId == paymentId) &&
            (identical(other.qrCode, qrCode) || other.qrCode == qrCode));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      routeId,
      userId,
      numberOfPassengers,
      hasExtraLuggage,
      totalAmount,
      bookingDate,
      status,
      paymentId,
      qrCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BusBookingImplCopyWith<_$BusBookingImpl> get copyWith =>
      __$$BusBookingImplCopyWithImpl<_$BusBookingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusBookingImplToJson(
      this,
    );
  }
}

abstract class _BusBooking implements BusBooking {
  const factory _BusBooking(
      {required final String id,
      required final String routeId,
      required final String userId,
      required final int numberOfPassengers,
      required final bool hasExtraLuggage,
      required final double totalAmount,
      required final DateTime bookingDate,
      final String status,
      final String? paymentId,
      final String? qrCode}) = _$BusBookingImpl;

  factory _BusBooking.fromJson(Map<String, dynamic> json) =
      _$BusBookingImpl.fromJson;

  @override
  String get id;
  @override
  String get routeId;
  @override
  String get userId;
  @override
  int get numberOfPassengers;
  @override
  bool get hasExtraLuggage;
  @override
  double get totalAmount;
  @override
  DateTime get bookingDate;
  @override
  String get status;
  @override
  String? get paymentId;
  @override
  String? get qrCode;
  @override
  @JsonKey(ignore: true)
  _$$BusBookingImplCopyWith<_$BusBookingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
