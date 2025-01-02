// lib/features/apartments/providers/apartments_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'apartment.dart';

part 'apartments_provider.freezed.dart';
part 'apartments_provider.g.dart';

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
class Apartments extends _$Apartments {
  @override
  Future<ApartmentsState> build() async {
    // Chargez immédiatement les appartements au démarrage
    await loadApartments();
    return const ApartmentsState();
  }

  Future<void> loadApartments({
    String? city,
    bool? isFurnished,
    int? minRooms,
    double? maxPrice,
  }) async {
    state = const AsyncLoading();
    try {
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
        // Ajoutez plus d'appartements
      ];

      state = AsyncData(ApartmentsState(
        apartments: apartments,
        featuredApartments: apartments.take(3).toList(),
        isLoading: false,
      ));
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  void selectApartment(Apartment apartment) {
    state.whenData((currentState) {
      state = AsyncData(currentState.copyWith(selectedApartment: apartment));
    });
  }
}

// Providers pour accéder facilement aux données
@riverpod
List<Apartment> allApartments(AllApartmentsRef ref) {
  return ref
          .watch(apartmentsProvider)
          .whenData(
            (state) => state.apartments,
          )
          .value ??
      [];
}

@riverpod
Apartment? selectedApartment(SelectedApartmentRef ref) {
  return ref
      .watch(apartmentsProvider)
      .whenData(
        (state) => state.selectedApartment,
      )
      .value;
}
