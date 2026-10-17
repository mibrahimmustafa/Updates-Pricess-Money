import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = NotifierProvider<LocaleNotifier, String>(
  LocaleNotifier.new,
);

/// Holds the current language code ('en' or 'ar') and persists it.
class LocaleNotifier extends Notifier<String> {
  static const _prefsKey = 'lang_code';
  static const _arabic = 'ar';
  static const _english = 'en';

  @override
  String build() {
    _init();
    return _english;
  }

  Future<void> _init() async {
    final prefs = SharedPreferencesAsync();
    final saved = await prefs.getString(_prefsKey);
    if (saved != null) state = saved;
  }

  Future<void> toggle() async {
    final next = state == _arabic ? _english : _arabic;
    state = next;
    await SharedPreferencesAsync().setString(_prefsKey, next);
  }
}
