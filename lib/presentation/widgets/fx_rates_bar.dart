import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../data/models/exchange_rates.dart';

/// Compact row of USD-based FX tiles for the user's visible currencies.
class FxRatesBar extends StatelessWidget {
  const FxRatesBar({
    super.key,
    required this.rates,
    required this.theme,
    required this.l10n,
    required this.currencies,
  });

  final ExchangeRates rates;
  final ThemeData theme;
  final AppL10n l10n;

  /// User-selected display currencies.
  final List<String> currencies;

  @override
  Widget build(BuildContext context) {
    if (currencies.length <= 1) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final c in currencies) ...[
            if (c != AppConstants.usd)
              _tile(
                c,
                rates.convertFromUsd(1.0, c),
              ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _tile(String currency, double perUsd) {
    String digits(double v) =>
        v.toStringAsFixed(v > 100 ? 2 : (v > 10 ? 3 : 4));
    final gold = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Forced LTR: "1 USD → SAR" must keep its visual order in
          // both directions; composing it inside RTL text scrambles it.
          Text.rich(
            TextSpan(
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.secondary,
              ),
              children: [
                const TextSpan(text: '1 USD  '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(Icons.east, size: 13, color: gold),
                ),
                TextSpan(text: '  '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Text(
                    AppConstants.currencyFlag(currency),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                TextSpan(
                  text: currency,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: gold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 4),
          Text(
            '${digits(perUsd)} ${AppConstants.currencySymbol(currency)}',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
