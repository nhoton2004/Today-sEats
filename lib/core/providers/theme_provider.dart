import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  SharedPreferences? _prefs;

  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    // For system mode, check the platform brightness
    // This will be handled by the MaterialApp
    return false;
  }

  /// Initialize and load saved theme preference
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final savedMode = _prefs?.getString(_themeModeKey);
    
    if (savedMode != null) {
      switch (savedMode) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
          _themeMode = ThemeMode.system;
          break;
      }
      notifyListeners();
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    
    await _saveThemeMode();
    notifyListeners();
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    await _saveThemeMode();
    notifyListeners();
  }

  /// Save theme mode to local storage
  Future<void> _saveThemeMode() async {
    String modeString;
    switch (_themeMode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    
    await _prefs?.setString(_themeModeKey, modeString);
  }
}
