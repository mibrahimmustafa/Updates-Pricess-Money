import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants.dart';
import '../../../../core/l10n.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/loading_chart_placeholder.dart';
import '../../../../core/widgets/network_error_display.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../settings/presentation/controllers/locale_controller.dart';
import '../../../settings/presentation/controllers/user_prefs_controller.dart';
import '../widgets/history_chart.dart';

/// Interactive historical price chart screen with responsive layout and dynamic height.
class ChartScreen extends ConsumerStatefulWidget {
  const ChartScreen({super.key});

  @override
  ConsumerState<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends ConsumerState<ChartScreen> {
  String _selectedMetalCode = AppConstants.goldSymbol;
  String _selectedQuoteCurrencyCode = AppConstants.egp;
  int _selectedPeriodDays = 30;

  @override
  Widget build(BuildContext context) {
    final languageCode = ref.watch(localeProvider);
    final l10n = AppLocalizations(languageCode);
    final theme = Theme.of(context);
    final preferences = ref.watch(userPreferencesProvider);

    final availableMetalCodes = preferences.orderedMetalCodes;
    final availableCurrencyCodes = preferences.orderedCurrencyCodes;
    if (!availableMetalCodes.contains(_selectedMetalCode) &&
        availableMetalCodes.isNotEmpty) {
      _selectedMetalCode = availableMetalCodes.first;
    }
    if (!availableCurrencyCodes.contains(_selectedQuoteCurrencyCode) &&
        availableCurrencyCodes.isNotEmpty) {
      _selectedQuoteCurrencyCode = availableCurrencyCodes.first;
    }

    final query = PeriodHistoryQuery(
      symbol: _selectedMetalCode,
      quote: _selectedQuoteCurrencyCode,
      days: _selectedPeriodDays,
    );
    final historyAsync = ref.watch(periodPriceHistoryProvider(query));

    // Dynamic responsive chart height based on screen height
    final screenHeight = MediaQuery.sizeOf(context).height;
    final responsiveChartHeight = (screenHeight * 0.34).clamp(220.0, 380.0);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabChart)),
      body: ResponsiveCenter(
        maxContentWidth: AppDimensions.maxContentWidth,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 350;
                final metalDropdown = DropdownButtonFormField<String>(
                  initialValue: _selectedMetalCode,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.metal,
                  ),
                  items: [
                    for (final metal in availableMetalCodes)
                      DropdownMenuItem(
                        value: metal,
                        child: Text(
                          AppConstants.metalPool[metal] ?? metal,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedMetalCode = value!),
                );

                final currencyDropdown = DropdownButtonFormField<String>(
                  initialValue: _selectedQuoteCurrencyCode,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.currency,
                  ),
                  items: [
                    for (final currency in availableCurrencyCodes)
                      DropdownMenuItem(
                        value: currency,
                        child: Text(
                          '${AppConstants.currencyFlag(currency)} $currency',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedQuoteCurrencyCode = value!),
                );

                if (isCompact) {
                  return Column(
                    children: [
                      metalDropdown,
                      AppSpacing.vGapSm,
                      currencyDropdown,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: metalDropdown),
                    AppSpacing.hGapSm,
                    Expanded(child: currencyDropdown),
                  ],
                );
              },
            ),
            AppSpacing.vGapMd,
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                segments: [
                  ButtonSegment(
                    value: 7,
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(l10n.range7d),
                    ),
                  ),
                  ButtonSegment(
                    value: 30,
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(l10n.range30d),
                    ),
                  ),
                  ButtonSegment(
                    value: 90,
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(l10n.range90d),
                    ),
                  ),
                ],
                selected: {_selectedPeriodDays},
                onSelectionChanged: (selection) =>
                    setState(() => _selectedPeriodDays = selection.first),
              ),
            ),
            AppSpacing.vGapLg,
            Card(
              elevation: 0,
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: historyAsync.when(
                  loading: () =>
                      LoadingChartPlaceholder(height: responsiveChartHeight),
                  error: (error, _) => SizedBox(
                    height: responsiveChartHeight,
                    child: NetworkErrorDisplay(
                      message: l10n.networkError,
                      onRetry: () =>
                          ref.invalidate(periodPriceHistoryProvider(query)),
                    ),
                  ),
                  data: (dataPoints) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedMetalCode == AppConstants.goldSymbol ? l10n.gold : l10n.silver} '
                        '— ${l10n.pricePerGram} ($_selectedQuoteCurrencyCode)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.vGapMd,
                      HistoryChart(
                        points: dataPoints,
                        quote: _selectedQuoteCurrencyCode,
                        height: responsiveChartHeight,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
