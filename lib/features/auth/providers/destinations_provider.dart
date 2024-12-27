import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/utils/mocks/destinations_mock.dart';
import '../../home/models/destination.dart';
import 'destinations_state.dart';

part 'destinations_provider.g.dart';

@riverpod
class Destinations extends _$Destinations {
  @override
  DestinationsState build() => const DestinationsState();

  Future<void> loadDestinations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simuler un délai d'API
      await Future.delayed(const Duration(milliseconds: 800));

      state = state.copyWith(
        destinations: DestinationsMock.popularDestinations,
        featuredDestinations: DestinationsMock.popularDestinations
            .where((d) => d.price != null)
            .toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectDestination(Destination destination) {
    state = state.copyWith(selectedDestination: destination);
  }

  void clearSelection() {
    state = state.copyWith(selectedDestination: null);
  }
}
