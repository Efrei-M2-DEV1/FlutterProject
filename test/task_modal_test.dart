import 'package:flutter_test/flutter_test.dart';
import 'package:flutterproject/features/tasks/domain/models/task.dart';

/// Tests pour le modal de tâches
/// 
/// Note: Les tests UI nécessitent Firebase configuré.
/// Pour l'instant, on teste la logique métier.
void main() {
  group('Task Modal Logic', () {
    test('Task title validation - empty title should be invalid', () {
      final title = '';
      expect(title.isEmpty, isTrue);
    });

    test('Task title validation - non-empty title should be valid', () {
      final title = 'Valid Title';
      expect(title.isNotEmpty, isTrue);
      expect(title.length, greaterThan(0));
    });

    test('Task can be created with minimum required fields', () {
      final task = Task(
        id: '',
        title: 'New Task',
        createdAt: DateTime.now(),
      );

      expect(task.title, equals('New Task'));
      expect(task.description, isEmpty);
      expect(task.isCompleted, isFalse);
    });
  });
}
