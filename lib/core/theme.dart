import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Exact Tasmota colors from documentation
  static const Color tasmotaBlue = Color(0xFF1FA3EC);
  static const Color tasmotaDarkBlue = Color(0xFF0E70A4);
  
  // Dark Theme (Default)
  static const Color tasmotaTextDark = Color(0xFFEAEAEA);
  static const Color tasmotaBgDark = Color(0xFF252525);
  static const Color tasmotaContainerDark = Color(0xFF1F1F1F);
  static const Color tasmotaButtonDark = Color(0xFF4F4F4F);
  static const Color tasmotaBlack = Color(0xFF000000);

  // Light Theme
  static const Color tasmotaTextLight = Color(0xFF000000);
  static const Color tasmotaBgLight = Color(0xFFFFFFFF);
  static const Color tasmotaContainerLight = Color(0xFFF2F2F2);

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: tasmotaBlue,
        primary: tasmotaBlue,
        onPrimary: Colors.white,
        secondary: tasmotaDarkBlue,
        surface: tasmotaBgLight,
        // background is deprecated
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: tasmotaTextLight,
        displayColor: tasmotaTextLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: tasmotaBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: tasmotaBgLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tasmotaBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          elevation: 1,
        ),
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
        secondary: tasmotaDarkBlue,
        surface: tasmotaBgDark,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: tasmotaTextDark,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: tasmotaBlack, // Tasmota dark header is often black
        foregroundColor: tasmotaTextDark,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: tasmotaBgDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFF333333), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tasmotaButtonDark,
          foregroundColor: tasmotaTextDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          elevation: 0,
        ),
      ),
      // For active/primary buttons, use a specific style if needed, 
      // but Material 3 uses colorScheme.primary for FilledButton etc.
    );
  }
}
