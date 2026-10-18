import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';

final userPrefsProvider = NotifierProvider<UserPrefsNotifier, UserPrefs>(
  UserPrefsNotifier.new,
);

/// Everything the user customises: visible currencies, visible assets,
/// default quote currency. Persisted locally as JSON.
class UserPrefs {
  const UserPrefs({
    this.visibleCurrencies = AppConstants.defaultVisibleCurrencies,
    this.visibleMetals = AppConstants.defaultVisibleMetals,
  });

  final Set<String> visibleCurrencies;
  final Set<String> visibleMetals;

  /// Ordered currency list (pool order, filtered by visibility).
  List<String> get currencyList =>
      AppConstants.currencyPool.keys
          .where(visibleCurrencies.contains)
          .toList();

  List<String> get metalList =>
      AppConstants.metalPool.keys.where(visibleMetals.contains).toList();

  UserPrefs copyWith({
    Set<String>? visibleCurrencies,
    Set<String>? visibleMetals,
  }) {
    return UserPrefs(
      visibleCurrencies: visibleCurrencies ?? this.visibleCurrencies,
      visibleMetals: visibleMetals ?? this.visibleMetals,
    );
  }
}

class UserPrefsNotifier extends Notifier<UserPrefs> {
  static const _prefsKey = 'user_prefs_v1';

  @override
  UserPrefs build() {
    _load();
    return const UserPrefs();
  }

  Future<void> _load() async {
    final raw =
        await SharedPreferencesAsync().getString(_prefsKey);
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final currencies = (j['currencies'] as List)
          .cast<String>()
          .where(AppConstants.currencyPool.containsKey)
          .toSet();
      final metals = (j['metals'] as List)
          .cast<String>()
          .where(AppConstants.metalPool.containsKey)
          .toSet();
      state = UserPrefs(
        visibleCurrencies:
            currencies.isEmpty ? state.visibleCurrencies : currencies,
        visibleMetals: metals.isEmpty ? state.visibleMetals : metals,
      );
    } catch (_) {}
  }

  Future<void> _save() async {
    final s = state;
    await SharedPreferencesAsync().setString(_prefsKey, jsonEncode({
          'currencies': s.visibleCurrencies.toList(),
          'metals': s.visibleMetals.toList(),
        }));
  }

  Future<void> toggleCurrency(String code) async {
    final set = Set.of(state.visibleCurrencies);
    if (!set.remove(code)) set.add(code);
    if (set.isEmpty) return; // must show at least one currency
    state = state.copyWith(visibleCurrencies: set);
    await _save();
  }

  Future<void> toggleMetal(String symbol) async {
    final set = Set.of(state.visibleMetals);
    if (!set.remove(symbol)) set.add(symbol);
    if (set.isEmpty) return; // must show at least one asset
    state = state.copyWith(visibleMetals: set);
    await _save();
  }
}
