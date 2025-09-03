import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/task_provider.dart';

/// Puces de filtrage élégantes avec animations
class TaskFilterChips extends StatefulWidget {
  const TaskFilterChips({super.key});

  @override
  State<TaskFilterChips> createState() => _TaskFilterChipsState();
}

class _TaskFilterChipsState extends State<TaskFilterChips>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _chipAnimations;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Animation décalée pour chaque chip
    _chipAnimations = List.generate(TaskFilter.values.length, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.6 + index * 0.1,
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Filtrer les tâches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: TaskFilter.values.asMap().entries.map((entry) {
                  final index = entry.key;
                  final filter = entry.value;

                  return AnimatedBuilder(
                    animation: _chipAnimations[index],
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _chipAnimations[index].value,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? 0 : 8,
                            right: index == TaskFilter.values.length - 1
                                ? 0
                                : 0,
                          ),
                          child: _buildFilterChip(filter, taskProvider),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(TaskFilter filter, TaskProvider taskProvider) {
    final isSelected = taskProvider.currentFilter == filter;
    final color = _getFilterColor(filter);
    final count = _getFilterCount(filter, taskProvider);

    return GestureDetector(
      onTap: () => taskProvider.setFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: AppTheme.radiusLarge,
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFilterIcon(filter),
              size: 18,
              color: isSelected ? Colors.white : color,
            ),

            const SizedBox(width: 8),

            Text(
              filter.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : color,
              ),
            ),

            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getFilterColor(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return AppColors.primary;
      case TaskFilter.pending:
        return AppColors.warning;
      case TaskFilter.completed:
        return AppColors.success;
      case TaskFilter.highPriority:
        return AppColors.error;
    }
  }

  IconData _getFilterIcon(TaskFilter filter) {
    switch (filter) {
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

  int _getFilterCount(TaskFilter filter, TaskProvider taskProvider) {
    switch (filter) {
      case TaskFilter.all:
        return taskProvider.stats.total;
      case TaskFilter.pending:
        return taskProvider.stats.pending;
      case TaskFilter.completed:
        return taskProvider.stats.completed;
      case TaskFilter.highPriority:
        return taskProvider.stats.highPriority;
    }
  }
}
