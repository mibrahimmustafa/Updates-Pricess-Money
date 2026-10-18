import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../core/utils.dart';
import '../../data/repositories/price_repository.dart';
import '../controllers/locale_controller.dart';
import '../controllers/default_currency_controller.dart';
import '../controllers/prices_controller.dart';
import '../controllers/user_prefs_controller.dart';

/// Converter for both metals (grams → price) and currencies
/// (USD ↔ SAR ↔ EGP) side by side in one asset dropdown.
class ConverterScreen extends ConsumerStatefulWidget {
  const ConverterScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen> {
  String _asset = AppConstants.goldSymbol;
  double _karat = 1.0;
  final _input = TextEditingController(text: '10');

  bool get _isMetal => AppConstants.metalPool.keys.contains(_asset);

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n(ref.watch(localeProvider));
    final theme = Theme.of(context);
    final defaultQuote = ref.watch(defaultCurrencyProvider);
    final snapshot = ref.watch(pricesProvider).snapshot;

    final appBar = widget.showAppBar
        ? AppBar(title: Text(l.t('tab_converter')))
            as PreferredSizeWidget?
        : null;

    final body = snapshot == null
        ? const Center(child: CircularProgressIndicator())
        : _buildConverter(l, theme, snapshot, defaultQuote);

    return Scaffold(
      appBar: appBar,
      body: body,
    );
  }

  Widget _buildConverter(
    AppL10n l,
    ThemeData theme,
    PriceSnapshot snapshot,
    String defaultQuote,
  ) {
    final prefs = ref.watch(userPrefsProvider);
    final amount = double.tryParse(_input.text) ?? 0;
    final karatFactor = _isMetal ? _karat : 1.0;

    List<(String, double)> rows;
    if (_isMetal) {
      final metal = _asset == AppConstants.goldSymbol
          ? snapshot.gold
          : snapshot.silver;
      final totalUsd = metal.pricePerGram * karatFactor * amount;
      rows = [
        for (final c in prefs.currencyList)
          (c, snapshot.rates.convertFromUsd(totalUsd, c)),
      ];
    } else {
      rows = _currencyRows(snapshot, amount, prefs.currencyList);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                initialValue: _asset,
                decoration: InputDecoration(
                  labelText: l.t('asset'),
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final m in prefs.metalList)
                    DropdownMenuItem(
                      value: m,
                      child: Text(l.t(
                        m == AppConstants.goldSymbol ? 'gold' : 'silver',
                      )),
                    ),
                  for (final c in prefs.currencyList)
                    DropdownMenuItem(
                      value: c,
                      child: Text(
                        '${AppConstants.currencySymbol(c)} $c',
                      ),
                    ),
                ],
                onChanged: (v) => setState(() {
                  _asset = v!;
                  if (_asset == AppConstants.silverSymbol) _karat = 1.0;
                }),
              ),
            ),
            if (_isMetal) ...[
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<double>(
                  initialValue: _karat,
                  decoration: InputDecoration(
                    labelText: l.t('karat'),
                    border: const OutlineInputBorder(),
                  ),
                  items: AppConstants.karats.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.value,
                          child: Text(e.key),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _karat = v!),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _input,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: _isMetal ? l.t('weight_grams') : l.t('amount'),
            border: const OutlineInputBorder(),
            suffixText: _isMetal ? 'g' : _asset,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.t('result'),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(height: 20),
                for (final (currency, value) in rows)
                  if (!_isMetal || currency != defaultQuote)
                    _resultRow(currency, value, theme),
                if (!_isMetal && amount > 0)
                  Text(
                    _fxFootnote(snapshot),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ),
        if (_isMetal) ...[
          const SizedBox(height: 12),
          Center(
            child: Text(
              '${l.t('price_per_gram')}: '
              '${formatMoney(snapshot.gold.pricePerGram, AppConstants.usd)} · '
              '${formatMoney(
                snapshot.rates.convertFromUsd(
                    snapshot.gold.pricePerGram, AppConstants.sar),
                AppConstants.sar,
              )} · '
              '${formatMoney(
                snapshot.rates.convertFromUsd(
                    snapshot.gold.pricePerGram, AppConstants.egp),
                AppConstants.egp,
              )}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }

  /// Currency mode: convert [amount] of [_asset] into the visible currencies.
  List<(String, double)> _currencyRows(
    PriceSnapshot s,
    double amount,
    List<String> visible,
  ) {
    final usd = s.rates.convert(amount, _asset, AppConstants.usd);
    return [
      for (final c in visible)
        if (c != _asset) (c, s.rates.convertFromUsd(usd, c)),
    ];
  }

  String _fxFootnote(PriceSnapshot s) {
    return '1 USD = ${s.rates.usdTo(AppConstants.sar).toStringAsFixed(4)} SAR = '
        '${s.rates.usdTo(AppConstants.egp).toStringAsFixed(2)} EGP';
  }

  Widget _resultRow(String currency, double? value, ThemeData t) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(currency, style: t.textTheme.titleMedium),
          Text(
            formatMoney(value, currency),
            style: t.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: t.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
