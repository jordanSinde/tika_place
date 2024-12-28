// lib/features/apartments/providers/apartment_booking_provider.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'apartment_booking.dart';
part 'apartment_booking_provider.freezed.dart';
part 'apartment_booking_provider.g.dart';

@freezed
class ApartmentBookingState with _$ApartmentBookingState {
  const factory ApartmentBookingState({
    @Default(null) ApartmentBooking? currentBooking,
    @Default([]) List<ApartmentBooking> userBookings,
    @Default(false) bool isLoading,
    @Default(null) String? error,
  }) = _ApartmentBookingState;
}

@riverpod
class ApartmentBookingNotifier extends _$ApartmentBookingNotifier {
  @override
  FutureOr<ApartmentBookingState> build() async {
    return const ApartmentBookingState();
  }

  Future<void> createBooking(ApartmentBooking booking) async {
    state = const AsyncValue.loading();
    try {
      // TODO: Implémenter l'appel API réel
      await Future.delayed(const Duration(seconds: 1));

      state = AsyncValue.data(state.value!.copyWith(
        currentBooking: booking,
        isLoading: false,
      ));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> loadUserBookings(String userId) async {
    state = const AsyncValue.loading();
    try {
      // TODO: Implémenter l'appel API réel
      await Future.delayed(const Duration(seconds: 1));

      final bookings = <ApartmentBooking>[];
      state = AsyncValue.data(state.value!.copyWith(
        userBookings: bookings,
        isLoading: false,
      ));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
