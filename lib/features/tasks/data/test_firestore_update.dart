import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreAssignationTester {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> testDirectUpdate(String taskId, String userIdToAssign) async {
    try {
      final beforeDoc = await _firestore.collection('tasks').doc(taskId).get();
      if (!beforeDoc.exists) {
        return;
      }

      await _firestore.collection('tasks').doc(taskId).update({
        'assignedTo': FieldValue.arrayUnion([userIdToAssign]),
      });

      await Future.delayed(const Duration(seconds: 2));

      final afterDoc = await _firestore.collection('tasks').doc(taskId).get();
      final afterData = afterDoc.data()!;

      final assignedTo = afterData['assignedTo'] as List<dynamic>?;
      if (assignedTo != null && assignedTo.contains(userIdToAssign)) {
      } else {
      }
    } on FirebaseException {
    } catch (_) {
    }
  }

  Future<void> testWithSet(String taskId, String userIdToAssign) async {
    try {
      final doc = await _firestore.collection('tasks').doc(taskId).get();
      if (!doc.exists) {
        return;
      }

      final data = doc.data()!;
      final currentAssignedTo = (data['assignedTo'] as List<dynamic>?) ?? [];

      final newAssignedTo = List<String>.from(currentAssignedTo);
      if (!newAssignedTo.contains(userIdToAssign)) {
        newAssignedTo.add(userIdToAssign);
      }

      await _firestore.collection('tasks').doc(taskId).set({
        'assignedTo': newAssignedTo,
      }, SetOptions(merge: true));

      await Future.delayed(const Duration(seconds: 2));
      await _firestore.collection('tasks').doc(taskId).get();
    } on FirebaseException {
    }
  }
}

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
