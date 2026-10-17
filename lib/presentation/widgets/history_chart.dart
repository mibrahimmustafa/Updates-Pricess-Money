import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../data/models/history_point.dart';
import '../../core/utils.dart';
import '../controllers/prices_controller.dart';

/// Parameter object for the history query.
class HistoryQuery {
  const HistoryQuery({
    required this.symbol,
    required this.quote,
    required this.days,
  });

  final String symbol;
  final String quote;
  final int days;

  @override
  bool operator ==(Object other) =>
      other is HistoryQuery &&
      other.symbol == symbol &&
      other.quote == quote &&
      other.days == days;

  @override
  int get hashCode => Object.hash(symbol, quote, days);
}

final historyProvider =
    FutureProvider.autoDispose.family<List<HistoryPoint>, HistoryQuery>(
  (ref, query) => ref.read(priceRepositoryProvider).fetchHistory(
        query.symbol,
        query.quote,
        query.days,
      ),
);

/// Line chart of per-gram metal price history.
class HistoryChart extends ConsumerWidget {
  const HistoryChart({super.key, required this.points, required this.quote});

  final List<HistoryPoint> points;
  final String quote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    if (points.length < 2) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('—')),
      );
    }

    final values = points.map((p) => p.perGram).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return SizedBox(
      height: 260,
      child: LineChart(
        LineChartData(
          minY: minY - padding,
          maxY: maxY + padding,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 56,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: (points.length / 5).ceilToDouble().clamp(1, 30),
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= points.length) {
                    return const SizedBox.shrink();
                  }
                  final d = points[i].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${d.month}/${d.day}',
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots
                  .map(
                    (s) => LineTooltipItem(
                      formatMoney(
                        values[s.x.toInt()],
                        quote,
                      ),
                      theme.textTheme.bodySmall!.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < values.length; i++)
                  FlSpot(i.toDouble(), values[i]),
              ],
              isCurved: true,
              barWidth: 2.5,
              color: color,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
