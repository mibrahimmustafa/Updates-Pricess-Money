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
  });

  final MetalPrice metal;
  final ExchangeRates rates;
  final ThemeData theme;
  final AppL10n l10n;

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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: goldColor.withValues(alpha: 0.15),
                  child: Icon(
                    showKarats ? Icons.currency_pound : Icons.currency_exchange,
                    color: goldColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.t(metal.symbol == AppConstants.goldSymbol
                      ? 'gold'
                      : 'silver'),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${l10n.t('per_oz')}: ${formatMoney(metal.price, AppConstants.usd)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: goldColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              children: [
                _row(
                  '${l10n.t('gram')} — ${AppConstants.usd}',
                  formatMoney(metal.pricePerGram, AppConstants.usd),
                ),
                _row(
                  '${l10n.t('gram')} — ${AppConstants.sar}',
                  formatMoney(
                    rates.convertFromUsd(metal.pricePerGram, AppConstants.sar),
                    AppConstants.sar,
                  ),
                ),
                _row(
                  '${l10n.t('gram')} — ${AppConstants.egp}',
                  formatMoney(
                    rates.convertFromUsd(metal.pricePerGram, AppConstants.egp),
                    AppConstants.egp,
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
                  for (final k in AppConstants.karats.entries)
                    _row(
                      '${l10n.t('gram')} ${k.key} — ${AppConstants.egp}',
                      formatMoney(
                        rates.convertFromUsd(
                          metal.pricePerGram * k.value,
                          AppConstants.egp,
                        ),
                        AppConstants.egp,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
