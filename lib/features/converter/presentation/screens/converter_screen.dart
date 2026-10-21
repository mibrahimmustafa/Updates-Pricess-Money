import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants.dart';
import '../../../../core/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../prices/data/repositories/price_repository.dart';
import '../../../prices/presentation/controllers/prices_controller.dart';
import '../../../settings/presentation/controllers/default_currency_controller.dart';
import '../../../settings/presentation/controllers/locale_controller.dart';
import '../../../settings/presentation/controllers/user_prefs_controller.dart';
import '../../domain/models/currency_conversion_result.dart';
import '../../domain/usecases/convert_asset_value_use_case.dart';

/// Executive converter for precious metals and global currencies.
/// Features a hero primary result card with one-tap copy, search filter, and 2-column responsive layout.
class ConverterScreen extends ConsumerStatefulWidget {
  const ConverterScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen> {
  String _selectedAssetCode = AppConstants.goldSymbol;
  double _selectedKaratPurity = 1.0;
  final _amountController = TextEditingController(text: '10');
  final _searchFilterController = TextEditingController();

  final _convertUseCase = const ConvertAssetValueUseCase();

  bool get _isMetalAssetSelected =>
      AppConstants.metalPool.keys.contains(_selectedAssetCode);

  @override
  void dispose() {
    _amountController.dispose();
    _searchFilterController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String currencyCode) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $text to clipboard'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = ref.watch(localeProvider);
    final l10n = AppLocalizations(languageCode);
    final theme = Theme.of(context);
    final defaultQuote = ref.watch(preferredQuoteCurrencyProvider);
    final snapshot = ref.watch(marketPricesProvider).snapshot ?? MarketSnapshot.initialSeed;

    final appBar = widget.showAppBar
        ? AppBar(title: Text(l10n.tabConverter)) as PreferredSizeWidget?
        : null;

    final body = ResponsiveCenter(
      maxContentWidth: AppDimensions.maxContentWidth,
      child: _buildConverter(l10n, theme, snapshot, defaultQuote),
    );

    return Scaffold(
      appBar: appBar,
      body: body,
    );
  }

  Widget _buildConverter(
    AppLocalizations l10n,
    ThemeData theme,
    MarketSnapshot snapshot,
    String defaultQuote,
  ) {
    final preferences = ref.watch(userPreferencesProvider);
    final enteredAmount = double.tryParse(_amountController.text) ?? 0.0;
    final karatPurity = _isMetalAssetSelected ? _selectedKaratPurity : 1.0;

    final conversionResults = _convertUseCase.execute(
      assetCode: _selectedAssetCode,
      amount: enteredAmount,
      karatPurityFactor: karatPurity,
      snapshot: snapshot,
      targetCurrencyCodes: preferences.orderedCurrencyCodes,
    );

    // Hero result in preferred default quote currency
    final heroResult = conversionResults.firstWhere(
      (r) => r.currencyCode == defaultQuote,
      orElse: () => conversionResults.isNotEmpty
          ? conversionResults.first
          : CurrencyConversionResult(
              currencyCode: defaultQuote,
              convertedValue: 0.0,
            ),
    );

    final searchQuery = _searchFilterController.text.trim().toUpperCase();
    final filteredResults = conversionResults.where((r) {
      if (r.currencyCode == defaultQuote) return false; // shown in hero card
      if (searchQuery.isEmpty) return true;
      return r.currencyCode.contains(searchQuery);
    }).toList();

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        // ─── Asset & Karat Controls ──────────────────────────────────────────
        Row(
          children: [
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                initialValue: _selectedAssetCode,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.asset,
                ),
                items: [
                  for (final metal in preferences.orderedMetalCodes)
                    DropdownMenuItem(
                      value: metal,
                      child: Text(
                        metal == AppConstants.goldSymbol
                            ? l10n.gold
                            : metal == AppConstants.silverSymbol
                                ? l10n.silver
                                : AppConstants.metalPool[metal] ?? metal,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  for (final currency in preferences.orderedCurrencyCodes)
                    DropdownMenuItem(
                      value: currency,
                      child: Text(
                        '${AppConstants.currencyFlag(currency)} $currency · ${AppConstants.currencySymbol(currency)}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) => setState(() {
                  _selectedAssetCode = value!;
                  if (_selectedAssetCode == AppConstants.silverSymbol) {
                    _selectedKaratPurity = 1.0;
                  }
                }),
              ),
            ),
            if (_isMetalAssetSelected) ...[
              AppSpacing.hGapSm,
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<double>(
                  initialValue: _selectedKaratPurity,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.karat,
                  ),
                  items: AppConstants.karats.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.value,
                          child: Text(e.key),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedKaratPurity = value!),
                ),
              ),
            ],
          ],
        ),
        AppSpacing.vGapMd,

        // ─── Amount Input ────────────────────────────────────────────────────
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: _isMetalAssetSelected ? l10n.weightGrams : l10n.amount,
            suffixText: _isMetalAssetSelected ? 'g' : _selectedAssetCode,
            prefixIcon: Icon(
              _isMetalAssetSelected ? Icons.scale_rounded : Icons.payments_outlined,
              size: AppSizes.iconLg,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        AppSpacing.vGapLg,

        // ─── Hero Primary Converted Card ─────────────────────────────────────
        Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.gold.withValues(alpha: 0.18),
                AppColors.gold.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: AppRadius.cardBorderRadius,
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        AppConstants.currencyFlag(heroResult.currencyCode),
                        style: const TextStyle(fontSize: 20),
                      ),
                      AppSpacing.hGapSm,
                      Text(
                        heroResult.currencyCode,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      AppSpacing.hGap6,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s6,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          borderRadius: AppRadius.s6BorderRadius,
                        ),
                        child: const Text(
                          'DEFAULT',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: AppSizes.iconMd),
                    tooltip: 'Copy value',
                    onPressed: () => _copyToClipboard(
                      formatMoney(heroResult.convertedValue, heroResult.currencyCode),
                      heroResult.currencyCode,
                    ),
                  ),
                ],
              ),
              AppSpacing.vGapSm,
              Text(
                formatMoney(heroResult.convertedValue, heroResult.currencyCode),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.vGapLg,

        // ─── Search Filter for Secondary Currencies ──────────────────────────
        TextField(
          controller: _searchFilterController,
          decoration: InputDecoration(
            hintText: 'Search currencies (e.g. SAR, EUR, EGP)...',
            prefixIcon: const Icon(Icons.search, size: AppSizes.iconLg),
            suffixIcon: _searchFilterController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: AppSizes.iconMd),
                    onPressed: () => setState(() => _searchFilterController.clear()),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s14,
              vertical: AppSpacing.s10,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        AppSpacing.vGapMd,

        // ─── Responsive Secondary Currency Grid ─────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isTablet = width > 680;
            final isWide = width > 460;
            final isNarrow = width < 310;
            final crossAxisCount =
                isTablet ? 4 : (isWide ? 3 : (isNarrow ? 1 : 2));
            final textScale = AppDimensions.textScaleFactor(context);
            // Dynamic aspect ratio scaling with text scaler and width to prevent text overflow
            final childAspectRatio = isTablet
                ? (3.0 / textScale).clamp(2.0, 3.4)
                : isWide
                    ? (2.8 / textScale).clamp(1.8, 3.2)
                    : isNarrow
                        ? (4.0 / textScale).clamp(2.4, 4.5)
                        : (2.3 / textScale).clamp(1.5, 2.6);

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredResults.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSpacing.s10,
                mainAxisSpacing: AppSpacing.s10,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (context, index) {
                final row = filteredResults[index];
                final val = row.convertedValue;

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.s10,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: AppRadius.inputBorderRadius,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        AppConstants.currencyFlag(row.currencyCode),
                        style: const TextStyle(fontSize: 14),
                      ),
                      AppSpacing.hGap6,
                      Text(
                        row.currencyCode,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGapXs,
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatMoney(val, row.currencyCode),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              );
            },
          );
        },
      ),
    ],
  );
  }
}
