import 'package:flutter/material.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la tâche')),
      body: Center(child: Text('Détail de la tâche $taskId - À implémenter')),
    );
  }
}
