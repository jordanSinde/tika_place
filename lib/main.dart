import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: MyApp(),
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