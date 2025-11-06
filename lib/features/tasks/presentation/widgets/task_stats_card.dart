import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/task_provider.dart';

class TaskStatsCard extends StatefulWidget {
  final TaskStats stats;

  const TaskStatsCard({super.key, required this.stats});

  @override
  State<TaskStatsCard> createState() => _TaskStatsCardState();
}

class _TaskStatsCardState extends State<TaskStatsCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _progressAnimations;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressAnimations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.2,
            0.8 + index * 0.05,
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

  double get _completionRate {
    if (widget.stats.total == 0) return 0.0;
    return widget.stats.completed / widget.stats.total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.paddingLarge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTheme.radiusLarge,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatsGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.analytics, color: Colors.white, size: 24),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vos statistiques',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${(_completionRate * 100).toInt()}% de tâches terminées',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        AnimatedBuilder(
          animation: _progressAnimations[0],
          builder: (context, child) {
            return SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: _completionRate * _progressAnimations[0].value,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 4,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      _StatData(
        label: 'Total',
        value: widget.stats.total,
        icon: Icons.list_alt,
        color: Colors.white,
        animation: _progressAnimations[0],
      ),
      _StatData(
        label: 'Terminées',
        value: widget.stats.completed,
        icon: Icons.check_circle,
        color: AppColors.success,
        animation: _progressAnimations[1],
      ),
      _StatData(
        label: 'En attente',
        value: widget.stats.pending,
        icon: Icons.pending,
        color: AppColors.warning,
        animation: _progressAnimations[2],
      ),
      _StatData(
        label: 'Priorité haute',
        value: widget.stats.highPriority,
        icon: Icons.priority_high,
        color: AppColors.error,
        animation: _progressAnimations[3],
      ),
    ];

    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: AnimatedBuilder(
            animation: stat.animation,
            builder: (context, child) {
              return Transform.scale(
                scale: stat.animation.value,
                child: _buildStatItem(stat),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatItem(_StatData stat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(stat.icon, color: stat.color, size: 20),
          ),

          const SizedBox(height: 8),

          AnimatedBuilder(
            animation: stat.animation,
            builder: (context, child) {
              return Text(
                (stat.value * stat.animation.value).toInt().toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),

          const SizedBox(height: 4),

          Text(
            stat.label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Animation<double> animation;

  _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.animation,
  });
}
