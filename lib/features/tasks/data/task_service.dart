import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../domain/models/task.dart';

/// Service pour CRUD des tâches dans Cloud Firestore.
class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Using per-user subcollections now; no global _tasksCollection required.

  /// Retourne un stream des tâches visibles pour l'utilisateur courant
  /// (tâches créées par lui OU tâches où il est assigné)
  /// Attend que l'utilisateur soit connecté avant de commencer à écouter
  Stream<List<Task>> tasksStream() {
    // Écouter les changements d'authentification et basculer sur le stream approprié
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) {
        // Pas d'utilisateur connecté, retourner un stream vide
        return Stream.value(<Task>[]);
      }

      final uid = user.uid;
      final col = _firestore.collection('tasks');

      debugPrint('🔄 TaskService.tasksStream: Démarrage pour utilisateur $uid');

      // Firestore ne supporte pas les requêtes OR directement.
      // On va donc récupérer les deux streams et les combiner:
      // 1. Tâches créées par l'utilisateur
      // 2. Tâches où l'utilisateur est assigné

      final myTasksStream = col
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) {
            debugPrint(
              '🔄 myTasksStream: ${snap.docs.length} tâches créées par moi',
            );
            return snap.docs
                .map((d) => Task.fromMap(d.data(), id: d.id))
                .toList();
          });

      final assignedTasksStream = col
          .where('assignedTo', arrayContains: uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) {
            debugPrint(
              '🔄 assignedTasksStream: ${snap.docs.length} tâches assignées à moi',
            );
            for (var doc in snap.docs) {
              debugPrint(
                '   - ${doc.data()['title']}: assignedTo=${doc.data()['assignedTo']}',
              );
            }
            return snap.docs
                .map((d) => Task.fromMap(d.data(), id: d.id))
                .toList();
          });

      // Combiner les deux streams et éliminer les doublons
      return Rx.combineLatest2<
        List<Task>,
        List<Task>,
        List<Task>
      >(myTasksStream, assignedTasksStream, (myTasks, assignedTasks) {
        debugPrint(
          '🔄 Combinaison: ${myTasks.length} créées + ${assignedTasks.length} assignées',
        );

        // Créer un Map pour éliminer les doublons (par id)
        final Map<String, Task> uniqueTasks = {};
        for (var task in myTasks) {
          uniqueTasks[task.id] = task;
        }
        for (var task in assignedTasks) {
          uniqueTasks[task.id] = task;
        }

        // Retourner la liste triée par date de création
        final allTasks = uniqueTasks.values.toList();
        allTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        debugPrint('🔄 Total final: ${allTasks.length} tâches');
        for (var task in allTasks) {
          debugPrint(
            '   - ${task.title}: créateur=${task.ownerId}, assignés=${task.assignedTo}',
          );
        }

        return allTasks;
      });
    });
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

  /// Assigner un utilisateur à une tâche
  Future<void> assignUserToTask(String taskId, String userIdToAssign) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Utilisateur non authentifié');
    try {
      debugPrint(
        '📌 TaskService.assignUserToTask: taskId=$taskId, userIdToAssign=$userIdToAssign',
      );
      debugPrint('   Current user UID: $uid');

      // Vérifier d'abord que la tâche existe et a le champ assignedTo
      final taskDoc = await _firestore.collection('tasks').doc(taskId).get();
      if (!taskDoc.exists) {
        debugPrint('❌ La tâche n\'existe pas: $taskId');
        throw Exception('Tâche introuvable');
      }

      final taskData = taskDoc.data();
      debugPrint(
        '   Tâche actuelle: userId=${taskData?['userId']}, assignedTo=${taskData?['assignedTo']}',
      );

      // Mettre à jour avec arrayUnion
      await _firestore.collection('tasks').doc(taskId).update({
        'assignedTo': FieldValue.arrayUnion([userIdToAssign]),
      });

      debugPrint('✅ TaskService.assignUserToTask: Succès');

      // Vérifier que la mise à jour a bien été appliquée
      final updatedDoc = await _firestore.collection('tasks').doc(taskId).get();
      final updatedData = updatedDoc.data();
      debugPrint(
        '   Tâche après update: assignedTo=${updatedData?['assignedTo']}',
      );
    } on FirebaseException catch (e) {
      debugPrint(
        '❌ TaskService.assignUserToTask: Erreur ${e.code} - ${e.message}',
      );
      debugPrint('   Details: ${e.toString()}');
      throw Exception(
        'Firestore assignUserToTask failed: ${e.code} ${e.message}',
      );
    }
  }

  /// Retirer un utilisateur assigné d'une tâche
  Future<void> unassignUserFromTask(
    String taskId,
    String userIdToRemove,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Utilisateur non authentifié');
    try {
      debugPrint(
        '📌 TaskService.unassignUserFromTask: taskId=$taskId, userIdToRemove=$userIdToRemove',
      );
      await _firestore.collection('tasks').doc(taskId).update({
        'assignedTo': FieldValue.arrayRemove([userIdToRemove]),
      });
      debugPrint('✅ TaskService.unassignUserFromTask: Succès');
    } on FirebaseException catch (e) {
      debugPrint(
        '❌ TaskService.unassignUserFromTask: Erreur ${e.code} - ${e.message}',
      );
      throw Exception(
        'Firestore unassignUserFromTask failed: ${e.code} ${e.message}',
      );
    }
  }

  /// Récupérer la liste des utilisateurs (pour l'assignation)
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
          .where((user) => user['id'] != uid) // Exclure l'utilisateur courant
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Firestore getAllUsers failed: ${e.code} ${e.message}');
    }
  }
}
