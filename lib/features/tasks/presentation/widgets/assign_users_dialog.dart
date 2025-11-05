import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/task.dart';
import '../providers/task_provider.dart';

/// Dialog pour assigner/retirer des utilisateurs d'une tâche
class AssignUsersDialog extends StatefulWidget {
  final Task task;

  const AssignUsersDialog({super.key, required this.task});

  @override
  State<AssignUsersDialog> createState() => _AssignUsersDialogState();
}

class _AssignUsersDialogState extends State<AssignUsersDialog> {
  List<Map<String, dynamic>> _allUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final provider = context.read<TaskProvider>();
      final users = await provider.getAllUsers();
      setState(() {
        _allUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleUserAssignment(String userId, bool isAssigned) async {
    try {
      final provider = context.read<TaskProvider>();
      if (isAssigned) {
        await provider.unassignUserFromTask(widget.task.id, userId);
      } else {
        await provider.assignUserToTask(widget.task.id, userId);
      }
      
      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAssigned
                  ? 'Utilisateur retiré avec succès'
                  : 'Utilisateur assigné avec succès',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Assigner des utilisateurs',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.task.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.getOnSurface(context).withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 24),

            // Contenu
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Text(
                            'Erreur: $_errorMessage',
                            style: TextStyle(color: AppColors.error),
                          ),
                        )
                      : _allUsers.isEmpty
                          ? const Center(
                              child: Text(
                                'Aucun utilisateur disponible',
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _allUsers.length,
                              itemBuilder: (context, index) {
                                final user = _allUsers[index];
                                final userId = user['id'] as String;
                                final userName =
                                    user['name'] as String? ?? 'Sans nom';
                                final userEmail =
                                    user['email'] as String? ?? '';
                                final isAssigned =
                                    widget.task.assignedTo.contains(userId);

                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.primary
                                              .withOpacity(0.2),
                                      child: Text(
                                        userName.isNotEmpty
                                            ? userName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(userName),
                                    subtitle: Text(userEmail),
                                    trailing: Checkbox(
                                      value: isAssigned,
                                      onChanged: (value) {
                                        _toggleUserAssignment(
                                          userId,
                                          isAssigned,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
            ),

            const SizedBox(height: 16),

            // Bouton de fermeture
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
