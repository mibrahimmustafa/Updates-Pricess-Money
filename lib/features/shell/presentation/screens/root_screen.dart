import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../converter/presentation/screens/converter_screen.dart';
import '../../../jewelry_calculator/presentation/screens/jewelry_calculator_screen.dart';
import '../../../prices/presentation/screens/home_screen.dart';
import '../../../settings/presentation/controllers/locale_controller.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../widgets/app_bar_pills.dart';
import 'more_screen.dart';

/// Bottom navigation shell: Prices / Jewelry / Calculator / Settings / More.
/// Built with responsive layout constraints for both mobile and tablet displays.
class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key});

  @override
  ConsumerState<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<RootScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final languageCode = ref.watch(localeProvider);
    final l10n = AppLocalizations(languageCode);

    final tabTitles = [
      l10n.tabPrices,
      l10n.tabJewelry,
      l10n.tabConverter,
      l10n.settingsTitle,
      l10n.tabMore,
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedTabIndex == 0) ...[
              ClipRRect(
                borderRadius: AppRadius.smBorderRadius,
                child: Image.asset(
                  'assets/icon/icon.png',
                  width: AppSizes.appBarIconSize,
                  height: AppSizes.appBarIconSize,
                  fit: BoxFit.cover,
                ),
              ),
              AppSpacing.hGapSm,
              Flexible(
                child: Text(
                  l10n.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ] else
              Flexible(
                child: Text(
                  tabTitles[_selectedTabIndex],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
          ],
        ),
        actions: const [
          ThemeTogglePill(),
          AppSpacing.hGap6,
          LanguageTogglePill(),
          AppSpacing.hGapMd,
        ],
      ),
      body: ResponsiveCenter(
        maxContentWidth: AppDimensions.maxWideContentWidth,
        child: IndexedStack(
          index: _selectedTabIndex,
          children: const [
            HomeScreen(),
            JewelryCalculatorScreen(showAppBar: false),
            ConverterScreen(showAppBar: false),
            SettingsScreen(showAppBar: false),
            MoreScreen(showAppBar: false),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedTabIndex = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.attach_money),
            label: tabTitles[0],
          ),
          NavigationDestination(
            icon: const Icon(Icons.diamond_outlined),
            label: tabTitles[1],
          ),
          NavigationDestination(
            icon: const Icon(Icons.calculate),
            label: tabTitles[2],
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            label: tabTitles[3],
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu),
            label: tabTitles[4],
          ),
        ],
      ),
    );
  }
}
