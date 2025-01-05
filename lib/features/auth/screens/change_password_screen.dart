import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../common/widgets/inputs/custom_textfield.dart';
import '../../common/widgets/buttons/primary_button.dart';
import '../providers/auth_provider.dart';
import '../utils/error_text.dart';
import '../utils/form_validator.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    setState(() => _errorMessage = null);

    if (_formKey.currentState?.validate() ?? false) {
      try {
        await ref.read(authProvider.notifier).changePassword(
              _currentPasswordController.text,
              _newPasswordController.text,
            );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        setState(() => _errorMessage = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your current password and choose a new one',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null) ErrorText(error: _errorMessage!),
              CustomTextField(
                label: 'Current Password',
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                validator: FormValidator.password.build(),
                suffixIcon: _obscureCurrentPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                onSuffixIconPressed: () {
                  setState(
                      () => _obscureCurrentPassword = !_obscureCurrentPassword);
                },
                enabled: !authState.isLoading,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'New Password',
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                validator: FormValidator.password.build(),
                suffixIcon: _obscureNewPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                onSuffixIconPressed: () {
                  setState(() => _obscureNewPassword = !_obscureNewPassword);
                },
                enabled: !authState.isLoading,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Confirm New Password',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                validator: (value) => FormValidator.confirmPassword(
                  value,
                  _newPasswordController.text,
                ),
                suffixIcon: _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                onSuffixIconPressed: () {
                  setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
                enabled: !authState.isLoading,
                onSubmitted: (_) => _handleChangePassword(),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Update Password',
                onPressed: _handleChangePassword,
                isLoading: authState.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
