import '../domain/models/task.dart';
import 'firestore_task_service.dart';

/// Repository pour gérer les tâches
/// Fournit une abstraction au-dessus du service Firestore
class TaskRepository {
  final FirestoreTaskService _firestoreService;

  TaskRepository({FirestoreTaskService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreTaskService();

  // ==================== OPÉRATIONS CRUD ====================

  /// Créer une nouvelle tâche
  Future<String> createTask(Task task) async {
    return await _firestoreService.createTask(task);
  }

  /// Récupérer toutes les tâches
  Future<List<Task>> getAllTasks() async {
    return await _firestoreService.getAllTasks();
  }

  /// Observer toutes les tâches en temps réel
  Stream<List<Task>> watchAllTasks() {
    return _firestoreService.watchAllTasks();
  }

  /// Récupérer une tâche par son ID
  Future<Task?> getTaskById(String id) async {
    return await _firestoreService.getTaskById(id);
  }

  /// Observer les tâches par statut
  Stream<List<Task>> watchTasksByStatus(bool isCompleted) {
    return _firestoreService.watchTasksByStatus(isCompleted);
  }

  /// Mettre à jour une tâche
  Future<void> updateTask(Task task) async {
    await _firestoreService.updateTask(task);
  }

  /// Supprimer une tâche
  Future<void> deleteTask(String id) async {
    await _firestoreService.deleteTask(id);
  }

  /// Basculer l'état de complétion d'une tâche
  Future<void> toggleTaskCompletion(String id) async {
    await _firestoreService.toggleTaskCompletion(id);
  }

  /// Supprimer toutes les tâches complétées
  Future<int> deleteCompletedTasks() async {
    return await _firestoreService.deleteCompletedTasks();
  }

  /// Récupérer les statistiques
  Future<Map<String, int>> getTaskStats() async {
    return await _firestoreService.getTaskStats();
  }
}
