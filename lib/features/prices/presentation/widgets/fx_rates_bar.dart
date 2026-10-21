import 'package:flutter/material.dart';

import '../../../../core/constants.dart';
import '../../../../core/l10n.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/models/exchange_rates.dart';

/// Compact, edge-faded row of USD-based FX tiles for the user's visible currencies.
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
  final AppLocalizations l10n;

  /// User-selected display currencies.
  final List<String> currencies;

  @override
  Widget build(BuildContext context) {
    if (currencies.length <= 1) {
      return const SizedBox.shrink();
    }

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: [0.0, 0.03, 0.97, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            for (final currencyCode in currencies) ...[
              if (currencyCode != AppConstants.usd)
                _buildRateTile(
                  currencyCode,
                  rates.convertFromUsd(1.0, currencyCode),
                ),
              AppSpacing.hGapSm,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRateTile(String currencyCode, double ratePerUsd) {
    String formatRate(double rate) =>
        rate.toStringAsFixed(rate > 100 ? 2 : (rate > 10 ? 3 : 4));
    final primaryColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.fabBorderRadius,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Forced LTR: "1 USD → SAR" keeps visual order in both directions
          Text.rich(
            TextSpan(
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
              children: [
                const TextSpan(text: '1 USD '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(Icons.east_rounded, size: AppSizes.iconXs, color: primaryColor),
                ),
                const TextSpan(text: ' '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Text(
                    AppConstants.currencyFlag(currencyCode),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: currencyCode,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            textDirection: TextDirection.ltr,
          ),
          AppSpacing.vGap3,
          Text(
            '${formatRate(ratePerUsd)} ${AppConstants.currencySymbol(currencyCode)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
