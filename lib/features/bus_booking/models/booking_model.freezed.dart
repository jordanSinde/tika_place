// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TicketReservation _$TicketReservationFromJson(Map<String, dynamic> json) {
  return _TicketReservation.fromJson(json);
}

/// @nodoc
mixin _$TicketReservation {
  String get id => throw _privateConstructorUsedError;
  Bus get bus => throw _privateConstructorUsedError;
  List<PassengerInfo> get passengers => throw _privateConstructorUsedError;
  BookingStatus get status => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  PromoCode? get appliedPromoCode => throw _privateConstructorUsedError;
  double? get discountAmount => throw _privateConstructorUsedError;
  PaymentAttempt? get lastPaymentAttempt => throw _privateConstructorUsedError;
  List<PaymentAttempt>? get paymentHistory =>
      throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  bool get isArchived => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TicketReservationCopyWith<TicketReservation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TicketReservationCopyWith<$Res> {
  factory $TicketReservationCopyWith(
          TicketReservation value, $Res Function(TicketReservation) then) =
      _$TicketReservationCopyWithImpl<$Res, TicketReservation>;
  @useResult
  $Res call(
      {String id,
      Bus bus,
      List<PassengerInfo> passengers,
      BookingStatus status,
      double totalAmount,
      DateTime createdAt,
      DateTime expiresAt,
      String userId,
      PromoCode? appliedPromoCode,
      double? discountAmount,
      PaymentAttempt? lastPaymentAttempt,
      List<PaymentAttempt>? paymentHistory,
      String? cancellationReason,
      bool isArchived});

  $PromoCodeCopyWith<$Res>? get appliedPromoCode;
  $PaymentAttemptCopyWith<$Res>? get lastPaymentAttempt;
}

/// @nodoc
class _$TicketReservationCopyWithImpl<$Res, $Val extends TicketReservation>
    implements $TicketReservationCopyWith<$Res> {
  _$TicketReservationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bus = null,
    Object? passengers = null,
    Object? status = null,
    Object? totalAmount = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? userId = null,
    Object? appliedPromoCode = freezed,
    Object? discountAmount = freezed,
    Object? lastPaymentAttempt = freezed,
    Object? paymentHistory = freezed,
    Object? cancellationReason = freezed,
    Object? isArchived = null,
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
      passengers: null == passengers
          ? _value.passengers
          : passengers // ignore: cast_nullable_to_non_nullable
              as List<PassengerInfo>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      appliedPromoCode: freezed == appliedPromoCode
          ? _value.appliedPromoCode
          : appliedPromoCode // ignore: cast_nullable_to_non_nullable
              as PromoCode?,
      discountAmount: freezed == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      lastPaymentAttempt: freezed == lastPaymentAttempt
          ? _value.lastPaymentAttempt
          : lastPaymentAttempt // ignore: cast_nullable_to_non_nullable
              as PaymentAttempt?,
      paymentHistory: freezed == paymentHistory
          ? _value.paymentHistory
          : paymentHistory // ignore: cast_nullable_to_non_nullable
              as List<PaymentAttempt>?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PromoCodeCopyWith<$Res>? get appliedPromoCode {
    if (_value.appliedPromoCode == null) {
      return null;
    }

    return $PromoCodeCopyWith<$Res>(_value.appliedPromoCode!, (value) {
      return _then(_value.copyWith(appliedPromoCode: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PaymentAttemptCopyWith<$Res>? get lastPaymentAttempt {
    if (_value.lastPaymentAttempt == null) {
      return null;
    }

    return $PaymentAttemptCopyWith<$Res>(_value.lastPaymentAttempt!, (value) {
      return _then(_value.copyWith(lastPaymentAttempt: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TicketReservationImplCopyWith<$Res>
    implements $TicketReservationCopyWith<$Res> {
  factory _$$TicketReservationImplCopyWith(_$TicketReservationImpl value,
          $Res Function(_$TicketReservationImpl) then) =
      __$$TicketReservationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      Bus bus,
      List<PassengerInfo> passengers,
      BookingStatus status,
      double totalAmount,
      DateTime createdAt,
      DateTime expiresAt,
      String userId,
      PromoCode? appliedPromoCode,
      double? discountAmount,
      PaymentAttempt? lastPaymentAttempt,
      List<PaymentAttempt>? paymentHistory,
      String? cancellationReason,
      bool isArchived});

  @override
  $PromoCodeCopyWith<$Res>? get appliedPromoCode;
  @override
  $PaymentAttemptCopyWith<$Res>? get lastPaymentAttempt;
}

/// @nodoc
class __$$TicketReservationImplCopyWithImpl<$Res>
    extends _$TicketReservationCopyWithImpl<$Res, _$TicketReservationImpl>
    implements _$$TicketReservationImplCopyWith<$Res> {
  __$$TicketReservationImplCopyWithImpl(_$TicketReservationImpl _value,
      $Res Function(_$TicketReservationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bus = null,
    Object? passengers = null,
    Object? status = null,
    Object? totalAmount = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? userId = null,
    Object? appliedPromoCode = freezed,
    Object? discountAmount = freezed,
    Object? lastPaymentAttempt = freezed,
    Object? paymentHistory = freezed,
    Object? cancellationReason = freezed,
    Object? isArchived = null,
  }) {
    return _then(_$TicketReservationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bus: null == bus
          ? _value.bus
          : bus // ignore: cast_nullable_to_non_nullable
              as Bus,
      passengers: null == passengers
          ? _value._passengers
          : passengers // ignore: cast_nullable_to_non_nullable
              as List<PassengerInfo>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      appliedPromoCode: freezed == appliedPromoCode
          ? _value.appliedPromoCode
          : appliedPromoCode // ignore: cast_nullable_to_non_nullable
              as PromoCode?,
      discountAmount: freezed == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      lastPaymentAttempt: freezed == lastPaymentAttempt
          ? _value.lastPaymentAttempt
          : lastPaymentAttempt // ignore: cast_nullable_to_non_nullable
              as PaymentAttempt?,
      paymentHistory: freezed == paymentHistory
          ? _value._paymentHistory
          : paymentHistory // ignore: cast_nullable_to_non_nullable
              as List<PaymentAttempt>?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TicketReservationImpl implements _TicketReservation {
  const _$TicketReservationImpl(
      {required this.id,
      required this.bus,
      required final List<PassengerInfo> passengers,
      required this.status,
      required this.totalAmount,
      required this.createdAt,
      required this.expiresAt,
      required this.userId,
      this.appliedPromoCode,
      this.discountAmount,
      this.lastPaymentAttempt,
      final List<PaymentAttempt>? paymentHistory,
      this.cancellationReason,
      this.isArchived = false})
      : _passengers = passengers,
        _paymentHistory = paymentHistory;

  factory _$TicketReservationImpl.fromJson(Map<String, dynamic> json) =>
      _$$TicketReservationImplFromJson(json);

  @override
  final String id;
  @override
  final Bus bus;
  final List<PassengerInfo> _passengers;
  @override
  List<PassengerInfo> get passengers {
    if (_passengers is EqualUnmodifiableListView) return _passengers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_passengers);
  }

  @override
  final BookingStatus status;
  @override
  final double totalAmount;
  @override
  final DateTime createdAt;
  @override
  final DateTime expiresAt;
  @override
  final String userId;
  @override
  final PromoCode? appliedPromoCode;
  @override
  final double? discountAmount;
  @override
  final PaymentAttempt? lastPaymentAttempt;
  final List<PaymentAttempt>? _paymentHistory;
  @override
  List<PaymentAttempt>? get paymentHistory {
    final value = _paymentHistory;
    if (value == null) return null;
    if (_paymentHistory is EqualUnmodifiableListView) return _paymentHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? cancellationReason;
  @override
  @JsonKey()
  final bool isArchived;

  @override
  String toString() {
    return 'TicketReservation(id: $id, bus: $bus, passengers: $passengers, status: $status, totalAmount: $totalAmount, createdAt: $createdAt, expiresAt: $expiresAt, userId: $userId, appliedPromoCode: $appliedPromoCode, discountAmount: $discountAmount, lastPaymentAttempt: $lastPaymentAttempt, paymentHistory: $paymentHistory, cancellationReason: $cancellationReason, isArchived: $isArchived)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TicketReservationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bus, bus) || other.bus == bus) &&
            const DeepCollectionEquality()
                .equals(other._passengers, _passengers) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.appliedPromoCode, appliedPromoCode) ||
                other.appliedPromoCode == appliedPromoCode) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.lastPaymentAttempt, lastPaymentAttempt) ||
                other.lastPaymentAttempt == lastPaymentAttempt) &&
            const DeepCollectionEquality()
                .equals(other._paymentHistory, _paymentHistory) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      bus,
      const DeepCollectionEquality().hash(_passengers),
      status,
      totalAmount,
      createdAt,
      expiresAt,
      userId,
      appliedPromoCode,
      discountAmount,
      lastPaymentAttempt,
      const DeepCollectionEquality().hash(_paymentHistory),
      cancellationReason,
      isArchived);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TicketReservationImplCopyWith<_$TicketReservationImpl> get copyWith =>
      __$$TicketReservationImplCopyWithImpl<_$TicketReservationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TicketReservationImplToJson(
      this,
    );
  }
}

abstract class _TicketReservation implements TicketReservation {
  const factory _TicketReservation(
      {required final String id,
      required final Bus bus,
      required final List<PassengerInfo> passengers,
      required final BookingStatus status,
      required final double totalAmount,
      required final DateTime createdAt,
      required final DateTime expiresAt,
      required final String userId,
      final PromoCode? appliedPromoCode,
      final double? discountAmount,
      final PaymentAttempt? lastPaymentAttempt,
      final List<PaymentAttempt>? paymentHistory,
      final String? cancellationReason,
      final bool isArchived}) = _$TicketReservationImpl;

  factory _TicketReservation.fromJson(Map<String, dynamic> json) =
      _$TicketReservationImpl.fromJson;

  @override
  String get id;
  @override
  Bus get bus;
  @override
  List<PassengerInfo> get passengers;
  @override
  BookingStatus get status;
  @override
  double get totalAmount;
  @override
  DateTime get createdAt;
  @override
  DateTime get expiresAt;
  @override
  String get userId;
  @override
  PromoCode? get appliedPromoCode;
  @override
  double? get discountAmount;
  @override
  PaymentAttempt? get lastPaymentAttempt;
  @override
  List<PaymentAttempt>? get paymentHistory;
  @override
  String? get cancellationReason;
  @override
  bool get isArchived;
  @override
  @JsonKey(ignore: true)
  _$$TicketReservationImplCopyWith<_$TicketReservationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PassengerInfo _$PassengerInfoFromJson(Map<String, dynamic> json) {
  return _PassengerInfo.fromJson(json);
}

/// @nodoc
mixin _$PassengerInfo {
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  int? get cniNumber => throw _privateConstructorUsedError;
  bool get isMainPassenger => throw _privateConstructorUsedError;
  String? get seatNumber => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PassengerInfoCopyWith<PassengerInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PassengerInfoCopyWith<$Res> {
  factory $PassengerInfoCopyWith(
          PassengerInfo value, $Res Function(PassengerInfo) then) =
      _$PassengerInfoCopyWithImpl<$Res, PassengerInfo>;
  @useResult
  $Res call(
      {String firstName,
      String lastName,
      String? phoneNumber,
      int? cniNumber,
      bool isMainPassenger,
      String? seatNumber});
}

/// @nodoc
class _$PassengerInfoCopyWithImpl<$Res, $Val extends PassengerInfo>
    implements $PassengerInfoCopyWith<$Res> {
  _$PassengerInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? phoneNumber = freezed,
    Object? cniNumber = freezed,
    Object? isMainPassenger = null,
    Object? seatNumber = freezed,
  }) {
    return _then(_value.copyWith(
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      cniNumber: freezed == cniNumber
          ? _value.cniNumber
          : cniNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      isMainPassenger: null == isMainPassenger
          ? _value.isMainPassenger
          : isMainPassenger // ignore: cast_nullable_to_non_nullable
              as bool,
      seatNumber: freezed == seatNumber
          ? _value.seatNumber
          : seatNumber // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PassengerInfoImplCopyWith<$Res>
    implements $PassengerInfoCopyWith<$Res> {
  factory _$$PassengerInfoImplCopyWith(
          _$PassengerInfoImpl value, $Res Function(_$PassengerInfoImpl) then) =
      __$$PassengerInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String firstName,
      String lastName,
      String? phoneNumber,
      int? cniNumber,
      bool isMainPassenger,
      String? seatNumber});
}

/// @nodoc
class __$$PassengerInfoImplCopyWithImpl<$Res>
    extends _$PassengerInfoCopyWithImpl<$Res, _$PassengerInfoImpl>
    implements _$$PassengerInfoImplCopyWith<$Res> {
  __$$PassengerInfoImplCopyWithImpl(
      _$PassengerInfoImpl _value, $Res Function(_$PassengerInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? phoneNumber = freezed,
    Object? cniNumber = freezed,
    Object? isMainPassenger = null,
    Object? seatNumber = freezed,
  }) {
    return _then(_$PassengerInfoImpl(
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      cniNumber: freezed == cniNumber
          ? _value.cniNumber
          : cniNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      isMainPassenger: null == isMainPassenger
          ? _value.isMainPassenger
          : isMainPassenger // ignore: cast_nullable_to_non_nullable
              as bool,
      seatNumber: freezed == seatNumber
          ? _value.seatNumber
          : seatNumber // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PassengerInfoImpl implements _PassengerInfo {
  const _$PassengerInfoImpl(
      {required this.firstName,
      required this.lastName,
      required this.phoneNumber,
      required this.cniNumber,
      required this.isMainPassenger,
      this.seatNumber});

  factory _$PassengerInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PassengerInfoImplFromJson(json);

  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String? phoneNumber;
  @override
  final int? cniNumber;
  @override
  final bool isMainPassenger;
  @override
  final String? seatNumber;

  @override
  String toString() {
    return 'PassengerInfo(firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, cniNumber: $cniNumber, isMainPassenger: $isMainPassenger, seatNumber: $seatNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PassengerInfoImpl &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.cniNumber, cniNumber) ||
                other.cniNumber == cniNumber) &&
            (identical(other.isMainPassenger, isMainPassenger) ||
                other.isMainPassenger == isMainPassenger) &&
            (identical(other.seatNumber, seatNumber) ||
                other.seatNumber == seatNumber));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, firstName, lastName, phoneNumber,
      cniNumber, isMainPassenger, seatNumber);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PassengerInfoImplCopyWith<_$PassengerInfoImpl> get copyWith =>
      __$$PassengerInfoImplCopyWithImpl<_$PassengerInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PassengerInfoImplToJson(
      this,
    );
  }
}

abstract class _PassengerInfo implements PassengerInfo {
  const factory _PassengerInfo(
      {required final String firstName,
      required final String lastName,
      required final String? phoneNumber,
      required final int? cniNumber,
      required final bool isMainPassenger,
      final String? seatNumber}) = _$PassengerInfoImpl;

  factory _PassengerInfo.fromJson(Map<String, dynamic> json) =
      _$PassengerInfoImpl.fromJson;

  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String? get phoneNumber;
  @override
  int? get cniNumber;
  @override
  bool get isMainPassenger;
  @override
  String? get seatNumber;
  @override
  @JsonKey(ignore: true)
  _$$PassengerInfoImplCopyWith<_$PassengerInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PaymentAttempt _$PaymentAttemptFromJson(Map<String, dynamic> json) {
  return _PaymentAttempt.fromJson(json);
}

/// @nodoc
mixin _$PaymentAttempt {
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get paymentMethod => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get transactionId => throw _privateConstructorUsedError;
  double? get amountPaid => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PaymentAttemptCopyWith<PaymentAttempt> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentAttemptCopyWith<$Res> {
  factory $PaymentAttemptCopyWith(
          PaymentAttempt value, $Res Function(PaymentAttempt) then) =
      _$PaymentAttemptCopyWithImpl<$Res, PaymentAttempt>;
  @useResult
  $Res call(
      {DateTime timestamp,
      String paymentMethod,
      String status,
      String? errorMessage,
      String? transactionId,
      double? amountPaid});
}

/// @nodoc
class _$PaymentAttemptCopyWithImpl<$Res, $Val extends PaymentAttempt>
    implements $PaymentAttemptCopyWith<$Res> {
  _$PaymentAttemptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? paymentMethod = null,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? transactionId = freezed,
    Object? amountPaid = freezed,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      amountPaid: freezed == amountPaid
          ? _value.amountPaid
          : amountPaid // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentAttemptImplCopyWith<$Res>
    implements $PaymentAttemptCopyWith<$Res> {
  factory _$$PaymentAttemptImplCopyWith(_$PaymentAttemptImpl value,
          $Res Function(_$PaymentAttemptImpl) then) =
      __$$PaymentAttemptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime timestamp,
      String paymentMethod,
      String status,
      String? errorMessage,
      String? transactionId,
      double? amountPaid});
}

/// @nodoc
class __$$PaymentAttemptImplCopyWithImpl<$Res>
    extends _$PaymentAttemptCopyWithImpl<$Res, _$PaymentAttemptImpl>
    implements _$$PaymentAttemptImplCopyWith<$Res> {
  __$$PaymentAttemptImplCopyWithImpl(
      _$PaymentAttemptImpl _value, $Res Function(_$PaymentAttemptImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? paymentMethod = null,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? transactionId = freezed,
    Object? amountPaid = freezed,
  }) {
    return _then(_$PaymentAttemptImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      amountPaid: freezed == amountPaid
          ? _value.amountPaid
          : amountPaid // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentAttemptImpl implements _PaymentAttempt {
  const _$PaymentAttemptImpl(
      {required this.timestamp,
      required this.paymentMethod,
      required this.status,
      this.errorMessage,
      this.transactionId,
      this.amountPaid});

  factory _$PaymentAttemptImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentAttemptImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final String paymentMethod;
  @override
  final String status;
  @override
  final String? errorMessage;
  @override
  final String? transactionId;
  @override
  final double? amountPaid;

  @override
  String toString() {
    return 'PaymentAttempt(timestamp: $timestamp, paymentMethod: $paymentMethod, status: $status, errorMessage: $errorMessage, transactionId: $transactionId, amountPaid: $amountPaid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentAttemptImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.amountPaid, amountPaid) ||
                other.amountPaid == amountPaid));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, timestamp, paymentMethod, status,
      errorMessage, transactionId, amountPaid);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentAttemptImplCopyWith<_$PaymentAttemptImpl> get copyWith =>
      __$$PaymentAttemptImplCopyWithImpl<_$PaymentAttemptImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentAttemptImplToJson(
      this,
    );
  }
}

abstract class _PaymentAttempt implements PaymentAttempt {
  const factory _PaymentAttempt(
      {required final DateTime timestamp,
      required final String paymentMethod,
      required final String status,
      final String? errorMessage,
      final String? transactionId,
      final double? amountPaid}) = _$PaymentAttemptImpl;

  factory _PaymentAttempt.fromJson(Map<String, dynamic> json) =
      _$PaymentAttemptImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  String get paymentMethod;
  @override
  String get status;
  @override
  String? get errorMessage;
  @override
  String? get transactionId;
  @override
  double? get amountPaid;
  @override
  @JsonKey(ignore: true)
  _$$PaymentAttemptImplCopyWith<_$PaymentAttemptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
