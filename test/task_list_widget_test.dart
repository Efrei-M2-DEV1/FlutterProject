import 'package:flutter_test/flutter_test.dart';
import 'package:flutterproject/features/tasks/domain/models/task.dart';

/// Tests pour les widgets de liste de tâches
/// 
/// Note: Ces tests nécessitent Firebase Firestore configuré.
/// Pour l'instant, on teste uniquement le modèle Task.
void main() {
  group('Task Model', () {
    test('Task can be created with required fields', () {
      final task = Task(
        id: '1',
        title: 'Test Task',
        createdAt: DateTime.now(),
      );

      expect(task.id, equals('1'));
      expect(task.title, equals('Test Task'));
      expect(task.isCompleted, isFalse);
      expect(task.priority, equals(TaskPriority.medium));
    });

    test('Task can be created with all fields', () {
      final now = DateTime.now();
      final dueDate = now.add(const Duration(days: 1));
      
      final task = Task(
        id: '2',
        title: 'Complete Task',
        description: 'Test description',
        isCompleted: true,
        priority: TaskPriority.high,
        createdAt: now,
        dueDate: dueDate,
        tags: ['test', 'important'],
      );

      expect(task.id, equals('2'));
      expect(task.title, equals('Complete Task'));
      expect(task.description, equals('Test description'));
      expect(task.isCompleted, isTrue);
      expect(task.priority, equals(TaskPriority.high));
      expect(task.createdAt, equals(now));
      expect(task.dueDate, equals(dueDate));
      expect(task.tags, hasLength(2));
    });

    test('Task copyWith creates new instance with updated fields', () {
      final original = Task(
        id: '3',
        title: 'Original',
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(
        title: 'Updated',
        isCompleted: true,
      );

      expect(updated.id, equals(original.id));
      expect(updated.title, equals('Updated'));
      expect(updated.isCompleted, isTrue);
      expect(updated.createdAt, equals(original.createdAt));
    });
  });
}
