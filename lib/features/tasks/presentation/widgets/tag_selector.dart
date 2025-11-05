import 'package:flutter/material.dart';
import '../../domain/models/task_category.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget pour sélectionner les tags/catégories d'une tâche
class TagSelector extends StatelessWidget {
  final List<String> selectedTags;
  final Function(String) onTagToggle;

  const TagSelector({
    super.key,
    required this.selectedTags,
    required this.onTagToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.getOnSurface(context),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TaskCategory.predefined.map((category) {
            final isSelected = selectedTags.contains(category.id);

            return _buildTagChip(
              context: context,
              category: category,
              isSelected: isSelected,
              onTap: () => onTagToggle(category.id),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagChip({
    required BuildContext context,
    required TaskCategory category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? category.color.withOpacity(0.2)
              : AppColors.getSurfaceVariant(context),
          border: Border.all(
            color: isSelected
                ? category.color
                : AppColors.getOnSurfaceVariant(context).withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 18,
              color: isSelected
                  ? category.color
                  : AppColors.getOnSurfaceVariant(context),
            ),
            const SizedBox(width: 6),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? category.color
                    : AppColors.getOnSurfaceVariant(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
