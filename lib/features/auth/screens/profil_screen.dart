import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../common/widgets/inputs/custom_textfield.dart';
import '../../common/widgets/buttons/primary_button.dart';
import '../providers/auth_provider.dart';
import '../utils/error_text.dart';
import '../utils/form_validator.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  String? _selectedLanguage;
  String? _selectedCountry;
  String? _errorMessage;
  bool _isEditing = false;

  final List<String> _languages = ['English', 'French', 'Arabic'];
  final List<String> _countries = ['Cameroon', 'France', 'USA', 'Canada'];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _firstNameController = TextEditingController(text: user?.firstName);
    _lastNameController = TextEditingController(text: user?.lastName);
    _phoneController = TextEditingController(text: user?.phoneNumber);
    _selectedLanguage = user?.language;
    _selectedCountry = user?.country;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authProvider.notifier).updateProfile({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'language': _selectedLanguage,
        'country': _selectedCountry,
      });

      if (mounted) {
        setState(() {
          _isEditing = false;
          _errorMessage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
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
            onChanged: _isEditing ? onChanged : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _errorMessage = null;
                  // Restaurer les valeurs originales
                  _firstNameController.text = user.firstName;
                  _lastNameController.text = user.lastName ?? '';
                  _phoneController.text = user.phoneNumber ?? '';
                  _selectedLanguage = user.language;
                  _selectedCountry = user.country;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ErrorText(error: _errorMessage!),

              // Section des informations de base
              Text(
                'Basic Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'First Name',
                      controller: _firstNameController,
                      enabled: _isEditing,
                      validator: FormValidator.name.build(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Last Name',
                      controller: _lastNameController,
                      enabled: _isEditing,
                      validator: FormValidator.name.build(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Email',
                initialValue: user.email,
                enabled: false, // Email ne peut pas être modifié
                validator: FormValidator.email.build(),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Phone Number',
                controller: _phoneController,
                enabled: _isEditing,
                validator: FormValidator.phone.build(),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // Section des préférences
              Text(
                'Preferences',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              _buildDropdownField(
                label: 'Language',
                value: _selectedLanguage,
                items: _languages,
                onChanged: (value) => setState(() => _selectedLanguage = value),
              ),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: 'Country',
                value: _selectedCountry,
                items: _countries,
                onChanged: (value) => setState(() => _selectedCountry = value),
              ),
              const SizedBox(height: 32),

              if (_isEditing)
                PrimaryButton(
                  text: 'Save Changes',
                  onPressed: _handleSave,
                  isLoading: authState.isLoading,
                ),

              const SizedBox(height: 24),

              // Section de sécurité
              if (!_isEditing) ...[
                Text(
                  'Security',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigation vers l'écran de changement de mot de passe
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
