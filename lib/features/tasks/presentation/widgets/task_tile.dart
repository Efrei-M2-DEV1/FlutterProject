import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/task.dart';
import '../../domain/models/task_category.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  Color get _priorityColor {
    switch (widget.task.priority) {
      case TaskPriority.high:
        return AppColors.error;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.low:
        return AppColors.info;
    }
  }

  bool get _isOverdue {
    if (widget.task.dueDate == null || widget.task.isCompleted) return false;
    return widget.task.dueDate!.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: widget.task.isCompleted
                    ? AppColors.surfaceVariant.withOpacity(0.7)
                    : Colors.white,
                borderRadius: AppTheme.radiusLarge,
                border: Border.all(
                  color: widget.task.isCompleted
                      ? AppColors.success.withOpacity(0.3)
                      : _priorityColor.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isPressed ? _priorityColor : Colors.black)
                        .withOpacity(0.1),
                    blurRadius: _isPressed ? 8 : 4,
                    offset: Offset(0, _isPressed ? 4 : 2),
                  ),
                ],
              ),
              child: _buildContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: AppTheme.paddingMedium,
      child: Row(
        children: [
          _buildCustomCheckbox(),
          const SizedBox(width: 16),
          Expanded(child: _buildMainContent()),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildCustomCheckbox() {
    return GestureDetector(
      onTap: widget.onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: widget.task.isCompleted
              ? AppColors.success
              : Colors.transparent,
          border: Border.all(
            color: widget.task.isCompleted
                ? AppColors.success
                : AppColors.onSurfaceVariant,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: widget.task.isCompleted
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: widget.task.isCompleted
                ? AppColors.onSurfaceVariant
                : AppColors.onSurface,
            decoration: widget.task.isCompleted
                ? TextDecoration.lineThrough
                : null,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        if (widget.task.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            widget.task.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: 8),
        _buildMetadata(),
      ],
    );
  }

  Widget _buildMetadata() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildPriorityChip(),
            if (widget.task.dueDate != null) _buildDueDateChip(),
          ],
        ),
        if (widget.task.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              ...widget.task.tags.map((tagId) {
                final category = TaskCategory.findById(tagId);
                if (category == null) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: category.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(category.icon, size: 12, color: category.color),
                      const SizedBox(width: 4),
                      Text(
                        category.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: category.color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ],
        if (widget.task.ownerName.isNotEmpty ||
            widget.task.assignedTo.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (widget.task.ownerName.isNotEmpty) _buildOwnerBadge(),
              if (widget.task.assignedTo.isNotEmpty) _buildAssignedUsersBadge(),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildOwnerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 8,
            backgroundColor: AppColors.primary,
            child: Text(
              widget.task.ownerName.isNotEmpty
                  ? widget.task.ownerName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            widget.task.ownerName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 2),
          Icon(Icons.star, size: 10, color: AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildAssignedUsersBadge() {
    final assignedCount = widget.task.assignedTo.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people, size: 10, color: AppColors.info),
          const SizedBox(width: 4),
          Text(
            '$assignedCount assigné${assignedCount > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _priorityColor.withOpacity(0.3)),
      ),
      child: Text(
        widget.task.priority.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _priorityColor,
        ),
      ),
    );
  }

  Widget _buildDueDateChip() {
    final isOverdue = _isOverdue;
    final color = isOverdue ? AppColors.error : AppColors.info;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning : Icons.schedule,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            DateFormat('dd/MM').format(widget.task.dueDate!),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _showDeleteDialog(),
          icon: Icon(
            Icons.delete_outline,
            size: 20,
            color: AppColors.error.withOpacity(0.7),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        title: const Text('Supprimer la tâche'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${widget.task.title}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
