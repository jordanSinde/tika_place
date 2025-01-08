import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../common/widgets/buttons/social_button.dart';
import '../../common/widgets/inputs/custom_textfield.dart';
import '../providers/auth_provider.dart';
import '../utils/error_text.dart';
import '../widgets/auth_header.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String? _errorMessage;
  bool _isGettingOTP = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // Gérer la connexion avec Google
  Future<void> _handleGoogleSignIn() async {
    setState(() => _errorMessage = null);
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  // Gérer la connexion avec Facebook
  Future<void> _handleFacebookSignIn() async {
    setState(() => _errorMessage = null);
    try {
      await ref.read(authProvider.notifier).signInWithFacebook();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  // Simuler l'envoi d'OTP
  Future<void> _handlePhoneSignIn() async {
    setState(() => _isGettingOTP = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulation
    setState(() => _isGettingOTP = false);
    // TODO: Implement actual phone authentication
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
                  title: 'Welcome Back',
                  subtitle: 'Sign in to continue your journey',
                  onBackPressed: () => context.go('/'),
                ),
                const SizedBox(height: 32),

                // Social Login Buttons
                SocialButton(
                  type: SocialButtonType.google,
                  onPressed: _handleGoogleSignIn,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: 16),
                SocialButton(
                  type: SocialButtonType.facebook,
                  onPressed: _handleFacebookSignIn,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: 32),

                // Divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('or continue with phone'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 32),

                // Error Message
                if (_errorMessage != null) ErrorText(error: _errorMessage!),

                // Phone Input Section
                CustomTextField(
                  hint: 'Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !authState.isLoading && !_isGettingOTP,
                  prefixIcon: Icons.phone,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handlePhoneSignIn(),
                ),
                const SizedBox(height: 24),

                // Get OTP Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState.isLoading || _isGettingOTP
                        ? null
                        : _handlePhoneSignIn,
                    child: _isGettingOTP
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Get OTP'),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Up Link
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/signup'),
                    child: RichText(
                      text: TextSpan(
                        text: 'Don\'t have an account? ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign up',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
