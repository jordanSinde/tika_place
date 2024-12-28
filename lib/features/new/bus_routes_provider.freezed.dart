// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bus_routes_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BusRoutesState {
  List<BusRoute> get routes => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  BusRoute? get selectedRoute => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BusRoutesStateCopyWith<BusRoutesState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusRoutesStateCopyWith<$Res> {
  factory $BusRoutesStateCopyWith(
          BusRoutesState value, $Res Function(BusRoutesState) then) =
      _$BusRoutesStateCopyWithImpl<$Res, BusRoutesState>;
  @useResult
  $Res call(
      {List<BusRoute> routes,
      bool isLoading,
      String? error,
      BusRoute? selectedRoute});

  $BusRouteCopyWith<$Res>? get selectedRoute;
}

/// @nodoc
class _$BusRoutesStateCopyWithImpl<$Res, $Val extends BusRoutesState>
    implements $BusRoutesStateCopyWith<$Res> {
  _$BusRoutesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routes = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? selectedRoute = freezed,
  }) {
    return _then(_value.copyWith(
      routes: null == routes
          ? _value.routes
          : routes // ignore: cast_nullable_to_non_nullable
              as List<BusRoute>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedRoute: freezed == selectedRoute
          ? _value.selectedRoute
          : selectedRoute // ignore: cast_nullable_to_non_nullable
              as BusRoute?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BusRouteCopyWith<$Res>? get selectedRoute {
    if (_value.selectedRoute == null) {
      return null;
    }

    return $BusRouteCopyWith<$Res>(_value.selectedRoute!, (value) {
      return _then(_value.copyWith(selectedRoute: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BusRoutesStateImplCopyWith<$Res>
    implements $BusRoutesStateCopyWith<$Res> {
  factory _$$BusRoutesStateImplCopyWith(_$BusRoutesStateImpl value,
          $Res Function(_$BusRoutesStateImpl) then) =
      __$$BusRoutesStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<BusRoute> routes,
      bool isLoading,
      String? error,
      BusRoute? selectedRoute});

  @override
  $BusRouteCopyWith<$Res>? get selectedRoute;
}

/// @nodoc
class __$$BusRoutesStateImplCopyWithImpl<$Res>
    extends _$BusRoutesStateCopyWithImpl<$Res, _$BusRoutesStateImpl>
    implements _$$BusRoutesStateImplCopyWith<$Res> {
  __$$BusRoutesStateImplCopyWithImpl(
      _$BusRoutesStateImpl _value, $Res Function(_$BusRoutesStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routes = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? selectedRoute = freezed,
  }) {
    return _then(_$BusRoutesStateImpl(
      routes: null == routes
          ? _value._routes
          : routes // ignore: cast_nullable_to_non_nullable
              as List<BusRoute>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedRoute: freezed == selectedRoute
          ? _value.selectedRoute
          : selectedRoute // ignore: cast_nullable_to_non_nullable
              as BusRoute?,
    ));
  }
}

/// @nodoc

class _$BusRoutesStateImpl implements _BusRoutesState {
  const _$BusRoutesStateImpl(
      {final List<BusRoute> routes = const [],
      this.isLoading = true,
      this.error = null,
      this.selectedRoute})
      : _routes = routes;

  final List<BusRoute> _routes;
  @override
  @JsonKey()
  List<BusRoute> get routes {
    if (_routes is EqualUnmodifiableListView) return _routes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_routes);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final String? error;
  @override
  final BusRoute? selectedRoute;

  @override
  String toString() {
    return 'BusRoutesState(routes: $routes, isLoading: $isLoading, error: $error, selectedRoute: $selectedRoute)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusRoutesStateImpl &&
            const DeepCollectionEquality().equals(other._routes, _routes) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.selectedRoute, selectedRoute) ||
                other.selectedRoute == selectedRoute));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_routes),
      isLoading,
      error,
      selectedRoute);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BusRoutesStateImplCopyWith<_$BusRoutesStateImpl> get copyWith =>
      __$$BusRoutesStateImplCopyWithImpl<_$BusRoutesStateImpl>(
          this, _$identity);
}

abstract class _BusRoutesState implements BusRoutesState {
  const factory _BusRoutesState(
      {final List<BusRoute> routes,
      final bool isLoading,
      final String? error,
      final BusRoute? selectedRoute}) = _$BusRoutesStateImpl;

  @override
  List<BusRoute> get routes;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  BusRoute? get selectedRoute;
  @override
  @JsonKey(ignore: true)
  _$$BusRoutesStateImplCopyWith<_$BusRoutesStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
