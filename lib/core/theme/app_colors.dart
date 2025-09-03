import 'package:flutter/material.dart';

abstract class AppColors {
  // ===== COULEURS PRINCIPALES =====
  // Ces couleurs définissent l'identité visuelle de ton app
  static const Color primary = Color(
    0xFF6366F1,
  ); // Indigo moderne, professionnel
  static const Color primaryContainer = Color(
    0xFFE0E7FF,
  ); // Version claire du primary
  static const Color onPrimary = Colors.white; // Texte sur couleur primary

  static const Color secondary = Color(0xFF8B5CF6); // Violet, pour accents
  static const Color onSecondary = Colors.white;

  // ===== COULEURS SÉMANTIQUES =====
  // Ces couleurs ont un sens métier (succès, erreur, etc.)
  static const Color success = Color(0xFF10B981); // Vert : tâche terminée
  static const Color warning = Color(0xFFF59E0B); // Orange : tâche urgente
  static const Color error = Color(0xFFEF4444); // Rouge : erreur, suppression
  static const Color info = Color(0xFF3B82F6); // Bleu : information

  // ===== COULEURS DE SURFACE =====
  // Pour les fonds, cartes, etc.
  static const Color surface = Colors.white; // Fond des cartes
  static const Color surfaceVariant = Color(
    0xFFF8FAFC,
  ); // Fond des champs de saisie
  static const Color onSurface = Color(0xFF1F2937); // Texte principal
  static const Color onSurfaceVariant = Color(0xFF6B7280); // Texte secondaire

  static const Color background = Color(0xFFFAFAFA); // Fond de l'app
  static const Color onBackground = Color(0xFF111827); // Texte sur fond

  // ===== GRADIENTS =====
  // Pour rendre l'app plus moderne et attractive
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== COULEURS PAR PRIORITÉ DE TÂCHE =====
  // Pour différencier visuellement les priorités
  static const Color priorityHigh = error; // Rouge pour priorité haute
  static const Color priorityMedium = warning; // Orange pour priorité moyenne
  static const Color priorityLow = info; // Bleu pour priorité basse
}
