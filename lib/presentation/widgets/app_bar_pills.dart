import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/locale_controller.dart';
import '../controllers/theme_mode_controller.dart';

/// Pill-shaped language switch shown in the AppBar.
/// Shows the name of the *other* language, so the user always knows
/// what tapping it will do.
class LangPill extends ConsumerWidget {
  const LangPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = ref.watch(localeProvider);
    final gold = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: () => ref.read(localeProvider.notifier).toggle(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.12),
            border: Border.all(color: gold.withValues(alpha: 0.45)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, size: 15, color: gold),
              const SizedBox(width: 5),
              Text(
                langCode == 'ar' ? 'EN' : 'عربي',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill-shaped theme toggle (sun ⟷ moon).
class ThemePill extends ConsumerWidget {
  const ThemePill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final gold = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: () => ref.read(themeModeProvider.notifier).toggle(),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.12),
            border: Border.all(color: gold.withValues(alpha: 0.45)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            size: 17,
            color: gold,
          ),
        ),
      ),
    );
  }
}
