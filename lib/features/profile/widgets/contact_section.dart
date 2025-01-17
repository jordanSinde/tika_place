// lib/features/profile/widgets/contacts_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/user.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../auth/utils/form_validator.dart';
import '../../common/widgets/inputs/custom_textfield.dart';
import '../../common/widgets/buttons/primary_button.dart';

class ContactsSection extends ConsumerWidget {
  final List<Contact> contacts;

  const ContactsSection({super.key, required this.contacts});

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            'Aucun proche ajouté',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.textLight),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Ajouter un proche',
            onPressed: () => _showAddContactDialog(context),
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList(List<Contact> contacts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                contact.firstName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text('${contact.firstName} ${contact.lastName ?? ""}'),
            subtitle: Text(contact.phoneNumber),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showAddContactDialog(context, contact: contact);
                } else if (value == 'delete') {
                  _showDeleteDialog(context, contact);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Supprimer',
                          style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Contact contact) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le contact'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer ${contact.firstName} de vos proches ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // Implémenter la suppression
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact supprimé'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Supprimer',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddContactDialog(BuildContext context, {Contact? contact}) {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController(text: contact?.firstName);
    final lastNameController = TextEditingController(text: contact?.lastName);
    final phoneController = TextEditingController(text: contact?.phoneNumber);
    final relationshipController =
        TextEditingController(text: contact?.relationship);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(contact == null ? 'Ajouter un proche' : 'Modifier le contact'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Prénom',
                  controller: firstNameController,
                  validator: FormValidator.name.build(),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Nom',
                  controller: lastNameController,
                  validator: FormValidator.name.build(),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Téléphone',
                  controller: phoneController,
                  validator: FormValidator.phoneNumber.build(),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Relation',
                  controller: relationshipController,
                  hint: 'Ex: Famille, Ami, etc.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Implémenter l'ajout/modification
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(contact == null
                        ? 'Contact ajouté avec succès'
                        : 'Contact modifié avec succès'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text(contact == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vos proches',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _showAddContactDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          contacts.isEmpty
              ? _buildEmptyState(context)
              : _buildContactsList(contacts),
        ],
      ),
    );
  }
}
