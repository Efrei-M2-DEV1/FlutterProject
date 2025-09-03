import 'package:flutter/foundation.dart';

import '../../domain/models/task.dart';

/// Provider pour gérer l'état des tâches
class TaskProvider extends ChangeNotifier {
  // ===== DONNÉES PRIVÉES =====
  final List<Task> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  TaskSort _currentSort = TaskSort.newest;
  bool _isLoading = false;

  // ===== GETTERS PUBLICS =====

  /// Liste de toutes les tâches
  List<Task> get allTasks => List.unmodifiable(_tasks);

  /// Liste des tâches filtrées et triées
  List<Task> get filteredTasks {
    var filtered = _applyFilter(_tasks);
    var sorted = _applySort(filtered);
    return sorted;
  }

  /// Filtre actuel
  TaskFilter get currentFilter => _currentFilter;

  /// Tri actuel
  TaskSort get currentSort => _currentSort;

  /// État de chargement
  bool get isLoading => _isLoading;

  /// Statistiques
  TaskStats get stats {
    final total = _tasks.length;
    final completed = _tasks.where((task) => task.isCompleted).length;
    final pending = total - completed;
    final highPriority = _tasks
        .where(
          (task) => !task.isCompleted && task.priority == TaskPriority.high,
        )
        .length;

    return TaskStats(
      total: total,
      completed: completed,
      pending: pending,
      highPriority: highPriority,
    );
  }

  // ===== ACTIONS CRUD =====

  /// Ajouter une nouvelle tâche
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  /// Modifier une tâche existante
  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  /// Supprimer une tâche
  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  /// Basculer l'état de completion d'une tâche ✅ MÉTHODE CORRIGÉE
  void toggleTaskCompletion(String taskId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index]
          .toggleCompleted(); // ✅ Maintenant ça marche !
      notifyListeners();
    }
  }

  // ===== FILTRES ET TRI =====

  /// Changer le filtre
  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// Changer le tri
  void setSort(TaskSort sort) {
    _currentSort = sort;
    notifyListeners();
  }

  // ===== MÉTHODES PRIVÉES =====

  /// Appliquer le filtre actuel
  List<Task> _applyFilter(List<Task> tasks) {
    switch (_currentFilter) {
      case TaskFilter.all:
        return tasks;
      case TaskFilter.pending:
        return tasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.completed:
        return tasks.where((task) => task.isCompleted).toList();
      case TaskFilter.highPriority:
        return tasks
            .where(
              (task) => !task.isCompleted && task.priority == TaskPriority.high,
            )
            .toList();
    }
  }

  /// Appliquer le tri actuel
  List<Task> _applySort(List<Task> tasks) {
    switch (_currentSort) {
      case TaskSort.newest:
        return tasks..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case TaskSort.oldest:
        return tasks..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case TaskSort.priority:
        return tasks
          ..sort((a, b) => b.priority.value.compareTo(a.priority.value));
      case TaskSort.alphabetical:
        return tasks..sort((a, b) => a.title.compareTo(b.title));
    }
  }

  // ===== DONNÉES DE TEST =====

  /// Charger des données de test
  void loadTestData() {
    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () {
      _tasks.clear();
      _tasks.addAll([
        Task(
          id: '1',
          title: 'Apprendre Flutter',
          description: 'Terminer le projet To-Do List avec une belle interface',
          priority: TaskPriority.high,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          dueDate: DateTime.now().add(const Duration(days: 3)),
        ),
        Task(
          id: '2',
          title: 'Faire les courses',
          description: 'Acheter du pain, du lait et des légumes',
          priority: TaskPriority.medium,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isCompleted: true,
        ),
        Task(
          id: '3',
          title: 'Rendez-vous médecin',
          description: 'Consultation de contrôle à 14h',
          priority: TaskPriority.high,
          createdAt: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 1)),
        ),
        Task(
          id: '4',
          title: 'Lire un livre',
          description: 'Continuer la lecture de "Clean Code"',
          priority: TaskPriority.low,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        Task(
          id: '5',
          title: 'Projet Flutter terminé',
          description: 'Application Todo List complètement fonctionnelle !',
          priority: TaskPriority.high,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          isCompleted: true,
        ),
      ]);

      _isLoading = false;
      notifyListeners();
    });
  }
}

/// Filtres disponibles pour les tâches
enum TaskFilter {
  all('Toutes'),
  pending('À faire'),
  completed('Terminées'),
  highPriority('Priorité haute');

  const TaskFilter(this.label);
  final String label;
}

/// Options de tri pour les tâches
enum TaskSort {
  newest('Plus récentes'),
  oldest('Plus anciennes'),
  priority('Par priorité'),
  alphabetical('Alphabétique');

  const TaskSort(this.label);
  final String label;
}

/// Statistiques des tâches
class TaskStats {
  final int total;
  final int completed;
  final int pending;
  final int highPriority;

  const TaskStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.highPriority,
  });

  double get completionRate {
    if (total == 0) return 0.0;
    return completed / total;
  }
}
