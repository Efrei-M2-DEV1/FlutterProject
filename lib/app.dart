import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/data/auth_service.dart';
import 'features/tasks/presentation/providers/task_provider.dart';

/// Widget racine de l'application avec support du thème dark/light
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider de thème
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),

        // Service d'authentification
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),

        // Provider des tâches
        ChangeNotifierProvider<TaskProvider>(create: (_) => TaskProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          print(
            '🌙 App: Reconstruction avec themeMode: ${themeProvider.themeMode}',
          ); // ✅ Debug

          // ✅ INITIALISATION CORRIGÉE
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!themeProvider.isDarkMode &&
                themeProvider.themeMode == ThemeMode.system) {
              themeProvider.initializeTheme(context);
            }
          });

          return MaterialApp.router(
            title: 'Todo List Pro',
            debugShowCheckedModeBanner: false,

            // ✅ THÈMES CONFIGURÉS
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                themeProvider.themeMode, // ✅ Utilise directement le themeMode
            // Configuration de la navigation
            routerConfig: AppRouter.router,

            // Configuration pour l'accessibilité
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(1.0)),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
