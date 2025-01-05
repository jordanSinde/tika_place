// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionSecurityHash() => r'e41f5798147ab781e9b9b2b763fa7384445e0f30';

/// See also [sessionSecurity].
@ProviderFor(sessionSecurity)
final sessionSecurityProvider =
    AutoDisposeProvider<SessionSecurityService>.internal(
  sessionSecurity,
  name: r'sessionSecurityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionSecurityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SessionSecurityRef = AutoDisposeProviderRef<SessionSecurityService>;
String _$activeSessionsHash() => r'aafcb24b2edb80c3e7952e247ce9e832a75cd6a9';

/// See also [activeSessions].
@ProviderFor(activeSessions)
final activeSessionsProvider =
    AutoDisposeStreamProvider<List<DeviceSession>>.internal(
  activeSessions,
  name: r'activeSessionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeSessionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveSessionsRef = AutoDisposeStreamProviderRef<List<DeviceSession>>;
String _$currentSessionHash() => r'd684b76d4cd8462ccb490072024076af9f13ec87';

/// See also [CurrentSession].
@ProviderFor(CurrentSession)
final currentSessionProvider =
    AutoDisposeNotifierProvider<CurrentSession, DeviceSession?>.internal(
  CurrentSession.new,
  name: r'currentSessionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentSession = AutoDisposeNotifier<DeviceSession?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
