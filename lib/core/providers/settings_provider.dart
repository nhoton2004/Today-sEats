import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  
  // Default to Vietnamese
  Locale _locale = const Locale('vi');
  SharedPreferences? _prefs;

  Locale get locale => _locale;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLang = _prefs?.getString(_languageKey);
    
    if (savedLang != null) {
      _locale = Locale(savedLang);
      notifyListeners();
    }
  }

  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    
    _locale = Locale(languageCode);
    await _prefs?.setString(_languageKey, languageCode);
    notifyListeners();
  }
}
