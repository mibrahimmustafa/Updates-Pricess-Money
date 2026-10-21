import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils.dart';
import '../../../prices/presentation/controllers/prices_controller.dart';
import '../../data/models/history_point.dart';

/// Backward compatibility aliases.
typedef HistoryQuery = PeriodHistoryQuery;
typedef HistoryQuery2 = DateRangeHistoryQuery;

/// Parameter object for period-based price history queries (e.g. 7d, 30d, 90d).
class PeriodHistoryQuery {
  const PeriodHistoryQuery({
    required this.symbol,
    required this.quote,
    required this.days,
  });

  final String symbol;
  final String quote;
  final int days;

  int get periodDays => days;

  @override
  bool operator ==(Object other) =>
      other is PeriodHistoryQuery &&
      other.symbol == symbol &&
      other.quote == quote &&
      other.days == days;

  @override
  int get hashCode => Object.hash(symbol, quote, days);
}

final periodPriceHistoryProvider = FutureProvider.autoDispose
    .family<List<HistoricalDataPoint>, PeriodHistoryQuery>(
  (ref, query) => ref.read(marketRepositoryProvider).fetchPriceHistory(
        metalSymbol: query.symbol,
        quoteCurrencyCode: query.quote,
        periodDays: query.days,
      ),
);

/// Backward compatibility alias.
final historyProvider = periodPriceHistoryProvider;

/// Explicit date-range history query (used by the time machine).
class DateRangeHistoryQuery {
  const DateRangeHistoryQuery({
    required this.symbol,
    required this.quote,
    required this.from,
    required this.to,
  });

  final String symbol;
  final String quote;
  final DateTime from;
  final DateTime to;

  @override
  bool operator ==(Object other) =>
      other is DateRangeHistoryQuery &&
      other.symbol == symbol &&
      other.quote == quote &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(symbol, quote, from, to);
}

final dateRangePriceHistoryProvider = FutureProvider.autoDispose
    .family<List<HistoricalDataPoint>, DateRangeHistoryQuery>(
  (ref, query) => ref.read(marketRepositoryProvider).fetchPriceHistoryRange(
        metalSymbol: query.symbol,
        quoteCurrencyCode: query.quote,
        fromDate: query.from,
        toDate: query.to,
      ),
);

/// Backward compatibility alias.
final historyRangeProvider = dateRangePriceHistoryProvider;

/// Executive interactive Line chart of per-gram metal price history with
/// KPI summary metrics, adaptive non-duplicating Y-axis labels, and non-colliding date ticks.
class HistoryChart extends ConsumerWidget {
  const HistoryChart({
    super.key,
    required this.points,
    required this.quote,
    this.height = 260.0,
  });

  final List<HistoricalDataPoint> points;
  final String quote;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    if (points.length < 2) {
      return SizedBox(
        height: height * 0.8,
        child: const Center(child: Text('—')),
      );
    }

    final pricePerGramValues = points.map((p) => p.valuePerGram).toList();
    final minY = pricePerGramValues.reduce((a, b) => a < b ? a : b);
    final maxY = pricePerGramValues.reduce((a, b) => a > b ? a : b);
    final deltaY = maxY - minY;
    final padding = deltaY > 0 ? deltaY * 0.12 : 1.0;
    final effectiveMinY = minY - padding;
    final effectiveMaxY = maxY + padding;
    final effectiveRange = effectiveMaxY - effectiveMinY;

    // KPI Metrics calculation
    final firstPrice = pricePerGramValues.first;
    final lastPrice = pricePerGramValues.last;
    final netChange = lastPrice - firstPrice;
    final netPercent = firstPrice > 0 ? (netChange / firstPrice) * 100 : 0.0;
    final isPositive = netChange >= 0;
    final trendColor = isPositive ? AppColors.trendUp : AppColors.trendDown;

    // 4 evenly spaced Y ticks
    final yInterval = (effectiveRange / 4).clamp(0.0001, double.infinity);

    // Pick 4 to 5 non-colliding X date indices
    final pointCount = points.length;
    final targetXIndices = <int>{
      0,
      pointCount ~/ 4,
      pointCount ~/ 2,
      (pointCount * 3) ~/ 4,
      pointCount - 1,
    };

    final textScale = AppDimensions.textScaleFactor(context);
    final longestTickSample = _formatYAxisTick(effectiveMaxY, deltaY);
    // Dynamically compute reserved size for Y-axis labels to avoid clipping on any font scale or currency
    final dynamicYReservedSize =
        ((longestTickSample.length * 8.0 + 16.0) * textScale).clamp(52.0, 96.0);
    final dynamicXReservedSize = (26.0 * textScale).clamp(24.0, 42.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Executive KPI Summary Header ────────────────────────────────────
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.s10,
          runSpacing: AppSpacing.xs,
          children: [
            Text(
              formatMoney(lastPrice, quote),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: trendColor.withValues(alpha: 0.14),
                borderRadius: AppRadius.s10BorderRadius,
                border: Border.all(color: trendColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    size: 14,
                    color: trendColor,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${isPositive ? '+' : ''}${netPercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: trendColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'High: ${formatMoney(maxY, quote)}  ·  Low: ${formatMoney(minY, quote)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.lg),

        // ─── Polished Chart Canvas ───────────────────────────────────────────
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minY: effectiveMinY,
              maxY: effectiveMaxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: yInterval,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.5)
                      : AppColors.lightBorder.withValues(alpha: 0.6),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: dynamicYReservedSize,
                    interval: yInterval,
                    getTitlesWidget: (value, meta) {
                      // Avoid duplicate 'K' rounding: format accurately according to range
                      final formatted = _formatYAxisTick(value, deltaY);
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          formatted,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.secondary,
                          ),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: dynamicXReservedSize,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      // Only draw for selected non-colliding indices
                      if (!targetXIndices.contains(i) || i >= points.length) {
                        return const SizedBox.shrink();
                      }
                      final d = points[i].date;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => isDark ? AppColors.darkSurface : AppColors.lightCard,
                  tooltipBorder: BorderSide(
                    color: primaryColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  getTooltipItems: (spots) => spots.map((s) {
                    final idx = s.x.toInt().clamp(0, points.length - 1);
                    final dateStr = DateFormat('yyyy-MM-dd').format(points[idx].date);
                    final price = pricePerGramValues[idx];
                    return LineTooltipItem(
                      '$dateStr\n${formatMoney(price, quote)}',
                      TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        height: 1.3,
                      ),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < pricePerGramValues.length; i++)
                      FlSpot(i.toDouble(), pricePerGramValues[i]),
                  ],
                  isCurved: true,
                  curveSmoothness: 0.25,
                  barWidth: 2.8,
                  color: primaryColor,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        primaryColor.withValues(alpha: 0.28),
                        primaryColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Formats Y-axis labels dynamically so that nearby numbers never round to the same value.
  String _formatYAxisTick(double value, double totalDelta) {
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    // If range is narrow (< 800), rounding to 1 decimal with 'K' would create duplicates like 7.3K, 7.3K.
    // Instead, format as exact integers with thousands comma separator.
    if (totalDelta < 1500) {
      return NumberFormat.decimalPattern('en').format(value.round());
    }
    if (value.abs() >= 10000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return NumberFormat.decimalPattern('en').format(value.round());
  }
}
