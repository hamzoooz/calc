import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:modern_calculator/core/theme/app_theme.dart';
import 'package:modern_calculator/providers/calculator_provider.dart';
import 'package:modern_calculator/providers/settings_provider.dart';
import 'package:modern_calculator/l10n/app_localizations.dart';
import 'package:modern_calculator/ui/screens/home_screen.dart';

class ModernCalculatorApp extends StatelessWidget {
  const ModernCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..init()),
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Calculator Pro',
            debugShowCheckedModeBanner: false,

            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.flutterThemeMode,

            // Localization
            locale: settings.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // Home
            home: const HomeScreen(),

            // Builder for RTL support
            builder: (context, child) {
              return Directionality(
                textDirection: settings.isRTL
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
