import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/manage_sessions_screen.dart';
import '../../features/auth/screens/opt_verification_screen.dart';
import '../../features/bus_booking/screens/bus_booking_process_screen.dart';
import '../../features/home/models/bus_mock_data.dart';
import '../../features/bus_booking/bus_booking_list_screen.dart';
import '../../features/main/screens/main_scaffold.dart';
import '../../features/onboarding/provider/onboarding_provider.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/notifications_settings_screen.dart';
import '../../features/settings/screens/report_problem_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../config/theme/app_colors.dart';

// Widgets et thèmes
import '../utils/page_transition.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

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

      GoRoute(
        path: '/report-problem',
        pageBuilder: (context, state) => PageTransitions.fadeTransition(
          context,
          state,
          const ReportProblemScreen(),
        ),
      ),
      GoRoute(
        path: '/edit-profile',
        pageBuilder: (context, state) => PageTransitions.fadeTransition(
          context,
          state,
          const EditProfileScreen(),
        ),
      ),

      GoRoute(
        path: '/notifications-settings',
        pageBuilder: (context, state) => PageTransitions.fadeTransition(
          context,
          state,
          const NotificationSettingsScreen(),
        ),
      ),

      GoRoute(
        path: '/bus-list',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>? ?? {};
          return BusBookingListScreen(
            initialFilters: params['filters'] as BusSearchFilters? ??
                const BusSearchFilters(),
          );
        },
      ),
      GoRoute(
        path: '/bus-booking',
        builder: (context, state) {
          final bus = state.extra as Bus;
          return BusBookingProcessScreen(selectedBus: bus);
        },
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
        path: '/manage-sessions',
        pageBuilder: (context, state) => PageTransitions.slideTransition(
          context,
          state,
          const ManageSessionsScreen(),
        ),
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

/*
'/payment': PaymentScreen,
'/payment-success': PaymentSuccessScreen,
'/tickets': TicketsHistoryScreen,
'/ticket-scanner': TicketScannerScreen,
'/validation-history': ValidationHistoryScreen
*/