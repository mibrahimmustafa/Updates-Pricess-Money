import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../controllers/locale_controller.dart';
import 'chart_screen.dart';
import 'converter_screen.dart';
import 'home_screen.dart';

/// Bottom navigation shell holding the three tabs.
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

    final titles = [l.t('tab_prices'), l.t('tab_converter'), l.t('tab_chart')];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('title')),
        actions: [
          IconButton(
            tooltip: 'EN / AR',
            onPressed: () => ref.read(localeProvider.notifier).toggle(),
            icon: const Icon(Icons.translate),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          ConverterScreen(),
          ChartScreen(),
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
            icon: const Icon(Icons.calculate),
            label: titles[1],
          ),
          NavigationDestination(
            icon: const Icon(Icons.show_chart),
            label: titles[2],
          ),
        ],
      ),
    );
  }
}
