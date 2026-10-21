import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants.dart';

/// Preferred quote currency provider (charts/converter default).
final preferredQuoteCurrencyProvider =
    NotifierProvider<PreferredCurrencyNotifier, String>(
  PreferredCurrencyNotifier.new,
);

/// Backward compatibility alias.
final defaultCurrencyProvider = preferredQuoteCurrencyProvider;

/// Backward compatibility alias.
typedef DefaultCurrencyNotifier = PreferredCurrencyNotifier;

/// Charts/converter default quote currency: device region (EG → EGP,
/// SA → SAR) with a persisted override from Settings.
class PreferredCurrencyNotifier extends Notifier<String> {
  static const _prefsKey = 'default_quote_currency';

  @override
  String build() {
    _initialize();
    final deviceCountryCode = PlatformDispatcher.instance.locale.countryCode;
    return deviceCountryCode == 'EG' ? AppConstants.egp : AppConstants.sar;
  }

  Future<void> _initialize() async {
    final saved = await SharedPreferencesAsync().getString(_prefsKey);
    if (saved != null) state = saved;
  }

  Future<void> set(String currency) async {
    state = currency;
    await SharedPreferencesAsync().setString(_prefsKey, currency);
  }
}
