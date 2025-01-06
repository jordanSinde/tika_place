import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../common/widgets/buttons/primary_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  Timer? _timer;
  bool _canResendEmail = true;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startEmailVerificationCheck() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerification(),
    );
  }

  Future<void> _checkEmailVerification() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    if (user.isEmailVerified) {
      _timer?.cancel();
      if (!mounted) return;

      // Afficher le dialogue de succès
      await showSuccessDialog();
    }
  }

  Future<void> _handleResendVerification() async {
    if (!_canResendEmail) return;

    setState(() {
      _canResendEmail = false;
      _resendCountdown = 60;
    });

    try {
      await ref.read(authProvider.notifier).verifyEmail();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Démarrer le compte à rebours pour le renvoi
      Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(() {
            if (_resendCountdown > 0) {
              _resendCountdown--;
            } else {
              _canResendEmail = true;
              timer.cancel();
            }
          });
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'Email Verified!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your email has been successfully verified. You can now access all features of the app.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Continue',
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) {
      context.go('/login');
      return const SizedBox();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              AuthHeader(
                title: 'Verify Your Email',
                subtitle:
                    'Please check your inbox and verify your email address',
                onBackPressed: () => context.go('/login'),
              ),
              const SizedBox(height: 48),

              const Icon(
                Icons.mark_email_unread_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),

              Text(
                'We sent a verification email to:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                user.email,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              const Text(
                "Click the link in the email to verify your address. If you can't find the email, check your spam folder.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              PrimaryButton(
                text: _canResendEmail
                    ? 'Resend Verification Email'
                    : 'Wait $_resendCountdown seconds',
                onPressed: () =>
                    _canResendEmail ? _handleResendVerification : null,
              ),
              const SizedBox(height: 16),

              TextButton.icon(
                onPressed: () => _checkEmailVerification(),
                icon: const Icon(Icons.refresh),
                label: const Text("I've verified my email"),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),

              const Spacer(),

              // Options supplémentaires
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => context.go('/support'),
                    child: const Text('Need Help?'),
                  ),
                  const SizedBox(width: 24),
                  TextButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).signOut();
                      if (!mounted) return;
                      context.go('/login');
                    },
                    child: const Text('Change Email'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
