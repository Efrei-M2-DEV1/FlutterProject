import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../domain/models/task.dart';
import '../providers/task_provider.dart';
import 'assign_users_dialog.dart';
import 'tag_selector.dart';

/// Modal élégant pour créer/éditer une tâche - VERSION STABLE
class TaskModal extends StatefulWidget {
  final Task? task;

  const TaskModal({super.key, this.task});

  @override
  State<TaskModal> createState() => _TaskModalState();
}

class _TaskModalState extends State<TaskModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  List<String> _selectedTags = [];

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    // Pré-remplir si on édite
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedPriority = widget.task!.priority;
      _selectedDueDate = widget.task!.dueDate;
      _selectedTags = List.from(widget.task!.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate:
          _selectedDueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() => _selectedDueDate = selectedDate);
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final taskProvider = context.read<TaskProvider>();
    final currentUser = FirebaseAuth.instance.currentUser;

    print('🔐 TaskModal - Utilisateur connecté: ${currentUser?.uid}');
    print('🔐 TaskModal - Email: ${currentUser?.email}');
    print('🔐 TaskModal - DisplayName: ${currentUser?.displayName}');

    if (currentUser == null) {
      // L'utilisateur n'est pas connecté, on ne peut pas créer de tâche
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour créer une tâche'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isEditing) {
      // Récupérer la tâche actuelle depuis le provider pour avoir les assignations à jour
      final currentTask = taskProvider.allTasks.firstWhere(
        (t) => t.id == widget.task!.id,
        orElse: () => widget.task!,
      );

      // Modifier la tâche existante en gardant les assignations actuelles
      final updatedTask = currentTask.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        tags: _selectedTags,
      );
      print('📝 TaskModal - Modification tâche: ${updatedTask.id}');
      print('   - assignedTo conservé: ${updatedTask.assignedTo}');
      taskProvider.updateTask(updatedTask);
    } else {
      // Créer une nouvelle tâche avec ownerId et ownerName
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        ownerId: currentUser.uid,
        ownerName:
            currentUser.displayName ?? currentUser.email ?? 'Utilisateur',
        priority: _selectedPriority,
        createdAt: DateTime.now(),
        dueDate: _selectedDueDate,
        assignedTo: const [],
        tags: _selectedTags,
      );
      print('✨ TaskModal - Création nouvelle tâche:');
      print('   - title: ${newTask.title}');
      print('   - ownerId: ${newTask.ownerId}');
      print('   - ownerName: ${newTask.ownerName}');
      print('   - tags: ${newTask.tags}');
      taskProvider.addTask(newTask);
    }

    Navigator.of(context).pop(); // ✅ Fermeture explicite
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // ✅ HAUTEUR FIXE pour éviter les problèmes de contraintes
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppColors.surface, // ✅ Couleur dynamique
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Indicateur de drag
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isEditing ? Icons.edit : Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditing ? 'Modifier la tâche' : 'Nouvelle tâche',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _isEditing
                          ? 'Modifiez les détails'
                          : 'Créez une nouvelle tâche',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Titre de la tâche
          CustomTextField(
            controller: _titleController,
            label: 'Titre de la tâche',
            hint: 'Ex: Finir le projet Flutter',
            prefixIcon: Icons.title,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le titre est obligatoire';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Description
          CustomTextField(
            controller: _descriptionController,
            label: 'Description (optionnel)',
            hint: 'Décrivez votre tâche...',
            prefixIcon: Icons.description,
            maxLines: 3,
          ),

          const SizedBox(height: 30),

          // Sélection de priorité
          _buildPrioritySelector(),

          const SizedBox(height: 30),

          // Sélection de date
          _buildDateSelector(),

          const SizedBox(height: 30),

          // Sélection de tags/catégories
          TagSelector(
            selectedTags: _selectedTags,
            onTagToggle: (tagId) {
              setState(() {
                if (_selectedTags.contains(tagId)) {
                  _selectedTags.remove(tagId);
                } else {
                  _selectedTags.add(tagId);
                }
              });
            },
          ),

          // Bouton d'assignation (seulement en mode édition)
          if (_isEditing) ...[
            const SizedBox(height: 30),
            _buildAssignUsersButton(),
          ],

          const SizedBox(height: 40),

          // Boutons d'action
          _buildActionButtons(),

          // Espacement supplémentaire pour le scroll
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priorité',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface, // ✅ Couleur dynamique
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: TaskPriority.values.map((priority) {
            final isSelected = _selectedPriority == priority;
            final color = _getPriorityColor(priority);

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPriority = priority),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.1),
                    borderRadius: AppTheme.radiusMedium,
                    border: Border.all(
                      color: isSelected ? color : color.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getPriorityIcon(priority),
                        color: isSelected ? Colors.white : color,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        priority.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date d\'échéance (optionnel)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface, // ✅ Couleur dynamique
          ),
        ),

        const SizedBox(height: 12),

        GestureDetector(
          onTap: _selectDueDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant, // ✅ Couleur dynamique
              borderRadius: AppTheme.radiusMedium,
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: _selectedDueDate != null
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant, // ✅ Couleur dynamique
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDueDate != null
                        ? 'Échéance : ${_formatDate(_selectedDueDate!)}'
                        : 'Sélectionner une date d\'échéance',
                    style: TextStyle(
                      color: _selectedDueDate != null
                          ? AppColors
                                .onSurface // ✅ Couleur dynamique
                          : AppColors.onSurfaceVariant, // ✅ Couleur dynamique
                      fontWeight: _selectedDueDate != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (_selectedDueDate != null)
                  IconButton(
                    onPressed: () => setState(() => _selectedDueDate = null),
                    icon: const Icon(Icons.clear, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignUsersButton() {
    // Récupérer la tâche à jour depuis le Provider si on modifie une tâche existante
    final currentTask = widget.task != null
        ? context.watch<TaskProvider>().allTasks.firstWhere(
            (t) => t.id == widget.task!.id,
            orElse: () => widget.task!,
          )
        : null;

    final assignedCount = currentTask?.assignedTo.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Collaboration',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AssignUsersDialog(task: currentTask!),
            );
          },
          icon: const Icon(Icons.people_outline),
          label: Text(
            assignedCount > 0
                ? 'Gérer les utilisateurs assignés ($assignedCount)'
                : 'Assigner des utilisateurs',
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            onPressed: () => Navigator.of(context).pop(),
            variant: ButtonVariant.outline,
            child: const Text('Annuler'),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          flex: 2,
          child: CustomButton(
            onPressed: _saveTask,
            child: Text(_isEditing ? 'Modifier' : 'Créer'),
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.error;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.low:
        return AppColors.info;
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Icons.priority_high;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) return 'Aujourd\'hui';
    if (difference == 1) return 'Demain';
    if (difference < 7) return 'Dans ${difference} jours';

    return '${date.day}/${date.month}/${date.year}';
  }
}
