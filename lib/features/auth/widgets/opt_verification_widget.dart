import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../providers/auth_provider.dart';
import '../utils/error_text.dart';

class OTPVerificationWidget extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final bool isLogin;
  final bool autoStartVerification;

  const OTPVerificationWidget({
    super.key,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.isLogin = false,
    this.autoStartVerification = true,
  });

  @override
  ConsumerState<OTPVerificationWidget> createState() =>
      _OTPVerificationWidgetState();
}

class _OTPVerificationWidgetState extends ConsumerState<OTPVerificationWidget> {
  final _otpController = TextEditingController();
  String? _errorMessage;
  bool _isInitialized = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _startPhoneVerification() async {
    try {
      await ref
          .read(authProvider.notifier)
          .startPhoneVerification(widget.phoneNumber);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) return;

    setState(() => _errorMessage = null);

    try {
      if (widget.isLogin) {
        await ref.read(authProvider.notifier).verifyOTP(
              smsCode: _otpController.text,
              phoneNumber: widget.phoneNumber,
              firstName: '',
              lastName: '',
            );
      } else {
        await ref.read(authProvider.notifier).verifyOTP(
              smsCode: _otpController.text,
              phoneNumber: widget.phoneNumber,
              firstName: widget.firstName ?? '',
              lastName: widget.lastName ?? '',
            );
      }

      // Vérifier si l'authentification a réussi
      if (mounted && ref.read(authProvider).isAuthenticated) {
        // Utiliser GoRouter pour la navigation
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final resendCountdown = ref.watch(authProvider.notifier).resendCountdown;

    if (!_isInitialized && widget.autoStartVerification) {
      _isInitialized = true;
      Future.microtask(() => _startPhoneVerification());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter verification code',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the code sent to ${widget.phoneNumber}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 24),
        if (_errorMessage != null) ErrorText(error: _errorMessage!),
        const SizedBox(height: 16),
        Pinput(
          length: 6,
          controller: _otpController,
          onCompleted: (pin) => _verifyOTP(),
          enabled: !authState.isLoading,
          defaultPinTheme: PinTheme(
            width: 56,
            height: 56,
            textStyle: theme.textTheme.headlineSmall,
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: resendCountdown == 0 && !authState.isLoading
                ? () => _startPhoneVerification()
                : null,
            child: Text(
              resendCountdown > 0
                  ? 'Resend code in ${resendCountdown}s'
                  : 'Resend code',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: resendCountdown > 0 || authState.isLoading
                    ? theme.disabledColor
                    : theme.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authState.isLoading ? null : () => _verifyOTP(),
            child: authState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Verify'),
          ),
        ),
      ],
    );
  }
}
