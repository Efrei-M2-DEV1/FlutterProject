import 'package:cloud_firestore/cloud_firestore.dart';

class TaskMigration {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> migrateAllTasks() async {
    try {
      final snapshot = await _firestore.collection('tasks').get();

      int migrated = 0;
      int skipped = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (!data.containsKey('assignedTo')) {
          await doc.reference.update({
            'assignedTo': [],
          });
          migrated++;
        } else {
          skipped++;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> needsMigration() async {
    try {
      final snapshot = await _firestore.collection('tasks').limit(1).get();

      if (snapshot.docs.isEmpty) {
        return false;
      }

      final firstTask = snapshot.docs.first.data();
      final needsMigration = !firstTask.containsKey('assignedTo');

      return needsMigration;
    } catch (e) {
      return false;
    }
  }
}
