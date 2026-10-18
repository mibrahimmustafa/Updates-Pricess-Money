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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.secondary,
              ),
              children: [
                TextSpan(
                  text: '1 USD → ',
                ),
                TextSpan(
                  text: currency,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${AppConstants.currencySymbol(currency)} ${digits(perUsd)}',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
