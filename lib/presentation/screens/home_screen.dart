import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../controllers/locale_controller.dart';
import '../controllers/prices_controller.dart';
import '../widgets/fx_rates_bar.dart';
import '../widgets/metal_price_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppL10n(ref.watch(localeProvider));
    final state = ref.watch(pricesProvider);
    final snapshot = state.snapshot;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(pricesProvider.notifier).refresh(),
        child: snapshot == null
            ? const _LoadingView()
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        state.error!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  FxRatesBar(rates: snapshot.rates, theme: theme, l10n: l),
                  const SizedBox(height: 12),
                  MetalPriceCard(
                    metal: snapshot.gold,
                    rates: snapshot.rates,
                    theme: theme,
                    l10n: l,
                    showKarats: true,
                  ),
                  const SizedBox(height: 12),
                  MetalPriceCard(
                    metal: snapshot.silver,
                    rates: snapshot.rates,
                    theme: theme,
                    l10n: l,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      '${l.t('updated')} ${_timeAgo(snapshot.fetchedAt, l)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _timeAgo(DateTime t, AppL10n l) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return l.t('just_now');
    if (d.inMinutes < 60) return '${d.inMinutes}${l.t('minutes_ago')}';
    if (d.inHours < 24) return '${d.inHours}${l.t('hours_ago')}';
    return '${d.inDays}${l.t('days_ago')}';
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 200),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
