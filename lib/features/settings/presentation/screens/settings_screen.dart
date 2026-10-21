import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants.dart';
import '../../../../core/l10n.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../controllers/default_currency_controller.dart';
import '../controllers/locale_controller.dart';
import '../controllers/theme_mode_controller.dart';
import '../controllers/user_prefs_controller.dart';

/// Executive settings screen for locale, theme, default quote currency,
/// and visible asset pools.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _currencySearchController = TextEditingController();
  String _currencySearchQuery = '';

  @override
  void dispose() {
    _currencySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = ref.watch(localeProvider);
    final l10n = AppLocalizations(languageCode);
    final preferredCurrencyCode = ref.watch(preferredQuoteCurrencyProvider);
    final preferences = ref.watch(userPreferencesProvider);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final filteredCurrencyCodes = AppConstants.currencyCodes
        .where((code) =>
            _currencySearchQuery.isEmpty ||
            code.contains(_currencySearchQuery.toUpperCase()))
        .toList();

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: Text(l10n.settingsTitle))
          : null,
      body: ResponsiveCenter(
        maxContentWidth: AppDimensions.maxContentWidth,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // ─── Section 1: Appearance & Language ────────────────────────────
            Card(
              elevation: 0,
              child: Padding(
                padding: AppSpacing.cardPaddingCompact,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.language_rounded, size: AppSizes.iconLg, color: primaryColor),
                            AppSpacing.hGapSm,
                            Text(
                              l10n.language,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          borderRadius: AppRadius.s20BorderRadius,
                          onTap: () => ref.read(localeProvider.notifier).toggle(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.s6,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.14),
                              borderRadius: AppRadius.s20BorderRadius,
                              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              languageCode == 'ar' ? 'العربية' : 'English',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: AppSizes.dividerHeight),
                    Row(
                      children: [
                        Icon(Icons.palette_outlined, size: AppSizes.iconLg, color: primaryColor),
                        AppSpacing.hGapSm,
                        Text(
                          l10n.theme,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGap10,
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(l10n.themeSystem),
                            ),
                            icon: const Icon(Icons.brightness_auto, size: AppSizes.iconBase),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(l10n.themeLight),
                            ),
                            icon: const Icon(Icons.light_mode, size: AppSizes.iconBase),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(l10n.themeDark),
                            ),
                            icon: const Icon(Icons.dark_mode, size: AppSizes.iconBase),
                          ),
                        ],
                        selected: {ref.watch(themeModeProvider)},
                        onSelectionChanged: (selection) =>
                            ref.read(themeModeProvider.notifier).set(selection.first),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.vGapLg,

            // ─── Section 2: Default Quote Currency ───────────────────────────
            Card(
              elevation: 0,
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: AppSizes.iconBoxMd,
                          height: AppSizes.iconBoxMd,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.16),
                            borderRadius: AppRadius.s10BorderRadius,
                          ),
                          child: Icon(Icons.star_rounded, color: primaryColor, size: AppSizes.iconLg),
                        ),
                        AppSpacing.hGap10,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.defaultCurrency,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${AppConstants.currencyFlag(preferredCurrencyCode)} $preferredCurrencyCode · ${AppConstants.currencySymbol(preferredCurrencyCode)}',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGap14,

                    // Quick currency pills
                    Builder(
                      builder: (context) {
                        final textScale = AppDimensions.textScaleFactor(context);
                        final dynamicHeight =
                            (AppSizes.chipHeight * textScale).clamp(AppSizes.chipHeight, 68.0);
                        return SizedBox(
                          height: dynamicHeight,
                          child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: [
                          if (!preferences.orderedCurrencyCodes.contains(preferredCurrencyCode))
                            preferredCurrencyCode,
                          ...preferences.orderedCurrencyCodes,
                        ].length,
                        separatorBuilder: (_, _) => AppSpacing.hGapSm,
                        itemBuilder: (context, index) {
                          final selectable = [
                            if (!preferences.orderedCurrencyCodes.contains(preferredCurrencyCode))
                              preferredCurrencyCode,
                            ...preferences.orderedCurrencyCodes,
                          ];
                          final currency = selectable[index];
                          final isSelected = currency == preferredCurrencyCode;

                          return InkWell(
                            borderRadius: AppRadius.pillBorderRadius,
                            onTap: () => ref
                                .read(preferredQuoteCurrencyProvider.notifier)
                                .set(currency),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s14,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor.withValues(alpha: 0.18)
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: AppRadius.pillBorderRadius,
                                border: Border.all(
                                  color: isSelected
                                      ? primaryColor
                                      : theme.dividerColor.withValues(alpha: 0.4),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppConstants.currencyFlag(currency),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  AppSpacing.hGap6,
                                  Text(
                                    currency,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected ? primaryColor : null,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    AppSpacing.hGap6,
                                    Icon(Icons.check_circle_rounded, size: AppSizes.iconSm, color: primaryColor),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
                ),
              ),
            ),
            AppSpacing.vGapLg,

            // ─── Section 3: Currencies Shown ─────────────────────────────────
            Card(
              elevation: 0,
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.chooseCurrencies,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.s3,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.14),
                            borderRadius: AppRadius.smBorderRadius,
                          ),
                          child: Text(
                            '${preferences.enabledCurrencyCodes.length} / ${AppConstants.currencyCodes.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGapMd,

                    TextField(
                      controller: _currencySearchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, size: AppSizes.iconLg),
                        hintText: 'Search (e.g. SAR, EUR, AED)...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s14,
                          vertical: AppSpacing.s10,
                        ),
                        suffixIcon: _currencySearchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: AppSizes.iconBase),
                                onPressed: () {
                                  _currencySearchController.clear();
                                  setState(() => _currencySearchQuery = '');
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) =>
                          setState(() => _currencySearchQuery = value.trim()),
                    ),
                    AppSpacing.vGapMd,

                    // Regional preset buttons
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPresetChip(
                            l10n.presetGcc,
                            () => ref.read(userPreferencesProvider.notifier).selectGroup(AppConstants.gccCurrencies),
                          ),
                          AppSpacing.hGap6,
                          _buildPresetChip(
                            l10n.presetMena,
                            () => ref.read(userPreferencesProvider.notifier).selectGroup(AppConstants.menaCurrencies),
                          ),
                          AppSpacing.hGap6,
                          _buildPresetChip(
                            l10n.presetDefault,
                            () => ref.read(userPreferencesProvider.notifier).resetCurrencies(),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.vGap14,

                    // Filter chips
                    Wrap(
                      spacing: AppSpacing.s6,
                      runSpacing: AppSpacing.s6,
                      children: [
                        for (final code in filteredCurrencyCodes)
                          FilterChip(
                            label: Text(
                              '${AppConstants.currencyFlag(code)} $code · ${AppConstants.currencySymbol(code)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: preferences.enabledCurrencyCodes.contains(code),
                            onSelected: (_) => ref
                                .read(userPreferencesProvider.notifier)
                                .toggleCurrency(code),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.vGapLg,

            // ─── Section 4: Assets Shown ─────────────────────────────────────
            Card(
              elevation: 0,
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.chooseAssets,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          borderRadius: AppRadius.s6BorderRadius,
                          onTap: () => ref.read(userPreferencesProvider.notifier).resetMetals(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s6,
                              vertical: AppSpacing.xs,
                            ),
                            child: Text(
                              l10n.presetDefault,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGap10,
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final metal in AppConstants.metalPool.entries)
                          FilterChip(
                            label: Text(metal.value),
                            selected: preferences.enabledMetalCodes.contains(metal.key),
                            onSelected: (_) => ref
                                .read(userPreferencesProvider.notifier)
                                .toggleMetal(metal.key),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: AppRadius.smBorderRadius,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.s6,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppRadius.smBorderRadius,
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
