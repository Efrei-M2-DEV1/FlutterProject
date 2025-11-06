import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/tasks/presentation/screens/task_form_screen.dart';
import '../../features/tasks/presentation/screens/task_list_screen.dart';
import '../../shared/widgets/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String tasks = '/tasks';
  static const String taskForm = '/tasks/new';
  static const String taskEdit = '/tasks/:id/edit';
  static const String taskDetail = '/tasks/:id';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    errorBuilder: (context, state) => const _ErrorScreen(),
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: tasks,
        name: 'tasks',
        builder: (context, state) => const TaskListScreen(),
      ),
      GoRoute(
        path: taskForm,
        name: 'task-form',
        builder: (context, state) => const TaskFormScreen(),
      ),
      GoRoute(
        path: taskEdit,
        name: 'task-edit',
        builder: (context, state) {
          final taskId = state.pathParameters['id']!;
          return TaskFormScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: taskDetail,
        name: 'task-detail',
        builder: (context, state) {
          final taskId = state.pathParameters['id']!;
          return TaskDetailScreen(taskId: taskId);
        },
      ),
    ],
  );
}

extension AppRouterExtension on BuildContext {
  void goToSplash() => go(AppRouter.splash);
  void goToLogin() => go(AppRouter.login);
  void goToRegister() => go(AppRouter.register);
  void goToTasks() => go(AppRouter.tasks);
  void goToTaskForm() => go(AppRouter.taskForm);
  void goToTaskEdit(String taskId) => go('/tasks/$taskId/edit');
  void goToTaskDetail(String taskId) => go('/tasks/$taskId');
  void pushTaskForm() => push(AppRouter.taskForm);
  void pushTaskDetail(String taskId) => push('/tasks/$taskId');
  void goBack() => pop();
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erreur'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goToTasks(),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('La page que vous cherchez n\'existe pas.'),
          ],
        ),
      ),
    );
  }
}
