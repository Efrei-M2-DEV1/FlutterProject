import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

enum ButtonVariant { primary, secondary, outline, text }

/// Bouton personnalisé avec plusieurs variantes
class CustomButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool expanded;
  final EdgeInsets? padding;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.expanded = true,
    this.padding,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = _buildButton(context);

    if (expanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Widget _buildButton(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: isLoading ? _buildLoader() : child,
        );

      case ButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.getSurfaceVariant(context),
            foregroundColor: AppColors.getOnSurface(context),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: isLoading ? _buildLoader() : child,
        );

      case ButtonVariant.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: isLoading ? _buildLoader() : child,
        );

      case ButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: isLoading ? _buildLoader() : child,
        );
    }
  }

  Widget _buildLoader() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}
