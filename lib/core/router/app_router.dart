import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/auth_state.dart';
import '../../features/new/appartement_list_screen.dart';
import '../../features/new/appartements_booking_screen.dart';
import '../../features/new/appartements_detail_screen.dart';
import '../../features/new/bus_booking_screen.dart';
import '../../features/new/bus_destination.dart';
import '../../features/new/bus_detail_screen.dart';
import '../../features/splash/providers/splash_provider.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../config/theme/app_colors.dart';

/*final routerProvider = Provider<GoRouter>(
  (ref) {
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
  },
);*/

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash et Auth
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

      // Application principale
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
          );
        },
        routes: [
          // Home
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Bus Routes
          GoRoute(
            path: '/bus/destinations',
            builder: (context, state) => const BusDestinationsScreen(),
          ),
          GoRoute(
            path: '/bus/details/:id',
            builder: (context, state) => BusDetailsScreen(
              busId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/bus/booking',
            builder: (context, state) => const BusBookingScreen(),
            redirect: (context, state) =>
                _authGuard(authState, state.fullPath!),
          ),

          // Apartment Routes
          GoRoute(
            path: '/apartments/list',
            builder: (context, state) => const ApartmentsListScreen(),
          ),
          GoRoute(
            path: '/apartments/details/:id',
            builder: (context, state) => ApartmentDetailsScreen(
              apartmentId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/apartments/booking',
            builder: (context, state) => const ApartmentBookingScreen(),
            redirect: (context, state) =>
                _authGuard(authState, state.fullPath!),
          ),

          // Hotel Routes
          GoRoute(
            path: '/hotels/list',
            builder: (context, state) => Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: Text("Hotel Liste"),
              ),
            ), //const HotelsListScreen()
          ),
          GoRoute(
            path: '/hotels/rooms',
            builder: (context, state) => Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: Text("Hotel Room"),
              ),
            ), //const HotelRoomsScreen()
          ),
          GoRoute(
            path: '/hotels/details/:id',
            builder: (context, state) => Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: Text("Hotel Destination"),
              ),
            ),
            /*HotelDetailsScreen(
              hotelId: state.pathParameters['id']!,
            ),*/
          ),
          GoRoute(
            path: '/hotels/booking',
            builder: (context, state) => Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: Text("Hotel Booking"),
              ),
            ), //const HotelBookingScreen()
            redirect: (context, state) =>
                _authGuard(authState, state.fullPath!),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Material(
      child: Container(
        color: AppColors.background,
        child: Center(
          child: Text(
            'Page introuvable: ${state.path}',
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

String? _authGuard(AuthState authState, String path) {
  if (!authState.isAuthenticated) {
    return '/login';
  }
  return null;
}
