import 'package:flutter/material.dart';

import '../../../../core/constants.dart';
import '../../../../core/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils.dart';
import '../../data/models/exchange_rates.dart';
import '../../data/models/metal_price.dart';

/// Executive responsive card showing one metal's price in USD and selected currencies,
/// featuring a prominent primary currency display, quick karat breakdown for gold,
/// and a collapsible secondary currency tray to avoid vertical clutter.
class MetalPriceCard extends StatefulWidget {
  const MetalPriceCard({
    super.key,
    required this.metal,
    required this.rates,
    required this.theme,
    required this.l10n,
    this.showKarats = false,
    bool? showKaratBreakdown,
    required this.currencies,
  }) : showKaratBreakdown = showKaratBreakdown ?? showKarats;

  final MetalPrice metal;
  final ExchangeRates rates;
  final ThemeData theme;
  final AppLocalizations l10n;

  /// User-selected display currencies.
  final List<String> currencies;

  /// Karat breakdown only applies to gold.
  final bool showKarats;
  final bool showKaratBreakdown;

  @override
  State<MetalPriceCard> createState() => _MetalPriceCardState();
}

class _MetalPriceCardState extends State<MetalPriceCard> {
  bool _isExpanded = false;

  TableRow _buildPriceRow(String label, String value, {bool isHighlighted = false}) {
    final theme = widget.theme;
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isHighlighted ? theme.colorScheme.primary : null,
              fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
                  color: isHighlighted ? theme.colorScheme.primary : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _iconForMetal(String symbol) {
    return switch (symbol) {
      AppConstants.goldSymbol => Icons.workspace_premium_rounded,
      AppConstants.silverSymbol => Icons.diamond_outlined,
      'BTC' => Icons.currency_bitcoin_rounded,
      _ => Icons.paid_rounded,
    };
  }

  String _labelForMetal(String symbol) {
    if (symbol == AppConstants.goldSymbol) return widget.l10n.gold;
    if (symbol == AppConstants.silverSymbol) return widget.l10n.silver;
    return AppConstants.metalPool[symbol] ?? widget.metal.name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final primaryColor = theme.colorScheme.primary;
    final accentColor = AppColors.accentForMetal(widget.metal.symbol, primaryColor);
    final supportsGramPricing = AppConstants.gramMetals.contains(widget.metal.symbol);
    final label = _labelForMetal(widget.metal.symbol);
    final icon = _iconForMetal(widget.metal.symbol);

    final primaryQuote = widget.currencies.isNotEmpty ? widget.currencies.last : AppConstants.usd;
    final visibleCurrencies = _isExpanded
        ? widget.currencies
        : widget.currencies.take(3).toList();

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header: Metal Title + Ounce Spot Price ──────────────────────
            Row(
              children: [
                Container(
                  width: AppSizes.iconBoxLg,
                  height: AppSizes.iconBoxLg,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.16),
                    borderRadius: AppRadius.circularBorderRadius,
                    border: Border.all(color: accentColor.withValues(alpha: 0.28)),
                  ),
                  child: Icon(icon, color: accentColor, size: AppSizes.iconXl),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.metal.symbol,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGapSm,
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatMoney(widget.metal.price, AppConstants.usd),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (widget.metal.symbol != 'BTC')
                          Text(
                            widget.l10n.perOz,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ─── Gram Pricing Table ──────────────────────────────────────────
            if (supportsGramPricing) ...[
              const Divider(height: AppSizes.dividerHeight),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FlexColumnWidth(1.05),
                  1: FlexColumnWidth(1.0),
                },
                children: [
                  for (final currency in visibleCurrencies)
                    _buildPriceRow(
                      '${widget.l10n.gram} · ${wrapBidiIsolate(currency)}',
                      formatMoney(
                        widget.rates.convertFromUsd(widget.metal.pricePerGram, currency),
                        currency,
                      ),
                      isHighlighted: currency == primaryQuote,
                    ),
                ],
              ),

              // ─── Collapsible Currency Toggle ───────────────────────────────
              if (widget.currencies.length > 3) ...[
                AppSpacing.vGapXs,
                InkWell(
                  borderRadius: AppRadius.smBorderRadius,
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s6,
                      horizontal: AppSpacing.xs,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isExpanded
                              ? 'Show less'
                              : '+${widget.currencies.length - 3} more currencies',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        AppSpacing.hGapXs,
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: AppSizes.iconBase,
                          color: theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // ─── Gold Karat Breakdown ──────────────────────────────────────
              if (widget.showKaratBreakdown) ...[
                const Divider(height: AppSizes.dividerThin),
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0: FlexColumnWidth(1.05),
                    1: FlexColumnWidth(1.0),
                  },
                  children: [
                    for (final karat in AppConstants.karats.entries)
                      if (karat.key != '24K')
                        _buildPriceRow(
                          '${widget.l10n.gram} ${wrapBidiIsolate(karat.key)} · ${wrapBidiIsolate(primaryQuote)}',
                          formatMoney(
                            widget.rates.convertFromUsd(
                              widget.metal.pricePerGram * karat.value,
                              primaryQuote,
                            ),
                            primaryQuote,
                          ),
                        ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
