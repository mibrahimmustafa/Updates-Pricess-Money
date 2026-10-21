import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = NotifierProvider<LocaleNotifier, String>(
  LocaleNotifier.new,
);

/// Holds the current language code ('en' or 'ar') and persists it.
class LocaleNotifier extends Notifier<String> {
  static const _prefsKey = 'lang_code';
  static const _arabicLanguageCode = 'ar';
  static const _englishLanguageCode = 'en';

  @override
  String build() {
    _initialize();
    return _englishLanguageCode;
  }

  Future<void> _initialize() async {
    final prefs = SharedPreferencesAsync();
    final saved = await prefs.getString(_prefsKey);
    if (saved != null) state = saved;
  }

  Future<void> toggle() async {
    final next = state == _arabicLanguageCode ? _englishLanguageCode : _arabicLanguageCode;
    state = next;
    await SharedPreferencesAsync().setString(_prefsKey, next);
  }
}
