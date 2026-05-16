import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Exact Tasmota colors but enhanced
  static const Color tasmotaBlue = Color(0xFF1FA3EC);
  static const Color tasmotaDarkBlue = Color(0xFF0E70A4);
  static const Color accentTeal = Color(0xFF00E5FF);
  
  // Dark Theme (Modern)
  static const Color tasmotaTextDark = Color(0xFFF5F5F5);
  static const Color tasmotaBgDark = Color(0xFF0F172A); // Deep Slate
  static const Color tasmotaContainerDark = Color(0xFF1E293B);
  static const Color tasmotaButtonDark = Color(0xFF334155);
  static const Color tasmotaBlack = Color(0xFF020617);

  // Light Theme
  static const Color tasmotaTextLight = Color(0xFF1E293B);
  static const Color tasmotaBgLight = Color(0xFFF8FAFC);
  static const Color tasmotaContainerLight = Color(0xFFFFFFFF);

  static const double borderRadius = 24.0;

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: tasmotaBlue,
        primary: tasmotaBlue,
        onPrimary: Colors.white,
        secondary: accentTeal,
        surface: tasmotaBgLight,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: tasmotaBgLight,
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: tasmotaTextLight,
        displayColor: tasmotaTextLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: tasmotaTextLight,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: tasmotaContainerLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: Colors.blue.withOpacity(0.05), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tasmotaBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: tasmotaBlue,
        primary: tasmotaBlue,
        onPrimary: Colors.white,
        secondary: accentTeal,
        surface: tasmotaBgDark,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: tasmotaBgDark,
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: tasmotaTextDark,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: tasmotaTextDark,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: tasmotaContainerDark.withOpacity(0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tasmotaButtonDark,
          foregroundColor: tasmotaTextDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tasmotaContainerDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        elevation: 24,
      ),
    );
  }

  static BoxDecoration glassDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark 
          ? Colors.white.withOpacity(0.05) 
          : Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark 
            ? Colors.white.withOpacity(0.1) 
            : Colors.white.withOpacity(0.2),
      ),
    );
  }
}
