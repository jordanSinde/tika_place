// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'apartment_booking_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ApartmentBookingState {
  ApartmentBooking? get currentBooking => throw _privateConstructorUsedError;
  List<ApartmentBooking> get userBookings => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ApartmentBookingStateCopyWith<ApartmentBookingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApartmentBookingStateCopyWith<$Res> {
  factory $ApartmentBookingStateCopyWith(ApartmentBookingState value,
          $Res Function(ApartmentBookingState) then) =
      _$ApartmentBookingStateCopyWithImpl<$Res, ApartmentBookingState>;
  @useResult
  $Res call(
      {ApartmentBooking? currentBooking,
      List<ApartmentBooking> userBookings,
      bool isLoading,
      String? error});

  $ApartmentBookingCopyWith<$Res>? get currentBooking;
}

/// @nodoc
class _$ApartmentBookingStateCopyWithImpl<$Res,
        $Val extends ApartmentBookingState>
    implements $ApartmentBookingStateCopyWith<$Res> {
  _$ApartmentBookingStateCopyWithImpl(this._value, this._then);

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
              as ApartmentBooking?,
      userBookings: null == userBookings
          ? _value.userBookings
          : userBookings // ignore: cast_nullable_to_non_nullable
              as List<ApartmentBooking>,
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
  $ApartmentBookingCopyWith<$Res>? get currentBooking {
    if (_value.currentBooking == null) {
      return null;
    }

    return $ApartmentBookingCopyWith<$Res>(_value.currentBooking!, (value) {
      return _then(_value.copyWith(currentBooking: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ApartmentBookingStateImplCopyWith<$Res>
    implements $ApartmentBookingStateCopyWith<$Res> {
  factory _$$ApartmentBookingStateImplCopyWith(
          _$ApartmentBookingStateImpl value,
          $Res Function(_$ApartmentBookingStateImpl) then) =
      __$$ApartmentBookingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ApartmentBooking? currentBooking,
      List<ApartmentBooking> userBookings,
      bool isLoading,
      String? error});

  @override
  $ApartmentBookingCopyWith<$Res>? get currentBooking;
}

/// @nodoc
class __$$ApartmentBookingStateImplCopyWithImpl<$Res>
    extends _$ApartmentBookingStateCopyWithImpl<$Res,
        _$ApartmentBookingStateImpl>
    implements _$$ApartmentBookingStateImplCopyWith<$Res> {
  __$$ApartmentBookingStateImplCopyWithImpl(_$ApartmentBookingStateImpl _value,
      $Res Function(_$ApartmentBookingStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentBooking = freezed,
    Object? userBookings = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$ApartmentBookingStateImpl(
      currentBooking: freezed == currentBooking
          ? _value.currentBooking
          : currentBooking // ignore: cast_nullable_to_non_nullable
              as ApartmentBooking?,
      userBookings: null == userBookings
          ? _value._userBookings
          : userBookings // ignore: cast_nullable_to_non_nullable
              as List<ApartmentBooking>,
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

class _$ApartmentBookingStateImpl implements _ApartmentBookingState {
  const _$ApartmentBookingStateImpl(
      {this.currentBooking = null,
      final List<ApartmentBooking> userBookings = const [],
      this.isLoading = false,
      this.error = null})
      : _userBookings = userBookings;

  @override
  @JsonKey()
  final ApartmentBooking? currentBooking;
  final List<ApartmentBooking> _userBookings;
  @override
  @JsonKey()
  List<ApartmentBooking> get userBookings {
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
    return 'ApartmentBookingState(currentBooking: $currentBooking, userBookings: $userBookings, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApartmentBookingStateImpl &&
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
  _$$ApartmentBookingStateImplCopyWith<_$ApartmentBookingStateImpl>
      get copyWith => __$$ApartmentBookingStateImplCopyWithImpl<
          _$ApartmentBookingStateImpl>(this, _$identity);
}

abstract class _ApartmentBookingState implements ApartmentBookingState {
  const factory _ApartmentBookingState(
      {final ApartmentBooking? currentBooking,
      final List<ApartmentBooking> userBookings,
      final bool isLoading,
      final String? error}) = _$ApartmentBookingStateImpl;

  @override
  ApartmentBooking? get currentBooking;
  @override
  List<ApartmentBooking> get userBookings;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$ApartmentBookingStateImplCopyWith<_$ApartmentBookingStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
