import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../data/models/exchange_rates.dart';

/// Compact row showing the live USD/SAR and USD/EGP FX rates.
class FxRatesBar extends StatelessWidget {
  const FxRatesBar({
    super.key,
    required this.rates,
    required this.theme,
    required this.l10n,
  });

  final ExchangeRates rates;
  final ThemeData theme;
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    Expanded tile(String label, String value) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(label, style: theme.textTheme.labelSmall),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        tile(
          '1 USD → ${AppConstants.sar}',
          rates.usdToSar.toStringAsFixed(4),
        ),
        const SizedBox(width: 8),
        tile(
          '1 USD → ${AppConstants.egp}',
          rates.usdToEgp.toStringAsFixed(2),
        ),
      ],
    );
  }
}
