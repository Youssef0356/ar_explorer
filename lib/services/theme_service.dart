import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const _themeKey = 'is_dark_mode';

  SharedPreferences? _prefs;
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

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
}
