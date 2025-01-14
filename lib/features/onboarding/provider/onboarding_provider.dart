// lib/features/onboarding/providers/onboarding_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/shared_preferences_provider.dart';

final onboardingCompletedProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingNotifier(prefs);
});

class OnboardingNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  OnboardingNotifier(this._prefs)
      : super(_prefs.getBool('onboarding_completed') ?? false);

  Future<void> completeOnboarding() async {
    await _prefs.setBool('onboarding_completed', true);
    state = true;
  }

  Future<void> resetOnboarding() async {
    await _prefs.setBool('onboarding_completed', false);
    state = false;
  }
}
