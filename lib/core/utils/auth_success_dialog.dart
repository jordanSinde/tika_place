import 'package:flutter/material.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../features/common/widgets/buttons/primary_button.dart';

class AuthSuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;
  final bool showCloseButton;
  final Widget? icon;

  const AuthSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
    this.showCloseButton = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCloseButton)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: AppColors.textSecondary,
                ),
              ),
            if (icon != null) ...[
              icon!,
              const SizedBox(height: 24),
            ] else
              const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: AppColors.success,
              ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (primaryButtonText != null)
              PrimaryButton(
                text: primaryButtonText!,
                onPressed:
                    onPrimaryButtonPressed ?? () => Navigator.of(context).pop(),
              ),
            if (secondaryButtonText != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onSecondaryButtonPressed ??
                    () => Navigator.of(context).pop(),
                child: Text(
                  secondaryButtonText!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Méthode utilitaire pour afficher le dialogue
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryButtonPressed,
    VoidCallback? onSecondaryButtonPressed,
    bool showCloseButton = true,
    Widget? icon,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AuthSuccessDialog(
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryButtonPressed: onPrimaryButtonPressed,
        onSecondaryButtonPressed: onSecondaryButtonPressed,
        showCloseButton: showCloseButton,
        icon: icon,
      ),
    );
  }
}
