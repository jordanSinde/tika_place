// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'apartment_booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ApartmentBooking _$ApartmentBookingFromJson(Map<String, dynamic> json) {
  return _ApartmentBooking.fromJson(json);
}

/// @nodoc
mixin _$ApartmentBooking {
  String get id => throw _privateConstructorUsedError;
  String get apartmentId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  int get durationInMonths => throw _privateConstructorUsedError;
  double get monthlyRent => throw _privateConstructorUsedError;
  double get deposit => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get paymentId => throw _privateConstructorUsedError;
  String? get contractUrl => throw _privateConstructorUsedError;
  Map<String, dynamic>? get tenantInfo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ApartmentBookingCopyWith<ApartmentBooking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApartmentBookingCopyWith<$Res> {
  factory $ApartmentBookingCopyWith(
          ApartmentBooking value, $Res Function(ApartmentBooking) then) =
      _$ApartmentBookingCopyWithImpl<$Res, ApartmentBooking>;
  @useResult
  $Res call(
      {String id,
      String apartmentId,
      String userId,
      DateTime startDate,
      int durationInMonths,
      double monthlyRent,
      double deposit,
      double totalAmount,
      String status,
      String? paymentId,
      String? contractUrl,
      Map<String, dynamic>? tenantInfo});
}

/// @nodoc
class _$ApartmentBookingCopyWithImpl<$Res, $Val extends ApartmentBooking>
    implements $ApartmentBookingCopyWith<$Res> {
  _$ApartmentBookingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? apartmentId = null,
    Object? userId = null,
    Object? startDate = null,
    Object? durationInMonths = null,
    Object? monthlyRent = null,
    Object? deposit = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? paymentId = freezed,
    Object? contractUrl = freezed,
    Object? tenantInfo = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      apartmentId: null == apartmentId
          ? _value.apartmentId
          : apartmentId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationInMonths: null == durationInMonths
          ? _value.durationInMonths
          : durationInMonths // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyRent: null == monthlyRent
          ? _value.monthlyRent
          : monthlyRent // ignore: cast_nullable_to_non_nullable
              as double,
      deposit: null == deposit
          ? _value.deposit
          : deposit // ignore: cast_nullable_to_non_nullable
              as double,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paymentId: freezed == paymentId
          ? _value.paymentId
          : paymentId // ignore: cast_nullable_to_non_nullable
              as String?,
      contractUrl: freezed == contractUrl
          ? _value.contractUrl
          : contractUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tenantInfo: freezed == tenantInfo
          ? _value.tenantInfo
          : tenantInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ApartmentBookingImplCopyWith<$Res>
    implements $ApartmentBookingCopyWith<$Res> {
  factory _$$ApartmentBookingImplCopyWith(_$ApartmentBookingImpl value,
          $Res Function(_$ApartmentBookingImpl) then) =
      __$$ApartmentBookingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String apartmentId,
      String userId,
      DateTime startDate,
      int durationInMonths,
      double monthlyRent,
      double deposit,
      double totalAmount,
      String status,
      String? paymentId,
      String? contractUrl,
      Map<String, dynamic>? tenantInfo});
}

/// @nodoc
class __$$ApartmentBookingImplCopyWithImpl<$Res>
    extends _$ApartmentBookingCopyWithImpl<$Res, _$ApartmentBookingImpl>
    implements _$$ApartmentBookingImplCopyWith<$Res> {
  __$$ApartmentBookingImplCopyWithImpl(_$ApartmentBookingImpl _value,
      $Res Function(_$ApartmentBookingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? apartmentId = null,
    Object? userId = null,
    Object? startDate = null,
    Object? durationInMonths = null,
    Object? monthlyRent = null,
    Object? deposit = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? paymentId = freezed,
    Object? contractUrl = freezed,
    Object? tenantInfo = freezed,
  }) {
    return _then(_$ApartmentBookingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      apartmentId: null == apartmentId
          ? _value.apartmentId
          : apartmentId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationInMonths: null == durationInMonths
          ? _value.durationInMonths
          : durationInMonths // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyRent: null == monthlyRent
          ? _value.monthlyRent
          : monthlyRent // ignore: cast_nullable_to_non_nullable
              as double,
      deposit: null == deposit
          ? _value.deposit
          : deposit // ignore: cast_nullable_to_non_nullable
              as double,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paymentId: freezed == paymentId
          ? _value.paymentId
          : paymentId // ignore: cast_nullable_to_non_nullable
              as String?,
      contractUrl: freezed == contractUrl
          ? _value.contractUrl
          : contractUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tenantInfo: freezed == tenantInfo
          ? _value._tenantInfo
          : tenantInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ApartmentBookingImpl implements _ApartmentBooking {
  const _$ApartmentBookingImpl(
      {required this.id,
      required this.apartmentId,
      required this.userId,
      required this.startDate,
      required this.durationInMonths,
      required this.monthlyRent,
      required this.deposit,
      required this.totalAmount,
      this.status = 'pending',
      this.paymentId,
      this.contractUrl,
      final Map<String, dynamic>? tenantInfo})
      : _tenantInfo = tenantInfo;

  factory _$ApartmentBookingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApartmentBookingImplFromJson(json);

  @override
  final String id;
  @override
  final String apartmentId;
  @override
  final String userId;
  @override
  final DateTime startDate;
  @override
  final int durationInMonths;
  @override
  final double monthlyRent;
  @override
  final double deposit;
  @override
  final double totalAmount;
  @override
  @JsonKey()
  final String status;
  @override
  final String? paymentId;
  @override
  final String? contractUrl;
  final Map<String, dynamic>? _tenantInfo;
  @override
  Map<String, dynamic>? get tenantInfo {
    final value = _tenantInfo;
    if (value == null) return null;
    if (_tenantInfo is EqualUnmodifiableMapView) return _tenantInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ApartmentBooking(id: $id, apartmentId: $apartmentId, userId: $userId, startDate: $startDate, durationInMonths: $durationInMonths, monthlyRent: $monthlyRent, deposit: $deposit, totalAmount: $totalAmount, status: $status, paymentId: $paymentId, contractUrl: $contractUrl, tenantInfo: $tenantInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApartmentBookingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.apartmentId, apartmentId) ||
                other.apartmentId == apartmentId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.durationInMonths, durationInMonths) ||
                other.durationInMonths == durationInMonths) &&
            (identical(other.monthlyRent, monthlyRent) ||
                other.monthlyRent == monthlyRent) &&
            (identical(other.deposit, deposit) || other.deposit == deposit) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentId, paymentId) ||
                other.paymentId == paymentId) &&
            (identical(other.contractUrl, contractUrl) ||
                other.contractUrl == contractUrl) &&
            const DeepCollectionEquality()
                .equals(other._tenantInfo, _tenantInfo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      apartmentId,
      userId,
      startDate,
      durationInMonths,
      monthlyRent,
      deposit,
      totalAmount,
      status,
      paymentId,
      contractUrl,
      const DeepCollectionEquality().hash(_tenantInfo));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ApartmentBookingImplCopyWith<_$ApartmentBookingImpl> get copyWith =>
      __$$ApartmentBookingImplCopyWithImpl<_$ApartmentBookingImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApartmentBookingImplToJson(
      this,
    );
  }
}

abstract class _ApartmentBooking implements ApartmentBooking {
  const factory _ApartmentBooking(
      {required final String id,
      required final String apartmentId,
      required final String userId,
      required final DateTime startDate,
      required final int durationInMonths,
      required final double monthlyRent,
      required final double deposit,
      required final double totalAmount,
      final String status,
      final String? paymentId,
      final String? contractUrl,
      final Map<String, dynamic>? tenantInfo}) = _$ApartmentBookingImpl;

  factory _ApartmentBooking.fromJson(Map<String, dynamic> json) =
      _$ApartmentBookingImpl.fromJson;

  @override
  String get id;
  @override
  String get apartmentId;
  @override
  String get userId;
  @override
  DateTime get startDate;
  @override
  int get durationInMonths;
  @override
  double get monthlyRent;
  @override
  double get deposit;
  @override
  double get totalAmount;
  @override
  String get status;
  @override
  String? get paymentId;
  @override
  String? get contractUrl;
  @override
  Map<String, dynamic>? get tenantInfo;
  @override
  @JsonKey(ignore: true)
  _$$ApartmentBookingImplCopyWith<_$ApartmentBookingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
