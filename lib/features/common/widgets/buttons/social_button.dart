import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';

enum SocialButtonType { google, facebook }

class SocialButton extends StatelessWidget {
  final SocialButtonType type;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialButton({
    super.key,
    required this.type,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getButtonColor(),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    _getIconPath(),
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(_getButtonText()),
                ],
              ),
      ),
    );
  }

  Color _getButtonColor() {
    return type == SocialButtonType.google
        ? AppColors.googleButton
        : AppColors.facebookButton;
  }

  String _getIconPath() {
    return type == SocialButtonType.google
        ? 'assets/icons/google.png'
        : 'assets/icons/facebook.png';
  }

  String _getButtonText() {
    return 'Continue with ${type == SocialButtonType.google ? 'Google' : 'Facebook'}';
  }
}
