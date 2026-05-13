import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode {
    return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}