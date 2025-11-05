import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

/// Modèle d'une tâche
@immutable
class Task {
  final String id;
  final String title;
  final String description;
  final String ownerId;
  final String ownerName;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final List<String> tags;
  
  /// Liste des UIDs des utilisateurs assignés à cette tâche (en plus du créateur)
  /// Le créateur (ownerId) a toujours accès, pas besoin de l'ajouter ici
  final List<String> assignedTo;

  const Task({
    required this.id,
    required this.title,
    this.ownerId = '',
    this.ownerName = '',
    this.description = '',
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    this.dueDate,
    this.tags = const [],
    this.assignedTo = const [],
  });

  /// Créer une copie modifiée de la tâche
  Task copyWith({
    String? id,
    String? title,
    String? ownerId,
    String? ownerName,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? dueDate,
    List<String>? tags,
    List<String>? assignedTo,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      assignedTo: assignedTo ?? this.assignedTo,
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

  /// Sérialisation pour Firestore
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.value,
      'tags': tags,
      'assignedTo': assignedTo, // Liste des UIDs assignés
    };

    // Owner info
    map['userId'] = ownerId;
    map['ownerName'] = ownerName;

    // createdAt and dueDate: include if present. Firestore accepts DateTime.
    map['createdAt'] = createdAt;
    if (dueDate != null) map['dueDate'] = dueDate;

    return map;
  }

  /// Désérialisation depuis Firestore / Map
  factory Task.fromMap(Map<String, dynamic> map, {required String id}) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      try {
        if (v is DateTime) return v;
        if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
        if (v is String) return DateTime.parse(v);
        if (v is Timestamp) return v.toDate();
        if (v is Map && v['seconds'] != null) {
          // Map representation from some platforms
          final seconds = v['seconds'];
          return DateTime.fromMillisecondsSinceEpoch(
            (seconds is int)
                ? seconds * 1000
                : (int.parse(seconds.toString()) * 1000),
          );
        }
      } catch (_) {}
      return DateTime.now();
    }

    final createdAt = map.containsKey('createdAt')
        ? parseDate(map['createdAt'])
        : DateTime.now();
    final dueDate = map.containsKey('dueDate') && map['dueDate'] != null
        ? parseDate(map['dueDate'])
        : null;

    final priorityValue = map['priority'] is int
        ? map['priority'] as int
        : int.tryParse(map['priority']?.toString() ?? '') ??
              TaskPriority.medium.value;

    final tagsRaw = map['tags'];
    List<String> tags = [];
    if (tagsRaw is List) {
      tags = tagsRaw.map((e) => e.toString()).toList();
    }

    final assignedToRaw = map['assignedTo'];
    List<String> assignedTo = [];
    if (assignedToRaw is List) {
      assignedTo = assignedToRaw.map((e) => e.toString()).toList();
    }

    final ownerId = map['userId']?.toString() ?? '';
    final ownerName = map['ownerName']?.toString() ?? '';

    return Task(
      id: id,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      ownerId: ownerId,
      ownerName: ownerName,
      isCompleted: map['isCompleted'] == true,
      priority: TaskPriority.fromValue(priorityValue),
      createdAt: createdAt,
      dueDate: dueDate,
      tags: tags,
      assignedTo: assignedTo,
    );
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

  static TaskPriority fromValue(int v) {
    return TaskPriority.values.firstWhere(
      (e) => e.value == v,
      orElse: () => TaskPriority.medium,
    );
  }
}
