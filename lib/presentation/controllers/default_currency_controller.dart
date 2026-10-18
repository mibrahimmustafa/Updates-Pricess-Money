import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';

final defaultCurrencyProvider =
    NotifierProvider<DefaultCurrencyNotifier, String>(
  DefaultCurrencyNotifier.new,
);

/// Charts/converter default quote currency: device region (EG → EGP,
/// SA → SAR) with a persisted override from Settings.
class DefaultCurrencyNotifier extends Notifier<String> {
  static const _prefsKey = 'default_quote_currency';

  @override
  String build() {
    _init();
    final region = PlatformDispatcher.instance.locale.countryCode;
    return region == 'EG' ? AppConstants.egp : AppConstants.sar;
  }

  Future<void> _init() async {
    final saved =
        await SharedPreferencesAsync().getString(_prefsKey);
    if (saved != null) state = saved;
  }

  Future<void> set(String currency) async {
    state = currency;
    await SharedPreferencesAsync().setString(_prefsKey, currency);
  }
}
