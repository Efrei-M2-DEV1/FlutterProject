import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/data/auth_service.dart';
import 'features/tasks/presentation/providers/task_provider.dart';
import 'features/tasks/data/task_service.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        Provider<TaskService>(create: (_) => TaskService()),
        ChangeNotifierProxyProvider<TaskService, TaskProvider>(
          create: (_) => TaskProvider(),
          update: (_, taskService, taskProvider) {
            final provider = taskProvider ?? TaskProvider();
            provider.setTaskService(taskService);
            return provider;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!themeProvider.isDarkMode &&
                themeProvider.themeMode == ThemeMode.system) {
              themeProvider.initializeTheme(context);
            }
          });

          return MaterialApp.router(
            title: 'Todo List Pro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
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
