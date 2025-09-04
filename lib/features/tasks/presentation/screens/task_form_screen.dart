import 'package:flutter/material.dart';

class TaskFormScreen extends StatelessWidget {
  final String? taskId;

  const TaskFormScreen({super.key, this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(taskId == null ? 'Nouvelle tâche' : 'Modifier la tâche'),
      ),
      body: const Center(child: Text('Formulaire de tâche - À implémenter')),
    );
  }
}
