import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../presentation/providers/task_provider.dart';

/// Page affichant la liste des tâches avec possibilité de tri
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  @override
  void initState() {
    super.initState();
    // Chargement de données de test
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TaskProvider>();
      if (provider.allTasks.isEmpty) {
        provider.loadTestData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes tâches'),
        actions: [
          Consumer<TaskProvider>(
            builder: (context, taskProvider, _) {
              return PopupMenuButton<TaskSort>(
                initialValue: taskProvider.currentSort,
                onSelected: taskProvider.setSort,
                itemBuilder: (_) => TaskSort.values
                    .map(
                      (s) => PopupMenuItem(
                        value: s,
                        child: Text(s.label),
                      ),
                    )
                    .toList(),
                icon: const Icon(Icons.sort),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          final tasks = taskProvider.filteredTasks;
          if (tasks.isEmpty) {
            return const Center(child: Text('Aucune tâche'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final task = tasks[i];
              final subtitle = task.dueDate != null
                  ? 'À faire pour ${DateFormat.yMd().format(task.dueDate!)}'
                  : 'Créée le ${DateFormat.yMd().format(task.createdAt)}';

              return CheckboxListTile(
                value: task.isCompleted,
                onChanged: (_) =>
                    context.read<TaskProvider>().toggleTaskCompletion(task.id),
                title: Text(task.title),
                subtitle: Text(subtitle),
              );
            },
          );
        },
      ),
    );
  }
}

