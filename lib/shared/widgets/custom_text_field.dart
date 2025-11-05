import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Champ de saisie personnalisé et réutilisable
///
/// Fonctionnalités :
/// - Design cohérent avec le thème
/// - Validation intégrée
/// - Icônes prefix/suffix
/// - Support de tous les types de clavier
/// - États focus/erreur gérés automatiquement
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final int maxLines;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label du champ
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getOnSurface(context),
          ),
        ),

        const SizedBox(height: 8),

        // Champ de saisie
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          maxLines: maxLines,
          enabled: enabled,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.getOnSurface(context),
          ),
          decoration: InputDecoration(
            // Texte d'aide
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.getOnSurfaceVariant(context).withOpacity(0.7),
            ),

            // Icônes
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primary)
                : null,
            suffixIcon: suffixIcon,

            // Style du conteneur
            filled: true,
            fillColor: AppColors.getSurfaceVariant(context),

            // Bordures
            border: OutlineInputBorder(
              borderRadius: AppTheme.radiusMedium,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppTheme.radiusMedium,
              borderSide: BorderSide(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppTheme.radiusMedium,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppTheme.radiusMedium,
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppTheme.radiusMedium,
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),

            // Espacement interne
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
