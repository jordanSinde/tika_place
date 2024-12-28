// lib/features/bus/providers/bus_routes_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'bus_route.dart';
part 'bus_routes_provider.freezed.dart';
part 'bus_routes_provider.g.dart';

@freezed
class BusRoutesState with _$BusRoutesState {
  const factory BusRoutesState({
    @Default([]) List<BusRoute> routes,
    @Default(true) bool isLoading,
    @Default(null) String? error,
    BusRoute? selectedRoute,
  }) = _BusRoutesState;
}

@riverpod
class BusRoutesNotifier extends _$BusRoutesNotifier {
  @override
  FutureOr<BusRoutesState> build() async {
    return const BusRoutesState();
  }

  Future<void> loadRoutes({
    String? departureCity,
    String? arrivalCity,
    DateTime? date,
  }) async {
    state = const AsyncValue.loading();
    try {
      // TODO: Implémenter l'appel API réel
      // Simulation de chargement
      await Future.delayed(const Duration(seconds: 1));

      final routes = [
        BusRoute(
          id: '1',
          departureCity: 'Douala',
          arrivalCity: 'Yaoundé',
          departureTime: DateTime.now().add(const Duration(hours: 2)),
          arrivalTime: DateTime.now().add(const Duration(hours: 6)),
          price: 5000,
          busType: 'VIP',
          availableSeats: 30,
          hasAC: true,
          hasWifi: true,
          companyName: 'Tika Transport',
        ),
        // Ajouter plus de routes fictives...
      ];

      state = AsyncValue.data(BusRoutesState(routes: routes, isLoading: false));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void selectRoute(BusRoute route) {
    state = AsyncValue.data(state.value!.copyWith(selectedRoute: route));
  }
}
