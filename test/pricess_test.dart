import 'package:flutter_test/flutter_test.dart';

import 'package:pricess_money/core/utils.dart';
import 'package:pricess_money/data/models/history_point.dart';
import 'package:pricess_money/data/models/metal_price.dart';
import 'package:pricess_money/data/models/exchange_rates.dart';
import 'package:pricess_money/presentation/controllers/alerts_controller.dart';

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

  test('formatMoney adds symbol and thousand separators', () {
    expect(formatMoney(7141.724, 'EGP'), 'ج.م 7,141.72');
    expect(formatMoney(3.75, 'SAR'), 'ر.س 3.750');
    expect(formatMoney(10, 'USD'), r'$ 10.000');
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
