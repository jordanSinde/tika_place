// lib/features/bus/providers/bus_routes_provider.dart
import 'package:collection/collection.dart';
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
class BusRoutes extends _$BusRoutes {
  @override
  Future<BusRoutesState> build() async {
    // Chargez les routes au démarrage
    await loadRoutes();
    return const BusRoutesState();
  }

  Future<void> loadRoutes({
    String? departureCity,
    String? arrivalCity,
    DateTime? date,
  }) async {
    state = const AsyncLoading();
    try {
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
        BusRoute(
          id: '2',
          departureCity: 'Yaoundé',
          arrivalCity: 'Bafoussam',
          departureTime: DateTime.now().add(const Duration(hours: 3)),
          arrivalTime: DateTime.now().add(const Duration(hours: 8)),
          price: 6000,
          busType: 'Standard',
          availableSeats: 45,
          hasAC: false,
          hasWifi: false,
          companyName: 'Tika Transport',
        ),
      ];

      state = AsyncData(BusRoutesState(
        routes: routes,
        isLoading: false,
      ));
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  void selectRoute(BusRoute route) {
    state.whenData((currentState) {
      state = AsyncData(currentState.copyWith(selectedRoute: route));
    });
  }
}

// Providers utilitaires
@riverpod
List<BusRoute> allRoutes(AllRoutesRef ref) {
  return ref
          .watch(busRoutesProvider)
          .whenData(
            (state) => state.routes,
          )
          .value ??
      [];
}

@riverpod
BusRoute? selectedRoute(SelectedRouteRef ref) {
  return ref
      .watch(busRoutesProvider)
      .whenData(
        (state) => state.selectedRoute,
      )
      .value;
}

@riverpod
BusRoute? busRouteById(BusRouteByIdRef ref, String id) {
  final routes = ref.watch(allRoutesProvider);
  return routes.firstWhereOrNull((route) => route.id == id);
}
