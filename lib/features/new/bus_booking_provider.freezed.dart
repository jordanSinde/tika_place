// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bus_booking_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BusBookingState {
  BusBooking? get currentBooking => throw _privateConstructorUsedError;
  List<BusBooking> get userBookings => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BusBookingStateCopyWith<BusBookingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusBookingStateCopyWith<$Res> {
  factory $BusBookingStateCopyWith(
          BusBookingState value, $Res Function(BusBookingState) then) =
      _$BusBookingStateCopyWithImpl<$Res, BusBookingState>;
  @useResult
  $Res call(
      {BusBooking? currentBooking,
      List<BusBooking> userBookings,
      bool isLoading,
      String? error});

  $BusBookingCopyWith<$Res>? get currentBooking;
}

/// @nodoc
class _$BusBookingStateCopyWithImpl<$Res, $Val extends BusBookingState>
    implements $BusBookingStateCopyWith<$Res> {
  _$BusBookingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentBooking = freezed,
    Object? userBookings = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      currentBooking: freezed == currentBooking
          ? _value.currentBooking
          : currentBooking // ignore: cast_nullable_to_non_nullable
              as BusBooking?,
      userBookings: null == userBookings
          ? _value.userBookings
          : userBookings // ignore: cast_nullable_to_non_nullable
              as List<BusBooking>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BusBookingCopyWith<$Res>? get currentBooking {
    if (_value.currentBooking == null) {
      return null;
    }

    return $BusBookingCopyWith<$Res>(_value.currentBooking!, (value) {
      return _then(_value.copyWith(currentBooking: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BusBookingStateImplCopyWith<$Res>
    implements $BusBookingStateCopyWith<$Res> {
  factory _$$BusBookingStateImplCopyWith(_$BusBookingStateImpl value,
          $Res Function(_$BusBookingStateImpl) then) =
      __$$BusBookingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {BusBooking? currentBooking,
      List<BusBooking> userBookings,
      bool isLoading,
      String? error});

  @override
  $BusBookingCopyWith<$Res>? get currentBooking;
}

/// @nodoc
class __$$BusBookingStateImplCopyWithImpl<$Res>
    extends _$BusBookingStateCopyWithImpl<$Res, _$BusBookingStateImpl>
    implements _$$BusBookingStateImplCopyWith<$Res> {
  __$$BusBookingStateImplCopyWithImpl(
      _$BusBookingStateImpl _value, $Res Function(_$BusBookingStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentBooking = freezed,
    Object? userBookings = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$BusBookingStateImpl(
      currentBooking: freezed == currentBooking
          ? _value.currentBooking
          : currentBooking // ignore: cast_nullable_to_non_nullable
              as BusBooking?,
      userBookings: null == userBookings
          ? _value._userBookings
          : userBookings // ignore: cast_nullable_to_non_nullable
              as List<BusBooking>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$BusBookingStateImpl implements _BusBookingState {
  const _$BusBookingStateImpl(
      {this.currentBooking = null,
      final List<BusBooking> userBookings = const [],
      this.isLoading = false,
      this.error = null})
      : _userBookings = userBookings;

  @override
  @JsonKey()
  final BusBooking? currentBooking;
  final List<BusBooking> _userBookings;
  @override
  @JsonKey()
  List<BusBooking> get userBookings {
    if (_userBookings is EqualUnmodifiableListView) return _userBookings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_userBookings);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final String? error;

  @override
  String toString() {
    return 'BusBookingState(currentBooking: $currentBooking, userBookings: $userBookings, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusBookingStateImpl &&
            (identical(other.currentBooking, currentBooking) ||
                other.currentBooking == currentBooking) &&
            const DeepCollectionEquality()
                .equals(other._userBookings, _userBookings) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentBooking,
      const DeepCollectionEquality().hash(_userBookings), isLoading, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BusBookingStateImplCopyWith<_$BusBookingStateImpl> get copyWith =>
      __$$BusBookingStateImplCopyWithImpl<_$BusBookingStateImpl>(
          this, _$identity);
}

abstract class _BusBookingState implements BusBookingState {
  const factory _BusBookingState(
      {final BusBooking? currentBooking,
      final List<BusBooking> userBookings,
      final bool isLoading,
      final String? error}) = _$BusBookingStateImpl;

  @override
  BusBooking? get currentBooking;
  @override
  List<BusBooking> get userBookings;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$BusBookingStateImplCopyWith<_$BusBookingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
