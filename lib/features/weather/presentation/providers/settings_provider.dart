import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _tempUnitKey = 'temp_unit';
  static const String _themeKey = 'theme_mode';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _refreshIntervalKey = 'refresh_interval';

  late SharedPreferences _prefs;
  bool _initialized = false;

  // Settings properties
  String _temperatureUnit = 'C'; // 'C' or 'F'
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  int _refreshInterval = 30; // minutes

  // Getters
  String get temperatureUnit => _temperatureUnit;
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  int get refreshInterval => _refreshInterval;
  bool get isInitialized => _initialized;

  // Initialize settings from SharedPreferences
  Future<void> init() async {
    if (_initialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    
    _temperatureUnit = _prefs.getString(_tempUnitKey) ?? 'C';
    String themeModeStr = _prefs.getString(_themeKey) ?? 'system';
    _themeMode = _stringToThemeMode(themeModeStr);
    _notificationsEnabled = _prefs.getBool(_notificationsKey) ?? true;
    _refreshInterval = _prefs.getInt(_refreshIntervalKey) ?? 30;
    
    _initialized = true;
    notifyListeners();
  }

  // Temperature unit setter
  Future<void> setTemperatureUnit(String unit) async {
    if (unit != 'C' && unit != 'F') return;
    
    _temperatureUnit = unit;
    await _prefs.setString(_tempUnitKey, unit);
    notifyListeners();
  }

  // Theme mode setter
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeKey, _themeModeToString(mode));
    notifyListeners();
  }

  // Notifications setter
  Future<void> setNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs.setBool(_notificationsKey, enabled);
    notifyListeners();
  }

  // Refresh interval setter
  Future<void> setRefreshInterval(int minutes) async {
    if (minutes < 5 || minutes > 1440) return; // 5 min to 24 hours
    
    _refreshInterval = minutes;
    await _prefs.setInt(_refreshIntervalKey, minutes);
    notifyListeners();
  }

  // Helper methods
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _stringToThemeMode(String str) {
    switch (str) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // Convert temperature
  double convertTemperature(double celsius) {
    if (_temperatureUnit == 'F') {
      return (celsius * 9 / 5) + 32;
    }
    return celsius;
  }

  String getTemperatureUnit() {
    return _temperatureUnit == 'F' ? '°F' : '°C';
  }
}
