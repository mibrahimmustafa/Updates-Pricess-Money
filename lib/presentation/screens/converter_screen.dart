import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../core/utils.dart';
import '../controllers/locale_controller.dart';
import '../controllers/prices_controller.dart';

/// Weight (grams) → price calculator using live rates.
class ConverterScreen extends ConsumerStatefulWidget {
  const ConverterScreen({super.key});

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen> {
  String _metal = AppConstants.goldSymbol;
  double _karat = 1.0;
  final _weightController = TextEditingController(text: '10');

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n(ref.watch(localeProvider));
    final theme = Theme.of(context);
    final state = ref.watch(pricesProvider);
    final snapshot = state.snapshot;
    final lang = ref.watch(localeProvider);

    final metalPrice = snapshot == null
        ? null
        : (_metal == AppConstants.goldSymbol ? snapshot.gold : snapshot.silver);

    final grams = double.tryParse(_weightController.text) ?? 0;
    final karatFactor = _metal == AppConstants.goldSymbol ? _karat : 1.0;
    final usdTotal =
        metalPrice == null ? 0.0 : metalPrice.pricePerGram * karatFactor * grams;

    return Scaffold(
      appBar: AppBar(title: Text(l.t('tab_converter'))),
      body: snapshot == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _metal,
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
                        onChanged: (v) => setState(() {
                          _metal = v!;
                          if (_metal == AppConstants.silverSymbol) _karat = 1.0;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
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
                        onChanged: _metal == AppConstants.goldSymbol
                            ? (v) => setState(() => _karat = v!)
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.t('weight_grams'),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
                        _resultRow(
                          lang,
                          AppConstants.usd,
                          usdTotal,
                          theme,
                        ),
                        _resultRow(
                          lang,
                          AppConstants.sar,
                          snapshot.rates.convertFromUsd(
                              usdTotal, AppConstants.sar),
                          theme,
                        ),
                        _resultRow(
                          lang,
                          AppConstants.egp,
                          snapshot.rates.convertFromUsd(
                              usdTotal, AppConstants.egp),
                          theme,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (metalPrice != null)
                  Center(
                    child: Text(
                      '${l.t('price_per_gram')}: '
                      'USD ${metalPrice.pricePerGram.toStringAsFixed(2)}'
                      ' · SAR ${(metalPrice.pricePerGram * snapshot.rates.usdToSar).toStringAsFixed(2)}'
                      ' · EGP ${(metalPrice.pricePerGram * snapshot.rates.usdToEgp).toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _resultRow(String lang, String currency, double value, ThemeData t) {
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
