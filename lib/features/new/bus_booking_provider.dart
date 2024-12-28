// lib/features/bus/providers/bus_booking_provider.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'bus_booking.dart';
part 'bus_booking_provider.freezed.dart';
part 'bus_booking_provider.g.dart';

@freezed
class BusBookingState with _$BusBookingState {
  const factory BusBookingState({
    @Default(null) BusBooking? currentBooking,
    @Default([]) List<BusBooking> userBookings,
    @Default(false) bool isLoading,
    @Default(null) String? error,
  }) = _BusBookingState;
}

@riverpod
class BusBookingNotifier extends _$BusBookingNotifier {
  @override
  FutureOr<BusBookingState> build() async {
    return const BusBookingState();
  }

  Future<void> createBooking(BusBooking booking) async {
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

      final bookings = <BusBooking>[];
      state = AsyncValue.data(state.value!.copyWith(
        userBookings: bookings,
        isLoading: false,
      ));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
