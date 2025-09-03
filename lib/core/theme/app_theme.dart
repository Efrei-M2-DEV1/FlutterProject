import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Configuration complète du thème de l'application
///
/// Cette classe est CRUCIALE pour ton rôle UI/UX !
/// Elle centralise TOUS les aspects visuels de l'app :
/// - Couleurs, typographie, formes, espacements
/// - Style des composants (boutons, champs, cartes...)
/// - Cohérence visuelle dans toute l'application
class AppTheme {
  // ===== ESPACEMENTS STANDARDISÉS =====
  // Utilise toujours ces valeurs pour l'espacement
  static const EdgeInsets paddingXS = EdgeInsets.all(4);
  static const EdgeInsets paddingSmall = EdgeInsets.all(8);
  static const EdgeInsets paddingMedium = EdgeInsets.all(16); // Le plus utilisé
  static const EdgeInsets paddingLarge = EdgeInsets.all(24);
  static const EdgeInsets paddingXL = EdgeInsets.all(32);

  // ===== BORDURES ARRONDIES =====
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusMedium = BorderRadius.all(
    Radius.circular(12),
  );
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(16));

  // ===== DURÉES D'ANIMATION =====
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);

  /// Thème principal de l'application (mode clair)
  static ThemeData get lightTheme {
    return ThemeData(
      // ===== CONFIGURATION MATERIAL 3 =====
      useMaterial3: true, // Nouveau design system Google
      // ===== SCHÉMA DE COULEURS =====
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary, // Couleur de base pour générer la palette
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        background: AppColors.background,
        onBackground: AppColors.onBackground,
        error: AppColors.error,
      ),

      // ===== TYPOGRAPHIE GLOBALE =====
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
      ),

      // ===== STYLE DE L'APP BAR =====
      appBarTheme: const AppBarTheme(
        elevation: 0, // Pas d'ombre par défaut
        scrolledUnderElevation: 1, // Légère ombre au scroll
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
        titleTextStyle: AppTextStyles.titleLarge,

        // Configuration de la barre de statut (Android/iOS)
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // ===== STYLE DES CARTES =====
      cardTheme: CardThemeData(
        elevation: 2, // Légère ombre
        shadowColor: AppColors.primary.withOpacity(0.1), // Ombre colorée
        shape: const RoundedRectangleBorder(
          borderRadius: radiusLarge, // Coins arrondis
        ),
        color: AppColors.surface,
        margin: paddingSmall, // Espacement autour des cartes
      ),

      // ===== STYLE DU BOUTON FLOTTANT =====
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: radiusLarge),
      ),
    );
  }
}
