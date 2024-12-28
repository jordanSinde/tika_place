// lib/features/apartments/providers/apartments_provider.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'apartment.dart';
part 'apartement_provider.freezed.dart';
part 'apartement_provider.g.dart';

@freezed
class ApartmentsState with _$ApartmentsState {
  const factory ApartmentsState({
    @Default([]) List<Apartment> apartments,
    @Default([]) List<Apartment> featuredApartments,
    @Default(true) bool isLoading,
    @Default(null) String? error,
    Apartment? selectedApartment,
    @Default({}) Map<String, dynamic> filters,
  }) = _ApartmentsState;
}

@riverpod
class ApartmentsNotifier extends _$ApartmentsNotifier {
  @override
  FutureOr<ApartmentsState> build() async {
    return const ApartmentsState();
  }

  Future<void> loadApartments({
    String? city,
    bool? isFurnished,
    int? minRooms,
    double? maxPrice,
  }) async {
    state = const AsyncValue.loading();
    try {
      // TODO: Implémenter l'appel API réel
      await Future.delayed(const Duration(seconds: 1));

      final apartments = [
        const Apartment(
          id: '1',
          title: 'Bel appartement 3 pièces',
          description: 'Appartement moderne et spacieux...',
          monthlyPrice: 150000,
          city: 'Douala',
          district: 'Akwa',
          images: ['apartment1.jpg'],
          numberOfRooms: 3,
          surfaceArea: 85,
          isFurnished: true,
          amenities: ['wifi', 'parking', 'security'],
          ownerName: 'Jean Dupont',
          ownerPhone: '+237600000000',
        ),
        // Ajouter plus d'appartements fictifs...
      ];

      state = AsyncValue.data(ApartmentsState(
        apartments: apartments,
        featuredApartments: apartments.take(3).toList(),
        isLoading: false,
      ));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void selectApartment(Apartment apartment) {
    state =
        AsyncValue.data(state.value!.copyWith(selectedApartment: apartment));
  }

  void updateFilters(Map<String, dynamic> newFilters) {
    state = AsyncValue.data(state.value!.copyWith(filters: newFilters));
    loadApartments(
      city: newFilters['city'],
      isFurnished: newFilters['isFurnished'],
      minRooms: newFilters['minRooms'],
      maxPrice: newFilters['maxPrice'],
    );
  }
}
