import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Provider pour gérer le thème de l'application
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  // ===== GETTERS =====
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  // ===== MÉTHODES =====

  /// Basculer entre thème clair et sombre
  void toggleTheme() {
    print('🌙 ThemeProvider: Basculement du thème'); // ✅ Debug

    if (_themeMode == ThemeMode.system) {
      // Si on est en mode système, passer en mode manuel
      _isDarkMode = !_isDarkMode;
      _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    } else {
      // Si on est en mode manuel, basculer
      _isDarkMode = !_isDarkMode;
      _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    }

    print('🌙 Nouveau mode: $_themeMode, isDark: $_isDarkMode'); // ✅ Debug

    _updateSystemChrome();
    notifyListeners(); // ✅ Important pour mettre à jour l'UI
  }

  /// Définir le thème explicitement
  void setThemeMode(ThemeMode mode) {
    print('🌙 ThemeProvider: setThemeMode($mode)'); // ✅ Debug

    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;
    _updateSystemChrome();
    notifyListeners();
  }

  /// Suivre le thème système
  void followSystemTheme() {
    print('🌙 ThemeProvider: Suivi du thème système'); // ✅ Debug

    _themeMode = ThemeMode.system;
    notifyListeners();
  }

  /// Initialiser selon le thème système
  void initializeTheme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    _isDarkMode = brightness == Brightness.dark;

    print(
      '🌙 ThemeProvider: Initialisation - brightness: $brightness, isDark: $_isDarkMode',
    ); // ✅ Debug

    // Si on n'a pas encore défini de mode, utiliser le système
    if (_themeMode == ThemeMode.system) {
      _updateSystemChrome();
    }
  }

  /// Mettre à jour la barre de statut
  void _updateSystemChrome() {
    print(
      '🌙 ThemeProvider: Mise à jour SystemChrome pour mode: $_themeMode',
    ); // ✅ Debug

    final isDark =
        _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system && _isDarkMode);

    if (isDark) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF1E293B),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    }
  }
}
