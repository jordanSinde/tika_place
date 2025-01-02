// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_routes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allRoutesHash() => r'2d7d633d458b5081ffd030638239a53f7cbf17dd';

/// See also [allRoutes].
@ProviderFor(allRoutes)
final allRoutesProvider = AutoDisposeProvider<List<BusRoute>>.internal(
  allRoutes,
  name: r'allRoutesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allRoutesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllRoutesRef = AutoDisposeProviderRef<List<BusRoute>>;
String _$selectedRouteHash() => r'4c777e67310d98edaaad05eb73f5fd15cdf5d800';

/// See also [selectedRoute].
@ProviderFor(selectedRoute)
final selectedRouteProvider = AutoDisposeProvider<BusRoute?>.internal(
  selectedRoute,
  name: r'selectedRouteProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedRouteHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SelectedRouteRef = AutoDisposeProviderRef<BusRoute?>;
String _$busRouteByIdHash() => r'e28075c52260a7233f32d78cfea8c08f9fa8a893';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [busRouteById].
@ProviderFor(busRouteById)
const busRouteByIdProvider = BusRouteByIdFamily();

/// See also [busRouteById].
class BusRouteByIdFamily extends Family<BusRoute?> {
  /// See also [busRouteById].
  const BusRouteByIdFamily();

  /// See also [busRouteById].
  BusRouteByIdProvider call(
    String id,
  ) {
    return BusRouteByIdProvider(
      id,
    );
  }

  @override
  BusRouteByIdProvider getProviderOverride(
    covariant BusRouteByIdProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'busRouteByIdProvider';
}

/// See also [busRouteById].
class BusRouteByIdProvider extends AutoDisposeProvider<BusRoute?> {
  /// See also [busRouteById].
  BusRouteByIdProvider(
    String id,
  ) : this._internal(
          (ref) => busRouteById(
            ref as BusRouteByIdRef,
            id,
          ),
          from: busRouteByIdProvider,
          name: r'busRouteByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$busRouteByIdHash,
          dependencies: BusRouteByIdFamily._dependencies,
          allTransitiveDependencies:
              BusRouteByIdFamily._allTransitiveDependencies,
          id: id,
        );

  BusRouteByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    BusRoute? Function(BusRouteByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BusRouteByIdProvider._internal(
        (ref) => create(ref as BusRouteByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<BusRoute?> createElement() {
    return _BusRouteByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BusRouteByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BusRouteByIdRef on AutoDisposeProviderRef<BusRoute?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _BusRouteByIdProviderElement extends AutoDisposeProviderElement<BusRoute?>
    with BusRouteByIdRef {
  _BusRouteByIdProviderElement(super.provider);

  @override
  String get id => (origin as BusRouteByIdProvider).id;
}

String _$busRoutesHash() => r'c78a60a552e227ec26ec3d352db799a8578f3c95';

/// See also [BusRoutes].
@ProviderFor(BusRoutes)
final busRoutesProvider =
    AutoDisposeAsyncNotifierProvider<BusRoutes, BusRoutesState>.internal(
  BusRoutes.new,
  name: r'busRoutesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$busRoutesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BusRoutes = AutoDisposeAsyncNotifier<BusRoutesState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
