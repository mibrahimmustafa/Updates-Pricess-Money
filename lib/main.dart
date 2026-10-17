import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/controllers/locale_controller.dart';
import 'presentation/screens/root_screen.dart';

void main() {
  runApp(const ProviderScope(child: PricessMoneyApp()));
}

class PricessMoneyApp extends ConsumerWidget {
  const PricessMoneyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = ref.watch(localeProvider);

    const gold = Color(0xFFD4A548);
    const darkBg = Color(0xFF121212);

    final dark = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: gold,
        secondary: const Color(0xFF8D99AE),
        surface: darkBg,
      ),
      scaffoldBackgroundColor: darkBg,
      appBarTheme: const AppBarTheme(elevation: 0),
    );

    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFFB58A2B),
        secondary: const Color(0xFF5C6B7A),
      ),
    );

    return MaterialApp(
      title: 'Pricess Money',
      debugShowCheckedModeBanner: false,
      theme: light,
      darkTheme: dark,
      themeMode: ThemeMode.dark,
      locale: Locale(langCode),
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
