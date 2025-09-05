import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutterproject/features/tasks/domain/models/task.dart';
import 'package:flutterproject/features/tasks/presentation/providers/task_provider.dart';

class _TaskList extends StatelessWidget {
  const _TaskList();

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().allTasks;
    return ListView(
      children: tasks.map((t) => Text(t.title)).toList(),
    );
  }
}

void main() {
  testWidgets('displays tasks from provider', (WidgetTester tester) async {
    final provider = TaskProvider();
    provider.addTask(Task(id: '1', title: 'Test 1', createdAt: DateTime.now()));
    provider.addTask(Task(id: '2', title: 'Test 2', createdAt: DateTime.now()));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: Scaffold(body: _TaskList())),
      ),
    );

    expect(find.text('Test 1'), findsOneWidget);
    expect(find.text('Test 2'), findsOneWidget);
  });
}
