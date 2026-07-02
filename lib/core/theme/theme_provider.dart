import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(AppConstants.themeKey);
    state = theme == 'dark'
        ? ThemeMode.dark
        : theme == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
  }

  Future<void> toggle(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeKey, isDark ? 'dark' : 'light');
  }
}
