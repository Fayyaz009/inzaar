import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color forest = Color(0xFF123C32);
  static const Color moss = Color(0xFF2E6A56);
  static const Color gold = Color(0xFFC49A53);
  static const Color parchment = Color(0xFFF7F1E3);
  static const Color ink = Color(0xFF111111);
  static const Color night = Color(0xFF0C0C0C);
  static const Color charcoal = Color(0xFF1A1A1A);

  static const Color primaryGreen = charcoal;
  static const Color primaryBeige = parchment;

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: charcoal,
      brightness: Brightness.light,
      primary: charcoal,
      secondary: gold,
      surface: const Color(0xFFFCFCFC),
    );

    return _baseTheme(colorScheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFFFCFCFC),
      cardColor: Colors.white,
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: charcoal,
      brightness: Brightness.dark,
      primary: const Color(0xFFE0E0E0),
      secondary: const Color(0xFFE0B870),
      surface: night,
    );

    return _baseTheme(colorScheme).copyWith(
      scaffoldBackgroundColor: night,
      cardColor: const Color(0xFF161616),
    );
  }

  static ThemeData get sepiaTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8A6235),
      brightness: Brightness.light,
      primary: const Color(0xFF6C4B2A),
      secondary: gold,
      surface: parchment,
    );

    return _baseTheme(colorScheme).copyWith(
      scaffoldBackgroundColor: parchment,
      cardColor: const Color(0xFFFFF7EA),
    );
  }

  static ThemeData _baseTheme(ColorScheme colorScheme) {
    final textTheme = TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
      displaySmall: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
      headlineSmall: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w700),
      titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
      bodySmall: GoogleFonts.inter(fontWeight: FontWeight.w500),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w700),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontSize: 24,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.14),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant;
          return IconThemeData(color: color);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.manrope(
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
            fontSize: 12,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static TextStyle urduStyle({
    double fontSize = 18.0,
    String fontFamily = 'Jameel',
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: fontFamily,
      height: 1.5,
    );
  }
}
