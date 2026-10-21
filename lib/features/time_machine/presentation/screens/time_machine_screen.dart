import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants.dart';
import '../../../../core/l10n.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils.dart';
import '../../../../core/widgets/loading_chart_placeholder.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../charts/presentation/widgets/history_chart.dart';
import '../../../prices/presentation/controllers/prices_controller.dart';
import '../../../settings/presentation/controllers/default_currency_controller.dart';
import '../../../settings/presentation/controllers/locale_controller.dart';
import '../../domain/usecases/calculate_investment_return_use_case.dart';

/// "What if I had bought N grams in year X?" — compares historical price
/// with today's live price with responsive layout and dynamic numeric scaling.
class TimeMachineScreen extends ConsumerStatefulWidget {
  const TimeMachineScreen({super.key});

  @override
  ConsumerState<TimeMachineScreen> createState() => _TimeMachineScreenState();
}

class _TimeMachineScreenState extends ConsumerState<TimeMachineScreen> {
  static const _earliestSupportedYear = 2015;
  int _selectedYear = DateTime.now().year - 5;
  final _gramWeightController = TextEditingController(text: '10');

  final _investmentUseCase = const CalculateInvestmentReturnUseCase();

  @override
  void dispose() {
    _gramWeightController.dispose();
    super.dispose();
  }

  int get selectedYearLabel => _selectedYear;

  @override
  Widget build(BuildContext context) {
    final languageCode = ref.watch(localeProvider);
    final l10n = AppLocalizations(languageCode);
    final theme = Theme.of(context);
    final quoteCurrencyCode = ref.watch(preferredQuoteCurrencyProvider);
    final snapshot = ref.watch(marketPricesProvider).snapshot;

    // First trading day of the selected year.
    final query = DateRangeHistoryQuery(
      symbol: AppConstants.goldSymbol,
      quote: quoteCurrencyCode,
      from: DateTime(_selectedYear, 1, 1),
      to: DateTime(_selectedYear, 1, 10),
    );
    final historicalAsync = ref.watch(dateRangePriceHistoryProvider(query));

    final currentPerGram21K = snapshot?.rates.convertFromUsd(
      snapshot.gold.pricePerGram * 0.875, // 21K like Egyptian market
      quoteCurrencyCode,
    );
    final weightGrams =
        double.tryParse(_gramWeightController.text) ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.timeMachineTitle)),
      body: ResponsiveCenter(
        maxContentWidth: AppDimensions.maxContentWidth,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 350;
                final yearDropdown = DropdownButtonFormField<int>(
                  initialValue: _selectedYear,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.selectYear,
                  ),
                  items: [
                    for (var year = DateTime.now().year - 1;
                        year >= _earliestSupportedYear;
                        year--)
                      DropdownMenuItem(value: year, child: Text('$year')),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedYear = value!),
                );

                final weightField = TextField(
                  controller: _gramWeightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.weightGrams,
                    suffixText: '21K',
                  ),
                  onChanged: (_) => setState(() {}),
                );

                if (isCompact) {
                  return Column(
                    children: [
                      yearDropdown,
                      AppSpacing.vGapSm,
                      weightField,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: yearDropdown),
                    AppSpacing.hGapSm,
                    Expanded(child: weightField),
                  ],
                );
              },
            ),
            AppSpacing.vGapLg,
            historicalAsync.when(
              loading: () => const LoadingChartPlaceholder(height: AppSizes.chartLoadingHeight),
              error: (e, _) => Text(
                l10n.networkError,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              data: (points) {
                if (points.isEmpty) {
                  return const SizedBox(
                    height: AppSizes.chartPlaceholderHeight,
                    child: Center(child: Text('—')),
                  );
                }

                // Value per gram for gold historical points
                final rawHistoricalGramPrice = points.first.valuePerGram;
                final historicalGramPrice21K = snapshot == null
                    ? rawHistoricalGramPrice
                    : rawHistoricalGramPrice * 0.875;

                final investmentReturn = _investmentUseCase.execute(
                  historicalPricePerGram: historicalGramPrice21K,
                  currentPricePerGram: currentPerGram21K ?? 0.0,
                  weightGrams: weightGrams,
                  selectedYear: _selectedYear,
                  quoteCurrencyCode: quoteCurrencyCode,
                );

                return Card(
                  elevation: 0,
                  child: Padding(
                    padding: AppSpacing.cardPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.since} $selectedYearLabel ($quoteCurrencyCode)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: AppSizes.dividerHeight),
                        _buildComparisonRow(
                          l10n.historicalPrice,
                          formatMoney(
                            investmentReturn.historicalTotalCost,
                            quoteCurrencyCode,
                          ),
                          theme,
                        ),
                        _buildComparisonRow(
                          l10n.currentPrice,
                          formatMoney(
                            investmentReturn.currentPortfolioValue,
                            quoteCurrencyCode,
                          ),
                          theme,
                        ),
                        const Divider(height: AppSizes.dividerHeight),
                        _buildComparisonRow(
                          l10n.change,
                          investmentReturn.growthMultiplier > 0
                              ? '${investmentReturn.formattedMultiplier} (${investmentReturn.formattedPercentageGain})'
                              : '—',
                          theme,
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    String value,
    ThemeData theme, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppSpacing.hGapSm,
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                  color: bold ? theme.colorScheme.primary : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
