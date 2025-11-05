import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Script de test pour vérifier que Firestore accepte les mises à jour d'assignation
///
/// COMMENT UTILISER :
/// 1. Importez ce fichier dans un écran existant
/// 2. Appelez testFirestoreAssignation() avec un ID de tâche
/// 3. Regardez les logs dans la console
class FirestoreAssignationTester {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Test direct de mise à jour Firestore
  Future<void> testDirectUpdate(String taskId, String userIdToAssign) async {
    debugPrint('🧪 TEST: Début du test d\'assignation directe');
    debugPrint('   TaskId: $taskId');
    debugPrint('   UserIdToAssign: $userIdToAssign');
    debugPrint('   Current User: ${_auth.currentUser?.uid}');

    try {
      // 1. Lire la tâche AVANT
      final beforeDoc = await _firestore.collection('tasks').doc(taskId).get();
      if (!beforeDoc.exists) {
        debugPrint('❌ TEST: La tâche n\'existe pas');
        return;
      }

      final beforeData = beforeDoc.data()!;
      debugPrint('   AVANT: assignedTo = ${beforeData['assignedTo']}');
      debugPrint('   AVANT: userId = ${beforeData['userId']}');

      // 2. Mettre à jour avec arrayUnion
      debugPrint('🧪 TEST: Tentative de mise à jour...');
      await _firestore.collection('tasks').doc(taskId).update({
        'assignedTo': FieldValue.arrayUnion([userIdToAssign]),
      });

      debugPrint('✅ TEST: update() réussi côté client');

      // 3. Attendre un peu pour que Firestore propage
      await Future.delayed(const Duration(seconds: 2));

      // 4. Lire la tâche APRÈS
      final afterDoc = await _firestore.collection('tasks').doc(taskId).get();
      final afterData = afterDoc.data()!;
      debugPrint('   APRÈS: assignedTo = ${afterData['assignedTo']}');

      // 5. Vérifier si la mise à jour a vraiment fonctionné
      final assignedTo = afterData['assignedTo'] as List<dynamic>?;
      if (assignedTo != null && assignedTo.contains(userIdToAssign)) {
        debugPrint('✅ TEST RÉUSSI: L\'UID est bien dans le tableau !');
      } else {
        debugPrint(
          '❌ TEST ÉCHOUÉ: Le tableau est vide ou ne contient pas l\'UID',
        );
        debugPrint(
          '   Cela signifie que Firestore a rejeté la mise à jour côté serveur',
        );
        debugPrint('   Vérifiez les règles de sécurité Firestore');
      }
    } on FirebaseException catch (e) {
      debugPrint('❌ TEST: Erreur Firestore ${e.code} - ${e.message}');
      debugPrint('   ${e.toString()}');
    } catch (e) {
      debugPrint('❌ TEST: Erreur inattendue: $e');
    }
  }

  /// Test avec set() au lieu de update()
  Future<void> testWithSet(String taskId, String userIdToAssign) async {
    debugPrint('🧪 TEST SET: Utilisation de set() avec merge');

    try {
      // Lire d'abord la tâche
      final doc = await _firestore.collection('tasks').doc(taskId).get();
      if (!doc.exists) {
        debugPrint('❌ TEST SET: Tâche inexistante');
        return;
      }

      final data = doc.data()!;
      final currentAssignedTo = (data['assignedTo'] as List<dynamic>?) ?? [];

      // Ajouter l'UID s'il n'est pas déjà présent
      final newAssignedTo = List<String>.from(currentAssignedTo);
      if (!newAssignedTo.contains(userIdToAssign)) {
        newAssignedTo.add(userIdToAssign);
      }

      debugPrint('   Nouveau tableau: $newAssignedTo');

      // Utiliser set() avec merge
      await _firestore.collection('tasks').doc(taskId).set({
        'assignedTo': newAssignedTo,
      }, SetOptions(merge: true));

      debugPrint('✅ TEST SET: set() réussi côté client');

      // Vérifier après 2 secondes
      await Future.delayed(const Duration(seconds: 2));
      final afterDoc = await _firestore.collection('tasks').doc(taskId).get();
      final afterData = afterDoc.data()!;
      debugPrint('   APRÈS SET: assignedTo = ${afterData['assignedTo']}');
    } on FirebaseException catch (e) {
      debugPrint('❌ TEST SET: Erreur ${e.code} - ${e.message}');
    }
  }
}

/// Widget de test à ajouter temporairement dans votre app
class FirestoreTestButton extends StatelessWidget {
  final String taskId;
  final String userIdToAssign;

  const FirestoreTestButton({
    super.key,
    required this.taskId,
    required this.userIdToAssign,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            FirestoreAssignationTester().testDirectUpdate(
              taskId,
              userIdToAssign,
            );
          },
          child: const Text('Test avec arrayUnion'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            FirestoreAssignationTester().testWithSet(taskId, userIdToAssign);
          },
          child: const Text('Test avec set()'),
        ),
      ],
    );
  }
}
