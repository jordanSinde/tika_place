import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../common/widgets/buttons/social_button.dart';
import '../../common/widgets/inputs/custom_textfield.dart';
import '../providers/auth_provider.dart';
import '../utils/error_text.dart';
import '../widgets/auth_header.dart';
import '../widgets/opt_verification_widget.dart';

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
  bool _showOtpVerification = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Country? _selectedCountryCode = Country(
    phoneCode: "237",
    countryCode: "CM",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Cameroon",
    example: "Example",
    displayName: "Cameroon",
    displayNameNoCountryCode: "CM",
    e164Key: "",
  );

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                onSelect: (Country country) {
                  setState(() {
                    _selectedCountryCode = country;
                  });
                },
              );
            },
            child: Text(
              '${_selectedCountryCode?.flagEmoji ?? '🌍'} +${_selectedCountryCode?.phoneCode ?? '237'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: AppColors.divider,
          ),
          Expanded(
            child: CustomTextField(
              hint: 'Phone Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              enabled: !ref.watch(authProvider).isLoading && !_isGettingOTP,
              contentPadding: const EdgeInsets.only(left: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _errorMessage = null);
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _handleFacebookSignIn() async {
    setState(() => _errorMessage = null);
    try {
      await ref.read(authProvider.notifier).signInWithFacebook();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _handlePhoneSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
      _isGettingOTP = true;
    });

    try {
      final fullPhoneNumber =
          '+${_selectedCountryCode?.phoneCode ?? '237'}${_phoneController.text.trim()}';

      // Démarrer la vérification du téléphone
      await ref
          .read(authProvider.notifier)
          .startPhoneVerification(fullPhoneNumber);

      if (mounted) {
        setState(() {
          _showOtpVerification = true;
          _isGettingOTP = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isGettingOTP = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isVerifyingPhone = ref.watch(authProvider.notifier).isVerifyingPhone;
    final theme = Theme.of(context);

    // Mettre à jour _showOtpVerification en fonction de isVerifyingPhone
    if (isVerifyingPhone && !_showOtpVerification) {
      setState(() {
        _showOtpVerification = true;
        _isGettingOTP = false;
      });
    }

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
                  title: _showOtpVerification
                      ? 'Verify Phone Login'
                      : 'Welcome Back',
                  subtitle: _showOtpVerification
                      ? 'Enter verification code Login'
                      : 'Sign in to continue your journey',
                  onBackPressed: () {
                    if (_showOtpVerification) {
                      // Annuler la vérification du téléphone
                      ref.read(authProvider.notifier).cancelPhoneVerification();
                      setState(() => _showOtpVerification = false);
                    } else {
                      context.go('/');
                    }
                  },
                ),
                const SizedBox(height: 32),
                if (_showOtpVerification)
                  OTPVerificationWidget(
                    phoneNumber:
                        '+${_selectedCountryCode?.phoneCode ?? '237'}${_phoneController.text.trim()}',
                    isLogin: true,
                    autoStartVerification: false,
                  )
                else ...[
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
                  _buildPhoneField(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
