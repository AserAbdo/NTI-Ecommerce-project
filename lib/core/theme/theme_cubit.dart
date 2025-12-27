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
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    emit(isDark ? const ThemeDark() : const ThemeLight());
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = state.themeMode == ThemeMode.dark;
    await prefs.setBool(_themeKey, !isDark);
    emit(isDark ? const ThemeLight() : const ThemeDark());
  }

  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = mode == ThemeMode.dark;
    await prefs.setBool(_themeKey, isDark);
    emit(isDark ? const ThemeDark() : const ThemeLight());
  }

  bool get isDark => state.themeMode == ThemeMode.dark;
}
