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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /*Future<void> _handleResetRequest() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await ref.read(authProvider.notifier).requestPasswordReset(
              _emailController.text.trim(),
            );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset instructions sent to your email'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        setState(() => _errorMessage = e.toString());
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

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
                  subtitle: 'Enter your email to receive reset instructions',
                  onBackPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 32),
                if (_errorMessage != null) ErrorText(error: _errorMessage!),
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: FormValidator.email.build(),
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Send Instructions',
                  onPressed: () {}, //_handleResetRequest,
                  isLoading: authState.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
