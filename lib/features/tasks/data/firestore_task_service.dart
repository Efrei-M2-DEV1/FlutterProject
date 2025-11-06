import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models/task.dart';

class FirestoreTaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collectionName = 'tasks';

  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection(_collectionName);

  Map<String, dynamic> _taskToMap(Task task) {
    return {
      'title': task.title,
      'description': task.description,
      'isCompleted': task.isCompleted,
      'priority': task.priority.value,
      'createdAt': Timestamp.fromDate(task.createdAt),
      'dueDate': task.dueDate != null
          ? Timestamp.fromDate(task.dueDate!)
          : null,
      'tags': task.tags,
      'userId': task.ownerId,
      'ownerName': task.ownerName,
      'assignedTo': task.assignedTo,
    };
  }

  Task _mapToTask(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      ownerId: data['userId'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? '',
      isCompleted: data['isCompleted'] as bool? ?? false,
      priority: TaskPriority.values[(data['priority'] as int? ?? 2) - 1],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      tags: List<String>.from(data['tags'] as List? ?? []),
      assignedTo: List<String>.from(data['assignedTo'] as List? ?? []),
    );
  }

  Future<String> createTask(Task task) async {
    try {
      final taskData = _taskToMap(task);
      final docRef = await _tasksCollection.add(taskData);
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de la tâche: $e');
    }
  }

  Future<List<Task>> getAllTasks() async {
    try {
      final snapshot = await _tasksCollection
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => _mapToTask(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tâches: $e');
    }
  }

  Stream<List<Task>> watchAllTasks() {
    try {
      return _tasksCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => _mapToTask(doc.id, doc.data()))
                .toList();
          });
    } catch (e) {
      throw Exception('Erreur lors de l\'écoute des tâches: $e');
    }
  }

  Future<Task?> getTaskById(String id) async {
    try {
      final doc = await _tasksCollection.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return _mapToTask(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la tâche: $e');
    }
  }

  Stream<List<Task>> watchTasksByStatus(bool isCompleted) {
    try {
      return _tasksCollection
          .where('isCompleted', isEqualTo: isCompleted)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => _mapToTask(doc.id, doc.data()))
                .toList();
          });
    } catch (e) {
      throw Exception('Erreur lors de l\'écoute des tâches: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _tasksCollection.doc(task.id).update(_taskToMap(task));
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la tâche: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _tasksCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la tâche: $e');
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    try {
      final task = await getTaskById(id);
      if (task != null) {
        await _tasksCollection.doc(id).update({
          'isCompleted': !task.isCompleted,
        });
      }
    } catch (e) {
      throw Exception('Erreur lors du basculement de la tâche: $e');
    }
  }

  Future<int> deleteCompletedTasks() async {
    try {
      final snapshot = await _tasksCollection
          .where('isCompleted', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception(
        'Erreur lors de la suppression des tâches complétées: $e',
      );
    }
  }

  Future<Map<String, int>> getTaskStats() async {
    try {
      final allTasks = await getAllTasks();
      final completed = allTasks.where((t) => t.isCompleted).length;
      final pending = allTasks.length - completed;
      final highPriority = allTasks
          .where((t) => !t.isCompleted && t.priority == TaskPriority.high)
          .length;

      return {
        'total': allTasks.length,
        'completed': completed,
        'pending': pending,
        'highPriority': highPriority,
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: $e');
    }
  }
}
