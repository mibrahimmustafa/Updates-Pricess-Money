import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// System / Light / Dark selection, persisted locally.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _prefsKey = 'theme_mode_v1';

  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final raw =
        await SharedPreferencesAsync().getString(_prefsKey);
    switch (raw) {
      case 'light':
        state = ThemeMode.light;
      case 'dark':
        state = ThemeMode.dark;
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await SharedPreferencesAsync().setString(_prefsKey, mode.name);
  }

  /// AppBar quick toggle: light ⟷ dark (system resolves to the opposite).
  void toggle() {
    switch (state) {
      case ThemeMode.light:
        set(ThemeMode.dark);
      case ThemeMode.dark || ThemeMode.system:
        set(ThemeMode.light);
    }
  }
}
