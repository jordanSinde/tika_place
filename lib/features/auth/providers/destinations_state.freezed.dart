// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'destinations_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DestinationsState {
  List<Destination> get destinations => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  List<Destination> get featuredDestinations =>
      throw _privateConstructorUsedError;
  Destination? get selectedDestination => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DestinationsStateCopyWith<DestinationsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DestinationsStateCopyWith<$Res> {
  factory $DestinationsStateCopyWith(
          DestinationsState value, $Res Function(DestinationsState) then) =
      _$DestinationsStateCopyWithImpl<$Res, DestinationsState>;
  @useResult
  $Res call(
      {List<Destination> destinations,
      bool isLoading,
      String? error,
      List<Destination> featuredDestinations,
      Destination? selectedDestination});

  $DestinationCopyWith<$Res>? get selectedDestination;
}

/// @nodoc
class _$DestinationsStateCopyWithImpl<$Res, $Val extends DestinationsState>
    implements $DestinationsStateCopyWith<$Res> {
  _$DestinationsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? destinations = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? featuredDestinations = null,
    Object? selectedDestination = freezed,
  }) {
    return _then(_value.copyWith(
      destinations: null == destinations
          ? _value.destinations
          : destinations // ignore: cast_nullable_to_non_nullable
              as List<Destination>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      featuredDestinations: null == featuredDestinations
          ? _value.featuredDestinations
          : featuredDestinations // ignore: cast_nullable_to_non_nullable
              as List<Destination>,
      selectedDestination: freezed == selectedDestination
          ? _value.selectedDestination
          : selectedDestination // ignore: cast_nullable_to_non_nullable
              as Destination?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $DestinationCopyWith<$Res>? get selectedDestination {
    if (_value.selectedDestination == null) {
      return null;
    }

    return $DestinationCopyWith<$Res>(_value.selectedDestination!, (value) {
      return _then(_value.copyWith(selectedDestination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DestinationsStateImplCopyWith<$Res>
    implements $DestinationsStateCopyWith<$Res> {
  factory _$$DestinationsStateImplCopyWith(_$DestinationsStateImpl value,
          $Res Function(_$DestinationsStateImpl) then) =
      __$$DestinationsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Destination> destinations,
      bool isLoading,
      String? error,
      List<Destination> featuredDestinations,
      Destination? selectedDestination});

  @override
  $DestinationCopyWith<$Res>? get selectedDestination;
}

/// @nodoc
class __$$DestinationsStateImplCopyWithImpl<$Res>
    extends _$DestinationsStateCopyWithImpl<$Res, _$DestinationsStateImpl>
    implements _$$DestinationsStateImplCopyWith<$Res> {
  __$$DestinationsStateImplCopyWithImpl(_$DestinationsStateImpl _value,
      $Res Function(_$DestinationsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? destinations = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? featuredDestinations = null,
    Object? selectedDestination = freezed,
  }) {
    return _then(_$DestinationsStateImpl(
      destinations: null == destinations
          ? _value._destinations
          : destinations // ignore: cast_nullable_to_non_nullable
              as List<Destination>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      featuredDestinations: null == featuredDestinations
          ? _value._featuredDestinations
          : featuredDestinations // ignore: cast_nullable_to_non_nullable
              as List<Destination>,
      selectedDestination: freezed == selectedDestination
          ? _value.selectedDestination
          : selectedDestination // ignore: cast_nullable_to_non_nullable
              as Destination?,
    ));
  }
}

/// @nodoc

class _$DestinationsStateImpl implements _DestinationsState {
  const _$DestinationsStateImpl(
      {final List<Destination> destinations = const [],
      this.isLoading = false,
      this.error,
      final List<Destination> featuredDestinations = const [],
      this.selectedDestination})
      : _destinations = destinations,
        _featuredDestinations = featuredDestinations;

  final List<Destination> _destinations;
  @override
  @JsonKey()
  List<Destination> get destinations {
    if (_destinations is EqualUnmodifiableListView) return _destinations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_destinations);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  final List<Destination> _featuredDestinations;
  @override
  @JsonKey()
  List<Destination> get featuredDestinations {
    if (_featuredDestinations is EqualUnmodifiableListView)
      return _featuredDestinations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_featuredDestinations);
  }

  @override
  final Destination? selectedDestination;

  @override
  String toString() {
    return 'DestinationsState(destinations: $destinations, isLoading: $isLoading, error: $error, featuredDestinations: $featuredDestinations, selectedDestination: $selectedDestination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DestinationsStateImpl &&
            const DeepCollectionEquality()
                .equals(other._destinations, _destinations) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other._featuredDestinations, _featuredDestinations) &&
            (identical(other.selectedDestination, selectedDestination) ||
                other.selectedDestination == selectedDestination));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_destinations),
      isLoading,
      error,
      const DeepCollectionEquality().hash(_featuredDestinations),
      selectedDestination);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DestinationsStateImplCopyWith<_$DestinationsStateImpl> get copyWith =>
      __$$DestinationsStateImplCopyWithImpl<_$DestinationsStateImpl>(
          this, _$identity);
}

abstract class _DestinationsState implements DestinationsState {
  const factory _DestinationsState(
      {final List<Destination> destinations,
      final bool isLoading,
      final String? error,
      final List<Destination> featuredDestinations,
      final Destination? selectedDestination}) = _$DestinationsStateImpl;

  @override
  List<Destination> get destinations;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  List<Destination> get featuredDestinations;
  @override
  Destination? get selectedDestination;
  @override
  @JsonKey(ignore: true)
  _$$DestinationsStateImplCopyWith<_$DestinationsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
