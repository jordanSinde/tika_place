import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../common/widgets/buttons/social_button.dart';
import '../../common/widgets/inputs/custom_textfield.dart';
import '../providers/auth_provider.dart';

import '../utils/error_text.dart';
import '../utils/form_validator.dart';
import '../widgets/auth_header.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Gérer la connexion avec email/mot de passe
  Future<void> _handleEmailSignIn() async {
    setState(() => _errorMessage = null);

    if (_formKey.currentState?.validate() ?? false) {
      try {
        await ref.read(authProvider.notifier).signInWithEmail(
              _emailController.text.trim(),
              _passwordController.text,
            );
      } catch (e) {
        setState(() => _errorMessage = e.toString());
      }
    }
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
                  title: 'Welcome',
                  subtitle: 'Sign in to continue',
                  onBackPressed: () => context.go('/'),
                ),
                const SizedBox(height: 32),

                // Boutons de connexion sociale
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

                // Séparateur
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('or'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 32),

                // Formulaire de connexion par email
                if (_errorMessage != null) ErrorText(error: _errorMessage!),

                CustomTextField(
                  hint: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: FormValidator.email.build(),
                  enabled: !authState.isLoading,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  hint: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: FormValidator.password.build(),
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixIconPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  enabled: !authState.isLoading,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleEmailSignIn(),
                ),
                const SizedBox(height: 8),

                // Lien "Mot de passe oublié"
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text(
                      'Forgot Password?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton de connexion
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleEmailSignIn,
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 16),

                // Lien d'inscription
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
