// lib/core/utils/snackbar_utils.dart

import 'package:flutter/material.dart';
import '../../core/config/theme/app_colors.dart';

class SnackbarUtils {
  /// Affiche une Snackbar avec le message "Bientôt disponible"
  static void showComingSoonMessage(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cette fonctionnalité sera bientôt disponible !'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Affiche une Snackbar avec un message personnalisé
  static void showMessage(
    BuildContext context, {
    required String message,
    Color backgroundColor = Colors.black87,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Affiche une Snackbar de succès
  static void showSuccess(BuildContext context, String message) {
    showMessage(
      context,
      message: message,
      backgroundColor: AppColors.success,
    );
  }

  /// Affiche une Snackbar d'erreur
  static void showError(BuildContext context, String message) {
    showMessage(
      context,
      message: message,
      backgroundColor: AppColors.error,
    );
  }

  /// Affiche une Snackbar d'information
  static void showInfo(BuildContext context, String message) {
    showMessage(
      context,
      message: message,
      backgroundColor: AppColors.primary,
    );
  }
}

//UTILISATIONs

/*

// Importez le fichier
import 'package:your_app_name/core/utils/snackbar_utils.dart';

// Puis utilisez-le dans vos widgets
ElevatedButton(
  onPressed: () => SnackbarUtils.showComingSoonMessage(context),
  child: const Text('Fonctionnalité future'),
),

// Ou utilisez l'une des autres méthodes
IconButton(
  icon: const Icon(Icons.share),
  onPressed: () => SnackbarUtils.showComingSoonMessage(context),
),

// Pour un message personnalisé
TextButton(
  onPressed: () => SnackbarUtils.showMessage(
    context, 
    message: 'Votre message personnalisé ici',
    backgroundColor: Colors.purple,
  ),
  child: const Text('Message personnalisé'),
),

// Pour un message de succès
ElevatedButton(
  onPressed: () => SnackbarUtils.showSuccess(context, 'Opération réussie !'),
  child: const Text('Succès'),
),

// Pour un message d'erreur
ElevatedButton(
  onPressed: () => SnackbarUtils.showError(context, 'Une erreur est survenue'),
  child: const Text('Erreur'),
),*/