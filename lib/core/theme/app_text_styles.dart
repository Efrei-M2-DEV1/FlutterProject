import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Styles de texte standardisés pour une cohérence visuelle
/// 
/// Pourquoi standardiser les styles de texte ?
/// - Cohérence visuelle (même taille, même poids partout)
/// - Accessibilité (tailles de texte appropriées)
/// - Maintenance facile
/// - Respect des guidelines Material Design
abstract class AppTextStyles {
  
  // Police principale (système par défaut pour commencer)
  static const String _fontFamily = 'Roboto';
  
  // ===== TITRES PRINCIPAUX =====
  // Pour les titres d'écrans, de sections importantes
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,                    // Grande taille pour l'impact
    fontWeight: FontWeight.bold,     // Gras pour hiérarchiser
    color: AppColors.onBackground,   // Couleur de base
    fontFamily: _fontFamily,
    height: 1.2,                     // Espacement entre lignes
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
    fontFamily: _fontFamily,
    height: 1.3,
  );
  
  // ===== TITRES DE SECTIONS =====
  // Pour les titres d'AppBar, de cartes, etc.
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,     // Semi-bold
    color: AppColors.onSurface,
    fontFamily: _fontFamily,
    height: 1.4,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    fontFamily: _fontFamily,
    height: 1.4,
  );
  
  // ===== TEXTE COURANT =====
  // Pour le contenu principal, descriptions, etc.
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurface,
    fontFamily: _fontFamily,
    height: 1.5,                     // Plus d'espace pour la lisibilité
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurface,
    fontFamily: _fontFamily,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurfaceVariant, // Plus clair pour info secondaire
    fontFamily: _fontFamily,
    height: 1.4,
  );
  
  // ===== STYLES SPÉCIALISÉS POUR LES TÂCHES =====
  // Styles métier spécifiques à l'app de tâches
  
  // Titre d'une tâche normale
  static const TextStyle taskTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    fontFamily: _fontFamily,
    height: 1.4,
  );
  
  // Titre d'une tâche terminée (barrée)
  static const TextStyle taskTitleCompleted = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurfaceVariant,   // Plus clair car terminée
    fontFamily: _fontFamily,
    height: 1.4,
    decoration: TextDecoration.lineThrough, // Ligne barrée
  );
  
  // Description d'une tâche
  static const TextStyle taskDescription = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurfaceVariant,
    fontFamily: _fontFamily,
    height: 1.5,
  );
  
  // Statistiques (compteurs de tâches)
  static const TextStyle statValue = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,              // Sur fond coloré
    fontFamily: _fontFamily,
  );
  
  static const TextStyle statLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white70,            // Plus transparent
    fontFamily: _fontFamily,
  );
}
