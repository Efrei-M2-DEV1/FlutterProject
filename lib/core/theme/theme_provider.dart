import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    if (_themeMode == ThemeMode.system) {
      _isDarkMode = !_isDarkMode;
      _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    } else {
      _isDarkMode = !_isDarkMode;
      _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    }

    _updateSystemChrome();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;
    _updateSystemChrome();
    notifyListeners();
  }

  void followSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }

  void initializeTheme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    _isDarkMode = brightness == Brightness.dark;

    if (_themeMode == ThemeMode.system) {
      _updateSystemChrome();
    }
  }

  void _updateSystemChrome() {
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
