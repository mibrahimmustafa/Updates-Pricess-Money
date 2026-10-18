import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../controllers/alerts_controller.dart';
import '../controllers/locale_controller.dart';
import '../controllers/prices_controller.dart';
import '../widgets/app_bar_pills.dart';
import 'converter_screen.dart';
import 'home_screen.dart';
import 'jewelry_calculator_screen.dart';
import 'more_screen.dart';
import 'settings_screen.dart';

/// Bottom navigation shell: Prices / Jewelry / Calculator / More.
/// Listens to every fresh snapshot and evaluates price alerts.
class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key});

  @override
  ConsumerState<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<RootScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final langCode = ref.watch(localeProvider);
    final l = AppL10n(langCode);

    // Alert evaluation on every snapshot update.
    ref.listen<PricesState>(pricesProvider, (prev, next) {
      final snap = next.snapshot;
      if (snap != null && prev?.snapshot != snap) {
        ref.read(alertsProvider.notifier).check(snap);
      }
    });

    final titles = [
      l.t('tab_prices'),
      l.t('tab_jewelry'),
      l.t('tab_converter'),
      l.t('settings_title'),
      l.t('tab_more'),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            if (_index == 0) ...[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Text(
                  'PM',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(l.t('title')),
            ] else
              Text(titles[_index]),
          ],
        ),
        actions: [
          ThemePill(),
          const SizedBox(width: 8),
          LangPill(),
          const SizedBox(width: 12),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          JewelryCalculatorScreen(showAppBar: false),
          ConverterScreen(showAppBar: false),
          SettingsScreen(showAppBar: false),
          MoreScreen(showAppBar: false),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.attach_money),
            label: titles[0],
          ),
          NavigationDestination(
            icon: const Icon(Icons.diamond_outlined),
            label: titles[1],
          ),
          NavigationDestination(
            icon: const Icon(Icons.calculate),
            label: titles[2],
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            label: titles[3],
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu),
            label: titles[4],
          ),
        ],
      ),
    );
  }
}
