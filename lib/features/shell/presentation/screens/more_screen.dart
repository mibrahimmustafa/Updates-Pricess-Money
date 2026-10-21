import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../alerts/presentation/screens/alerts_screen.dart';
import '../../../banks/presentation/screens/banks_screen.dart';
import '../../../charts/presentation/screens/chart_screen.dart';
import '../../../jewelry_calculator/presentation/screens/jewelry_calculator_screen.dart';
import '../../../settings/presentation/controllers/locale_controller.dart';
import '../../../time_machine/presentation/screens/time_machine_screen.dart';

typedef _MoreMenuItem = ({String iconKey, String title, Widget destination});

/// Overflow menu screen with secondary destinations.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(localeProvider);
    final l10n = AppLocalizations(languageCode);

    final List<_MoreMenuItem> menuItems = [
      (
        iconKey: 'show_chart',
        title: l10n.tabChart,
        destination: const ChartScreen(),
      ),
      (
        iconKey: 'notifications_active',
        title: l10n.alertsTitle,
        destination: const AlertsScreen(),
      ),
      (
        iconKey: 'diamond',
        title: l10n.calculatorTitle,
        destination: const JewelryCalculatorScreen(),
      ),
      (
        iconKey: 'history',
        title: l10n.timeMachineTitle,
        destination: const TimeMachineScreen(),
      ),
      (
        iconKey: 'account_balance',
        title: l10n.banksTitle,
        destination: const BanksScreen(),
      ),
    ];

    final theme = Theme.of(context);

    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(l10n.moreTitle)) : null,
      body: ResponsiveCenter(
        maxContentWidth: AppDimensions.maxContentWidth,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.smBorderRadius,
                      child: Image.asset(
                        'assets/icon/icon.png',
                        width: AppSizes.iconHero,
                        height: AppSizes.iconHero,
                        fit: BoxFit.cover,
                      ),
                    ),
                    AppSpacing.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                            ),
                          ),
                          AppSpacing.vGapXs,
                          Text(
                            l10n.tagline,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.s10BorderRadius,
                      ),
                      child: Text(
                        'v1.0.2',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (final item in menuItems) ...[
              Card(
                elevation: 0,
                child: ListTile(
                  leading: Icon(_resolveMenuIcon(item.iconKey)),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => item.destination),
                  ),
                ),
              ),
              AppSpacing.vGapSm,
            ],
          ],
        ),
      ),
    );
  }

  IconData _resolveMenuIcon(String iconKey) => switch (iconKey) {
        'show_chart' => Icons.show_chart,
        'notifications_active' => Icons.notifications_active,
        'diamond' => Icons.diamond_outlined,
        'history' => Icons.history,
        'account_balance' => Icons.account_balance,
        _ => Icons.settings,
      };
}
