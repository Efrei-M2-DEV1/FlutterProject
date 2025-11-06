import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';

class TaskSortButton extends StatelessWidget {
  const TaskSortButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return PopupMenuButton<TaskSort>(
          initialValue: taskProvider.currentSort,
          onSelected: taskProvider.setSort,
          icon: const Icon(Icons.sort, color: Colors.white),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: TaskSort.createdAt,
              child: Text(TaskSort.createdAt.label),
            ),
            PopupMenuItem(
              value: TaskSort.dueDate,
              child: Text(TaskSort.dueDate.label),
            ),
          ],
        );
      },
    );
  }
}
