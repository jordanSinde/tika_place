// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'apartement_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ApartmentsState {
  List<Apartment> get apartments => throw _privateConstructorUsedError;
  List<Apartment> get featuredApartments => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Apartment? get selectedApartment => throw _privateConstructorUsedError;
  Map<String, dynamic> get filters => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ApartmentsStateCopyWith<ApartmentsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApartmentsStateCopyWith<$Res> {
  factory $ApartmentsStateCopyWith(
          ApartmentsState value, $Res Function(ApartmentsState) then) =
      _$ApartmentsStateCopyWithImpl<$Res, ApartmentsState>;
  @useResult
  $Res call(
      {List<Apartment> apartments,
      List<Apartment> featuredApartments,
      bool isLoading,
      String? error,
      Apartment? selectedApartment,
      Map<String, dynamic> filters});

  $ApartmentCopyWith<$Res>? get selectedApartment;
}

/// @nodoc
class _$ApartmentsStateCopyWithImpl<$Res, $Val extends ApartmentsState>
    implements $ApartmentsStateCopyWith<$Res> {
  _$ApartmentsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apartments = null,
    Object? featuredApartments = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? selectedApartment = freezed,
    Object? filters = null,
  }) {
    return _then(_value.copyWith(
      apartments: null == apartments
          ? _value.apartments
          : apartments // ignore: cast_nullable_to_non_nullable
              as List<Apartment>,
      featuredApartments: null == featuredApartments
          ? _value.featuredApartments
          : featuredApartments // ignore: cast_nullable_to_non_nullable
              as List<Apartment>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedApartment: freezed == selectedApartment
          ? _value.selectedApartment
          : selectedApartment // ignore: cast_nullable_to_non_nullable
              as Apartment?,
      filters: null == filters
          ? _value.filters
          : filters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ApartmentCopyWith<$Res>? get selectedApartment {
    if (_value.selectedApartment == null) {
      return null;
    }

    return $ApartmentCopyWith<$Res>(_value.selectedApartment!, (value) {
      return _then(_value.copyWith(selectedApartment: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ApartmentsStateImplCopyWith<$Res>
    implements $ApartmentsStateCopyWith<$Res> {
  factory _$$ApartmentsStateImplCopyWith(_$ApartmentsStateImpl value,
          $Res Function(_$ApartmentsStateImpl) then) =
      __$$ApartmentsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Apartment> apartments,
      List<Apartment> featuredApartments,
      bool isLoading,
      String? error,
      Apartment? selectedApartment,
      Map<String, dynamic> filters});

  @override
  $ApartmentCopyWith<$Res>? get selectedApartment;
}

/// @nodoc
class __$$ApartmentsStateImplCopyWithImpl<$Res>
    extends _$ApartmentsStateCopyWithImpl<$Res, _$ApartmentsStateImpl>
    implements _$$ApartmentsStateImplCopyWith<$Res> {
  __$$ApartmentsStateImplCopyWithImpl(
      _$ApartmentsStateImpl _value, $Res Function(_$ApartmentsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apartments = null,
    Object? featuredApartments = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? selectedApartment = freezed,
    Object? filters = null,
  }) {
    return _then(_$ApartmentsStateImpl(
      apartments: null == apartments
          ? _value._apartments
          : apartments // ignore: cast_nullable_to_non_nullable
              as List<Apartment>,
      featuredApartments: null == featuredApartments
          ? _value._featuredApartments
          : featuredApartments // ignore: cast_nullable_to_non_nullable
              as List<Apartment>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedApartment: freezed == selectedApartment
          ? _value.selectedApartment
          : selectedApartment // ignore: cast_nullable_to_non_nullable
              as Apartment?,
      filters: null == filters
          ? _value._filters
          : filters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$ApartmentsStateImpl implements _ApartmentsState {
  const _$ApartmentsStateImpl(
      {final List<Apartment> apartments = const [],
      final List<Apartment> featuredApartments = const [],
      this.isLoading = true,
      this.error = null,
      this.selectedApartment,
      final Map<String, dynamic> filters = const {}})
      : _apartments = apartments,
        _featuredApartments = featuredApartments,
        _filters = filters;

  final List<Apartment> _apartments;
  @override
  @JsonKey()
  List<Apartment> get apartments {
    if (_apartments is EqualUnmodifiableListView) return _apartments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_apartments);
  }

  final List<Apartment> _featuredApartments;
  @override
  @JsonKey()
  List<Apartment> get featuredApartments {
    if (_featuredApartments is EqualUnmodifiableListView)
      return _featuredApartments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_featuredApartments);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final String? error;
  @override
  final Apartment? selectedApartment;
  final Map<String, dynamic> _filters;
  @override
  @JsonKey()
  Map<String, dynamic> get filters {
    if (_filters is EqualUnmodifiableMapView) return _filters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_filters);
  }

  @override
  String toString() {
    return 'ApartmentsState(apartments: $apartments, featuredApartments: $featuredApartments, isLoading: $isLoading, error: $error, selectedApartment: $selectedApartment, filters: $filters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApartmentsStateImpl &&
            const DeepCollectionEquality()
                .equals(other._apartments, _apartments) &&
            const DeepCollectionEquality()
                .equals(other._featuredApartments, _featuredApartments) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.selectedApartment, selectedApartment) ||
                other.selectedApartment == selectedApartment) &&
            const DeepCollectionEquality().equals(other._filters, _filters));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_apartments),
      const DeepCollectionEquality().hash(_featuredApartments),
      isLoading,
      error,
      selectedApartment,
      const DeepCollectionEquality().hash(_filters));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ApartmentsStateImplCopyWith<_$ApartmentsStateImpl> get copyWith =>
      __$$ApartmentsStateImplCopyWithImpl<_$ApartmentsStateImpl>(
          this, _$identity);
}

abstract class _ApartmentsState implements ApartmentsState {
  const factory _ApartmentsState(
      {final List<Apartment> apartments,
      final List<Apartment> featuredApartments,
      final bool isLoading,
      final String? error,
      final Apartment? selectedApartment,
      final Map<String, dynamic> filters}) = _$ApartmentsStateImpl;

  @override
  List<Apartment> get apartments;
  @override
  List<Apartment> get featuredApartments;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  Apartment? get selectedApartment;
  @override
  Map<String, dynamic> get filters;
  @override
  @JsonKey(ignore: true)
  _$$ApartmentsStateImplCopyWith<_$ApartmentsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
