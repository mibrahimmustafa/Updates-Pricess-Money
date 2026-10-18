import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../core/utils.dart';
import '../controllers/alerts_controller.dart';
import '../controllers/locale_controller.dart';
import '../controllers/default_currency_controller.dart';
import '../controllers/user_prefs_controller.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n(ref.watch(localeProvider));
    final theme = Theme.of(context);
    final alerts = ref.watch(alertsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.t('alerts_title'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const _AddAlertDialog(),
        ),
        label: Text(l.t('add_alert')),
        icon: const Icon(Icons.notifications_active),
      ),
      body: alerts.isEmpty
          ? Center(child: Text(l.t('no_alerts')))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final a = alerts[i];
                final metalKey = a.metalSymbol == AppConstants.goldSymbol
                    ? 'gold'
                    : 'silver';
                return Card(
                  child: ListTile(
                    leading: Icon(
                      a.above ? Icons.trending_up : Icons.trending_down,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      '${l.t(metalKey)} '
                      '${a.above ? '↑' : '↓'} '
                      '${formatMoney(a.targetPerGram, a.currency)}',
                    ),
                    subtitle:
                        Text(a.active ? l.t('alert_active') : l.t('alert_fired')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: a.active,
                          onChanged: (_) => ref
                              .read(alertsProvider.notifier)
                              .toggleActive(a.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => ref
                              .read(alertsProvider.notifier)
                              .removeAlert(a.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _AddAlertDialog extends ConsumerStatefulWidget {
  const _AddAlertDialog();

  @override
  ConsumerState<_AddAlertDialog> createState() => _AddAlertDialogState();
}

class _AddAlertDialogState extends ConsumerState<_AddAlertDialog> {
  String _metal = AppConstants.goldSymbol;
  bool _above = true;
  final _targetCtrl = TextEditingController();

  @override
  void dispose() {
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n(ref.watch(localeProvider));
    final currency = ref.watch(defaultCurrencyProvider);

    return AlertDialog(
      title: Text(l.t('add_alert')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _metal,
            decoration: InputDecoration(
              labelText: l.t('metal'),
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final s in ref.watch(userPrefsProvider).metalList)
                DropdownMenuItem(
                  value: s,
                  child: Text(
                    s == AppConstants.goldSymbol
                        ? l.t('gold')
                        : s == AppConstants.silverSymbol
                            ? l.t('silver')
                            : AppConstants.metalPool[s] ?? s,
                  ),
                ),
            ],
            onChanged: (v) => setState(() => _metal = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _targetCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l.t('target_price'),
              border: const OutlineInputBorder(),
              suffixText: currency,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: true, label: Text('↑ ${l.t('above')}')),
              ButtonSegment(value: false, label: Text('↓ ${l.t('below')}')),
            ],
            selected: {_above},
            onSelectionChanged: (s) => setState(() => _above = s.first),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final t = double.tryParse(_targetCtrl.text);
            if (t == null || t <= 0) return;
            ref.read(alertsProvider.notifier).addAlert(PriceAlert(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  metalSymbol: _metal,
                  currency: currency,
                  targetPerGram: t,
                  above: _above,
                  active: true,
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                ));
            Navigator.pop(context);
          },
          child: Text(l.t('add_alert')),
        ),
      ],
    );
  }
}
