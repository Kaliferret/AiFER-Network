import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService with ChangeNotifier {
  static ThemeService? _instance;

  // Fix singleton pattern to prevent circular calls
  static ThemeService get instance {
    if (_instance == null) {
      _instance = ThemeService._internal();
    }
    return _instance!;
  }

  // Private constructor
  ThemeService._internal();

  ThemeMode _themeMode = ThemeMode.dark; // FER Network is dark-first
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;

  Future<void> initialize() async {
    if (_isInitialized) return; // Prevent re-initialization

    try {
      _isInitialized = true;
      await _loadThemeFromDevice();
      // TEMPORARY: Disable database loading to prevent crashes
      // await _loadThemeFromDatabase();
      debugPrint('✅ Theme service initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize theme service: $e');
    }
  }

  Future<void> _loadThemeFromDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex =
          prefs.getInt('theme_mode') ?? ThemeMode.system.index;
      _themeMode = ThemeMode.values[themeModeIndex];
    } catch (e) {
      debugPrint('❌ Failed to load theme from device: $e');
      _themeMode = ThemeMode.dark; // Fallback
    }
  }

  // TEMPORARY: Disable database integration for testing
  // Future<void> _loadThemeFromDatabase() async {
  //   // Commented out to prevent Supabase dependency issues
  // }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode != themeMode) {
      _themeMode = themeMode;
      notifyListeners();

      await _saveThemeToDevice(themeMode);
      // TEMPORARY: Disable database saving
      // await _saveThemeToDatabase(themeMode);
    }
  }

  Future<void> _saveThemeToDevice(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', themeMode.index);
    } catch (e) {
      debugPrint('❌ Failed to save theme to device: $e');
    }
  }

  // TEMPORARY: Disable database saving for testing
  // Future<void> _saveThemeToDatabase(ThemeMode themeMode) async {
  //   // Commented out to prevent Supabase dependency issues
  // }

  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }

  ThemeMode _stringToThemeMode(String themeString) {
    switch (themeString.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
