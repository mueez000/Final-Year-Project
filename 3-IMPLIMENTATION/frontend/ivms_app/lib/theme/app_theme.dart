import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Green (Driver/Officer)
  static const Color green950 = Color(0xFF022C22);
  static const Color green900 = Color(0xFF064E3B);
  static const Color green800 = Color(0xFF065F46);
  static const Color green700 = Color(0xFF047857);
  static const Color green600 = Color(0xFF059669);
  static const Color green500 = Color(0xFF10B981);
  static const Color green400 = Color(0xFF34D399);

  // Brand Colors - Navy (Admin)
  static const Color navy950 = Color(0xFF000D1A);
  static const Color navy900 = Color(0xFF001226);
  static const Color navy800 = Color(0xFF001830);
  static const Color navy700 = Color(0xFF002147);

  // Brand Colors - Blue (Officer)
  static const Color blue950 = Color(0xFF0A192F);
  static const Color blue900 = Color(0xFF0F2A4A);
  static const Color blue800 = Color(0xFF173D6E);
  static const Color blue700 = Color(0xFF1E4D8C);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue400 = Color(0xFF60A5FA);

  // Accent Colors
  static const Color gold = Color(0xFFFBBF24);
  static const Color goldLight = Color(0xFFFCD34D);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // Neutral Colors
  static const Color textDark = Color(0xFF0F172A);
  static const Color textAdmin = Color(0xFF1E293B);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: green500,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme(),
      colorScheme: const ColorScheme.light(
        primary: green500,
        secondary: gold,
        surface: surface,
        error: danger,
        onPrimary: Colors.white,
        onSecondary: textDark,
        onSurface: textDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: green500,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: green500, width: 2),
        ),
        hintStyle: const TextStyle(color: muted),
      ),
    );
  }

  static ThemeData get adminTheme {
    return lightTheme.copyWith(
      primaryColor: navy800,
      colorScheme: lightTheme.colorScheme.copyWith(
        primary: navy800,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navy800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
