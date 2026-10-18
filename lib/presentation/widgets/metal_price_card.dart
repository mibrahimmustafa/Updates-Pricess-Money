import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../core/utils.dart';
import '../../data/models/exchange_rates.dart';
import '../../data/models/metal_price.dart';

/// Card showing one metal's price in USD / SAR / EGP,
/// per ounce and per gram, plus a karat breakdown (gold only).
class MetalPriceCard extends StatelessWidget {
  const MetalPriceCard({
    super.key,
    required this.metal,
    required this.rates,
    required this.theme,
    required this.l10n,
    this.showKarats = false,
    required this.currencies,
  });

  final MetalPrice metal;
  final ExchangeRates rates;
  final ThemeData theme;
  final AppL10n l10n;

  /// User-selected display currencies (drives the per-gram rows).
  final List<String> currencies;

  /// Karat breakdown only makes sense for gold.
  final bool showKarats;

  TableRow _row(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final goldColor = theme.colorScheme.primary;
    final isGold = metal.symbol == AppConstants.goldSymbol;
    final isSilver = metal.symbol == AppConstants.silverSymbol;
    final accent = isGold
        ? goldColor
        : isSilver
            ? const Color(0xFFB7C0CC)
            : const Color(0xFF9BA8B5);
    final isGramMetal = AppConstants.gramMetals.contains(metal.symbol);
    final label = isGold
        ? l10n.t('gold')
        : isSilver
            ? l10n.t('silver')
            : AppConstants.metalPool[metal.symbol] ?? metal.name;
    final icon = isGold
        ? Icons.currency_pound
        : isSilver
            ? Icons.currency_exchange
            : Icons.paid;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF2C2820)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: Icon(icon, color: accent, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      metal.symbol,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  formatMoney(metal.price, AppConstants.usd),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: goldColor,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  metal.symbol == 'BTC' ? '' : l10n.t('per_oz'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            if (isGramMetal) ...[
              const Divider(height: 20),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                },
                children: [
                  for (final c in currencies)
                    _row(
                      '${l10n.t('gram')} · ${iso(c)}',
                      formatMoney(
                        rates.convertFromUsd(metal.pricePerGram, c),
                        c,
                      ),
                    ),
                ],
              ),
              if (showKarats) ...[
                const SizedBox(height: 8),
                const Divider(height: 12),
                Table(
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                  },
                  children: [
                    // 24K equals the pure spot gram row above — skipped.
                    for (final k in AppConstants.karats.entries)
                      if (k.key != '24K')
                        _row(
                          '${l10n.t('gram')} ${iso(k.key)} · ${iso(currencies.last)}',
                          formatMoney(
                            rates.convertFromUsd(
                              metal.pricePerGram * k.value,
                              currencies.last,
                            ),
                            currencies.last,
                          ),
                        ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
