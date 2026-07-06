import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/admin_data_store.dart';
import 'core/app_colors.dart';
import 'core/app_localizations.dart';
import 'core/theme_provider.dart';
import 'core/language_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AdminDataStore()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Holds light and dark [ThemeData] for the app, enforcing theme-based UI.
class AppThemes {
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      surface: const Color(0xFFF5F6FA),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F6FA),
    cardColor: const Color(0xFFF7F7FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F6FA),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFF141518),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      iconTheme: IconThemeData(color: Color(0xFF141518)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColors.primary),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
      hintStyle: const TextStyle(
        color: Color(0xFFB0B3B8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDBDBE4), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF141518), fontFamilyFallback: ['Segoe UI', 'Tahoma', 'Arial', 'sans-serif']),
      bodyMedium: TextStyle(color: Color(0xFF39394D), fontFamilyFallback: ['Segoe UI', 'Tahoma', 'Arial', 'sans-serif']),
      bodySmall: TextStyle(color: Color(0xFF717187), fontFamilyFallback: ['Segoe UI', 'Tahoma', 'Arial', 'sans-serif']),
      titleLarge: TextStyle(color: Color(0xFF141518), fontWeight: FontWeight.bold, fontFamilyFallback: ['Segoe UI', 'Tahoma', 'Arial', 'sans-serif']),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF141518),
    ),
    dividerColor: Color(0xFFE0E0E3),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.9),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF181A20),
    cardColor: const Color(0xFF23262F),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF181A20),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColors.primary),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF23262F),
      hintStyle: const TextStyle(
        color: Color(0xFFB0B3B8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF353941), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontFamilyFallback: ['Segoe UI', 'Tahoma', 'Arial', 'sans-serif']),
      bodyMedium: TextStyle(color: Color(0xFFDBDBE4), fontFamilyFallback: ['Segoe UI', 'Tahoma', 'Arial', 'sans-serif']),
      bodySmall: TextStyle(color: Color(0xFFB0B3B8), fontFamilyFallback: ['Segoe UI', 'Tahoma', 'Arial', 'sans-serif']),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamilyFallback: ['Segoe UI', 'Tahoma', 'Arial', 'sans-serif']),
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    dividerColor: Color(0xFF353941),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppThemes.light,
          darkTheme: AppThemes.dark,
          themeMode: themeProvider.themeMode,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('ar'), // Arabic
          ],
          locale: languageProvider.selectedLocale,
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            if (deviceLocale == null) return supportedLocales.first;
            for (final l in supportedLocales) {
              if (l.languageCode == deviceLocale.languageCode) return l;
            }
            return supportedLocales.first;
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
