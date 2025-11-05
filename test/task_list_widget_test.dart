import 'package:flutter_test/flutter_test.dart';
import 'package:flutterproject/features/tasks/presentation/providers/task_provider.dart';

void main() {
  group('TaskProvider - Tests unitaires', () {
    test('TaskStats calculates correctly', () {
      const stats = TaskStats(
        total: 10,
        completed: 7,
        pending: 3,
        highPriority: 2,
      );

      expect(stats.total, 10);
      expect(stats.completed, 7);
      expect(stats.pending, 3);
      expect(stats.highPriority, 2);
      expect(stats.completionRate, closeTo(0.7, 0.001));
    });

    test('TaskStats with zero tasks returns 0 completion rate', () {
      const stats = TaskStats(
        total: 0,
        completed: 0,
        pending: 0,
        highPriority: 0,
      );

      expect(stats.completionRate, 0.0);
    });

    test('TaskFilter enum has correct labels', () {
      expect(TaskFilter.all.label, 'Toutes');
      expect(TaskFilter.pending.label, 'À faire');
      expect(TaskFilter.completed.label, 'Terminées');
      expect(TaskFilter.highPriority.label, 'Priorité haute');
    });

    test('TaskSort enum has correct labels', () {
      expect(TaskSort.createdAt.label, 'Date de création');
      expect(TaskSort.dueDate.label, "Date d'échéance");
    });
  });

  // NOTE: Les tests widget nécessitant Firebase sont désactivés
  // Pour les activer, utilisez fake_cloud_firestore et firebase_auth_mocks
}
