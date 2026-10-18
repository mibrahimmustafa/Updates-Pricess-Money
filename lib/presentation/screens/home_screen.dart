import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../controllers/locale_controller.dart';
import '../controllers/prices_controller.dart';
import '../controllers/user_prefs_controller.dart';
import '../widgets/fx_rates_bar.dart';
import '../widgets/metal_price_card.dart';
import '../widgets/price_card_skeleton.dart';

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
        color: theme.colorScheme.primary,
        onRefresh: () => ref.read(pricesProvider.notifier).refresh(),
        child: _buildBody(context, ref, l, theme, state, snapshot),
      ),
    );
  }

    Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AppL10n l,
    ThemeData theme,
    PricesState state,
    dynamic snapshot,
  ) {
    final prefs = ref.watch(userPrefsProvider);
    // First launch without cache: skeleton placeholders instead of a spinner.
    if (snapshot == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [const PriceCardSkeleton(), const SizedBox(height: 12), const PriceCardSkeleton()],
      );
    }

    final visible =
        prefs.metalList.where(snapshot.metals.containsKey).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _Header(
          state: state,
          l: l,
          theme: theme,
          onRetry: () => ref.read(pricesProvider.notifier).refresh(),
        ),
        const SizedBox(height: 12),
        FxRatesBar(
          rates: snapshot.rates,
          theme: theme,
          l10n: l,
          currencies: prefs.currencyList,
        ),
        const SizedBox(height: 12),
        for (final symbol in visible) ...[
          MetalPriceCard(
            metal: snapshot.metals[symbol]!,
            rates: snapshot.rates,
            theme: theme,
            l10n: l,
            showKarats: symbol == AppConstants.goldSymbol,
            currencies: prefs.currencyList,
          ),
          const SizedBox(height: 12),
        ],
        Center(
          child: Text(
            '${l.t('updated')} ${_timeAgo(snapshot.fetchedAt, l)}',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
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

/// Top area: LIVE badge + error banner with retry.
class _Header extends StatelessWidget {
  const _Header({
    required this.state,
    required this.l,
    required this.theme,
    required this.onRetry,
  });

  final PricesState state;
  final AppL10n l;
  final ThemeData theme;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LiveBadge(state: state, l: l),
          ],
        ),
        if (state.error != null) ...[
          const SizedBox(height: 10),
          Card(
            color: theme.colorScheme.error.withValues(alpha: 0.12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                children: [
                  Icon(Icons.cloud_off, color: theme.colorScheme.error, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(state.error!,
                        style: TextStyle(color: theme.colorScheme.error)),
                  ),
                  TextButton(
                    onPressed: onRetry,
                    child: Text(l.t('retry')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.state, required this.l});

  final PricesState state;
  final AppL10n l;

  @override
  Widget build(BuildContext context) {
    final live = state.error == null;
    final color = live ? const Color(0xFF66BB6A) : Colors.orangeAccent;
    final latency = state.latencyMs;
    final latencyColor = latency == null
        ? color
        : latency < 700
            ? const Color(0xFF66BB6A)
            : latency < 1600
                ? const Color(0xFFFFB74D)
                : const Color(0xFFE57373);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            live ? l.t('live') : '—',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: color,
            ),
          ),
          if (live && latency != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: latencyColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              // Forced LTR: "234 ms" never scrambles inside RTL text.
              child: Text.rich(
                TextSpan(
                  text: '$latency ms',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: latencyColor,
                  ),
                ),
                textDirection: TextDirection.ltr,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

