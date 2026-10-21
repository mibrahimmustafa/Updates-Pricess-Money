import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants.dart';
import '../../../../core/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../settings/presentation/controllers/locale_controller.dart';
import '../../../settings/presentation/controllers/user_prefs_controller.dart';
import '../../data/repositories/price_repository.dart';
import '../controllers/prices_controller.dart';
import '../widgets/fx_rates_bar.dart';
import '../widgets/metal_price_card.dart';
import '../widgets/price_card_skeleton.dart';

/// Main market prices overview screen (Gold, Silver, Platinum, FX rates).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations(ref.watch(localeProvider));
    final pricesState = ref.watch(marketPricesProvider);
    final snapshot = pricesState.snapshot ?? MarketSnapshot.initialSeed;

    return Scaffold(
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () => ref.read(marketPricesProvider.notifier).refresh(),
        child: ResponsiveCenter(
          maxContentWidth: AppDimensions.maxContentWidth,
          child: _HomeBody(
            pricesState: pricesState,
            snapshot: snapshot,
            l10n: l10n,
            theme: theme,
          ),
        ),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({
    required this.pricesState,
    required this.snapshot,
    required this.l10n,
    required this.theme,
  });

  final MarketPricesState pricesState;
  final MarketSnapshot? snapshot;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(userPreferencesProvider);

    // Initial loading without cache: display skeleton cards
    if (snapshot == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          PriceCardSkeleton(),
          AppSpacing.vGapMd,
          PriceCardSkeleton(),
        ],
      );
    }

    final activeSnapshot = snapshot!;
    final visibleSymbols = preferences.orderedMetalCodes
        .where(activeSnapshot.metals.containsKey)
        .toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        _Header(
          pricesState: pricesState,
          l10n: l10n,
          onRetry: () => ref.read(marketPricesProvider.notifier).refresh(),
        ),
        AppSpacing.vGapMd,
        FxRatesBar(
          rates: activeSnapshot.rates,
          theme: theme,
          l10n: l10n,
          currencies: preferences.orderedCurrencyCodes,
        ),
        AppSpacing.vGapMd,
        for (final symbol in visibleSymbols) ...[
          MetalPriceCard(
            metal: activeSnapshot.metals[symbol]!,
            rates: activeSnapshot.rates,
            theme: theme,
            l10n: l10n,
            showKarats: symbol == AppConstants.goldSymbol,
            currencies: preferences.orderedCurrencyCodes,
          ),
          AppSpacing.vGapMd,
        ],
        Center(
          child: Text(
            '${l10n.updatedLabel} ${formatRelativeTime(activeSnapshot.snapshotTimestamp, l10n)}',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

/// Header section with LIVE status badge and optional error notification banner.
class _Header extends StatelessWidget {
  const _Header({
    required this.pricesState,
    required this.l10n,
    required this.onRetry,
  });

  final MarketPricesState pricesState;
  final AppLocalizations l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LiveStatusBadge(pricesState: pricesState, l10n: l10n),
          ],
        ),
        if (pricesState.error != null) ...[
          AppSpacing.vGap10,
          _ErrorBanner(
            errorMessage: pricesState.error!,
            retryLabel: l10n.retryLabel,
            onRetry: onRetry,
          ),
        ],
      ],
    );
  }
}

/// Polished error banner notifying user of network/server degradation with a retry CTA.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.errorMessage,
    required this.retryLabel,
    required this.onRetry,
  });

  final String errorMessage;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s14,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.12),
        borderRadius: AppRadius.inputBorderRadius,
        border: Border.all(color: errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: errorColor, size: AppSizes.iconMd),
          AppSpacing.hGap10,
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: errorColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: errorColor,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s10,
                vertical: AppSpacing.xs,
              ),
            ),
            child: Text(
              retryLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Status badge displaying live connection status.
class _LiveStatusBadge extends StatelessWidget {
  const _LiveStatusBadge({required this.pricesState, required this.l10n});

  final MarketPricesState pricesState;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isLive = pricesState.hasNoError;
    final statusColor = isLive ? AppColors.statusLive : AppColors.statusSlow;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s5,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.14),
        borderRadius: AppRadius.s20BorderRadius,
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.liveDotSize,
            height: AppSizes.liveDotSize,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: isLive
                  ? [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.65),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          AppSpacing.hGap6,
          Text(
            isLive ? l10n.liveLabel : '—',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
