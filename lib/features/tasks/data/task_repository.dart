import '../domain/models/task.dart';
import 'firestore_task_service.dart';

class TaskRepository {
  final FirestoreTaskService _firestoreService;

  TaskRepository({FirestoreTaskService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreTaskService();

  Future<String> createTask(Task task) async {
    return await _firestoreService.createTask(task);
  }

  Future<List<Task>> getAllTasks() async {
    return await _firestoreService.getAllTasks();
  }

  Stream<List<Task>> watchAllTasks() {
    return _firestoreService.watchAllTasks();
  }

  Future<Task?> getTaskById(String id) async {
    return await _firestoreService.getTaskById(id);
  }

  Stream<List<Task>> watchTasksByStatus(bool isCompleted) {
    return _firestoreService.watchTasksByStatus(isCompleted);
  }

  Future<void> updateTask(Task task) async {
    await _firestoreService.updateTask(task);
  }

  Future<void> deleteTask(String id) async {
    await _firestoreService.deleteTask(id);
  }

  Future<void> toggleTaskCompletion(String id) async {
    await _firestoreService.toggleTaskCompletion(id);
  }

  Future<int> deleteCompletedTasks() async {
    return await _firestoreService.deleteCompletedTasks();
  }

  Future<Map<String, int>> getTaskStats() async {
    return await _firestoreService.getTaskStats();
  }
}
