import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Vibrant Purple Admin Theme (Matching Purple Admin Template)
  static const Color primaryPurple = Color(0xFF9A55FF); // Vibrant Purple accent
  static const Color primary = Color(0xFF9A55FF);
  static const Color secondary = Color(0xFF3699FF);
  static const Color sidebarBg = Color(0xFFFFFFFF);
  static const Color scaffoldBg = Color(0xFFF2F4F9); // Light soft purple-grey background
  static const Color onlineGreen = Color(0xFF1B84FF);
  static const Color offlineRed = Color(0xFFF1416C);
  static const Color warningOrange = Color(0xFFFF9900);

  // Gradient definitions from Purple Admin
  static const List<Color> gradientPink = [Color(0xFFFFBF96), Color(0xFFFE7096)];
  static const List<Color> gradientBlue = [Color(0xFF90CAF9), Color(0xFF047DF6)];
  static const List<Color> gradientTeal = [Color(0xFF84D9D2), Color(0xFF07CDAE)];

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: scaffoldBg,
    colorScheme: const ColorScheme.light(
      primary: primaryPurple,
      secondary: secondary,
      surface: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
    ),
    textTheme: GoogleFonts.ubuntuTextTheme(ThemeData.light().textTheme),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF181824),
    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      secondary: secondary,
      surface: Color(0xFF1E1E2D),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E2D),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
    ),
    textTheme: GoogleFonts.ubuntuTextTheme(ThemeData.dark().textTheme),
  );
}
