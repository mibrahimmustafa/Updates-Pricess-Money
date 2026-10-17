import 'package:flutter_test/flutter_test.dart';

import 'package:pricess_money/core/utils.dart';
import 'package:pricess_money/data/models/history_point.dart';
import 'package:pricess_money/data/models/metal_price.dart';
import 'package:pricess_money/data/models/exchange_rates.dart';

void main() {
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
      usdToSar: 3.75,
      usdToEgp: 53.32,
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

  test('formatMoney adds symbol and thousand separators', () {
    expect(formatMoney(7141.724, 'EGP'), 'ج.م 7,141.72');
    expect(formatMoney(3.75, 'SAR'), 'ر.س 3.750');
    expect(formatMoney(10, 'USD'), r'$ 10.000');
  });
}
