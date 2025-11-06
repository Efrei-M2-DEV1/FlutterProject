import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

import '../domain/models/task.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Task>> tasksStream() {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) {
        return Stream.value(<Task>[]);
      }

      final uid = user.uid;
      final col = _firestore.collection('tasks');

      final myTasksStream = col
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) {
            return snap.docs
                .map((d) => Task.fromMap(d.data(), id: d.id))
                .toList();
          });

      final assignedTasksStream = col
          .where('assignedTo', arrayContains: uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) {
            return snap.docs
                .map((d) => Task.fromMap(d.data(), id: d.id))
                .toList();
          });

      return Rx.combineLatest2<
        List<Task>,
        List<Task>,
        List<Task>
      >(myTasksStream, assignedTasksStream, (myTasks, assignedTasks) {
        final Map<String, Task> uniqueTasks = {};
        for (var task in myTasks) {
          uniqueTasks[task.id] = task;
        }
        for (var task in assignedTasks) {
          uniqueTasks[task.id] = task;
        }

        final allTasks = uniqueTasks.values.toList();
        allTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return allTasks;
      });
    });
  }

  Future<void> addTask(Task task) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Utilisateur non authentifié');
    try {
      String ownerName = _auth.currentUser?.displayName ?? '';
      if (ownerName.isEmpty) {
        try {
          final userDoc = await _firestore.collection('users').doc(uid).get();
          ownerName =
              userDoc.data()?['name'] ?? userDoc.data()?['displayName'] ?? '';
        } catch (_) {
          // ignore
        }
      }

      final data = task.toMap();
      data.remove('createdAt');
      data['userId'] = uid;
      data['ownerName'] = ownerName;

      await _firestore.collection('tasks').add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Firestore addTask failed: ${e.code} ${e.message}');
    }
  }

  Future<void> updateTask(Task task) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Utilisateur non authentifié');
    try {
      final data = task.toMap();
      data.remove('createdAt');
      data.remove('userId');
      data.remove('ownerName');
      await _firestore.collection('tasks').doc(task.id).update(data);
    } on FirebaseException catch (e) {
      throw Exception('Firestore updateTask failed: ${e.code} ${e.message}');
    }
  }

  Future<void> deleteTask(String taskId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Utilisateur non authentifié');
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } on FirebaseException catch (e) {
      throw Exception('Firestore deleteTask failed: ${e.code} ${e.message}');
    }
  }

  Future<void> toggleCompleted(String taskId, bool completed) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Utilisateur non authentifié');
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'isCompleted': completed,
      });
    } on FirebaseException catch (e) {
      throw Exception(
        'Firestore toggleCompleted failed: ${e.code} ${e.message}',
      );
    }
  }

  Future<void> assignUserToTask(String taskId, String userIdToAssign) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Utilisateur non authentifié');
    try {
      final taskDoc = await _firestore.collection('tasks').doc(taskId).get();
      if (!taskDoc.exists) {
        throw Exception('Tâche introuvable');
      }

      await _firestore.collection('tasks').doc(taskId).update({
        'assignedTo': FieldValue.arrayUnion([userIdToAssign]),
      });
    } on FirebaseException catch (e) {
      throw Exception(
        'Firestore assignUserToTask failed: ${e.code} ${e.message}',
      );
    }
  }

  Future<void> unassignUserFromTask(
    String taskId,
    String userIdToRemove,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Utilisateur non authentifié');
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'assignedTo': FieldValue.arrayRemove([userIdToRemove]),
      });
    } on FirebaseException catch (e) {
      throw Exception(
        'Firestore unassignUserFromTask failed: ${e.code} ${e.message}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Utilisateur non authentifié');
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map(
            (doc) => {
              'id': doc.id,
              'name': doc.data()['name'] ?? doc.data()['displayName'] ?? '',
              'email': doc.data()['email'] ?? '',
            },
          )
          .where((user) => user['id'] != uid)
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Firestore getAllUsers failed: ${e.code} ${e.message}');
    }
  }
}
