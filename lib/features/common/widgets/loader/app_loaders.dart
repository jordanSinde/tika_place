import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoader({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          color: color ?? AppColors.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
