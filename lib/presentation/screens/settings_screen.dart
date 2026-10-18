import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../controllers/locale_controller.dart';
import '../controllers/default_currency_controller.dart';
import '../controllers/user_prefs_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n(ref.watch(localeProvider));
    final langCode = ref.watch(localeProvider);
    final currency = ref.watch(defaultCurrencyProvider);
    final prefs = ref.watch(userPrefsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.t('settings_title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language),
            title: Text(l.t('language')),
            subtitle: Text(langCode == 'ar' ? 'العربية' : 'English'),
            trailing: Switch(
              value: langCode == 'ar',
              onChanged: (_) => ref.read(localeProvider.notifier).toggle(),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.currency_exchange),
            title: Text(l.t('default_currency')),
            subtitle: Text(currency),
          ),
          SegmentedButton<String>(
            segments: [
              for (final c in prefs.currencyList)
                ButtonSegment(value: c, label: Text(c)),
            ],
            selected: {currency},
            onSelectionChanged: (s) =>
                ref.read(defaultCurrencyProvider.notifier).set(s.first),
          ),

          const SizedBox(height: 24),
          Text(l.t('choose_currencies'),
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in AppConstants.currencyPool.keys)
                FilterChip(
                  label: Text(
                      '${AppConstants.currencySymbol(c)} $c'),
                  selected: prefs.visibleCurrencies.contains(c),
                  onSelected: (_) =>
                      ref.read(userPrefsProvider.notifier).toggleCurrency(c),
                ),
            ],
          ),

          const SizedBox(height: 24),
          Text(l.t('choose_assets'),
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in AppConstants.metalPool.entries)
                FilterChip(
                  label: Text(m.value),
                  selected: prefs.visibleMetals.contains(m.key),
                  onSelected: (_) =>
                      ref.read(userPrefsProvider.notifier).toggleMetal(m.key),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
