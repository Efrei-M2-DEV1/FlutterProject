import 'package:flutter/material.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes tâches')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => CheckboxListTile(
          value: i.isEven,
          onChanged: (_) {},
          title: Text('Tâche #$i (mock)'),
          subtitle: const Text('Clique pour éditer (bientôt)'),
        ),
      ),
    );
  }
}
