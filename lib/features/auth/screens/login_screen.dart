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

  Future<void> _handleLoginWithEmailPasswoord() async {
    setState(() => _errorMessage = null);

    if (_formKey.currentState?.validate() ?? false) {
      try {
        await ref.read(authProvider.notifier).signInWithEmail(
              _emailController.text.trim(),
              _passwordController.text,
            );

        if (!mounted) return;

        // La navigation sera gérée automatiquement par le routeur
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
                  title: 'Welcome Back',
                  subtitle: 'Sign in to continue',
                  onBackPressed: () => context.go('/'),
                ),
                const SizedBox(height: 32),
                // Social Buttons
                SocialButton(
                  type: SocialButtonType.google,
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                SocialButton(
                  type: SocialButtonType.facebook,
                  onPressed: () {},
                ),
                const SizedBox(height: 32),
                // Divider
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
                // Email Input
                Center(
                  child: Text(
                    'Sign up with your email address',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                const SizedBox(height: 32),
                /*CustomTextField(
                  label: 'Email',
                  hint: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email';
                    }
                    if (!value!.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Password Input
                CustomTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixIconPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your password';
                    }
                    if (value!.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),*/
                if (_errorMessage != null) ErrorText(error: _errorMessage!),
                CustomTextField(
                  //label: 'Email',
                  hint: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: FormValidator.email.build(),
                  enabled: !authState.isLoading,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  //label: 'Password',
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
                  onSubmitted: (_) => _handleLoginWithEmailPasswoord(),
                ),
                const SizedBox(height: 8),
                //const SizedBox(height: 32),
                // Login Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implémenter la réinitialisation du mot de passe
                    },
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState.isLoading
                        ? null
                        : _handleLoginWithEmailPasswoord,
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
                // Sign Up Link
                /*Center(
                  child: TextButton(
                    onPressed: () {
                      //Navigator.pushNamed(context, '/signup');
                      context.go('/signup');
                    },
                    child: const Text(
                      'Don\'t have an account? Sign up',
                      style: TextStyle(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),*/
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
