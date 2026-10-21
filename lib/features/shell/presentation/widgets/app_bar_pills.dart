import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../settings/presentation/controllers/locale_controller.dart';
import '../../../settings/presentation/controllers/theme_mode_controller.dart';

/// Backward compatibility aliases.
typedef LangPill = LanguageTogglePill;
typedef ThemePill = ThemeTogglePill;

/// Pill-shaped language switch shown in the AppBar.
class LanguageTogglePill extends ConsumerWidget {
  const LanguageTogglePill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(localeProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: () => ref.read(localeProvider.notifier).toggle(),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.s6,
          ),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.12),
            border: Border.all(color: primaryColor.withValues(alpha: 0.45)),
            borderRadius: AppRadius.s20BorderRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, size: AppSizes.iconSm, color: primaryColor),
              AppSpacing.hGap5,
              Text(
                languageCode == 'ar' ? 'EN' : 'عربي',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
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
class ThemeTogglePill extends ConsumerWidget {
  const ThemeTogglePill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final isInDarkMode = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: () => ref.read(themeModeProvider.notifier).toggle(),
        child: Container(
          width: AppSizes.iconBoxSm,
          height: AppSizes.iconBoxSm,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.12),
            border: Border.all(color: primaryColor.withValues(alpha: 0.45)),
            borderRadius: AppRadius.s20BorderRadius,
          ),
          child: Icon(
            isInDarkMode ? Icons.light_mode : Icons.dark_mode,
            size: AppSizes.iconMd,
            color: primaryColor,
          ),
        ),
      ),
    );
  }
}
