// lib/features/common/widgets/inputs/custom_textfield.dart
import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.contentPadding,
  }) : assert(
          controller == null || initialValue == null,
          'Cannot provide both a controller and an initialValue',
        );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          focusNode: focusNode,
          enabled: enabled,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          onChanged: onChanged,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          expands: expands,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: enabled
                ? AppColors.inputBackground
                : AppColors.inputBackground.withOpacity(0.5),
            contentPadding: contentPadding ??
                const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
            errorStyle: const TextStyle(
              color: AppColors.error,
            ),
          ),
          style: enabled
              ? null
              : TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
        ),
      ],
    );
  }
}
