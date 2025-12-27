import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeCubit() : super(const ThemeLight()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      print('🎨 Loading theme: ${isDark ? "Dark" : "Light"}');
      emit(isDark ? const ThemeDark() : const ThemeLight());
    } catch (e) {
      print('❌ Error loading theme: $e');
    }
  }

  Future<void> toggleTheme() async {
    try {
      print('🔄 Toggle theme called. Current: ${state.themeMode}');
      final prefs = await SharedPreferences.getInstance();
      final isDark = state.themeMode == ThemeMode.dark;
      await prefs.setBool(_themeKey, !isDark);
      emit(isDark ? const ThemeLight() : const ThemeDark());
      print('✅ Theme toggled to: ${isDark ? "Light" : "Dark"}');
    } catch (e) {
      print('❌ Error toggling theme: $e');
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = mode == ThemeMode.dark;
      await prefs.setBool(_themeKey, isDark);
      emit(isDark ? const ThemeDark() : const ThemeLight());
      print('✅ Theme set to: ${isDark ? "Dark" : "Light"}');
    } catch (e) {
      print('❌ Error setting theme: $e');
    }
  }

  bool get isDark => state.themeMode == ThemeMode.dark;
}
