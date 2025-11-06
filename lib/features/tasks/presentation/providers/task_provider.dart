import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/models/task.dart';
import '../../data/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
  late TaskService _taskService;
  StreamSubscription<List<Task>>? _tasksSub;
  TaskFilter _currentFilter = TaskFilter.all;
  TaskSort _currentSort = TaskSort.createdAt;
  bool _isLoading = false;
  String? _errorMessage;

  List<Task> get allTasks => List.unmodifiable(_tasks);
  String? get errorMessage => _errorMessage;

  List<Task> get filteredTasks {
    var filtered = _applyFilter(_tasks);
    var sorted = _applySort(filtered);
    return sorted;
  }

  TaskFilter get currentFilter => _currentFilter;
  TaskSort get currentSort => _currentSort;
  bool get isLoading => _isLoading;

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

  void setTaskService(TaskService service) {
    _taskService = service;
    _tasksSub?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _tasksSub = _taskService.tasksStream().listen(
      (list) {
        _tasks
          ..clear()
          ..addAll(list);
        _isLoading = false;
        notifyListeners();
      },
      onError: (e, st) {
        _errorMessage = e?.toString() ?? 'Erreur inconnue sur Firestore';
        _isLoading = false;
        notifyListeners();
        if (kDebugMode) {
          debugPrint('Firestore listen error: $_errorMessage');
          debugPrintStack(stackTrace: st);
        }
      },
    );
  }

  @override
  void dispose() {
    _tasksSub?.cancel();
    super.dispose();
  }

  Future<void> addTask(Task task) async {
    await _taskService.addTask(task);
  }

  Future<void> updateTask(Task updatedTask) async {
    await _taskService.updateTask(updatedTask);
  }

  Future<void> deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final newState = !_tasks[index].isCompleted;
      await _taskService.toggleCompleted(taskId, newState);
    }
  }

  Future<void> assignUserToTask(String taskId, String userId) async {
    await _taskService.assignUserToTask(taskId, userId);
  }

  Future<void> unassignUserFromTask(String taskId, String userId) async {
    await _taskService.unassignUserFromTask(taskId, userId);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _taskService.getAllUsers();
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSort(TaskSort sort) {
    _currentSort = sort;
    notifyListeners();
  }

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

  List<Task> _applySort(List<Task> tasks) {
    switch (_currentSort) {
      case TaskSort.createdAt:
        return tasks..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case TaskSort.dueDate:
        return tasks..sort((a, b) {
          final aDate = a.dueDate ?? DateTime(9999);
          final bDate = b.dueDate ?? DateTime(9999);
          return aDate.compareTo(bDate);
        });
    }
  }

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

enum TaskFilter {
  all('Toutes'),
  pending('À faire'),
  completed('Terminées'),
  highPriority('Priorité haute');

  const TaskFilter(this.label);
  final String label;
}

enum TaskSort {
  createdAt('Date de création'),
  dueDate('Date d\'échéance');

  const TaskSort(this.label);
  final String label;
}

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
