import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/notifications_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/controllers/locale_controller.dart';
import 'features/settings/presentation/controllers/theme_mode_controller.dart';
import 'features/shell/presentation/screens/root_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // IMPORTANT: must be awaited before runApp() to prevent platform channel
  // deadlock in release mode where SharedPreferencesAsync() would block
  // waiting behind an unresolved notifications platform channel call.
  await initNotifications();
  runApp(const ProviderScope(child: DahabLiveApp()));
}

/// Root application widget configuring global themes, localization, and navigation.
class DahabLiveApp extends ConsumerWidget {
  const DahabLiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Dahab Live',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: Locale(languageCode),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const RootScreen(),
    );
  }
}

/// Backward compatibility alias for the root application widget.
typedef PricessMoneyApp = DahabLiveApp;
