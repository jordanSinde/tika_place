// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'promo_code.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PromoCode _$PromoCodeFromJson(Map<String, dynamic> json) {
  return _PromoCode.fromJson(json);
}

/// @nodoc
mixin _$PromoCode {
  String get code => throw _privateConstructorUsedError;
  double get discountPercent => throw _privateConstructorUsedError;
  DateTime get validUntil => throw _privateConstructorUsedError;
  int get maxUsage => throw _privateConstructorUsedError;
  List<String> get usedByUsers => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double? get minPurchaseAmount => throw _privateConstructorUsedError;
  double? get maxDiscountAmount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PromoCodeCopyWith<PromoCode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PromoCodeCopyWith<$Res> {
  factory $PromoCodeCopyWith(PromoCode value, $Res Function(PromoCode) then) =
      _$PromoCodeCopyWithImpl<$Res, PromoCode>;
  @useResult
  $Res call(
      {String code,
      double discountPercent,
      DateTime validUntil,
      int maxUsage,
      List<String> usedByUsers,
      String? description,
      double? minPurchaseAmount,
      double? maxDiscountAmount});
}

/// @nodoc
class _$PromoCodeCopyWithImpl<$Res, $Val extends PromoCode>
    implements $PromoCodeCopyWith<$Res> {
  _$PromoCodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? discountPercent = null,
    Object? validUntil = null,
    Object? maxUsage = null,
    Object? usedByUsers = null,
    Object? description = freezed,
    Object? minPurchaseAmount = freezed,
    Object? maxDiscountAmount = freezed,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      discountPercent: null == discountPercent
          ? _value.discountPercent
          : discountPercent // ignore: cast_nullable_to_non_nullable
              as double,
      validUntil: null == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime,
      maxUsage: null == maxUsage
          ? _value.maxUsage
          : maxUsage // ignore: cast_nullable_to_non_nullable
              as int,
      usedByUsers: null == usedByUsers
          ? _value.usedByUsers
          : usedByUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      minPurchaseAmount: freezed == minPurchaseAmount
          ? _value.minPurchaseAmount
          : minPurchaseAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      maxDiscountAmount: freezed == maxDiscountAmount
          ? _value.maxDiscountAmount
          : maxDiscountAmount // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PromoCodeImplCopyWith<$Res>
    implements $PromoCodeCopyWith<$Res> {
  factory _$$PromoCodeImplCopyWith(
          _$PromoCodeImpl value, $Res Function(_$PromoCodeImpl) then) =
      __$$PromoCodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String code,
      double discountPercent,
      DateTime validUntil,
      int maxUsage,
      List<String> usedByUsers,
      String? description,
      double? minPurchaseAmount,
      double? maxDiscountAmount});
}

/// @nodoc
class __$$PromoCodeImplCopyWithImpl<$Res>
    extends _$PromoCodeCopyWithImpl<$Res, _$PromoCodeImpl>
    implements _$$PromoCodeImplCopyWith<$Res> {
  __$$PromoCodeImplCopyWithImpl(
      _$PromoCodeImpl _value, $Res Function(_$PromoCodeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? discountPercent = null,
    Object? validUntil = null,
    Object? maxUsage = null,
    Object? usedByUsers = null,
    Object? description = freezed,
    Object? minPurchaseAmount = freezed,
    Object? maxDiscountAmount = freezed,
  }) {
    return _then(_$PromoCodeImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      discountPercent: null == discountPercent
          ? _value.discountPercent
          : discountPercent // ignore: cast_nullable_to_non_nullable
              as double,
      validUntil: null == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime,
      maxUsage: null == maxUsage
          ? _value.maxUsage
          : maxUsage // ignore: cast_nullable_to_non_nullable
              as int,
      usedByUsers: null == usedByUsers
          ? _value._usedByUsers
          : usedByUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      minPurchaseAmount: freezed == minPurchaseAmount
          ? _value.minPurchaseAmount
          : minPurchaseAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      maxDiscountAmount: freezed == maxDiscountAmount
          ? _value.maxDiscountAmount
          : maxDiscountAmount // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PromoCodeImpl implements _PromoCode {
  const _$PromoCodeImpl(
      {required this.code,
      required this.discountPercent,
      required this.validUntil,
      required this.maxUsage,
      required final List<String> usedByUsers,
      this.description,
      this.minPurchaseAmount,
      this.maxDiscountAmount})
      : _usedByUsers = usedByUsers;

  factory _$PromoCodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$PromoCodeImplFromJson(json);

  @override
  final String code;
  @override
  final double discountPercent;
  @override
  final DateTime validUntil;
  @override
  final int maxUsage;
  final List<String> _usedByUsers;
  @override
  List<String> get usedByUsers {
    if (_usedByUsers is EqualUnmodifiableListView) return _usedByUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_usedByUsers);
  }

  @override
  final String? description;
  @override
  final double? minPurchaseAmount;
  @override
  final double? maxDiscountAmount;

  @override
  String toString() {
    return 'PromoCode(code: $code, discountPercent: $discountPercent, validUntil: $validUntil, maxUsage: $maxUsage, usedByUsers: $usedByUsers, description: $description, minPurchaseAmount: $minPurchaseAmount, maxDiscountAmount: $maxDiscountAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PromoCodeImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.discountPercent, discountPercent) ||
                other.discountPercent == discountPercent) &&
            (identical(other.validUntil, validUntil) ||
                other.validUntil == validUntil) &&
            (identical(other.maxUsage, maxUsage) ||
                other.maxUsage == maxUsage) &&
            const DeepCollectionEquality()
                .equals(other._usedByUsers, _usedByUsers) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.minPurchaseAmount, minPurchaseAmount) ||
                other.minPurchaseAmount == minPurchaseAmount) &&
            (identical(other.maxDiscountAmount, maxDiscountAmount) ||
                other.maxDiscountAmount == maxDiscountAmount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      code,
      discountPercent,
      validUntil,
      maxUsage,
      const DeepCollectionEquality().hash(_usedByUsers),
      description,
      minPurchaseAmount,
      maxDiscountAmount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PromoCodeImplCopyWith<_$PromoCodeImpl> get copyWith =>
      __$$PromoCodeImplCopyWithImpl<_$PromoCodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PromoCodeImplToJson(
      this,
    );
  }
}

abstract class _PromoCode implements PromoCode {
  const factory _PromoCode(
      {required final String code,
      required final double discountPercent,
      required final DateTime validUntil,
      required final int maxUsage,
      required final List<String> usedByUsers,
      final String? description,
      final double? minPurchaseAmount,
      final double? maxDiscountAmount}) = _$PromoCodeImpl;

  factory _PromoCode.fromJson(Map<String, dynamic> json) =
      _$PromoCodeImpl.fromJson;

  @override
  String get code;
  @override
  double get discountPercent;
  @override
  DateTime get validUntil;
  @override
  int get maxUsage;
  @override
  List<String> get usedByUsers;
  @override
  String? get description;
  @override
  double? get minPurchaseAmount;
  @override
  double? get maxDiscountAmount;
  @override
  @JsonKey(ignore: true)
  _$$PromoCodeImplCopyWith<_$PromoCodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
