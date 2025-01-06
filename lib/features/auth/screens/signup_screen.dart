import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../common/widgets/inputs/custom_textfield.dart';
import '../providers/auth_provider.dart';
import '../../common/widgets/buttons/primary_button.dart';
import '../utils/error_text.dart';
import '../utils/form_validator.dart';
import '../widgets/auth_header.dart';
import '../../common/widgets/buttons/social_button.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String? _selectedLanguage;
  String? _selectedCountry;

  final List<String> _languages = ['English', 'French', 'Arabic'];
  final List<String> _countries = ['Cameroon', 'France', 'USA', 'Canada'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Gérer l'inscription avec email/mot de passe
  Future<void> _handleEmailSignUp() async {
    setState(() => _errorMessage = null);

    if (_formKey.currentState?.validate() ?? false) {
      try {
        await ref.read(authProvider.notifier).signUpWithEmail({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'phoneNumber': _phoneController.text.trim(),
          'language': _selectedLanguage,
          'country': _selectedCountry,
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your email address'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
      } catch (e) {
        setState(() => _errorMessage = e.toString());
      }
    }
  }

  // Gérer l'inscription avec Google
  Future<void> _handleGoogleSignIn() async {
    setState(() => _errorMessage = null);
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      if (!mounted) return;

      // Vérifier si le profil est complet après la connexion Google
      _checkAndCompleteProfile();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  // Gérer l'inscription avec Facebook
  Future<void> _handleFacebookSignIn() async {
    setState(() => _errorMessage = null);
    try {
      await ref.read(authProvider.notifier).signInWithFacebook();
      if (!mounted) return;

      // Vérifier si le profil est complet après la connexion Facebook
      _checkAndCompleteProfile();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  // Vérifier et compléter le profil si nécessaire
  void _checkAndCompleteProfile() {
    final user = ref.read(authProvider).user;
    if (user != null && !user.hasCompletedProfile) {
      context.push('/complete-profile');
    }
  }

  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            hint: Text(
              hint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            items: items.map((String item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            validator: validator ?? FormValidator.required.build(),
          ),
        ),
      ],
    );
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
                  title: 'Create Account',
                  subtitle: 'Fill in your details to get started',
                  onBackPressed: () => context.go('/login'),
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

                // Message d'erreur
                if (_errorMessage != null) ErrorText(error: _errorMessage!),

                // Formulaire d'inscription
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        hint: 'First Name',
                        controller: _firstNameController,
                        validator: FormValidator.name.build(),
                        textInputAction: TextInputAction.next,
                        enabled: !authState.isLoading,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        hint: 'Last Name',
                        controller: _lastNameController,
                        validator: FormValidator.name.build(),
                        textInputAction: TextInputAction.next,
                        enabled: !authState.isLoading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  hint: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: FormValidator.email.build(),
                  textInputAction: TextInputAction.next,
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  hint: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: FormValidator.password.build(),
                  textInputAction: TextInputAction.next,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixIconPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  hint: 'Confirm Password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  validator: (value) => FormValidator.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  textInputAction: TextInputAction.next,
                  suffixIcon: _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixIconPressed: () {
                    setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  hint: 'Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: FormValidator.phone.build(),
                  textInputAction: TextInputAction.next,
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 16),

                _buildDropdownField(
                  hint: 'Language',
                  value: _selectedLanguage,
                  items: _languages,
                  onChanged: (value) =>
                      setState(() => _selectedLanguage = value),
                ),
                const SizedBox(height: 16),

                _buildDropdownField(
                  hint: 'Country',
                  value: _selectedCountry,
                  items: _countries,
                  onChanged: (value) =>
                      setState(() => _selectedCountry = value),
                ),
                const SizedBox(height: 32),

                // Bouton d'inscription
                PrimaryButton(
                  text: 'Create Account',
                  onPressed: _handleEmailSignUp,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: 24),

                // Lien de connexion
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
