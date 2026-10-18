import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:pricess_money/core/constants.dart';
import 'package:pricess_money/core/utils.dart';
import 'package:pricess_money/data/models/history_point.dart';
import 'package:pricess_money/data/models/metal_price.dart';
import 'package:pricess_money/data/models/exchange_rates.dart';
import 'package:pricess_money/presentation/controllers/alerts_controller.dart';
import 'package:pricess_money/presentation/controllers/user_prefs_controller.dart';

void main() {
  test('user prefs: toggle / preset / reset / persistence round-trip', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({});

    // Fresh app start: defaults.
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(
      c.read(userPrefsProvider).visibleCurrencies,
      AppConstants.defaultVisibleCurrencies,
    );
    expect(
      c.read(userPrefsProvider).visibleMetals,
      AppConstants.defaultVisibleMetals,
    );

    // Toggle adds a currency and saves ('BRL' is not in the defaults).
    await c.read(userPrefsProvider.notifier).toggleCurrency('BRL');
    expect(c.read(userPrefsProvider).visibleCurrencies.contains('BRL'), isTrue);

    // Protection: the list can never be emptied completely.
    for (final code in List.of(c.read(userPrefsProvider).visibleCurrencies)) {
      await c.read(userPrefsProvider.notifier).toggleCurrency(code);
    }
    expect(c.read(userPrefsProvider).visibleCurrencies, isNotEmpty);

    // Preset selects a group.
    await c.read(userPrefsProvider.notifier).selectGroup(AppConstants.gccCurrencies);
    expect(c.read(userPrefsProvider).visibleCurrencies, AppConstants.gccCurrencies);

    // Metal toggle protection too.
    for (final m in List.of(c.read(userPrefsProvider).visibleMetals)) {
      await c.read(userPrefsProvider.notifier).toggleMetal(m);
    }
    expect(c.read(userPrefsProvider).visibleMetals, isNotEmpty);

    // Persistence: raw JSON is on disk.
    final raw = await SharedPreferencesAsync().getString('user_prefs_v2');
    expect(raw, isNotNull);
    expect(raw!, contains('QAR'));

    // Second "app start" reads persisted state from storage.
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    for (var i = 0; i < 50; i++) {
      await Future.delayed(const Duration(milliseconds: 10));
      if (c2.read(userPrefsProvider).visibleCurrencies.length == 6) break;
    }
    expect(c2.read(userPrefsProvider).visibleCurrencies, AppConstants.gccCurrencies);

    // Reset returns defaults.
    await c2.read(userPrefsProvider.notifier).resetCurrencies();
    expect(
      c2.read(userPrefsProvider).visibleCurrencies,
      AppConstants.defaultVisibleCurrencies,
    );
  });

  test('MetalPrice parses gold-api JSON', () {
    final m = MetalPrice.fromJson({
      'symbol': 'XAU',
      'name': 'Gold',
      'price': 4166.10,
      'currency': 'USD',
      'updatedAt': '2026-10-17T18:56:43Z',
    });
    expect(m.pricePerGram, closeTo(4166.10 / 31.1034768, 0.0001));
  });

  test('ExchangeRates converts USD to SAR and EGP', () {
    final r = ExchangeRates(
      usdRates: const {'USD': 1.0, 'SAR': 3.75, 'EGP': 53.32},
      date: DateTime(2026, 10, 17),
    );
    expect(r.convertFromUsd(10, 'SAR'), closeTo(37.5, 0.001));
    expect(r.convertFromUsd(10, 'EGP'), closeTo(533.2, 0.001));
    expect(r.convertFromUsd(10, 'USD'), 10);
  });

  test('HistoryPoint computes per-gram price', () {
    final h = HistoryPoint.fromJson({
      'date': '2026-10-13',
      'base': 'XAU',
      'quote': 'EGP',
      'rate': 220284,
    });
    expect(h.perGram, closeTo(220284 / 31.1034768, 0.01));
  });

  test('formatMoney adds symbol and thousand separators, bidi-safe', () {
    // digits first, directional isolates around the number
    expect(formatMoney(7141.724, 'EGP'), '\u20667,141.72\u2069 ج.م');
    expect(formatMoney(3.75, 'SAR'), '\u20663.750\u2069 ر.س');
    expect(formatMoney(10, 'USD'), '\u206610.000\u2069 \$');
    // isolates keep the digits LTR even inside Arabic text
    final out = formatMoney(7141.724, 'EGP');
    expect(out.startsWith('\u2066'), isTrue);
    expect(out.contains('\u2069'), isTrue);
  });

  test('PriceAlert triggers above and below targets', () {
    PriceAlert alert(bool above) => PriceAlert(
          id: '1',
          metalSymbol: 'XAU',
          currency: 'EGP',
          targetPerGram: 7000,
          above: above,
          active: true,
          createdAt: 0,
        );
    expect(alert(true).isTriggered(7100), true);
    expect(alert(true).isTriggered(6900), false);
    expect(alert(false).isTriggered(6900), true);
    expect(alert(false).isTriggered(7100), false);
  });

  test('HistoryPoint parses quote currency from CBE rows', () {
    final p = HistoryPoint.fromJson({
      'date': '2026-10-15',
      'base': 'USD',
      'quote': 'EGP',
      'rate': 53.4614,
    });
    expect(p.quote, 'EGP');
    expect(p.perOunce, 53.4614);
  });
}
