import 'package:flutter_test/flutter_test.dart';
import 'package:flutterproject/features/tasks/domain/models/task.dart';

void main() {
  group('TaskModal - Tests unitaires', () {
    test('Task model can be created with required fields', () {
      final task = Task(
        id: 'test-1',
        title: 'Test Task',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(task.id, 'test-1');
      expect(task.title, 'Test Task');
      expect(task.isCompleted, false);
      expect(task.priority, TaskPriority.medium);
      expect(task.description, '');
    });

    test('Task copyWith creates new instance with updated fields', () {
      final original = Task(
        id: '1',
        title: 'Original',
        createdAt: DateTime(2024, 1, 1),
      );

      final updated = original.copyWith(title: 'Updated', isCompleted: true);

      expect(updated.title, 'Updated');
      expect(updated.isCompleted, true);
      expect(updated.id, '1'); // Unchanged
      expect(original.title, 'Original'); // Original immutable
    });

    test('TaskPriority has correct labels', () {
      expect(TaskPriority.low.label, 'Faible');
      expect(TaskPriority.medium.label, 'Moyenne');
      expect(TaskPriority.high.label, 'Haute');
    });

    test('TaskPriority.fromValue returns correct priority', () {
      expect(TaskPriority.fromValue(1), TaskPriority.low);
      expect(TaskPriority.fromValue(2), TaskPriority.medium);
      expect(TaskPriority.fromValue(3), TaskPriority.high);
      expect(TaskPriority.fromValue(999), TaskPriority.medium); // Default
    });
  });

  // NOTE: Les tests widget de TaskModal nécessitant Firebase sont désactivés
  // Pour les activer, utilisez fake_cloud_firestore et firebase_auth_mocks
}
