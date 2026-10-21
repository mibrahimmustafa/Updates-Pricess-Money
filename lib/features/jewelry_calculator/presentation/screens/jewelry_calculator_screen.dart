import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants.dart';
import '../../../../core/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../prices/presentation/controllers/prices_controller.dart';
import '../../../settings/presentation/controllers/default_currency_controller.dart';
import '../../../settings/presentation/controllers/locale_controller.dart';
import '../../domain/usecases/calculate_jewelry_cost_use_case.dart';

/// Jewellery purchase calculator: metal + manufacturing fees + VAT,
/// minus credit for exchanged old-gold (scrap / trade-in).
/// Features quick-increment weight chips, segmented karat selectors, and an executive trade-in card.
class JewelryCalculatorScreen extends ConsumerStatefulWidget {
  const JewelryCalculatorScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  ConsumerState<JewelryCalculatorScreen> createState() =>
      _JewelryCalculatorScreenState();
}

class _JewelryCalculatorScreenState
    extends ConsumerState<JewelryCalculatorScreen> {
  final _newGoldWeightController = TextEditingController(text: '10');
  final _manufacturingFeeController = TextEditingController(text: '60');

  double _selectedKaratPurity = 0.875; // 21K default

  // Old gold to exchange (scrap / trade-in)
  bool _hasTradeIn = false;
  final _tradeInGoldWeightController = TextEditingController(text: '5');
  double _tradeInKaratPurity = 0.875;
  bool _includeVat = true;

  final _calculatorUseCase = const CalculateJewelryCostUseCase();

  @override
  void dispose() {
    _newGoldWeightController.dispose();
    _manufacturingFeeController.dispose();
    _tradeInGoldWeightController.dispose();
    super.dispose();
  }

  void _addWeight(double grams) {
    final current = double.tryParse(_newGoldWeightController.text) ?? 0.0;
    final next = (current + grams).clamp(0.0, 9999.0);
    setState(() {
      _newGoldWeightController.text = next == next.roundToDouble()
          ? next.toInt().toString()
          : next.toStringAsFixed(1);
    });
  }

  void _setWeight(double grams) {
    setState(() {
      _newGoldWeightController.text = grams == grams.roundToDouble()
          ? grams.toInt().toString()
          : grams.toStringAsFixed(1);
    });
  }

  void _addTradeInWeight(double grams) {
    final current = double.tryParse(_tradeInGoldWeightController.text) ?? 0.0;
    final next = (current + grams).clamp(0.0, 9999.0);
    setState(() {
      _tradeInGoldWeightController.text = next == next.roundToDouble()
          ? next.toInt().toString()
          : next.toStringAsFixed(1);
    });
  }

  void _setTradeInWeight(double grams) {
    setState(() {
      _tradeInGoldWeightController.text = grams == grams.roundToDouble()
          ? grams.toInt().toString()
          : grams.toStringAsFixed(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = ref.watch(localeProvider);
    final l10n = AppLocalizations(languageCode);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final quoteCurrencyCode = ref.watch(preferredQuoteCurrencyProvider);
    final snapshot = ref.watch(marketPricesProvider).snapshot;

    if (snapshot == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.calculatorTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final gold = snapshot.gold;
    final rates = snapshot.rates;
    final pureGramPriceInQuote =
        rates.convertFromUsd(gold.pricePerGram, quoteCurrencyCode);

    final newGoldWeight = double.tryParse(_newGoldWeightController.text) ?? 0.0;
    final feePerGram = double.tryParse(_manufacturingFeeController.text) ?? 0.0;
    final tradeInWeight = _hasTradeIn
        ? (double.tryParse(_tradeInGoldWeightController.text) ?? 0.0)
        : 0.0;

    final breakdown = _calculatorUseCase.execute(
      newWeightGrams: newGoldWeight,
      karatPurityFactor: _selectedKaratPurity,
      pureGramPriceInQuoteCurrency: pureGramPriceInQuote,
      manufacturingFeePerGram: feePerGram,
      vatRate: AppConstants.vatRate,
      includeVat: _includeVat,
      tradeInWeightGrams: tradeInWeight,
      tradeInKaratPurityFactor: _tradeInKaratPurity,
      quoteCurrencyCode: quoteCurrencyCode,
    );

    final total = breakdown.grossTotalCost;
    final metalFraction = total > 0 ? (breakdown.metalMaterialCost / total).clamp(0.0, 1.0) : 0.7;
    final mfgFraction = total > 0 ? (breakdown.totalManufacturingFee / total).clamp(0.0, 1.0) : 0.2;
    final vatFraction = total > 0 ? (breakdown.vatAmount / total).clamp(0.0, 1.0) : 0.1;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: Text(l10n.calculatorTitle))
          : null,
      body: ResponsiveCenter(
        maxContentWidth: AppDimensions.maxContentWidth,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          children: [
            // ─── Weight Input & Quick Chips ──────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 350;
                final weightField = TextField(
                  controller: _newGoldWeightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.weightGrams,
                    suffixText: 'g',
                    prefixIcon: const Icon(Icons.scale_rounded, size: AppSizes.iconLg),
                  ),
                  onChanged: (_) => setState(() {}),
                );

                final karatDropdown = DropdownButtonFormField<double>(
                  initialValue: _selectedKaratPurity,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.karat,
                  ),
                  items: AppConstants.karats.entries
                      .map((e) => DropdownMenuItem(
                            value: e.value,
                            child: Text(e.key),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedKaratPurity = v!),
                );

                if (isCompact) {
                  return Column(
                    children: [
                      weightField,
                      AppSpacing.vGapSm,
                      karatDropdown,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(flex: 3, child: weightField),
                    AppSpacing.hGapSm,
                    Expanded(flex: 2, child: karatDropdown),
                  ],
                );
              },
            ),
            AppSpacing.vGapSm,

            // Quick increment chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickWeightChip('+1g', () => _addWeight(1)),
                  _buildQuickWeightChip('+5g', () => _addWeight(5)),
                  _buildQuickWeightChip('+10g', () => _addWeight(10)),
                  _buildQuickWeightChip('+50g', () => _addWeight(50)),
                  _buildQuickWeightChip('10g', () => _setWeight(10), isPreset: true),
                  _buildQuickWeightChip('20g', () => _setWeight(20), isPreset: true),
                  _buildQuickWeightChip('Clear', () => _setWeight(0), isReset: true),
                ],
              ),
            ),
            AppSpacing.vGap14,

            // ─── Manufacturing Fee & VAT ─────────────────────────────────────
            TextField(
              controller: _manufacturingFeeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.manufacturingFeePerGram,
                suffixText: quoteCurrencyCode,
                prefixIcon: const Icon(Icons.handyman_outlined, size: AppSizes.iconLg),
              ),
              onChanged: (_) => setState(() {}),
            ),
            AppSpacing.vGap10,

            Material(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.inputBorderRadius,
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s14),
                title: Text(
                  l10n.vatLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                value: _includeVat,
                onChanged: (v) => setState(() => _includeVat = v),
              ),
            ),
            AppSpacing.vGap14,

            // ─── Executive Trade-in (Old Gold / Scrap) Card ───────────────────
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.fabBorderRadius,
                side: BorderSide(
                  color: _hasTradeIn
                      ? AppColors.gold.withValues(alpha: 0.45)
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: _hasTradeIn ? 1.5 : 1.0,
                ),
              ),
              child: Padding(
                padding: AppSpacing.cardPaddingCompact,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with toggle
                    Row(
                      children: [
                        Container(
                          width: AppSizes.iconBoxMd,
                          height: AppSizes.iconBoxMd,
                          decoration: BoxDecoration(
                            color: (_hasTradeIn ? AppColors.trendUp : theme.colorScheme.secondary)
                                .withValues(alpha: 0.16),
                            borderRadius: AppRadius.s10BorderRadius,
                          ),
                          child: Icon(
                            Icons.swap_horizontal_circle_outlined,
                            color: _hasTradeIn ? AppColors.trendUp : theme.colorScheme.secondary,
                            size: AppSizes.iconLg,
                          ),
                        ),
                        AppSpacing.hGap10,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.oldGoldSection,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (_hasTradeIn && breakdown.tradeInCreditAmount > 0)
                                Text(
                                  'Credit: -${formatMoney(breakdown.tradeInCreditAmount, quoteCurrencyCode)}',
                                  style: const TextStyle(
                                    color: AppColors.trendUp,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _hasTradeIn,
                          onChanged: (val) {
                            setState(() {
                              _hasTradeIn = val;
                              if (val && (double.tryParse(_tradeInGoldWeightController.text) ?? 0) <= 0) {
                                _tradeInGoldWeightController.text = '5';
                              }
                            });
                          },
                        ),
                      ],
                    ),

                    // Expandable trade-in input controls
                    if (_hasTradeIn) ...[
                      const Divider(height: AppSpacing.xl),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 350;
                          final tradeInWeightField = TextField(
                            controller: _tradeInGoldWeightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: l10n.oldGoldWeight,
                              suffixText: 'g',
                              prefixIcon: const Icon(Icons.scale_outlined, size: AppSizes.iconLg),
                            ),
                            onChanged: (_) => setState(() {}),
                          );

                          final tradeInKaratDropdown = DropdownButtonFormField<double>(
                            initialValue: _tradeInKaratPurity,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l10n.oldGoldKarat,
                            ),
                            items: AppConstants.karats.entries
                                .map((e) => DropdownMenuItem(
                                      value: e.value,
                                      child: Text(e.key),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _tradeInKaratPurity = v!),
                          );

                          if (isCompact) {
                            return Column(
                              children: [
                                tradeInWeightField,
                                AppSpacing.vGapSm,
                                tradeInKaratDropdown,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(flex: 3, child: tradeInWeightField),
                              AppSpacing.hGapSm,
                              Expanded(flex: 2, child: tradeInKaratDropdown),
                            ],
                          );
                        },
                      ),
                      AppSpacing.vGapSm,

                      // Quick increment chips for trade-in weight
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildQuickWeightChip('+1g', () => _addTradeInWeight(1)),
                            _buildQuickWeightChip('+5g', () => _addTradeInWeight(5)),
                            _buildQuickWeightChip('+10g', () => _addTradeInWeight(10)),
                            _buildQuickWeightChip('5g', () => _setTradeInWeight(5), isPreset: true),
                            _buildQuickWeightChip('10g', () => _setTradeInWeight(10), isPreset: true),
                            _buildQuickWeightChip('20g', () => _setTradeInWeight(20), isPreset: true),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            AppSpacing.vGapLg,

            // ─── Executive Invoice Breakdown Card ────────────────────────────
            Card(
              elevation: 0,
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Visual cost proportions bar
                    if (total > 0) ...[
                      ClipRRect(
                        borderRadius: AppRadius.s6BorderRadius,
                        child: SizedBox(
                          height: AppSizes.sliderThumbHeight,
                          child: Row(
                            children: [
                              Expanded(
                                flex: (metalFraction * 100).toInt().clamp(1, 100),
                                child: Container(color: AppColors.gold),
                              ),
                              Expanded(
                                flex: (mfgFraction * 100).toInt().clamp(1, 100),
                                child: Container(color: AppColors.goldDeep),
                              ),
                              if (_includeVat)
                                Expanded(
                                  flex: (vatFraction * 100).toInt().clamp(1, 100),
                                  child: Container(color: theme.colorScheme.secondary),
                                ),
                            ],
                          ),
                        ),
                      ),
                      AppSpacing.vGap14,
                    ],

                    _buildSummaryRow(
                      l10n.metalValue,
                      formatMoney(breakdown.metalMaterialCost, quoteCurrencyCode),
                      theme,
                    ),
                    _buildSummaryRow(
                      l10n.manufacturingTotal,
                      formatMoney(breakdown.totalManufacturingFee, quoteCurrencyCode),
                      theme,
                    ),
                    if (AppConstants.vatRate > 0 && _includeVat)
                      _buildSummaryRow(
                        l10n.vatTotal,
                        formatMoney(breakdown.vatAmount, quoteCurrencyCode),
                        theme,
                      ),
                    const Divider(height: AppSizes.dividerHeight),

                    _buildSummaryRow(
                      l10n.totalCost,
                      formatMoney(breakdown.grossTotalCost, quoteCurrencyCode),
                      theme,
                      bold: true,
                    ),

                    if (breakdown.tradeInCreditAmount > 0) ...[
                      const Divider(height: AppSizes.dividerHeight),
                      _buildSummaryRow(
                        l10n.oldGoldCredit,
                        '- ${formatMoney(breakdown.tradeInCreditAmount, quoteCurrencyCode)}',
                        theme,
                        textColor: AppColors.trendUp,
                      ),
                      AppSpacing.vGapSm,

                      // Highlighted Net Payable Container
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s14,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.14),
                          borderRadius: AppRadius.mdBorderRadius,
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.netPayable,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              formatMoney(breakdown.netPayableAmount, quoteCurrencyCode),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickWeightChip(
    String label,
    VoidCallback onTap, {
    bool isPreset = false,
    bool isReset = false,
  }) {
    final theme = Theme.of(context);
    final color = isReset
        ? theme.colorScheme.error.withValues(alpha: 0.15)
        : (isPreset
            ? theme.colorScheme.primary.withValues(alpha: 0.18)
            : theme.colorScheme.surfaceContainerHighest);

    final textColor = isReset
        ? theme.colorScheme.error
        : (isPreset ? theme.colorScheme.primary : theme.colorScheme.onSurface);

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.s6),
      child: InkWell(
        borderRadius: AppRadius.s10BorderRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s10,
            vertical: AppSpacing.s6,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.s10BorderRadius,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    ThemeData t, {
    bool bold = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                value,
                style: (bold ? t.textTheme.titleMedium : t.textTheme.bodyLarge)?.copyWith(
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: textColor ?? (bold ? t.colorScheme.primary : null),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
