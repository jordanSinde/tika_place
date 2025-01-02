// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apartments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allApartmentsHash() => r'1208055d251761f81702a110dec75f560a71de29';

/// See also [allApartments].
@ProviderFor(allApartments)
final allApartmentsProvider = AutoDisposeProvider<List<Apartment>>.internal(
  allApartments,
  name: r'allApartmentsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allApartmentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllApartmentsRef = AutoDisposeProviderRef<List<Apartment>>;
String _$selectedApartmentHash() => r'eac93b8e8fde645f6ff615f0f481e58c17c07b71';

/// See also [selectedApartment].
@ProviderFor(selectedApartment)
final selectedApartmentProvider = AutoDisposeProvider<Apartment?>.internal(
  selectedApartment,
  name: r'selectedApartmentProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedApartmentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SelectedApartmentRef = AutoDisposeProviderRef<Apartment?>;
String _$apartmentsHash() => r'208373833f92c32592a145519743483277a32b8e';

/// See also [Apartments].
@ProviderFor(Apartments)
final apartmentsProvider =
    AutoDisposeAsyncNotifierProvider<Apartments, ApartmentsState>.internal(
  Apartments.new,
  name: r'apartmentsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$apartmentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Apartments = AutoDisposeAsyncNotifier<ApartmentsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
