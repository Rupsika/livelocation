import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Clean Professional Navy / Indigo Accent Palette
  static const Color primary = Color(0xFF3B82F6); // Clean Indigo/Blue Primary Accent
  static const Color secondary = Color(0xFF10B981); // Emerald Secondary
  static const Color sidebarBg = Color(0xFFFFFFFF);
  static const Color scaffoldBg = Color(0xFFF3F4F6); // Soft clean grey background
  static const Color onlineGreen = Color(0xFF10B981);
  static const Color offlineRed = Color(0xFFEF4444);
  static const Color warningOrange = Color(0xFFF59E0B);

  // Clean Metric Card Gradients
  static const List<Color> gradientBlue = [Color(0xFF60A5FA), Color(0xFF2563EB)];
  static const List<Color> gradientTeal = [Color(0xFF34D399), Color(0xFF059669)];
  static const List<Color> gradientOrange = [Color(0xFFFBBF24), Color(0xFFD97706)];

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: scaffoldBg,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
    ),
    textTheme: GoogleFonts.ubuntuTextTheme(ThemeData.light().textTheme),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF111827),
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: Color(0xFF1F2937),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1F2937),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
    ),
    textTheme: GoogleFonts.ubuntuTextTheme(ThemeData.dark().textTheme),
  );
}
