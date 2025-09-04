import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Imports des écrans
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/tasks/presentation/screens/task_form_screen.dart';
import '../../features/tasks/presentation/screens/task_list_screen.dart';
import '../../shared/widgets/splash_screen.dart';

/// Configuration centralisée de la navigation avec go_router
///
/// go_router est le nouveau standard pour la navigation Flutter :
/// - Navigation déclarative (on déclare les routes, pas les actions)
/// - Support natif du web (URLs dans la barre d'adresse)
/// - Navigation typée (pas d'erreurs de routes)
/// - Gestion automatique de la pile de navigation
class AppRouter {
  // ===== CONSTANTES DE ROUTES =====
  // Toujours utiliser des constantes pour éviter les erreurs de frappe
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String tasks = '/tasks';
  static const String taskForm = '/tasks/new';
  static const String taskEdit = '/tasks/:id/edit';
  static const String taskDetail = '/tasks/:id';

  /// Configuration du routeur principal
  static final GoRouter router = GoRouter(
    // Route de démarrage de l'app
    initialLocation: splash,

    // Gestion des erreurs de navigation
    errorBuilder: (context, state) => const _ErrorScreen(),

    // ===== DÉFINITION DES ROUTES =====
    routes: [
      // ===== ROUTE SPLASH =====
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ===== ROUTES D'AUTHENTIFICATION =====
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

      // ===== ROUTES DES TÂCHES =====

      // Liste des tâches (écran principal)
      GoRoute(
        path: tasks,
        name: 'tasks',
        builder: (context, state) => const TaskListScreen(),
      ),

      // Création d'une nouvelle tâche
      GoRoute(
        path: taskForm,
        name: 'task-form',
        builder: (context, state) => const TaskFormScreen(),
      ),

      // Édition d'une tâche existante
      GoRoute(
        path: taskEdit,
        name: 'task-edit',
        builder: (context, state) {
          final taskId = state.pathParameters['id']!;
          return TaskFormScreen(taskId: taskId); // Mode édition
        },
      ),

      // Détail d'une tâche (lecture seule)
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

/// Extension pour simplifier la navigation dans l'app
///
/// Cette extension ajoute des méthodes pratiques au BuildContext
/// Utilisation : context.goToTasks() au lieu de context.go('/tasks')
extension AppRouterExtension on BuildContext {
  // ===== NAVIGATION SIMPLE (remplace la page actuelle) =====
  void goToSplash() => go(AppRouter.splash);
  void goToLogin() => go(AppRouter.login);
  void goToRegister() => go(AppRouter.register);
  void goToTasks() => go(AppRouter.tasks);
  void goToTaskForm() => go(AppRouter.taskForm);
  void goToTaskEdit(String taskId) => go('/tasks/$taskId/edit');
  void goToTaskDetail(String taskId) => go('/tasks/$taskId');

  // ===== NAVIGATION AVEC EMPILAGE (garde la page précédente) =====
  void pushTaskForm() => push(AppRouter.taskForm);
  void pushTaskDetail(String taskId) => push('/tasks/$taskId');

  // ===== RETOUR EN ARRIÈRE =====
  void goBack() => pop();
}

/// Écran d'erreur personnalisé
///
/// Affiché quand une route n'existe pas ou qu'il y a une erreur de navigation
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erreur'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goToTasks(), // Retour à l'accueil
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
