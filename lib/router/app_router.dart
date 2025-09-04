import 'package:go_router/go_router.dart';
import '../features/splash/ui/splash_page.dart';
import '../features/auth/ui/auth_page.dart';
import '../features/tasks/ui/tasks_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashPage()),
    GoRoute(path: '/auth', builder: (_, __) => const AuthPage()),
    GoRoute(path: '/tasks', builder: (_, __) => const TasksPage()),
  ],
);
