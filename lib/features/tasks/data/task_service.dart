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
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      // Utilisateur non connecté -> stream vide
      return const Stream<List<Task>>.empty();
    }

    // Use a per-user subcollection to avoid requiring composite indexes
    final col = _firestore.collection('users').doc(uid).collection('tasks');
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
      final data = task.toMap();
      // createdAt will be set server-side for consistency
      data.remove('createdAt');
      await _firestore.collection('users').doc(uid).collection('tasks').add({
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
      data.remove('createdAt');
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(task.id)
          .update(data);
    } on FirebaseException catch (e) {
      throw Exception('Firestore updateTask failed: ${e.code} ${e.message}');
    }
  }

  Future<void> deleteTask(String taskId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Utilisateur non authentifié');
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } on FirebaseException catch (e) {
      throw Exception('Firestore deleteTask failed: ${e.code} ${e.message}');
    }
  }

  Future<void> toggleCompleted(String taskId, bool completed) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Utilisateur non authentifié');
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(taskId)
          .update({'isCompleted': completed});
    } on FirebaseException catch (e) {
      throw Exception(
        'Firestore toggleCompleted failed: ${e.code} ${e.message}',
      );
    }
  }
}
