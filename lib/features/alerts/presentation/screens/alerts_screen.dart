import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants.dart';
import '../../../../core/l10n.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../settings/presentation/controllers/default_currency_controller.dart';
import '../../../settings/presentation/controllers/locale_controller.dart';
import '../../../settings/presentation/controllers/user_prefs_controller.dart';
import '../../domain/enums/alert_trigger_direction.dart';
import '../controllers/alerts_controller.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(localeProvider);
    final l10n = AppLocalizations(languageCode);
    final theme = Theme.of(context);
    final alerts = ref.watch(alertsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.alertsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const _AddAlertDialog(),
        ),
        label: Text(l10n.addAlert),
        icon: const Icon(Icons.notifications_active),
      ),
      body: alerts.isEmpty
          ? Center(child: Text(l10n.noAlerts))
          : ResponsiveCenter(
              maxContentWidth: AppDimensions.maxContentWidth,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: alerts.length,
                separatorBuilder: (_, _) => AppSpacing.vGapSm,
                itemBuilder: (context, i) {
                  final alert = alerts[i];
                  final metalLabel =
                      alert.metalSymbol == AppConstants.goldSymbol
                          ? l10n.gold
                          : l10n.silver;
                  return Card(
                    elevation: 0,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s14,
                        vertical: AppSpacing.xs,
                      ),
                      leading: Icon(
                        alert.direction == AlertTriggerDirection.aboveTarget
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        '$metalLabel '
                        '${alert.direction.arrowSymbol} '
                        '${formatMoney(alert.targetPerGram, alert.currency)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        alert.isActive ? l10n.alertActive : l10n.alertFired,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: alert.isActive,
                            onChanged: (_) => ref
                                .read(alertsProvider.notifier)
                                .toggleActive(alert.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => ref
                                .read(alertsProvider.notifier)
                                .removeAlert(alert.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
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
  String? _selectedMetalCode;
  String? _selectedCurrencyCode;
  bool _isAboveTarget = true;
  final _targetPriceController = TextEditingController();

  @override
  void dispose() {
    _targetPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = ref.watch(localeProvider);
    final l10n = AppLocalizations(languageCode);
    final preferences = ref.watch(userPreferencesProvider);
    final defaultQuote = ref.watch(preferredQuoteCurrencyProvider);
    _selectedCurrencyCode ??= defaultQuote;
    _selectedMetalCode ??= preferences.orderedMetalCodes.isNotEmpty
        ? preferences.orderedMetalCodes.first
        : AppConstants.goldSymbol;

    return AlertDialog(
      title: Text(l10n.addAlert),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedMetalCode,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.metal,
                border: const OutlineInputBorder(),
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
              ],
              onChanged: (value) =>
                  setState(() => _selectedMetalCode = value!),
            ),
            AppSpacing.vGapMd,
            DropdownButtonFormField<String>(
              initialValue: _selectedCurrencyCode,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.currency,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final currency in preferences.orderedCurrencyCodes)
                  DropdownMenuItem(
                    value: currency,
                    child: Text(
                      '${AppConstants.currencyFlag(currency)} $currency',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _selectedCurrencyCode = value!),
            ),
            AppSpacing.vGapMd,
            TextField(
              controller: _targetPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.targetPrice,
                border: const OutlineInputBorder(),
                suffixText: _selectedCurrencyCode,
              ),
            ),
            AppSpacing.vGapMd,
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text('↑ ${l10n.above}'),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('↓ ${l10n.below}'),
                  ),
                ],
                selected: {_isAboveTarget},
                onSelectionChanged: (selection) =>
                    setState(() => _isAboveTarget = selection.first),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final targetPrice = double.tryParse(_targetPriceController.text);
            if (targetPrice == null || targetPrice <= 0) return;
            ref.read(alertsProvider.notifier).addAlert(
                  PriceThresholdAlert(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    metalSymbol: _selectedMetalCode!,
                    currency: _selectedCurrencyCode!,
                    targetPerGram: targetPrice,
                    direction: _isAboveTarget
                        ? AlertTriggerDirection.aboveTarget
                        : AlertTriggerDirection.belowTarget,
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                  ),
                );
            Navigator.pop(context);
          },
          child: Text(l10n.addAlert),
        ),
      ],
    );
  }
}
