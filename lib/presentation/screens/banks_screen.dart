import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/utils.dart';
import '../controllers/locale_controller.dart';
import '../controllers/prices_controller.dart';

/// Official Central Bank of Egypt daily rates vs the market blend.
class BanksScreen extends ConsumerWidget {
  const BanksScreen({super.key});

  /// A friendly subset of the 19 CBE-published currencies.
  static const _shown = [
    'EGP', 'EUR', 'GBP', 'CHF', 'JPY', 'AED', 'SAR', 'KWD', 'QAR',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n(ref.watch(localeProvider));
    final theme = Theme.of(context);
    final snapshot = ref.watch(pricesProvider).snapshot;
    final cbe = ref.watch(cbeRatesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.t('banks_title'))),
      body: cbe.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(l.t('error_network'),
              style: TextStyle(color: theme.colorScheme.error)),
        ),
        data: (points) {
          final cbeMap = {for (final p in points) p.quote: p};
          final sourceDate = points.isEmpty ? null : points.first.date;
          double? market(String c) {
            if (snapshot == null) return null;
            return snapshot.rates.usdTo(c);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Text('1 USD =', style: theme.textTheme.bodySmall),
                  const Spacer(),
                  Text(l.t('official'),
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: theme.colorScheme.primary)),
                  const SizedBox(width: 16),
                  Text(l.t('market'),
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: theme.colorScheme.secondary)),
                ],
              ),
              const Divider(height: 20),
              for (final c in _shown)
                _rateRow(
                  theme,
                  currency: c,
                  official: cbeMap[c]?.perGram,
                  market: market(c),
                ),
              const SizedBox(height: 12),
              if (sourceDate != null)
                Center(
                  child: Text(
                    '${l.t('updated_date')}: ${formatDate(sourceDate)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _rateRow(ThemeData t,
      {required String currency, double? official, double? market}) {
    String fmt(double? v) =>
        v == null ? '—' : v.toStringAsFixed(v > 100 ? 2 : 4);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Text(currency,
                  style: t.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
            Text(fmt(official),
                style: t.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 24),
            SizedBox(
              width: 70,
              child: Text(fmt(market), textAlign: TextAlign.end),
            ),
          ],
        ),
      ),
    );
  }
}
