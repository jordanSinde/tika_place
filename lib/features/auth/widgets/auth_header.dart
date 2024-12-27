import 'package:flutter/material.dart';
import '../../../core/config/theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBackPressed;

  const AuthHeader({
    super.key,
    required this.title,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onBackPressed,
          child: Row(
            children: [
              const Icon(
                Icons.arrow_back_ios,
                color: AppColors.primary,
                size: 20,
              ),
              Text(
                'Back To Home',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
