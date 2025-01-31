// lib/features/bus_booking/screens/booking/steps/booking_step_indicator.dart

import 'package:flutter/material.dart';
import '../../../../../core/config/theme/app_colors.dart';

class BookingStepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const BookingStepIndicator({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(steps.length * 2 - 1, (index) {
              // Si l'index est pair, on affiche un cercle
              if (index.isEven) {
                final stepIndex = index ~/ 2;
                return _buildStep(stepIndex);
              }
              // Sinon, on affiche une ligne de connexion
              return _buildConnector(index ~/ 2);
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: steps.asMap().entries.map((entry) {
              return Expanded(
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: entry.key == currentStep
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: entry.key <= currentStep
                        ? AppColors.primary
                        : AppColors.textLight,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int index) {
    final isCompleted = index < currentStep;
    final isCurrent = index == currentStep;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? AppColors.success
            : isCurrent
                ? AppColors.primary
                : AppColors.background,
        border: Border.all(
          color: isCompleted
              ? AppColors.success
              : isCurrent
                  ? AppColors.primary
                  : AppColors.textLight,
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: isCurrent ? Colors.white : AppColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildConnector(int index) {
    return Container(
      width: 40,
      height: 2,
      color: index < currentStep
          ? AppColors.success
          : AppColors.textLight.withOpacity(0.3),
    );
  }
}
