import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/theme/app_theme.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override le provider de SharedPreferences avec l'instance initialisée
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Tika Place',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        return _ErrorHandler(
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}

/*

// Exemple dans LoginScreen
context.go('/home'); // Au lieu de Navigator.pushNamed

// Exemple pour la navigation avec paramètres
context.go('/home/destination/${destination.id}');

// Navigation avec remplacement
context.goNamed('/login');

// Navigation avec retour
context.pop();

*/

// Widget pour gérer les erreurs globales
class _ErrorHandler extends ConsumerWidget {
  final Widget child;

  const _ErrorHandler({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écouter l'état d'authentification pour les erreurs
    ref.listen(authProvider, (previous, next) {
      if (next.error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return child;
  }
}
