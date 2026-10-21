import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils.dart';
import '../../../../core/widgets/network_error_display.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../prices/presentation/controllers/prices_controller.dart';
import '../../../settings/presentation/controllers/locale_controller.dart';

/// Official Central Bank of Egypt daily rates vs the market blend.
/// Fully responsive layout using proportional flex alignment and dynamic scaling.
class BanksScreen extends ConsumerWidget {
  const BanksScreen({super.key});

  /// A friendly subset of the 19 CBE-published currencies.
  static const _trackedCurrencyCodes = [
    'EGP', 'EUR', 'GBP', 'CHF', 'JPY', 'AED', 'SAR', 'KWD', 'QAR',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(localeProvider);
    final l10n = AppLocalizations(languageCode);
    final theme = Theme.of(context);
    final snapshot = ref.watch(marketPricesProvider).snapshot;
    final cbeRatesAsync = ref.watch(centralBankRatesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.banksTitle)),
      body: ResponsiveCenter(
        maxContentWidth: AppDimensions.maxContentWidth,
        child: cbeRatesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: NetworkErrorDisplay(
              message: l10n.networkError,
              onRetry: () => ref.invalidate(centralBankRatesProvider),
            ),
          ),
          data: (points) {
            final centralBankRatesByCurrency = {
              for (final p in points) p.quoteCurrencyCode ?? p.quote: p,
            };
            final centralBankPublishDate =
                points.isEmpty ? null : points.first.date;

            double? getMarketRate(String currencyCode) {
              if (snapshot == null) return null;
              return snapshot.rates.getRate(currencyCode);
            }

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          '1 USD =',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            l10n.officialRate,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.hGapMd,
                      Expanded(
                        flex: 4,
                        child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            l10n.marketRate,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: AppSizes.dividerThin),
                for (final currencyCode in _trackedCurrencyCodes)
                  _buildCurrencyRateRow(
                    theme,
                    currencyCode: currencyCode,
                    officialRate:
                        centralBankRatesByCurrency[currencyCode]?.valuePerUnit,
                    marketRate: getMarketRate(currencyCode),
                  ),
                AppSpacing.vGapLg,
                if (centralBankPublishDate != null)
                  Center(
                    child: Text(
                      '${l10n.updatedDate}: ${formatDate(centralBankPublishDate)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrencyRateRow(
    ThemeData theme, {
    required String currencyCode,
    double? officialRate,
    double? marketRate,
  }) {
    String formatRateValue(double? rate) =>
        rate == null ? '—' : rate.toStringAsFixed(rate > 100 ? 2 : 4);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                currencyCode,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatRateValue(officialRate),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            AppSpacing.hGapMd,
            Expanded(
              flex: 4,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatRateValue(marketRate),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
