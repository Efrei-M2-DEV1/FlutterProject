import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_service.dart';
import 'features/tasks/presentation/providers/task_provider.dart';

/// Widget racine de l'application
/// Centralise la configuration du thème, de la navigation et de l'état global
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Service d'authentification
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),

        // Provider des tâches
        ChangeNotifierProvider<TaskProvider>(create: (_) => TaskProvider()),
      ],
      child: MaterialApp.router(
        // Informations de base de l'app
        title: 'Todo List Pro',
        debugShowCheckedModeBanner: false,

        // TON DOMAINE : Thème visuel personnalisé
        theme: AppTheme.lightTheme,

        // TON DOMAINE : Configuration de la navigation
        routerConfig: AppRouter.router,

        // Configuration de l'accessibilité
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                1.0,
              ), // Évite le scaling automatique
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
