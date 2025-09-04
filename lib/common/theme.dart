import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness brightness) {
  final base = ThemeData(brightness: brightness, useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3F51B5),
      brightness: brightness,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
