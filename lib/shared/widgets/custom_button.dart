import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Bouton personnalisé et réutilisable
///
/// Fonctionnalités :
/// - Design cohérent avec le thème
/// - État de chargement intégré
/// - Variantes de style (primary, secondary, outline)
/// - Tailles personnalisables
/// - Animations fluides
class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool expanded;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(),
        child: isLoading ? _buildLoadingWidget() : child,
      ),
    );
  }

  /// Hauteur selon la taille
  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 40;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  /// Style du bouton selon la variante
  ButtonStyle _getButtonStyle() {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
        );

      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceVariant,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
        );

      case ButtonVariant.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
        );
    }
  }

  /// Widget de chargement
  Widget _buildLoadingWidget() {
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

/// Variantes de style du bouton
enum ButtonVariant {
  primary, // Fond coloré
  secondary, // Fond gris
  outline, // Bordure seulement
}

/// Tailles du bouton
enum ButtonSize { small, medium, large }
