import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/auth_state.dart';
import '../../features/new/apartments_provider.dart';
import '../../features/new/appartement_list_screen.dart';
import '../../features/new/appartements_booking_screen.dart';
import '../../features/new/appartements_detail_screen.dart';
import '../../features/new/bus_booking_screen.dart';
import '../../features/new/bus_destination.dart';
import '../../features/new/bus_detail_screen.dart';
import '../../features/new/bus_routes_provider.dart';
import '../../features/splash/providers/splash_provider.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../config/theme/app_colors.dart';

// Widgets et thèmes
import '../../features/common/widgets/drawers/custom_drawer.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Routes sans shell (pas d'AppBar)
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

      // Application principale avec Shell (AppBar commune)
      ShellRoute(
        builder: (context, state, child) {
          return Consumer(
            builder: (context, ref, _) {
              final showAppBar = state.uri.toString() != '/home';
              final drawerEnabled = state.uri.toString() != '/login' &&
                  state.uri.toString() != '/signup' &&
                  state.uri.toString() != '/';

              return Scaffold(
                // AppBar dynamique

                appBar: showAppBar
                    ? AppBar(
                        leading: Navigator.of(context).canPop()
                            ? IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => context.pop(),
                              )
                            : drawerEnabled
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back_ios,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    onPressed: () => context.go('/home'),
                                  )
                                : null,
                        title: Text(_getTitle(state, ref)),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        actions: [
                          // Vous pouvez ajouter des actions communes ici
                          if (drawerEnabled) ...[
                            IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                // Implémentez la recherche globale
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      )
                    : null,
                // Drawer conditionnel
                drawer: drawerEnabled ? const CustomDrawer() : null,
                body: child,
              );
            },
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
            builder: (context, state) => const Center(
              child: Text("Liste des hôtels"),
            ),
          ),
          GoRoute(
            path: '/hotels/rooms',
            builder: (context, state) => const Center(
              child: Text("Chambres disponibles"),
            ),
          ),
          GoRoute(
            path: '/hotels/details/:id',
            builder: (context, state) => Center(
              child: Text("Détails de l'hôtel ${state.pathParameters['id']}"),
            ),
          ),
          GoRoute(
            path: '/hotels/booking',
            builder: (context, state) => const Center(
              child: Text("Réservation d'hôtel"),
            ),
            redirect: (context, state) =>
                _authGuard(authState, state.fullPath!),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Material(
      child: Scaffold(
        body: SafeArea(
          child: Container(
            color: AppColors.background,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Page introuvable: ${state.path}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/home');
                    },
                    child: const Text('Retour à l\'accueil'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
});

String _getTitle(GoRouterState state, WidgetRef ref) {
  final path = state.matchedLocation;

  if (path.startsWith('/bus/details/')) {
    final busId = state.pathParameters['id']!;
    final busRoute = ref.watch(busRouteByIdProvider(busId));
    if (busRoute != null) {
      return '${busRoute.departureCity} → ${busRoute.arrivalCity}';
    }
    return 'Détails du trajet';
  }

  if (path.startsWith('/apartments/details/')) {
    final apartmentId = state.pathParameters['id']!;
    final apartments = ref.watch(allApartmentsProvider);
    final apartment = apartments.firstWhereOrNull(
      (apt) => apt.id == apartmentId,
    );
    if (apartment != null) {
      return apartment.title;
    }
    return 'Détails de l\'appartement';
  }

  // Titres statiques pour les autres routes
  switch (path) {
    case '/home':
      return 'Accueil';
    case '/bus/destinations':
      return 'Destinations des bus';
    case '/bus/booking':
      return 'Réservation de billet';
    case '/apartments/list':
      return 'Appartements disponibles';
    case '/apartments/booking':
      return 'Réservation d\'appartement';
    case '/hotels/list':
      return 'Liste des hôtels';
    case '/hotels/rooms':
      return 'Chambres disponibles';
    case '/hotels/booking':
      return 'Réservation d\'hôtel';
    case '/login':
      return 'Connexion';
    case '/signup':
      return 'Inscription';
    default:
      return 'Tika Place';
  }
}

String? _authGuard(AuthState authState, String path) {
  if (!authState.isAuthenticated) {
    return '/login';
  }
  return null;
}

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
