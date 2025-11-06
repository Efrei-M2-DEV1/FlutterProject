import 'package:flutter/material.dart';
import 'package:flutterproject/core/theme/theme_provider.dart';
import 'package:flutterproject/features/auth/data/auth_service.dart';
import 'package:flutterproject/features/tasks/domain/models/task.dart';
import 'package:flutterproject/shared/widgets/theme_switch.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/task_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_filter_chips.dart';
import '../widgets/task_modal.dart';
import '../widgets/task_stats_card.dart';
import '../widgets/task_tile.dart';
import '../widgets/task_sort_button.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _showTaskModal({Task? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext context) {
        return TaskModal(task: task);
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          CustomButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthService>().logout();
              context.goToLogin();
            },
            variant: ButtonVariant.outline,
            expanded: false,
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return _buildLoadingState();
          }

          if (taskProvider.errorMessage != null) {
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Erreur Cloud Firestore',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            taskProvider.errorMessage!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                            },
                            child: const Text(
                              'Voir les indexes dans la console Firebase',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildSearchBar(),
              _buildStatsSection(taskProvider.stats),
              _buildFiltersSection(),
              _buildTasksList(_filterTasks(taskProvider.filteredTasks)),
            ],
          );
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton.extended(
          onPressed: () => _showTaskModal(),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Nouvelle tâche',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement de vos tâches...'),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: const FlexibleSpaceBar(
          title: Text(
            'Mes Tâches',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          titlePadding: EdgeInsets.only(left: 16, bottom: 16),
        ),
      ),
      actions: [
        Consumer<AuthService>(
          builder: (context, authService, child) {
            final email = authService.currentUserEmail;
            if (email != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person, size: 18, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const TaskSortButton(),
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return const Padding(
              padding: EdgeInsets.only(right: 8),
              child: ThemeSwitch(showLabel: false),
            );
          },
        ),

        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: _showLogoutDialog,
        ),
      ],
    );
  }

  List<Task> _filterTasks(List<Task> tasks) {
    if (_searchQuery.isEmpty) return tasks;

    return tasks.where((task) {
      final titleMatch = task.title.toLowerCase().contains(_searchQuery);
      final descriptionMatch = task.description.toLowerCase().contains(
        _searchQuery,
      );
      final tagsMatch = task.tags.any(
        (tag) => tag.toLowerCase().contains(_searchQuery),
      );

      return titleMatch || descriptionMatch || tagsMatch;
    }).toList();
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.getSurfaceVariant(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: TextStyle(
              color: AppColors.getOnSurface(context),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Rechercher des tâches...',
              hintStyle: TextStyle(
                color: AppColors.getOnSurfaceVariant(context).withOpacity(0.6),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppColors.getOnSurfaceVariant(context),
                      ),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(TaskStats stats) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TaskStatsCard(stats: stats),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: TaskFilterChips(),
      ),
    );
  }

  Widget _buildTasksList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const SliverFillRemaining(child: EmptyState());
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final task = tasks[index];
          return TaskTile(
            task: task,
            onTap: () => _showTaskModal(task: task),
            onToggle: () =>
                context.read<TaskProvider>().toggleTaskCompletion(task.id),
            onDelete: () => context.read<TaskProvider>().deleteTask(task.id),
          );
        }, childCount: tasks.length),
      ),
    );
  }
}
