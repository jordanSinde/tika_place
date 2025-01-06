// lib/features/auth/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../common/widgets/inputs/custom_textfield.dart';
import '../../common/widgets/buttons/primary_button.dart';
import '../providers/auth_provider.dart';
import '../utils/error_text.dart';
import '../utils/form_validator.dart';
import '../widgets/auth_header.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _errorMessage;
  bool _isResetSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetRequest() async {
    setState(() => _errorMessage = null);

    if (_formKey.currentState?.validate() ?? false) {
      try {
        await ref.read(authProvider.notifier).resetPassword(
              _emailController.text.trim(),
            );

        if (!mounted) return;

        setState(() => _isResetSent = true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset instructions sent to your email'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Attendre quelques secondes avant de rediriger
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            context.pop();
          }
        });
      } catch (e) {
        setState(() => _errorMessage = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthHeader(
                  title: 'Reset Password',
                  subtitle:
                      'Enter your email address to receive reset instructions',
                  onBackPressed: () => context.pop(),
                ),
                const SizedBox(height: 32),

                // Instructions
                Text(
                  _isResetSent
                      ? 'A password reset link has been sent to your email. Please check your inbox and follow the instructions.'
                      : 'We will send you an email with instructions to reset your password.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Message d'erreur
                if (_errorMessage != null) ErrorText(error: _errorMessage!),

                // Champ email
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: FormValidator.email.build(),
                  enabled: !authState.isLoading && !_isResetSent,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleResetRequest(),
                ),
                const SizedBox(height: 32),

                // Bouton d'envoi
                PrimaryButton(
                  text: _isResetSent ? 'Resend Email' : 'Send Instructions',
                  onPressed: () => !_isResetSent ? _handleResetRequest : null,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: 16),

                // Lien de retour
                if (!_isResetSent)
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: RichText(
                        text: TextSpan(
                          text: 'Remember your password? ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Timer si email envoyé
                if (_isResetSent)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Center(
                      child: Text(
                        'You can close this window or request a new reset link',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
