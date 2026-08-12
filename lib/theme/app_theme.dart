import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF388E8E); // Primary Teal
  static const Color primaryTeal = Color(0xFF388E8E);
  static const Color secondary = Color(0xFF88D49E);
  static const Color accentGreen = Color(0xFF88D49E);
  static const Color sidebarBg = Color(0xFF2C4A6F); // Slate Navy
  static const Color scaffoldBg = Color(0xFFEFEFEF);
  static const Color cardBg = Color(0xFFFFFFFF);

  static const Color onlineGreen = Color(0xFF2ECC71);
  static const Color offlineRed = Color(0xFFE74C3C);
  static const Color warningOrange = Color(0xFFF39C12);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: scaffoldBg,
    colorScheme: const ColorScheme.light(
      primary: primaryTeal,
      secondary: accentGreen,
      surface: cardBg,
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
    ),
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1E272C),
    colorScheme: const ColorScheme.dark(
      primary: primaryTeal,
      secondary: accentGreen,
      surface: Color(0xFF2C3E50),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2C3E50),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Color(0xFF34495E)),
      ),
    ),
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
  );
}
