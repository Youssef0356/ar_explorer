import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const _themeKey = 'is_dark_mode';
  static const _animationsKey = 'enable_animations';

  SharedPreferences? _prefs;
  bool _isDarkMode = true;
  bool _enableAnimations = false; // Default to false for better performance

  bool get isDarkMode => _isDarkMode;
  bool get enableAnimations => _enableAnimations;

  ThemeService();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool(_themeKey) ?? true;
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs?.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool dark) async {
    _isDarkMode = dark;
    await _prefs?.setBool(_themeKey, dark);
    notifyListeners();
  }

  Future<void> toggleAnimations() async {
    _enableAnimations = !_enableAnimations;
    await _prefs?.setBool(_animationsKey, _enableAnimations);
    notifyListeners();
  }
}
