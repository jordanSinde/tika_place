import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/destinations_provider.dart';

part 'splash_provider.g.dart';

enum SplashState {
  initialized,
  loading,
}

@riverpod
class Splash extends _$Splash {
  @override
  Future<SplashState> build() async {
    try {
      // Charger les données initiales
      await ref.read(destinationsProvider.notifier).loadDestinations();
      await Future.delayed(const Duration(seconds: 2));
      return SplashState.initialized;
    } catch (e) {
      // Gérer l'erreur si nécessaire
      return SplashState.initialized;
    }
  }
}
