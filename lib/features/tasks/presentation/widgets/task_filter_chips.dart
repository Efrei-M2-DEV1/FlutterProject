import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/task_provider.dart';

class TaskFilterChips extends StatelessWidget {
  const TaskFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4),
              child: Text(
                'Filtrer les tâches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getSectionTitle(context),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: TaskFilter.values.map((filter) {
                  final isSelected = taskProvider.currentFilter == filter;
                  final filterColors = _getFilterColors(filter);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        filter.label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : filterColors.textColor,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          taskProvider.setFilter(filter);
                        }
                      },

                      backgroundColor: isSelected
                          ? filterColors.selectedColor
                          : filterColors.backgroundColor,
                      selectedColor: filterColors.selectedColor,
                      side: BorderSide(
                        color: isSelected
                            ? filterColors.selectedColor
                            : filterColors.borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.radiusMedium,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: isSelected ? 2 : 0,
                      shadowColor: filterColors.selectedColor.withOpacity(0.3),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  FilterColors _getFilterColors(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return FilterColors(
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          borderColor: AppColors.primary.withOpacity(0.3),
          textColor: AppColors.primary,
        );

      case TaskFilter.pending:
        return FilterColors(
          selectedColor: AppColors.warning,
          backgroundColor: AppColors.warning.withOpacity(0.1),
          borderColor: AppColors.warning.withOpacity(0.3),
          textColor: AppColors.warning,
        );

      case TaskFilter.completed:
        return FilterColors(
          selectedColor: AppColors.success,
          backgroundColor: AppColors.success.withOpacity(0.1),
          borderColor: AppColors.success.withOpacity(0.3),
          textColor: AppColors.success,
        );

      case TaskFilter.highPriority:
        return FilterColors(
          selectedColor: AppColors.error,
          backgroundColor: AppColors.error.withOpacity(0.1),
          borderColor: AppColors.error.withOpacity(0.3),
          textColor: AppColors.error,
        );
    }
  }
}

class FilterColors {
  final Color selectedColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const FilterColors({
    required this.selectedColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}
