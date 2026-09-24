import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_color_scheme.dart';
import 'app_tokens.dart';

/// "Warm Amber & Ink" — the one locked accent (amber) on warm stone
/// neutrals, Manrope for type, pill-shaped actions / AppRadius.card cards /
/// AppRadius.control inputs. See AppRadius for the shape scale.
class AppTheme {
  static const _pillShape = StadiumBorder();

  static ThemeData fromDynamic(ColorScheme? dynamicScheme, {required bool isDark}) {
    if (dynamicScheme != null) {
      final base = isDark ? dark : light;
      final colorScheme = dynamicScheme.copyWith(
        surface: isDark ? const Color(0xFF292524) : Colors.white,
      );
      return base.copyWith(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: isDark ? const Color(0xFF1C1917) : const Color(0xFFFAFAF9),
        appBarTheme: base.appBarTheme.copyWith(
          backgroundColor: isDark ? const Color(0xFF292524) : Colors.white,
          foregroundColor: colorScheme.onSurface,
        ),
        cardTheme: base.cardTheme.copyWith(
          color: isDark ? const Color(0xFF292524) : Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: const Size.fromHeight(50),
            shape: _pillShape,
            elevation: 0,
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
    return isDark ? dark : light;
  }

  static ThemeData get light {
    const primaryColor = Color(0xFFB45309); // amber-700 — the one locked accent
    const secondaryColor = Color(0xFF78716C); // stone-500
    const tertiaryColor = Color(0xFF9A3412); // orange-800, warm complement to the accent
    const errorColor = Color(0xFFDC2626); // red-600

    final base = ThemeData(brightness: Brightness.light);
    final textTheme = _tabularStats(GoogleFonts.manropeTextTheme(base.textTheme));

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        surface: Colors.white,
        error: errorColor,
      ),
      scaffoldBackgroundColor: const Color(0xFFFAFAF9), // stone-50
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C1917), // stone-900
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF57534E)), // stone-600
        titleTextStyle: GoogleFonts.manrope(
          color: const Color(0xFF1C1917),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: Color(0xFFE7E5E4), width: 1), // stone-200
        ),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAFAF9), // stone-50
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: Color(0xFFD6D3D1), width: 1), // stone-300
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: Color(0xFFE7E5E4), width: 1), // stone-200
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: _pillShape,
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: _pillShape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: Color(0xFFD6D3D1), width: 1), // stone-300
          shape: _pillShape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: _pillShape),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: const BorderSide(color: Color(0xFFE7E5E4)),
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppColorScheme.light,
      ],
    );
  }

  static ThemeData get dark {
    const primaryColor = Color(0xFFFBBF24); // amber-400
    const secondaryColor = Color(0xFFA8A29E); // stone-400
    const tertiaryColor = Color(0xFFF97316); // orange-500
    const surfaceColor = Color(0xFF1C1917); // stone-900
    const cardColor = Color(0xFF292524); // stone-800
    const errorColor = Color(0xFFFCA5A5); // red-300

    final base = ThemeData(brightness: Brightness.dark);
    final textTheme = _tabularStats(GoogleFonts.manropeTextTheme(base.textTheme));

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        surface: cardColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: surfaceColor,
      appBarTheme: AppBarTheme(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.manrope(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: Color(0xFF44403C), width: 1), // stone-700
        ),
        color: cardColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: Color(0xFF44403C), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: Color(0xFF44403C), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: surfaceColor,
          minimumSize: const Size.fromHeight(50),
          shape: _pillShape,
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: _pillShape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: Color(0xFF44403C), width: 1),
          shape: _pillShape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: _pillShape),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: const BorderSide(color: Color(0xFF44403C)),
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppColorScheme.dark,
      ],
    );
  }

  /// Tabular (monospaced-width) numerals on the headline styles used to
  /// display stats/percentages, so counters don't jitter as digits change.
  static TextTheme _tabularStats(TextTheme theme) {
    const tabular = [FontFeature.tabularFigures()];
    return theme.copyWith(
      headlineLarge: theme.headlineLarge?.copyWith(fontFeatures: tabular),
      headlineMedium: theme.headlineMedium?.copyWith(fontFeatures: tabular),
      headlineSmall: theme.headlineSmall?.copyWith(fontFeatures: tabular),
    );
  }
}
