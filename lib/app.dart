// lib/app.dart
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // pas besoin pour l’instant
import 'common/theme.dart';
import 'router/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FlutterProject',
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      routerConfig: appRouter,
    );
  }
}
