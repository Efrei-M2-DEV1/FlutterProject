import 'package:flutter/foundation.dart';

/// Modèle d'une tâche
@immutable
class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final List<String> tags;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    this.dueDate,
    this.tags = const [],
  });

  /// Créer une copie modifiée de la tâche
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? dueDate,
    List<String>? tags,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
    );
  }

  /// Basculer l'état de completion ✅ MÉTHODE MANQUANTE
  Task toggleCompleted() {
    return copyWith(isCompleted: !isCompleted);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, isCompleted: $isCompleted, priority: $priority)';
  }
}

/// Niveaux de priorité des tâches
enum TaskPriority {
  low('Faible', 1),
  medium('Moyenne', 2),
  high('Haute', 3);

  const TaskPriority(this.label, this.value);

  final String label;
  final int value;
}
