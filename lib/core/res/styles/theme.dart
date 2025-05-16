import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ColorScheme? scheme;
  static ThemeData lightTheme(ColorScheme? lightColorScheme) {
    scheme = lightColorScheme ??
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF36C2CE),
          brightness: Brightness.dark,
        );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme!.surface,
      fontFamily: GoogleFonts.quicksand().fontFamily,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          letterSpacing: 2,
        ),
      ),
    );
  }

  static ThemeData dartTheme(ColorScheme? darkColorScheme) {
    scheme = darkColorScheme ??
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF36C2CE),
          brightness: Brightness.light,
        );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme!.surface,
      fontFamily: GoogleFonts.quicksand().fontFamily,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          letterSpacing: 2,
        ),
      ),
    );
  }
}
