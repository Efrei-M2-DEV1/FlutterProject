import 'package:flutter/material.dart';

/// Couleurs de l'application avec support dark/light
class AppColors {
  // ===== COULEURS PRINCIPALES =====
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color tertiary = Color(0xFF06B6D4);

  // ===== COULEURS SYSTÈME =====
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ===== COULEURS COMMUNES =====
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onError = Colors.white;

  // ===== THÈME CLAIR =====
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF3F4F6);
  static const Color lightOnSurface = Color(0xFF1F2937);
  static const Color lightOnSurfaceVariant = Color(0xFF6B7280);
  static const Color lightOnBackground = Color(0xFF1F2937);
  static const Color lightOutline = Color(0xFFE5E7EB);

  // ===== THÈME SOMBRE - COULEURS AMÉLIORÉES =====
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkOnSurface = Color(
    0xFFF1F5F9,
  ); // ✅ Plus clair pour meilleure lisibilité
  static const Color darkOnSurfaceVariant = Color(
    0xFFCBD5E1,
  ); // ✅ AMÉLIORÉ : Plus clair et contrasté
  static const Color darkOnBackground = Color(
    0xFFF8FAFC,
  ); // ✅ AMÉLIORÉ : Encore plus clair
  static const Color darkOutline = Color(0xFF475569);

  // ===== GRADIENTS =====
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkSurface, darkSurfaceVariant],
  );

  // ===== MÉTHODES DYNAMIQUES =====

  /// Background selon le thème
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  /// Surface selon le thème
  static Color getSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : lightSurface;
  }

  /// Surface variant selon le thème
  static Color getSurfaceVariant(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurfaceVariant
        : lightSurfaceVariant;
  }

  /// OnSurface selon le thème
  static Color getOnSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkOnSurface
        : lightOnSurface;
  }

  static Color getOnSurfaceVariant(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkOnSurfaceVariant
        : lightOnSurfaceVariant;
  }

  /// OnBackground selon le thème
  static Color getOnBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkOnBackground
        : lightOnBackground;
  }

  /// Outline selon le thème
  static Color getOutline(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkOutline
        : lightOutline;
  }

  // ===== COULEURS SPÉCIALES POUR TEXTES =====

  /// Couleur pour les titres de section en mode dark
  static Color getSectionTitle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF374151); // Gris foncé en light
  }

  /// Couleur pour les labels/descriptions en mode dark
  static Color getLabel(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF6B7280); // Gris moyen en light
  }

  // ===== COMPATIBILITÉ (pour l'ancien code) =====
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color surfaceVariant = lightSurfaceVariant;
  static const Color onSurface = lightOnSurface;
  static const Color onSurfaceVariant = lightOnSurfaceVariant;
  static const Color onBackground = lightOnBackground;
  static const Color outline = lightOutline;
}
