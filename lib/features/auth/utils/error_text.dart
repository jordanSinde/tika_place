import 'package:flutter/material.dart';
import '../../../core/config/theme/app_colors.dart';

class ErrorText extends StatelessWidget {
  final String? error;
  final double bottomPadding;

  const ErrorText({
    super.key,
    required this.error,
    this.bottomPadding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    if (error == null || error!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
