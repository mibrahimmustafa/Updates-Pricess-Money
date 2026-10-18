import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../core/utils.dart';
import '../controllers/locale_controller.dart';
import '../controllers/default_currency_controller.dart';
import '../controllers/prices_controller.dart';
import '../widgets/history_chart.dart';

/// "What if I had bought N grams in year X?" — compares historical price
/// with today's live price.
class TimeMachineScreen extends ConsumerStatefulWidget {
  const TimeMachineScreen({super.key});

  @override
  ConsumerState<TimeMachineScreen> createState() => _TimeMachineScreenState();
}

class _TimeMachineScreenState extends ConsumerState<TimeMachineScreen> {
  static const _earliestYear = 2015;
  int _year = DateTime.now().year - 5;
  final _grams = TextEditingController(text: '10');

  @override
  void dispose() {
    _grams.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n(ref.watch(localeProvider));
    final theme = Theme.of(context);
    final quote = ref.watch(defaultCurrencyProvider);
    final snapshot = ref.watch(pricesProvider).snapshot;

    // First trading day of the selected year.
    final query = HistoryQuery2(
      symbol: AppConstants.goldSymbol,
      quote: quote,
      from: DateTime(_year, 1, 1),
      to: DateTime(_year, 1, 10),
    );
    final historical = ref.watch(historyRangeProvider(query));

    final nowPerGram = snapshot?.rates.convertFromUsd(
          snapshot.gold.pricePerGram * 0.875, // 21K like Egyptian market
          quote,
        );
    final grams = double.tryParse(_grams.text) ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(l.t('timemachine_title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _year,
                  decoration: InputDecoration(
                    labelText: l.t('select_year'),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (var y = DateTime.now().year - 1;
                        y >= _earliestYear;
                        y--)
                      DropdownMenuItem(value: y, child: Text('$y')),
                  ],
                  onChanged: (v) => setState(() => _year = v!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _grams,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.t('weight_grams'),
                    border: const OutlineInputBorder(),
                    suffixText: '21K',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          historical.when(
            loading: () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(l.t('error_network'),
                style: TextStyle(color: theme.colorScheme.error)),
            data: (points) {
              if (points.isEmpty) {
                return const SizedBox(height: 60, child: Center(child: Text('—')));
              }
              final thenPerGram =
                  points.first.perGram * 1; // XAU→quote is per ounce
              final thenPerGramKarat =
                  snapshot == null ? thenPerGram : thenPerGram * 0.875;
              final thenTotal = thenPerGramKarat * grams;
              final nowTotal = (nowPerGram ?? 0) * grams;
              final multiplier =
                  thenPerGramKarat == 0 ? 0.0 : nowPerGram! / thenPerGramKarat;

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l.t('since')} $yearLabel ($quote)',
                        style: theme.textTheme.titleSmall,
                      ),
                      const Divider(height: 20),
                      _line(l.t('then_price'),
                          formatMoney(thenTotal, quote), theme),
                      _line(l.t('now_price'),
                          formatMoney(nowTotal, quote), theme),
                      const Divider(height: 20),
                      _line(
                        l.t('change'),
                        multiplier > 0
                            ? '${multiplier.toStringAsFixed(2)}× '
                                '(+${((multiplier - 1) * 100).toStringAsFixed(0)}%)'
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
    );
  }

  int get yearLabel => _year;

  Widget _line(String label, String value, ThemeData t, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: t.textTheme.bodyMedium),
          Text(
            value,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: bold ? t.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
