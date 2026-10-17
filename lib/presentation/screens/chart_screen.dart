import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../controllers/locale_controller.dart';
import '../widgets/history_chart.dart';

class ChartScreen extends ConsumerStatefulWidget {
  const ChartScreen({super.key});

  @override
  ConsumerState<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends ConsumerState<ChartScreen> {
  String _symbol = AppConstants.goldSymbol;
  String _quote = AppConstants.egp;
  int _days = 30;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n(ref.watch(localeProvider));
    final theme = Theme.of(context);
    final query = HistoryQuery(symbol: _symbol, quote: _quote, days: _days);
    final history = ref.watch(historyProvider(query));

    return Scaffold(
      appBar: AppBar(title: Text(l.t('tab_chart'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _symbol,
                  decoration: InputDecoration(
                    labelText: l.t('metal'),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: AppConstants.goldSymbol,
                      child: Text(l.t('gold')),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.silverSymbol,
                      child: Text(l.t('silver')),
                    ),
                  ],
                  onChanged: (v) => setState(() => _symbol = v!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _quote,
                  decoration: InputDecoration(
                    labelText: l.t('currency'),
                    border: const OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: AppConstants.usd, child: Text('USD')),
                    DropdownMenuItem(value: AppConstants.sar, child: Text('SAR')),
                    DropdownMenuItem(value: AppConstants.egp, child: Text('EGP')),
                  ],
                  onChanged: (v) => setState(() => _quote = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: [
              ButtonSegment(
                value: 7,
                label: Text(l.t('range_7d')),
              ),
              ButtonSegment(value: 30, label: Text(l.t('range_30d'))),
              ButtonSegment(value: 90, label: Text(l.t('range_90d'))),
            ],
            selected: {_days},
            onSelectionChanged: (s) => setState(() => _days = s.first),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: history.when(
                loading: () =>
                    const SizedBox(height: 260, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => SizedBox(
                  height: 260,
                  child: Center(
                    child: Text(
                      l.t('error_network'),
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ),
                data: (points) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l.t(_symbol == AppConstants.goldSymbol ? 'gold' : 'silver')} '
                      '— ${l.t('price_per_gram')} ($_quote)',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    HistoryChart(points: points, quote: _quote),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
