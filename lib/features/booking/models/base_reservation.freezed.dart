// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base_reservation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BaseReservation _$BaseReservationFromJson(Map<String, dynamic> json) {
  return _BaseReservation.fromJson(json);
}

/// @nodoc
mixin _$BaseReservation {
  String get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  ReservationType get type => throw _privateConstructorUsedError;
  ReservationStatus get status => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get paymentId => throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  bool get isArchived => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BaseReservationCopyWith<BaseReservation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BaseReservationCopyWith<$Res> {
  factory $BaseReservationCopyWith(
          BaseReservation value, $Res Function(BaseReservation) then) =
      _$BaseReservationCopyWithImpl<$Res, BaseReservation>;
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      DateTime updatedAt,
      ReservationType type,
      ReservationStatus status,
      double amount,
      String userId,
      String? paymentId,
      String? cancellationReason,
      bool isArchived});
}

/// @nodoc
class _$BaseReservationCopyWithImpl<$Res, $Val extends BaseReservation>
    implements $BaseReservationCopyWith<$Res> {
  _$BaseReservationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? type = null,
    Object? status = null,
    Object? amount = null,
    Object? userId = null,
    Object? paymentId = freezed,
    Object? cancellationReason = freezed,
    Object? isArchived = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReservationType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReservationStatus,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      paymentId: freezed == paymentId
          ? _value.paymentId
          : paymentId // ignore: cast_nullable_to_non_nullable
              as String?,
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
}

/// @nodoc
abstract class _$$BaseReservationImplCopyWith<$Res>
    implements $BaseReservationCopyWith<$Res> {
  factory _$$BaseReservationImplCopyWith(_$BaseReservationImpl value,
          $Res Function(_$BaseReservationImpl) then) =
      __$$BaseReservationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      DateTime updatedAt,
      ReservationType type,
      ReservationStatus status,
      double amount,
      String userId,
      String? paymentId,
      String? cancellationReason,
      bool isArchived});
}

/// @nodoc
class __$$BaseReservationImplCopyWithImpl<$Res>
    extends _$BaseReservationCopyWithImpl<$Res, _$BaseReservationImpl>
    implements _$$BaseReservationImplCopyWith<$Res> {
  __$$BaseReservationImplCopyWithImpl(
      _$BaseReservationImpl _value, $Res Function(_$BaseReservationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? type = null,
    Object? status = null,
    Object? amount = null,
    Object? userId = null,
    Object? paymentId = freezed,
    Object? cancellationReason = freezed,
    Object? isArchived = null,
  }) {
    return _then(_$BaseReservationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReservationType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReservationStatus,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      paymentId: freezed == paymentId
          ? _value.paymentId
          : paymentId // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$BaseReservationImpl implements _BaseReservation {
  const _$BaseReservationImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.type,
      required this.status,
      required this.amount,
      required this.userId,
      this.paymentId,
      this.cancellationReason,
      this.isArchived = false});

  factory _$BaseReservationImpl.fromJson(Map<String, dynamic> json) =>
      _$$BaseReservationImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final ReservationType type;
  @override
  final ReservationStatus status;
  @override
  final double amount;
  @override
  final String userId;
  @override
  final String? paymentId;
  @override
  final String? cancellationReason;
  @override
  @JsonKey()
  final bool isArchived;

  @override
  String toString() {
    return 'BaseReservation(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, type: $type, status: $status, amount: $amount, userId: $userId, paymentId: $paymentId, cancellationReason: $cancellationReason, isArchived: $isArchived)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BaseReservationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.paymentId, paymentId) ||
                other.paymentId == paymentId) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, updatedAt, type,
      status, amount, userId, paymentId, cancellationReason, isArchived);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BaseReservationImplCopyWith<_$BaseReservationImpl> get copyWith =>
      __$$BaseReservationImplCopyWithImpl<_$BaseReservationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BaseReservationImplToJson(
      this,
    );
  }
}

abstract class _BaseReservation implements BaseReservation {
  const factory _BaseReservation(
      {required final String id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final ReservationType type,
      required final ReservationStatus status,
      required final double amount,
      required final String userId,
      final String? paymentId,
      final String? cancellationReason,
      final bool isArchived}) = _$BaseReservationImpl;

  factory _BaseReservation.fromJson(Map<String, dynamic> json) =
      _$BaseReservationImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  ReservationType get type;
  @override
  ReservationStatus get status;
  @override
  double get amount;
  @override
  String get userId;
  @override
  String? get paymentId;
  @override
  String? get cancellationReason;
  @override
  bool get isArchived;
  @override
  @JsonKey(ignore: true)
  _$$BaseReservationImplCopyWith<_$BaseReservationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BusReservation _$BusReservationFromJson(Map<String, dynamic> json) {
  return _BusReservation.fromJson(json);
}

/// @nodoc
mixin _$BusReservation {
  BaseReservation get base => throw _privateConstructorUsedError;
  Bus get bus => throw _privateConstructorUsedError;
  List<PassengerInfo> get passengers => throw _privateConstructorUsedError;
  PromoCode? get appliedPromoCode => throw _privateConstructorUsedError;
  double? get discountAmount => throw _privateConstructorUsedError;
  PaymentAttempt? get lastPaymentAttempt => throw _privateConstructorUsedError;
  List<PaymentAttempt>? get paymentHistory =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BusReservationCopyWith<BusReservation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusReservationCopyWith<$Res> {
  factory $BusReservationCopyWith(
          BusReservation value, $Res Function(BusReservation) then) =
      _$BusReservationCopyWithImpl<$Res, BusReservation>;
  @useResult
  $Res call(
      {BaseReservation base,
      Bus bus,
      List<PassengerInfo> passengers,
      PromoCode? appliedPromoCode,
      double? discountAmount,
      PaymentAttempt? lastPaymentAttempt,
      List<PaymentAttempt>? paymentHistory});

  $BaseReservationCopyWith<$Res> get base;
  $PromoCodeCopyWith<$Res>? get appliedPromoCode;
  $PaymentAttemptCopyWith<$Res>? get lastPaymentAttempt;
}

/// @nodoc
class _$BusReservationCopyWithImpl<$Res, $Val extends BusReservation>
    implements $BusReservationCopyWith<$Res> {
  _$BusReservationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? base = null,
    Object? bus = null,
    Object? passengers = null,
    Object? appliedPromoCode = freezed,
    Object? discountAmount = freezed,
    Object? lastPaymentAttempt = freezed,
    Object? paymentHistory = freezed,
  }) {
    return _then(_value.copyWith(
      base: null == base
          ? _value.base
          : base // ignore: cast_nullable_to_non_nullable
              as BaseReservation,
      bus: null == bus
          ? _value.bus
          : bus // ignore: cast_nullable_to_non_nullable
              as Bus,
      passengers: null == passengers
          ? _value.passengers
          : passengers // ignore: cast_nullable_to_non_nullable
              as List<PassengerInfo>,
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
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BaseReservationCopyWith<$Res> get base {
    return $BaseReservationCopyWith<$Res>(_value.base, (value) {
      return _then(_value.copyWith(base: value) as $Val);
    });
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
abstract class _$$BusReservationImplCopyWith<$Res>
    implements $BusReservationCopyWith<$Res> {
  factory _$$BusReservationImplCopyWith(_$BusReservationImpl value,
          $Res Function(_$BusReservationImpl) then) =
      __$$BusReservationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {BaseReservation base,
      Bus bus,
      List<PassengerInfo> passengers,
      PromoCode? appliedPromoCode,
      double? discountAmount,
      PaymentAttempt? lastPaymentAttempt,
      List<PaymentAttempt>? paymentHistory});

  @override
  $BaseReservationCopyWith<$Res> get base;
  @override
  $PromoCodeCopyWith<$Res>? get appliedPromoCode;
  @override
  $PaymentAttemptCopyWith<$Res>? get lastPaymentAttempt;
}

/// @nodoc
class __$$BusReservationImplCopyWithImpl<$Res>
    extends _$BusReservationCopyWithImpl<$Res, _$BusReservationImpl>
    implements _$$BusReservationImplCopyWith<$Res> {
  __$$BusReservationImplCopyWithImpl(
      _$BusReservationImpl _value, $Res Function(_$BusReservationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? base = null,
    Object? bus = null,
    Object? passengers = null,
    Object? appliedPromoCode = freezed,
    Object? discountAmount = freezed,
    Object? lastPaymentAttempt = freezed,
    Object? paymentHistory = freezed,
  }) {
    return _then(_$BusReservationImpl(
      base: null == base
          ? _value.base
          : base // ignore: cast_nullable_to_non_nullable
              as BaseReservation,
      bus: null == bus
          ? _value.bus
          : bus // ignore: cast_nullable_to_non_nullable
              as Bus,
      passengers: null == passengers
          ? _value._passengers
          : passengers // ignore: cast_nullable_to_non_nullable
              as List<PassengerInfo>,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BusReservationImpl implements _BusReservation {
  const _$BusReservationImpl(
      {required this.base,
      required this.bus,
      required final List<PassengerInfo> passengers,
      this.appliedPromoCode,
      this.discountAmount,
      this.lastPaymentAttempt,
      final List<PaymentAttempt>? paymentHistory})
      : _passengers = passengers,
        _paymentHistory = paymentHistory;

  factory _$BusReservationImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusReservationImplFromJson(json);

  @override
  final BaseReservation base;
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
  String toString() {
    return 'BusReservation(base: $base, bus: $bus, passengers: $passengers, appliedPromoCode: $appliedPromoCode, discountAmount: $discountAmount, lastPaymentAttempt: $lastPaymentAttempt, paymentHistory: $paymentHistory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusReservationImpl &&
            (identical(other.base, base) || other.base == base) &&
            (identical(other.bus, bus) || other.bus == bus) &&
            const DeepCollectionEquality()
                .equals(other._passengers, _passengers) &&
            (identical(other.appliedPromoCode, appliedPromoCode) ||
                other.appliedPromoCode == appliedPromoCode) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.lastPaymentAttempt, lastPaymentAttempt) ||
                other.lastPaymentAttempt == lastPaymentAttempt) &&
            const DeepCollectionEquality()
                .equals(other._paymentHistory, _paymentHistory));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      base,
      bus,
      const DeepCollectionEquality().hash(_passengers),
      appliedPromoCode,
      discountAmount,
      lastPaymentAttempt,
      const DeepCollectionEquality().hash(_paymentHistory));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BusReservationImplCopyWith<_$BusReservationImpl> get copyWith =>
      __$$BusReservationImplCopyWithImpl<_$BusReservationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusReservationImplToJson(
      this,
    );
  }
}

abstract class _BusReservation implements BusReservation {
  const factory _BusReservation(
      {required final BaseReservation base,
      required final Bus bus,
      required final List<PassengerInfo> passengers,
      final PromoCode? appliedPromoCode,
      final double? discountAmount,
      final PaymentAttempt? lastPaymentAttempt,
      final List<PaymentAttempt>? paymentHistory}) = _$BusReservationImpl;

  factory _BusReservation.fromJson(Map<String, dynamic> json) =
      _$BusReservationImpl.fromJson;

  @override
  BaseReservation get base;
  @override
  Bus get bus;
  @override
  List<PassengerInfo> get passengers;
  @override
  PromoCode? get appliedPromoCode;
  @override
  double? get discountAmount;
  @override
  PaymentAttempt? get lastPaymentAttempt;
  @override
  List<PaymentAttempt>? get paymentHistory;
  @override
  @JsonKey(ignore: true)
  _$$BusReservationImplCopyWith<_$BusReservationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HotelReservation _$HotelReservationFromJson(Map<String, dynamic> json) {
  return _HotelReservation.fromJson(json);
}

/// @nodoc
mixin _$HotelReservation {
  BaseReservation get base => throw _privateConstructorUsedError;
  String get hotelId => throw _privateConstructorUsedError;
  String get roomId => throw _privateConstructorUsedError;
  DateTime get checkIn => throw _privateConstructorUsedError;
  DateTime get checkOut => throw _privateConstructorUsedError;
  int get guests => throw _privateConstructorUsedError;
  String? get specialRequests => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HotelReservationCopyWith<HotelReservation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HotelReservationCopyWith<$Res> {
  factory $HotelReservationCopyWith(
          HotelReservation value, $Res Function(HotelReservation) then) =
      _$HotelReservationCopyWithImpl<$Res, HotelReservation>;
  @useResult
  $Res call(
      {BaseReservation base,
      String hotelId,
      String roomId,
      DateTime checkIn,
      DateTime checkOut,
      int guests,
      String? specialRequests});

  $BaseReservationCopyWith<$Res> get base;
}

/// @nodoc
class _$HotelReservationCopyWithImpl<$Res, $Val extends HotelReservation>
    implements $HotelReservationCopyWith<$Res> {
  _$HotelReservationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? base = null,
    Object? hotelId = null,
    Object? roomId = null,
    Object? checkIn = null,
    Object? checkOut = null,
    Object? guests = null,
    Object? specialRequests = freezed,
  }) {
    return _then(_value.copyWith(
      base: null == base
          ? _value.base
          : base // ignore: cast_nullable_to_non_nullable
              as BaseReservation,
      hotelId: null == hotelId
          ? _value.hotelId
          : hotelId // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      checkIn: null == checkIn
          ? _value.checkIn
          : checkIn // ignore: cast_nullable_to_non_nullable
              as DateTime,
      checkOut: null == checkOut
          ? _value.checkOut
          : checkOut // ignore: cast_nullable_to_non_nullable
              as DateTime,
      guests: null == guests
          ? _value.guests
          : guests // ignore: cast_nullable_to_non_nullable
              as int,
      specialRequests: freezed == specialRequests
          ? _value.specialRequests
          : specialRequests // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BaseReservationCopyWith<$Res> get base {
    return $BaseReservationCopyWith<$Res>(_value.base, (value) {
      return _then(_value.copyWith(base: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HotelReservationImplCopyWith<$Res>
    implements $HotelReservationCopyWith<$Res> {
  factory _$$HotelReservationImplCopyWith(_$HotelReservationImpl value,
          $Res Function(_$HotelReservationImpl) then) =
      __$$HotelReservationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {BaseReservation base,
      String hotelId,
      String roomId,
      DateTime checkIn,
      DateTime checkOut,
      int guests,
      String? specialRequests});

  @override
  $BaseReservationCopyWith<$Res> get base;
}

/// @nodoc
class __$$HotelReservationImplCopyWithImpl<$Res>
    extends _$HotelReservationCopyWithImpl<$Res, _$HotelReservationImpl>
    implements _$$HotelReservationImplCopyWith<$Res> {
  __$$HotelReservationImplCopyWithImpl(_$HotelReservationImpl _value,
      $Res Function(_$HotelReservationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? base = null,
    Object? hotelId = null,
    Object? roomId = null,
    Object? checkIn = null,
    Object? checkOut = null,
    Object? guests = null,
    Object? specialRequests = freezed,
  }) {
    return _then(_$HotelReservationImpl(
      base: null == base
          ? _value.base
          : base // ignore: cast_nullable_to_non_nullable
              as BaseReservation,
      hotelId: null == hotelId
          ? _value.hotelId
          : hotelId // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      checkIn: null == checkIn
          ? _value.checkIn
          : checkIn // ignore: cast_nullable_to_non_nullable
              as DateTime,
      checkOut: null == checkOut
          ? _value.checkOut
          : checkOut // ignore: cast_nullable_to_non_nullable
              as DateTime,
      guests: null == guests
          ? _value.guests
          : guests // ignore: cast_nullable_to_non_nullable
              as int,
      specialRequests: freezed == specialRequests
          ? _value.specialRequests
          : specialRequests // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HotelReservationImpl implements _HotelReservation {
  const _$HotelReservationImpl(
      {required this.base,
      required this.hotelId,
      required this.roomId,
      required this.checkIn,
      required this.checkOut,
      required this.guests,
      this.specialRequests});

  factory _$HotelReservationImpl.fromJson(Map<String, dynamic> json) =>
      _$$HotelReservationImplFromJson(json);

  @override
  final BaseReservation base;
  @override
  final String hotelId;
  @override
  final String roomId;
  @override
  final DateTime checkIn;
  @override
  final DateTime checkOut;
  @override
  final int guests;
  @override
  final String? specialRequests;

  @override
  String toString() {
    return 'HotelReservation(base: $base, hotelId: $hotelId, roomId: $roomId, checkIn: $checkIn, checkOut: $checkOut, guests: $guests, specialRequests: $specialRequests)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HotelReservationImpl &&
            (identical(other.base, base) || other.base == base) &&
            (identical(other.hotelId, hotelId) || other.hotelId == hotelId) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.checkIn, checkIn) || other.checkIn == checkIn) &&
            (identical(other.checkOut, checkOut) ||
                other.checkOut == checkOut) &&
            (identical(other.guests, guests) || other.guests == guests) &&
            (identical(other.specialRequests, specialRequests) ||
                other.specialRequests == specialRequests));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, base, hotelId, roomId, checkIn,
      checkOut, guests, specialRequests);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HotelReservationImplCopyWith<_$HotelReservationImpl> get copyWith =>
      __$$HotelReservationImplCopyWithImpl<_$HotelReservationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HotelReservationImplToJson(
      this,
    );
  }
}

abstract class _HotelReservation implements HotelReservation {
  const factory _HotelReservation(
      {required final BaseReservation base,
      required final String hotelId,
      required final String roomId,
      required final DateTime checkIn,
      required final DateTime checkOut,
      required final int guests,
      final String? specialRequests}) = _$HotelReservationImpl;

  factory _HotelReservation.fromJson(Map<String, dynamic> json) =
      _$HotelReservationImpl.fromJson;

  @override
  BaseReservation get base;
  @override
  String get hotelId;
  @override
  String get roomId;
  @override
  DateTime get checkIn;
  @override
  DateTime get checkOut;
  @override
  int get guests;
  @override
  String? get specialRequests;
  @override
  @JsonKey(ignore: true)
  _$$HotelReservationImplCopyWith<_$HotelReservationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ApartmentReservation _$ApartmentReservationFromJson(Map<String, dynamic> json) {
  return _ApartmentReservation.fromJson(json);
}

/// @nodoc
mixin _$ApartmentReservation {
  BaseReservation get base => throw _privateConstructorUsedError;
  String get apartmentId => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  int get guests => throw _privateConstructorUsedError;
  String? get specialRequests => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ApartmentReservationCopyWith<ApartmentReservation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApartmentReservationCopyWith<$Res> {
  factory $ApartmentReservationCopyWith(ApartmentReservation value,
          $Res Function(ApartmentReservation) then) =
      _$ApartmentReservationCopyWithImpl<$Res, ApartmentReservation>;
  @useResult
  $Res call(
      {BaseReservation base,
      String apartmentId,
      DateTime startDate,
      DateTime endDate,
      int guests,
      String? specialRequests});

  $BaseReservationCopyWith<$Res> get base;
}

/// @nodoc
class _$ApartmentReservationCopyWithImpl<$Res,
        $Val extends ApartmentReservation>
    implements $ApartmentReservationCopyWith<$Res> {
  _$ApartmentReservationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? base = null,
    Object? apartmentId = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? guests = null,
    Object? specialRequests = freezed,
  }) {
    return _then(_value.copyWith(
      base: null == base
          ? _value.base
          : base // ignore: cast_nullable_to_non_nullable
              as BaseReservation,
      apartmentId: null == apartmentId
          ? _value.apartmentId
          : apartmentId // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      guests: null == guests
          ? _value.guests
          : guests // ignore: cast_nullable_to_non_nullable
              as int,
      specialRequests: freezed == specialRequests
          ? _value.specialRequests
          : specialRequests // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BaseReservationCopyWith<$Res> get base {
    return $BaseReservationCopyWith<$Res>(_value.base, (value) {
      return _then(_value.copyWith(base: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ApartmentReservationImplCopyWith<$Res>
    implements $ApartmentReservationCopyWith<$Res> {
  factory _$$ApartmentReservationImplCopyWith(_$ApartmentReservationImpl value,
          $Res Function(_$ApartmentReservationImpl) then) =
      __$$ApartmentReservationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {BaseReservation base,
      String apartmentId,
      DateTime startDate,
      DateTime endDate,
      int guests,
      String? specialRequests});

  @override
  $BaseReservationCopyWith<$Res> get base;
}

/// @nodoc
class __$$ApartmentReservationImplCopyWithImpl<$Res>
    extends _$ApartmentReservationCopyWithImpl<$Res, _$ApartmentReservationImpl>
    implements _$$ApartmentReservationImplCopyWith<$Res> {
  __$$ApartmentReservationImplCopyWithImpl(_$ApartmentReservationImpl _value,
      $Res Function(_$ApartmentReservationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? base = null,
    Object? apartmentId = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? guests = null,
    Object? specialRequests = freezed,
  }) {
    return _then(_$ApartmentReservationImpl(
      base: null == base
          ? _value.base
          : base // ignore: cast_nullable_to_non_nullable
              as BaseReservation,
      apartmentId: null == apartmentId
          ? _value.apartmentId
          : apartmentId // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      guests: null == guests
          ? _value.guests
          : guests // ignore: cast_nullable_to_non_nullable
              as int,
      specialRequests: freezed == specialRequests
          ? _value.specialRequests
          : specialRequests // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ApartmentReservationImpl implements _ApartmentReservation {
  const _$ApartmentReservationImpl(
      {required this.base,
      required this.apartmentId,
      required this.startDate,
      required this.endDate,
      required this.guests,
      this.specialRequests});

  factory _$ApartmentReservationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApartmentReservationImplFromJson(json);

  @override
  final BaseReservation base;
  @override
  final String apartmentId;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final int guests;
  @override
  final String? specialRequests;

  @override
  String toString() {
    return 'ApartmentReservation(base: $base, apartmentId: $apartmentId, startDate: $startDate, endDate: $endDate, guests: $guests, specialRequests: $specialRequests)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApartmentReservationImpl &&
            (identical(other.base, base) || other.base == base) &&
            (identical(other.apartmentId, apartmentId) ||
                other.apartmentId == apartmentId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.guests, guests) || other.guests == guests) &&
            (identical(other.specialRequests, specialRequests) ||
                other.specialRequests == specialRequests));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, base, apartmentId, startDate,
      endDate, guests, specialRequests);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ApartmentReservationImplCopyWith<_$ApartmentReservationImpl>
      get copyWith =>
          __$$ApartmentReservationImplCopyWithImpl<_$ApartmentReservationImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApartmentReservationImplToJson(
      this,
    );
  }
}

abstract class _ApartmentReservation implements ApartmentReservation {
  const factory _ApartmentReservation(
      {required final BaseReservation base,
      required final String apartmentId,
      required final DateTime startDate,
      required final DateTime endDate,
      required final int guests,
      final String? specialRequests}) = _$ApartmentReservationImpl;

  factory _ApartmentReservation.fromJson(Map<String, dynamic> json) =
      _$ApartmentReservationImpl.fromJson;

  @override
  BaseReservation get base;
  @override
  String get apartmentId;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  int get guests;
  @override
  String? get specialRequests;
  @override
  @JsonKey(ignore: true)
  _$$ApartmentReservationImplCopyWith<_$ApartmentReservationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
