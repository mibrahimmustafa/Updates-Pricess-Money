// Live smoke test — hits the real free APIs.
// ignore_for_file: avoid_print, depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:pricess_money/data/repositories/price_repository.dart';

// Live smoke test — hits the real free APIs.
void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({});
  });
  test('fetchSnapshot returns real gold/silver/FX data', () async {
    final repo = PriceRepository();
    final snap = await repo.fetchSnapshot();

    print('Gold   USD/oz: ${snap.gold.price}');
    print('Silver USD/oz: ${snap.silver.price}');
    print('USD→SAR: ${snap.rates.usdToSar}');
    print('USD→EGP: ${snap.rates.usdToEgp}');
    print('Gold EGP/gram 24K: ${snap.rates.convertFromUsd(snap.gold.pricePerGram, 'EGP').toStringAsFixed(2)}');

    expect(snap.gold.price, greaterThan(1000));
    expect(snap.silver.price, greaterThan(1));
    expect(snap.rates.usdToSar, closeTo(3.75, 0.01));
    expect(snap.rates.usdToEgp, greaterThan(10));
  });

  test('cache round-trips through JSON', () async {
    final repo = PriceRepository();
    final snap = await repo.fetchSnapshot();
    await repo.saveCached(snap);
    final cached = await repo.loadCached();
    expect(cached, isNotNull);
    expect(cached!.gold.price, snap.gold.price);
  });
}
