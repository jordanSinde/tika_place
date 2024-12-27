import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/splash/providers/splash_provider.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../config/theme/app_colors.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
        redirect: (context, state) async {
          final splashState = await ref.read(splashProvider.future);
          if (splashState == SplashState.initialized) {
            return '/home';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'destination/:id',
                builder: (context, state) {
                  return Scaffold(
                    appBar: AppBar(),
                    body: const Center(
                      child: Text("Destination"),
                    ),
                  );
                },
              ),
              GoRoute(
                path: 'booking',
                redirect: (context, state) {
                  // Vérifier si l'utilisateur est connecté
                  final isAuthenticated =
                      ref.read(authProvider).isAuthenticated;
                  if (!isAuthenticated) {
                    // Sauvegarder la destination prévue pour y retourner après la connexion
                    ref
                        .read(authProvider.notifier)
                        .setRedirectPath('/home/booking');
                    return '/login';
                  }
                  return null;
                },
                builder: (context, state) => const BookingScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Material(
      child: Container(
        color: AppColors.background,
        child: Center(
          child: Text(
            'Page not found: ${state.path}',
            style: const TextStyle(
              fontSize: 20,
              color: AppColors.error,
            ),
          ),
        ),
      ),
    ),
  );
});

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
