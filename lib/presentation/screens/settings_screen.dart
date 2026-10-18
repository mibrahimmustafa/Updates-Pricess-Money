import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../controllers/locale_controller.dart';
import '../controllers/default_currency_controller.dart';
import '../controllers/user_prefs_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _searchCtrl = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n(ref.watch(localeProvider));
    final langCode = ref.watch(localeProvider);
    final currency = ref.watch(defaultCurrencyProvider);
    final prefs = ref.watch(userPrefsProvider);
    final theme = Theme.of(context);

    final filtered = AppConstants.currencyCodes
        .where((c) => _filter.isEmpty || c.contains(_filter.toUpperCase()))
        .toList();

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
            leading: const Icon(Icons.star_outline),
            title: Text(l.t('default_currency')),
            subtitle: Text(
                '${AppConstants.currencySymbol(currency)} $currency'),
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
              style: theme.textTheme.titleSmall),
          Text(
            '${prefs.visibleCurrencies.length} / ${AppConstants.currencyCodes.length}',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.secondary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'SAR, EUR, AED…',
            ),
            onChanged: (v) => setState(() => _filter = v.trim()),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              ActionChip(
                label: Text(l.t('preset_gcc')),
                onPressed: () => ref
                    .read(userPrefsProvider.notifier)
                    .selectGroup(AppConstants.gccCurrencies),
              ),
              ActionChip(
                label: Text(l.t('preset_mena')),
                onPressed: () => ref
                    .read(userPrefsProvider.notifier)
                    .selectGroup(AppConstants.menaCurrencies),
              ),
              ActionChip(
                label: Text(l.t('preset_default')),
                onPressed: () => ref
                    .read(userPrefsProvider.notifier)
                    .resetCurrencies(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in filtered)
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
          Row(
            children: [
              Text(l.t('choose_assets'),
                  style: theme.textTheme.titleSmall),
              const Spacer(),
              ActionChip(
                label: Text(l.t('preset_default')),
                onPressed: () => ref
                    .read(userPrefsProvider.notifier)
                    .resetMetals(),
              ),
            ],
          ),
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
