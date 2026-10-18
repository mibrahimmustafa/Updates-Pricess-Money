import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/controllers/locale_controller.dart';
import 'presentation/screens/root_screen.dart';
import 'services/notifications_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initNotifications();
  runApp(const ProviderScope(child: PricessMoneyApp()));
}

class PricessMoneyApp extends ConsumerWidget {
  const PricessMoneyApp({super.key});

  static const gold = Color(0xFFD4A548);
  static const goldSoft = Color(0xFFF6CD60);
  static const darkBg = Color(0xFF111111);
  static const cardBg = Color(0xFF1C1A14);

  ThemeData _darkTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: gold,
        secondary: const Color(0xFF8D99AE),
        surface: darkBg,
        onSurface: const Color(0xFFEDE6D6),
        surfaceContainerHighest: const Color(0xFF221F17),
        error: const Color(0xFFE57373),
      ),
      scaffoldBackgroundColor: darkBg,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: darkBg,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFFEDE6D6),
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2C2820)),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF171611),
        indicatorColor: gold.withValues(alpha: 0.22),
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? gold
                  : const Color(0xFF8C8778),
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: states.contains(WidgetState.selected)
                  ? gold
                  : const Color(0xFF8C8778),
            )),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF221F17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: gold, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          side: const WidgetStatePropertyAll(BorderSide(color: Color(0xFF3A3524))),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? gold.withValues(alpha: 0.2)
                : Colors.transparent,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? darkBg : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? gold : null,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: darkBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: darkBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2C2820), space: 1),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = ref.watch(localeProvider);

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
      darkTheme: _darkTheme(),
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
