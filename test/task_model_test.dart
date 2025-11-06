import 'package:flutter_test/flutter_test.dart';
import 'package:flutterproject/features/tasks/domain/models/task.dart';
import 'package:flutterproject/features/tasks/presentation/providers/task_provider.dart';

void main() {
  test('toggleCompleted switches the completion state', () {
    final task = Task(
      id: '1',
      title: 'Demo',
      createdAt: DateTime(2024, 1, 1),
      isCompleted: false,
    );
    final toggled = task.toggleCompleted();
    expect(toggled.isCompleted, isTrue);
    expect(task.isCompleted, isFalse);
  });

  test('TaskStats calculates completion rate', () {
    const stats = TaskStats(total: 4, completed: 1, pending: 3, highPriority: 0);
    expect(stats.completionRate, closeTo(0.25, 0.001));
  });
}
