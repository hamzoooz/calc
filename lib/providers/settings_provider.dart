import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

enum AppLanguage { english, arabic }

/// Calculator operation modes
enum CalculatorMode {
  standard,
  scientific,
  matrix,
  equations,
  statistics,
}

class SettingsProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _soundKey = 'sound_enabled';
  static const String _hapticKey = 'haptic_enabled';
  static const String _languageKey = 'language';
  static const String _scientificModeKey = 'scientific_mode';
  static const String _radiansKey = 'use_radians';
  static const String _calculatorModeKey = 'calculator_mode';

  AppThemeMode _themeMode = AppThemeMode.system;
  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  AppLanguage _language = AppLanguage.english;
  bool _scientificMode = false;
  bool _useRadians = false;
  CalculatorMode _calculatorMode = CalculatorMode.standard;

  // Getters
  AppThemeMode get themeMode => _themeMode;
  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;
  AppLanguage get language => _language;
  bool get scientificMode => _scientificMode;
  bool get useRadians => _useRadians;
  CalculatorMode get calculatorMode => _calculatorMode;

  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Locale get locale {
    switch (_language) {
      case AppLanguage.english:
        return const Locale('en');
      case AppLanguage.arabic:
        return const Locale('ar');
    }
  }

  bool get isRTL => _language == AppLanguage.arabic;

  // Initialize from SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_themeKey) ?? 2; // Default to system
    _themeMode = AppThemeMode.values[themeIndex];

    _soundEnabled = prefs.getBool(_soundKey) ?? true;
    _hapticEnabled = prefs.getBool(_hapticKey) ?? true;

    final langIndex = prefs.getInt(_languageKey) ?? 0; // Default to English
    _language = AppLanguage.values[langIndex];

    _scientificMode = prefs.getBool(_scientificModeKey) ?? false;
    _useRadians = prefs.getBool(_radiansKey) ?? false;

    final calcModeIndex = prefs.getInt(_calculatorModeKey) ?? 0;
    _calculatorMode = CalculatorMode.values[calcModeIndex];

    notifyListeners();
  }

  // Setters
  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, enabled);
  }

  Future<void> setHapticEnabled(bool enabled) async {
    _hapticEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticKey, enabled);
  }

  Future<void> setLanguage(AppLanguage language) async {
    _language = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_languageKey, language.index);
  }

  Future<void> setScientificMode(bool enabled) async {
    _scientificMode = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_scientificModeKey, enabled);
  }

  Future<void> setUseRadians(bool useRadians) async {
    _useRadians = useRadians;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_radiansKey, useRadians);
  }

  void toggleScientificMode() {
    setScientificMode(!_scientificMode);
  }

  void toggleAngleMode() {
    setUseRadians(!_useRadians);
  }

  Future<void> setCalculatorMode(CalculatorMode mode) async {
    _calculatorMode = mode;
    // Also update scientific mode based on calculator mode
    _scientificMode = mode == CalculatorMode.scientific;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_calculatorModeKey, mode.index);
    await prefs.setBool(_scientificModeKey, _scientificMode);
  }
}
