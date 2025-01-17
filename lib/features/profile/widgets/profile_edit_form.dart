// lib/features/profile/widgets/profile_edit_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../auth/models/user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/utils/form_validator.dart';
import '../../common/widgets/inputs/custom_textfield.dart';
import '../../common/widgets/buttons/primary_button.dart';

class ProfileEditForm extends ConsumerStatefulWidget {
  final UserModel user;

  const ProfileEditForm({super.key, required this.user});

  @override
  ConsumerState<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends ConsumerState<ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  String? _selectedLanguage;
  String? _selectedCountry;
  bool _isLoading = false;

  final List<String> _languages = ['English', 'French', 'Arabic'];
  final List<String> _countries = ['Cameroon', 'France', 'USA', 'Canada'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _selectedLanguage = widget.user.language;
    _selectedCountry = widget.user.country;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).updateProfile({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'language': _selectedLanguage,
        'country': _selectedCountry,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Informations de base'),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Prénom',
            controller: _firstNameController,
            validator: FormValidator.name.build(),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Nom',
            controller: _lastNameController,
            validator: FormValidator.name.build(),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Email',
            initialValue: widget.user.email,
            enabled: false,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Téléphone',
            controller: _phoneController,
            validator: FormValidator.phone.build(),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Préférences'),
          const SizedBox(height: 24),
          _buildDropdownField(
            label: 'Langue',
            value: _selectedLanguage,
            items: _languages,
            onChanged: (value) => setState(() => _selectedLanguage = value),
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Pays',
            value: _selectedCountry,
            items: _countries,
            onChanged: (value) => setState(() => _selectedCountry = value),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Enregistrer les modifications',
            onPressed: _handleSubmit,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
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
          ),
        ),
      ],
    );
  }
}

// Widget titre de section réutilisable
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}
