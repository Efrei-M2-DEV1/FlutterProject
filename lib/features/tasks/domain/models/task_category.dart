import 'package:flutter/material.dart';

/// Catégories prédéfinies pour les tâches
class TaskCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const TaskCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });

  static const List<TaskCategory> predefined = [
    TaskCategory(
      id: 'travail',
      label: 'Travail',
      icon: Icons.work_outline,
      color: Color(0xFF2196F3),
    ),
    TaskCategory(
      id: 'personnel',
      label: 'Personnel',
      icon: Icons.person_outline,
      color: Color(0xFF9C27B0),
    ),
    TaskCategory(
      id: 'urgent',
      label: 'Urgent',
      icon: Icons.priority_high,
      color: Color(0xFFF44336),
    ),
    TaskCategory(
      id: 'important',
      label: 'Important',
      icon: Icons.star_outline,
      color: Color(0xFFFF9800),
    ),
    TaskCategory(
      id: 'shopping',
      label: 'Shopping',
      icon: Icons.shopping_cart_outlined,
      color: Color(0xFF4CAF50),
    ),
    TaskCategory(
      id: 'sante',
      label: 'Santé',
      icon: Icons.favorite_outline,
      color: Color(0xFFE91E63),
    ),
    TaskCategory(
      id: 'maison',
      label: 'Maison',
      icon: Icons.home_outlined,
      color: Color(0xFF00BCD4),
    ),
    TaskCategory(
      id: 'etude',
      label: 'Étude',
      icon: Icons.school_outlined,
      color: Color(0xFF673AB7),
    ),
    TaskCategory(
      id: 'sport',
      label: 'Sport',
      icon: Icons.fitness_center,
      color: Color(0xFF8BC34A),
    ),
    TaskCategory(
      id: 'voyage',
      label: 'Voyage',
      icon: Icons.flight_outlined,
      color: Color(0xFF03A9F4),
    ),
    TaskCategory(
      id: 'finance',
      label: 'Finance',
      icon: Icons.attach_money,
      color: Color(0xFF4CAF50),
    ),
    TaskCategory(
      id: 'famille',
      label: 'Famille',
      icon: Icons.family_restroom,
      color: Color(0xFFFF5722),
    ),
  ];

  static TaskCategory? findById(String id) {
    try {
      return predefined.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }
}
