import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../common/widgets/inputs/custom_textfield.dart';
import '../providers/auth_provider.dart';
import '../utils/error_text.dart';
import '../utils/form_validator.dart';
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
  final _phoneController = TextEditingController();
  String? _errorMessage;
  String? _selectedLanguage;
  bool _isGettingOTP = false;
  String title = "Créer un compte";
  String? subtitle = "Rejoignez-nous et commencez votre voyage.";

  final List<String> _languages = ['English', 'French', 'Arabic'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
              hint: 'Numéro',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: FormValidator.phone.build(),
              textInputAction: TextInputAction.next,
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
      if (!mounted) return;
      _checkAndCompleteProfile();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _handleFacebookSignIn() async {
    setState(() => _errorMessage = null);
    try {
      await ref.read(authProvider.notifier).signInWithFacebook();
      if (!mounted) return;
      _checkAndCompleteProfile();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

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
    return Container(
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
    );
  }

  Future<void> _handlePhoneSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

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
        // Navigation vers l'écran de vérification OTP
        context.push('/verify-otp', extra: {
          'phoneNumber': fullPhoneNumber,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'isLogin': false,
        });
        setState(() => _isGettingOTP = false);
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
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      Text(
                        'Back',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
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
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('ou numéro de téléphone'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 32),
                if (_errorMessage != null) ErrorText(error: _errorMessage!),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        hint: 'Prénom',
                        controller: _firstNameController,
                        validator: FormValidator.name.build(),
                        textInputAction: TextInputAction.next,
                        enabled: !authState.isLoading && !_isGettingOTP,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        hint: 'Nom',
                        controller: _lastNameController,
                        validator: FormValidator.name.build(),
                        textInputAction: TextInputAction.next,
                        enabled: !authState.isLoading && !_isGettingOTP,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPhoneField(),
                const SizedBox(height: 16),
                _buildDropdownField(
                  hint: 'Langue',
                  value: _selectedLanguage,
                  items: _languages,
                  onChanged: (value) =>
                      setState(() => _selectedLanguage = value),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState.isLoading || _isGettingOTP
                        ? null
                        : _handlePhoneSignUp,
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
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: RichText(
                      text: TextSpan(
                        text: 'Vous avez déjà un compte ? ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Se connecter',
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
