import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants.dart';

/// Backward compatibility aliases.
typedef UserPrefs = UserPreferences;
typedef UserPrefsNotifier = UserPreferencesNotifier;

final userPreferencesProvider =
    NotifierProvider<UserPreferencesNotifier, UserPreferences>(
  UserPreferencesNotifier.new,
);

/// Backward compatibility alias.
final userPrefsProvider = userPreferencesProvider;

/// Everything the user customises: enabled currencies, enabled assets,
/// default quote currency. Persisted locally as JSON.
class UserPreferences {
  const UserPreferences({
    this.enabledCurrencyCodes = AppConstants.defaultVisibleCurrencies,
    this.enabledMetalCodes = AppConstants.defaultVisibleMetals,
  });

  final Set<String> enabledCurrencyCodes;
  final Set<String> enabledMetalCodes;

  /// Backward-compatibility getters
  Set<String> get visibleCurrencies => enabledCurrencyCodes;
  Set<String> get visibleMetals => enabledMetalCodes;

  /// Ordered currency list (pool order, filtered by user enablement).
  List<String> get orderedCurrencyCodes => AppConstants.currencyCodes
      .where(enabledCurrencyCodes.contains)
      .toList();

  /// Backward-compatibility getter
  List<String> get currencyList => orderedCurrencyCodes;

  /// Ordered metal list (pool order, filtered by user enablement).
  List<String> get orderedMetalCodes => AppConstants.metalPool.keys
      .where(enabledMetalCodes.contains)
      .toList();

  /// Backward-compatibility getter
  List<String> get metalList => orderedMetalCodes;

  UserPreferences copyWith({
    Set<String>? enabledCurrencyCodes,
    Set<String>? enabledMetalCodes,
    Set<String>? visibleCurrencies,
    Set<String>? visibleMetals,
  }) {
    return UserPreferences(
      enabledCurrencyCodes: enabledCurrencyCodes ??
          visibleCurrencies ??
          this.enabledCurrencyCodes,
      enabledMetalCodes:
          enabledMetalCodes ?? visibleMetals ?? this.enabledMetalCodes,
    );
  }
}

class UserPreferencesNotifier extends Notifier<UserPreferences> {
  /// v2: migrates old 3-currency default to the wide Arab+world default.
  static const _prefsKey = 'user_prefs_v2';

  @override
  UserPreferences build() {
    _load();
    return const UserPreferences();
  }

  Future<void> _load() async {
    final raw = await SharedPreferencesAsync().getString(_prefsKey);
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final currencies = (j['currencies'] as List)
          .cast<String>()
          .where(AppConstants.currencyCodes.contains)
          .toSet();
      final metals = (j['metals'] as List)
          .cast<String>()
          .where(AppConstants.metalPool.containsKey)
          .toSet();
      state = UserPreferences(
        enabledCurrencyCodes:
            currencies.isEmpty ? state.enabledCurrencyCodes : currencies,
        enabledMetalCodes: metals.isEmpty ? state.enabledMetalCodes : metals,
      );
    } catch (_) {}
  }

  Future<void> _save() async {
    final s = state;
    await SharedPreferencesAsync().setString(_prefsKey, jsonEncode({
          'currencies': s.enabledCurrencyCodes.toList(),
          'metals': s.enabledMetalCodes.toList(),
        }));
  }

  Future<void> toggleCurrency(String code) async {
    final set = Set.of(state.enabledCurrencyCodes);
    if (!set.remove(code)) set.add(code);
    if (set.isEmpty) return; // must show at least one currency
    state = state.copyWith(enabledCurrencyCodes: set);
    await _save();
  }

  Future<void> toggleMetal(String symbol) async {
    final set = Set.of(state.enabledMetalCodes);
    if (!set.remove(symbol)) set.add(symbol);
    if (set.isEmpty) return; // must show at least one asset
    state = state.copyWith(enabledMetalCodes: set);
    await _save();
  }

  Future<void> selectGroup(Set<String> codes) async {
    state = state.copyWith(
      enabledCurrencyCodes: codes.intersection(AppConstants.currencyCodes),
    );
    await _save();
  }

  Future<void> resetCurrencies() async {
    state = state.copyWith(
      enabledCurrencyCodes: AppConstants.defaultVisibleCurrencies,
    );
    await _save();
  }

  Future<void> resetMetals() async {
    state = state.copyWith(
      enabledMetalCodes: AppConstants.defaultVisibleMetals,
    );
    await _save();
  }
}
