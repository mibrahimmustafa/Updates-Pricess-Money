import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../controllers/locale_controller.dart';
import 'alerts_screen.dart';
import 'banks_screen.dart';
import 'chart_screen.dart';
import 'jewelry_calculator_screen.dart';
import 'time_machine_screen.dart';

/// Overflow menu screen with secondary destinations.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n(ref.watch(localeProvider));

    final items = [
      ('show_chart', l.t('tab_chart'), const ChartScreen()),
      ('notifications_active', l.t('alerts_title'), const AlertsScreen()),
      ('diamond', l.t('calc_title'), const JewelryCalculatorScreen()),
      ('history', l.t('timemachine_title'), const TimeMachineScreen()),
      ('account_balance', l.t('banks_title'), const BanksScreen()),
    ];

    return Scaffold(
      appBar: showAppBar
          ? AppBar(title: Text(l.t('more_title')))
          : null,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final (icon, label, screen) = items[i];
          return Card(
            child: ListTile(
              leading: Icon(_icon(icon)),
              title: Text(label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => screen),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _icon(String key) => switch (key) {
        'show_chart' => Icons.show_chart,
        'notifications_active' => Icons.notifications_active,
        'diamond' => Icons.diamond_outlined,
        'history' => Icons.history,
        'account_balance' => Icons.account_balance,
        _ => Icons.settings,
      };
}
