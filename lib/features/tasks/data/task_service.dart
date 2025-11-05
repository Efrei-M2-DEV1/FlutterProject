import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/models/task.dart';

/// Service pour CRUD des tâches dans Cloud Firestore.
class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Using per-user subcollections now; no global _tasksCollection required.

  /// Retourne un stream des tâches du user courant
  Stream<List<Task>> tasksStream() {
    // Return a global tasks stream (includes owner fields) so the UI can list all tasks
    final col = _firestore.collection('tasks');
    return col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Task.fromMap(d.data(), id: d.id)).toList(),
        );
  }

  Future<void> addTask(Task task) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Utilisateur non authentifié');
    try {
      // Ensure owner fields are included. Try to get displayName from auth or users collection
      String ownerName = _auth.currentUser?.displayName ?? '';
      if (ownerName.isEmpty) {
        try {
          final userDoc = await _firestore.collection('users').doc(uid).get();
          ownerName =
              userDoc.data()?['name'] ?? userDoc.data()?['displayName'] ?? '';
        } catch (_) {
          // ignore errors reading user doc; ownerName can stay empty
        }
      }

      final data = task.toMap();
      // createdAt will be set server-side for consistency
      data.remove('createdAt');
      // Override owner fields to be safe
      data['userId'] = uid;
      data['ownerName'] = ownerName;

      await _firestore.collection('tasks').add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      // Provide clearer message for permission issues
      throw Exception('Firestore addTask failed: ${e.code} ${e.message}');
    }
  }

  Future<void> updateTask(Task task) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Utilisateur non authentifié');
    try {
      final data = task.toMap();
      // Prevent owner fields from being changed by client
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
}
