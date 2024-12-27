// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'destination.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Destination _$DestinationFromJson(Map<String, dynamic> json) {
  return _Destination.fromJson(json);
}

/// @nodoc
mixin _$Destination {
  String get id => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String? get price => throw _privateConstructorUsedError;
  bool get hasHotels => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DestinationCopyWith<Destination> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DestinationCopyWith<$Res> {
  factory $DestinationCopyWith(
          Destination value, $Res Function(Destination) then) =
      _$DestinationCopyWithImpl<$Res, Destination>;
  @useResult
  $Res call(
      {String id,
      String city,
      String country,
      String imageUrl,
      String? price,
      bool hasHotels,
      String? description});
}

/// @nodoc
class _$DestinationCopyWithImpl<$Res, $Val extends Destination>
    implements $DestinationCopyWith<$Res> {
  _$DestinationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? city = null,
    Object? country = null,
    Object? imageUrl = null,
    Object? price = freezed,
    Object? hasHotels = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String?,
      hasHotels: null == hasHotels
          ? _value.hasHotels
          : hasHotels // ignore: cast_nullable_to_non_nullable
              as bool,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DestinationImplCopyWith<$Res>
    implements $DestinationCopyWith<$Res> {
  factory _$$DestinationImplCopyWith(
          _$DestinationImpl value, $Res Function(_$DestinationImpl) then) =
      __$$DestinationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String city,
      String country,
      String imageUrl,
      String? price,
      bool hasHotels,
      String? description});
}

/// @nodoc
class __$$DestinationImplCopyWithImpl<$Res>
    extends _$DestinationCopyWithImpl<$Res, _$DestinationImpl>
    implements _$$DestinationImplCopyWith<$Res> {
  __$$DestinationImplCopyWithImpl(
      _$DestinationImpl _value, $Res Function(_$DestinationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? city = null,
    Object? country = null,
    Object? imageUrl = null,
    Object? price = freezed,
    Object? hasHotels = null,
    Object? description = freezed,
  }) {
    return _then(_$DestinationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String?,
      hasHotels: null == hasHotels
          ? _value.hasHotels
          : hasHotels // ignore: cast_nullable_to_non_nullable
              as bool,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DestinationImpl implements _Destination {
  const _$DestinationImpl(
      {required this.id,
      required this.city,
      required this.country,
      required this.imageUrl,
      this.price,
      this.hasHotels = false,
      this.description});

  factory _$DestinationImpl.fromJson(Map<String, dynamic> json) =>
      _$$DestinationImplFromJson(json);

  @override
  final String id;
  @override
  final String city;
  @override
  final String country;
  @override
  final String imageUrl;
  @override
  final String? price;
  @override
  @JsonKey()
  final bool hasHotels;
  @override
  final String? description;

  @override
  String toString() {
    return 'Destination(id: $id, city: $city, country: $country, imageUrl: $imageUrl, price: $price, hasHotels: $hasHotels, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DestinationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.hasHotels, hasHotels) ||
                other.hasHotels == hasHotels) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, city, country, imageUrl, price, hasHotels, description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DestinationImplCopyWith<_$DestinationImpl> get copyWith =>
      __$$DestinationImplCopyWithImpl<_$DestinationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DestinationImplToJson(
      this,
    );
  }
}

abstract class _Destination implements Destination {
  const factory _Destination(
      {required final String id,
      required final String city,
      required final String country,
      required final String imageUrl,
      final String? price,
      final bool hasHotels,
      final String? description}) = _$DestinationImpl;

  factory _Destination.fromJson(Map<String, dynamic> json) =
      _$DestinationImpl.fromJson;

  @override
  String get id;
  @override
  String get city;
  @override
  String get country;
  @override
  String get imageUrl;
  @override
  String? get price;
  @override
  bool get hasHotels;
  @override
  String? get description;
  @override
  @JsonKey(ignore: true)
  _$$DestinationImplCopyWith<_$DestinationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
