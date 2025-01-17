import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/auth_state.dart';
import '../../features/auth/providers/session_provider.dart';
import '../../features/auth/screens/manage_sessions_screen.dart';
import '../../features/auth/screens/opt_verification_screen.dart';
import '../../features/auth/screens/profil_screen.dart';
import '../../features/common/widgets/drawers/custom_drawer.dart';
import '../../features/main/screens/main_scaffold.dart';
import '../../features/new/apartments_provider.dart';
import '../../features/new/appartement_list_screen.dart';
import '../../features/new/appartements_booking_screen.dart';
import '../../features/new/appartements_detail_screen.dart';
import '../../features/new/bus_booking_screen.dart';
import '../../features/new/bus_destination.dart';
import '../../features/new/bus_detail_screen.dart';
import '../../features/new/bus_routes_provider.dart';
import '../../features/onboarding/provider/onboarding_provider.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../config/theme/app_colors.dart';

// Widgets et thèmes
import '../utils/page_transition.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final onboardingCompleted = ref.watch(onboardingCompletedProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // États de base
      final isAuth = authState.isAuthenticated;
      final isVerifyingPhone = ref.read(authProvider.notifier).isVerifyingPhone;
      final isInRecaptchaFlow =
          ref.read(authProvider.notifier).isInRecaptchaFlow;
      final onboardingDone = onboardingCompleted;

      // Routes actuelles
      final isSplash = state.matchedLocation == '/';
      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';
      final isVerifyingOTP = state.matchedLocation == '/verify-otp';

      // Si en cours de chargement ou dans le flux Recaptcha, ne pas rediriger
      if (authState.isLoading || isInRecaptchaFlow) return null;

      // Vérifier d'abord l'onboarding
      if (!onboardingDone && !isVerifyingPhone) {
        return '/onboarding';
      }

      // Priorité à la vérification OTP
      if (isVerifyingPhone && !isVerifyingOTP) {
        return '/verify-otp';
      }

      // Si l'utilisateur est authentifié
      if (isAuth) {
        if (isLoggingIn || isSigningUp || isSplash || isVerifyingOTP) {
          return '/home';
        }
        return null;
      }

      // Si non authentifié
      if (!isAuth && !isVerifyingPhone) {
        if (isSplash) return '/login';
        if (!isLoggingIn && !isSigningUp && !isVerifyingOTP) return '/login';
      }

      return null;
    },
    routes: [
      // Routes publiques
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => PageTransitions.fadeTransition(
          context,
          state,
          const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) {
          // Récupérer les paramètres extra en toute sécurité
          final params = state.extra as Map<String, dynamic>? ?? {};
          return OTPVerificationScreen(
            phoneNumber: params['phoneNumber'] as String? ?? '',
            firstName: params['firstName'] as String?,
            lastName: params['lastName'] as String?,
            isLogin: params['isLogin'] as bool? ?? false,
          );
        },
      ),

      //route protéger:
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => PageTransitions.fadeTransition(
          context,
          state,
          const MainScaffold(),
        ),
      ),

      // Routes protégées avec Shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Consumer(
            builder: (context, ref, _) {
              // Vérifier l'authentification
              final isAuth = ref.watch(authProvider).isAuthenticated;
              if (!isAuth) {
                return const LoginScreen();
              }

              // UI Shell commun pour les routes protégées
              return Scaffold(
                appBar: AppBar(
                  title: Text(_getTitle(state, ref)),
                  actions: _getActions(context, state, ref),
                ),
                drawer: const CustomDrawer(),
                body: child,
              );
            },
          );
        },
        routes: [
          // Home

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

          GoRoute(
            path: '/manage-sessions',
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              context,
              state,
              const ManageSessionsScreen(),
            ),
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

List<Widget> _getActions(
    BuildContext context, GoRouterState state, WidgetRef ref) {
  final currentRoute = state.matchedLocation;

  // Actions spécifiques selon la route
  if (currentRoute == '/profile') {
    return [
      IconButton(
        icon: const Icon(Icons.security),
        onPressed: () => context.push('/manage-sessions'),
      ),
    ];
  }

  if (currentRoute.startsWith('/manage-sessions')) {
    return [
      TextButton(
        onPressed: () async {
          final currentSession = ref.read(currentSessionProvider);
          if (currentSession != null) {
            await ref
                .read(sessionSecurityProvider)
                .revokeAllOtherSessions(currentSession.id);
          }
        },
        child: const Text('Revoke All'),
      ),
    ];
  }

  return [
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () async {
        await ref.read(authProvider.notifier).signOut();
        if (context.mounted) {
          context.go('/login');
        }
      },
    ),
  ];
}

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
