import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/task_provider.dart';
import 'task_modal.dart';

/// État vide élégant avec illustration et actions
class EmptyState extends StatefulWidget {
  const EmptyState({super.key});

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showTaskModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TaskModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final hasNoTasks = taskProvider.allTasks.isEmpty;
        final currentFilter = taskProvider.currentFilter;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Padding(
                  padding: AppTheme.paddingLarge,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Illustration animée
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildIllustration(hasNoTasks, currentFilter),
                      ),

                      const SizedBox(height: 32),

                      // Texte principal
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildContent(hasNoTasks, currentFilter),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIllustration(bool hasNoTasks, TaskFilter currentFilter) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 2),
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) {
            return Transform.rotate(
              angle: value * 0.1,
              child: Icon(
                _getIllustrationIcon(hasNoTasks, currentFilter),
                size: 80,
                color: AppColors.primary.withOpacity(0.6),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(bool hasNoTasks, TaskFilter currentFilter) {
    return Column(
      children: [
        Text(
          _getTitle(hasNoTasks, currentFilter),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Text(
          _getSubtitle(hasNoTasks, currentFilter),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Boutons d'action
        _buildActionButtons(hasNoTasks, currentFilter),
      ],
    );
  }

  Widget _buildActionButtons(bool hasNoTasks, TaskFilter currentFilter) {
    if (hasNoTasks) {
      // Première tâche
      return Column(
        children: [
          CustomButton(
            onPressed: _showTaskModal,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 8),
                Text('Créer ma première tâche'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          CustomButton(
            onPressed: () => context.read<TaskProvider>().loadTestData(),
            variant: ButtonVariant.outline,
            child: const Text('Charger des exemples'),
          ),
        ],
      );
    } else {
      // Filtres sans résultats
      return Column(
        children: [
          CustomButton(
            onPressed: () =>
                context.read<TaskProvider>().setFilter(TaskFilter.all),
            child: const Text('Voir toutes les tâches'),
          ),

          const SizedBox(height: 12),

          CustomButton(
            onPressed: _showTaskModal,
            variant: ButtonVariant.outline,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add),
                SizedBox(width: 8),
                Text('Nouvelle tâche'),
              ],
            ),
          ),
        ],
      );
    }
  }

  IconData _getIllustrationIcon(bool hasNoTasks, TaskFilter currentFilter) {
    if (hasNoTasks) return Icons.checklist;

    switch (currentFilter) {
      case TaskFilter.all:
        return Icons.list;
      case TaskFilter.pending:
        return Icons.pending;
      case TaskFilter.completed:
        return Icons.check_circle;
      case TaskFilter.highPriority:
        return Icons.priority_high;
    }
  }

  String _getTitle(bool hasNoTasks, TaskFilter currentFilter) {
    if (hasNoTasks) {
      return 'Commencez votre organisation !';
    }

    switch (currentFilter) {
      case TaskFilter.all:
        return 'Aucune tâche trouvée';
      case TaskFilter.pending:
        return 'Aucune tâche en attente';
      case TaskFilter.completed:
        return 'Aucune tâche terminée';
      case TaskFilter.highPriority:
        return 'Aucune tâche prioritaire';
    }
  }

  String _getSubtitle(bool hasNoTasks, TaskFilter currentFilter) {
    if (hasNoTasks) {
      return 'Créez votre première tâche et commencez à organiser votre quotidien de manière efficace.';
    }

    switch (currentFilter) {
      case TaskFilter.all:
        return 'Il semblerait qu\'il n\'y ait aucune tâche dans votre liste.';
      case TaskFilter.pending:
        return 'Félicitations ! Vous avez terminé toutes vos tâches en attente.';
      case TaskFilter.completed:
        return 'Aucune tâche n\'a encore été terminée. Motivez-vous !';
      case TaskFilter.highPriority:
        return 'Aucune tâche haute priorité pour le moment. Profitez-en !';
    }
  }
}
