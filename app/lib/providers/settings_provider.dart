import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Paramètres (simplifié - pas de config serveur)
  bool _isDarkMode = false;
  bool _saveToHistory = true;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isDarkMode => _isDarkMode;
  bool get saveToHistory => _saveToHistory;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    _isDarkMode = _prefs.getBool('dark_mode') ?? false;
    _saveToHistory = _prefs.getBool('save_to_history') ?? true;

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs.setBool('dark_mode', value);
    notifyListeners();
  }

  Future<void> setSaveToHistory(bool value) async {
    _saveToHistory = value;
    await _prefs.setBool('save_to_history', value);
    notifyListeners();
  }

  Future<void> resetSettings() async {
    await _prefs.clear();
    await _loadSettings();
  }
}
