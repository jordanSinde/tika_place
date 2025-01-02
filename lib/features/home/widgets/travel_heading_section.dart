import 'package:flutter/material.dart';
import '../../../core/config/theme/app_colors.dart';

class TravelHeadingSection extends StatelessWidget {
  const TravelHeadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        // Texte animé
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildWordBox('TRAVEL'),
            const SizedBox(width: 8),
            _buildWordBox('ALL'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildWordBox('OVER'),
            const SizedBox(width: 8),
            _buildWordBox('The', isHighlighted: true),
          ],
        ),
        const SizedBox(height: 8),
        _buildWordBox('WORLD', isHighlighted: true),
        const SizedBox(height: 24),
        // Bouton de réservation
      ],
    );
  }

  Widget _buildWordBox(String text, {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
    );
  }
}
