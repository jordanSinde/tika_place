// Créez un nouveau fichier otp_verification_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import '../../../core/config/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../utils/error_text.dart';

class OTPVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String? firstName; // Optional maintenant
  final String? lastName; // Optional maintenant
  final bool isLogin; // Ajout du champ isLogin

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.isLogin = false,
  });

  @override
  ConsumerState<OTPVerificationScreen> createState() =>
      _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final resendCountdown = ref.watch(authProvider.notifier).resendCountdown;

    if (!_isInitialized) {
      _isInitialized = true;
      Future.microtask(() => _startPhoneVerification());
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthHeader(
                  title: 'Verify Phone',
                  subtitle: 'Enter the code sent to ${widget.phoneNumber}',
                  onBackPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 32),
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
                      color: AppColors.inputBackground,
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
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) return;

    setState(() => _errorMessage = null);

    try {
      if (widget.isLogin) {
        // Mode connexion : vérification simple
        await ref.read(authProvider.notifier).verifyOTP(
              smsCode: _otpController.text,
              phoneNumber: widget.phoneNumber,
              firstName: '',
              lastName: '',
            );
      } else {
        // Mode inscription : création de compte
        if (widget.firstName == null || widget.lastName == null) {
          throw Exception('First name and last name are required for signup');
        }
        await ref.read(authProvider.notifier).verifyOTP(
              smsCode: _otpController.text,
              firstName: widget.firstName!,
              lastName: widget.lastName!,
              phoneNumber: widget.phoneNumber,
            );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    }
  }
}
/*class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startPhoneVerification();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _startPhoneVerification() async {
    try {
      print(
          'Démarrage de la vérification pour: ${widget.phoneNumber}'); // Debug
      await ref
          .read(authProvider.notifier)
          .startPhoneVerification(widget.phoneNumber);
    } catch (e) {
      print('Erreur de vérification: $e'); // Debug
      setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) return;

    setState(() => _errorMessage = null);

    try {
      await ref.read(authProvider.notifier).verifyOTP(
            smsCode: _otpController.text,
            firstName: widget.firstName,
            lastName: widget.lastName,
            phoneNumber: widget.phoneNumber,
          );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final resendCountdown = ref.watch(authProvider.notifier).resendCountdown;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthHeader(
                  title: 'Verify Phone',
                  subtitle: 'Enter the code sent to ${widget.phoneNumber}',
                  onBackPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 32),
                if (_errorMessage != null) ErrorText(error: _errorMessage!),
                const SizedBox(height: 16),
                Pinput(
                  length: 6,
                  controller: _otpController,
                  onCompleted: (pin) => _verifyOTP(),
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: resendCountdown == 0
                        ? () => _startPhoneVerification()
                        : null,
                    child: Text(
                      resendCountdown > 0
                          ? 'Resend code in ${resendCountdown}s'
                          : 'Resend code',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: resendCountdown > 0
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
                    onPressed: authState.isLoading ? null : _verifyOTP,
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
            ),
          ),
        ),
      ),
    );
  }
}*/
