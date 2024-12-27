import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';

class TextDivider extends StatelessWidget {
  final String text;

  const TextDivider({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppColors.divider,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppColors.divider,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
