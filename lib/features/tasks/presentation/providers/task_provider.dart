import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/task_repository.dart';
import '../../domain/models/task.dart';

/// Provider pour gérer l'état des tâches avec Firebase Firestore
class TaskProvider extends ChangeNotifier {
  // ===== DONNÉES PRIVÉES =====
  final TaskRepository _repository;
  List<Task> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  TaskSort _currentSort = TaskSort.createdAt;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<Task>>? _tasksSubscription;

  /// Constructeur avec injection du repository
  TaskProvider({TaskRepository? repository})
      : _repository = repository ?? TaskRepository() {
    _initializeTasks();
  }

  /// Initialiser et écouter les tâches en temps réel
  void _initializeTasks() {
    _isLoading = true;
    notifyListeners();

    // Écouter les changements en temps réel depuis Firestore
    _tasksSubscription = _repository.watchAllTasks().listen(
      (tasks) {
        _tasks = tasks;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Erreur de chargement: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }

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

  /// Message d'erreur (si existant)
  String? get errorMessage => _errorMessage;

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
  Future<void> addTask(Task task) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.createTask(task);
      
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Modifier une tâche existante
  Future<void> updateTask(Task updatedTask) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.updateTask(updatedTask);
      
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Supprimer une tâche
  Future<void> deleteTask(String taskId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.deleteTask(taskId);
      
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Basculer l'état de completion d'une tâche
  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      await _repository.toggleTaskCompletion(taskId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur lors du basculement: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Supprimer toutes les tâches complétées
  Future<int> deleteCompletedTasks() async {
    try {
      _isLoading = true;
      notifyListeners();

      final count = await _repository.deleteCompletedTasks();
      
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      
      return count;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
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
      case TaskSort.createdAt:
        return tasks..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case TaskSort.dueDate:
        return tasks
          ..sort((a, b) {
            final aDate = a.dueDate ?? DateTime(9999);
            final bDate = b.dueDate ?? DateTime(9999);
            return aDate.compareTo(bDate);
          });
    }
  }

  // ===== DONNÉES DE TEST =====

  /// Charger des données de test dans Firestore
  Future<void> loadTestData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Créer des tâches de test
      final testTasks = [
        Task(
          id: '',
          title: 'Apprendre Flutter',
          description: 'Terminer le projet To-Do List avec une belle interface',
          priority: TaskPriority.high,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          dueDate: DateTime.now().add(const Duration(days: 3)),
        ),
        Task(
          id: '',
          title: 'Faire les courses',
          description: 'Acheter du pain, du lait et des légumes',
          priority: TaskPriority.medium,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isCompleted: true,
        ),
        Task(
          id: '',
          title: 'Rendez-vous médecin',
          description: 'Consultation de contrôle à 14h',
          priority: TaskPriority.high,
          createdAt: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 1)),
        ),
        Task(
          id: '',
          title: 'Lire un livre',
          description: 'Continuer la lecture de "Clean Code"',
          priority: TaskPriority.low,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        Task(
          id: '',
          title: 'Projet Flutter terminé',
          description: 'Application Todo List complètement fonctionnelle !',
          priority: TaskPriority.high,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          isCompleted: true,
        ),
      ];

      // Ajouter chaque tâche à Firestore
      for (final task in testTasks) {
        await _repository.createTask(task);
      }

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des données: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rafraîchir manuellement les tâches
  Future<void> refreshTasks() async {
    try {
      _isLoading = true;
      notifyListeners();

      final tasks = await _repository.getAllTasks();
      _tasks = tasks;
      
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du rafraîchissement: $e';
      _isLoading = false;
      notifyListeners();
    }
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
  createdAt('Date de création'),
  dueDate('Date d\'échéance');

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
