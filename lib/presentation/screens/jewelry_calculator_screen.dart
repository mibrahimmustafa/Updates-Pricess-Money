import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../core/utils.dart';
import '../controllers/locale_controller.dart';
import '../controllers/default_currency_controller.dart';
import '../controllers/prices_controller.dart';

/// Jewellery purchase calculator: metal + manufacturing fees + VAT,
/// minus credit for exchanged old-gold (moyaval).
class JewelryCalculatorScreen extends ConsumerStatefulWidget {
  const JewelryCalculatorScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  ConsumerState<JewelryCalculatorScreen> createState() =>
      _JewelryCalculatorScreenState();
}

class _JewelryCalculatorScreenState
    extends ConsumerState<JewelryCalculatorScreen> {
  final _weight = TextEditingController(text: '10');
  final _feePerGram = TextEditingController(text: '60');

  double _karat = 0.875; // 21K — Egypt's most common

  // Old gold to exchange (moyaval) — 0 disables the credit row.
  final _oldWeight = TextEditingController(text: '0');
  double _oldKarat = 0.875;
  bool _showVat = true;

  @override
  void dispose() {
    _weight.dispose();
    _feePerGram.dispose();
    _oldWeight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final langCode = ref.watch(localeProvider);
    final l = AppL10n(langCode);
    final theme = Theme.of(context);
    final defaultQuote = ref.watch(defaultCurrencyProvider);
    final snapshot = ref.watch(pricesProvider).snapshot;

    final quote = defaultQuote;
    if (snapshot == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.t('calc_title'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final gold = snapshot.gold;
    final rates = snapshot.rates;

    double perGramKarat(double karat) =>
        rates.convertFromUsd(gold.pricePerGram * karat, quote);

    final newWeight = double.tryParse(_weight.text) ?? 0;
    final fee = double.tryParse(_feePerGram.text) ?? 0;
    final oldW = double.tryParse(_oldWeight.text) ?? 0;

    final metalValue = perGramKarat(_karat) * newWeight;
    final mfgTotal = fee * newWeight;
    final vatRateVal = AppConstants.vatRate;
    final vat = (metalValue + mfgTotal) * (_showVat ? vatRateVal : 0.0);
    final total = metalValue + mfgTotal + vat;

    // Moyaval: dealer credits old gold at spot for its karat.
    final oldCredit = perGramKarat(_oldKarat) * oldW;
    final payable = total - oldCredit;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: Text(l.t('calc_title')))
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _row(
            TextField(
              controller: _weight,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l.t('weight_grams'),
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            DropdownButtonFormField<double>(
              initialValue: _karat,
              decoration: InputDecoration(
                labelText: l.t('karat'),
                border: const OutlineInputBorder(),
              ),
              items: AppConstants.karats.entries
                  .map((e) => DropdownMenuItem(
                        value: e.value,
                        child: Text(e.key),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _karat = v!),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _feePerGram,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l.t('mfg_fee_per_gram'),
              border: const OutlineInputBorder(),
              suffixText: quote,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.t('vat_label')),
            value: _showVat,
            onChanged: (v) => setState(() => _showVat = v),
          ),
          const Divider(height: 24),
          Text(l.t('old_gold_section'),
              style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _row(
            TextField(
              controller: _oldWeight,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l.t('old_gold_weight'),
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            DropdownButtonFormField<double>(
              initialValue: _oldKarat,
              decoration: InputDecoration(
                labelText: l.t('old_gold_note'),
                border: const OutlineInputBorder(),
              ),
              items: AppConstants.karats.entries
                  .map((e) => DropdownMenuItem(
                        value: e.value,
                        child: Text(e.key),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _oldKarat = v!),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line(l.t('metal_value'),
                      formatMoney(metalValue, quote), theme),
                  _line(l.t('mfg_total'),
                      formatMoney(mfgTotal, quote), theme),
                  if (vatRateVal > 0)
                    _line(l.t('vat_total'), formatMoney(vat, quote), theme),
                  const Divider(height: 20),
                  _line(
                    l.t('total_cost'),
                    formatMoney(total, quote),
                    theme,
                    bold: true,
                  ),
                  if (oldCredit > 0) ...[
                    const Divider(height: 20),
                    _line(l.t('old_gold_credit'),
                        '- ${formatMoney(oldCredit, quote)}', theme),
                    _line(
                      l.t('net_payable'),
                      formatMoney(payable, quote),
                      theme,
                      bold: true,
                      big: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(Widget a, Widget b) => Row(
        children: [
          Expanded(child: a),
          const SizedBox(width: 8),
          Expanded(child: b),
        ],
      );

  Widget _line(String label, String value, ThemeData t,
      {bool bold = false, bool big = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: t.textTheme.bodyMedium),
          Text(
            value,
            style: (big ? t.textTheme.titleLarge : t.textTheme.titleMedium)
                ?.copyWith(
              fontWeight: FontWeight.bold,
              color: bold || big ? t.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
