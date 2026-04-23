import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _darkBg = Color(0xFF1E1E2E);
  static const Color _darkSurface = Color(0xFF252535);
  static const Color _darkCard = Color(0xFF2A2A3E);
  static const Color _accent = Color(0xFF7C3AED);
  static const Color _accentLight = Color(0xFFA78BFA);
  static const Color _darkText = Color(0xFFCDD6F4);
  static const Color _darkSubtext = Color(0xFF9399B2);

  static const Color _lightBg = Color(0xFFF8F8FC);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightCard = Color(0xFFF0F0F8);
  static const Color _lightText = Color(0xFF1E1E2E);
  static const Color _lightSubtext = Color(0xFF6B6B8A);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _accent,
        secondary: _accentLight,
        surface: _darkSurface,
        background: _darkBg,
        onBackground: _darkText,
        onSurface: _darkText,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: _darkBg,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: GoogleFonts.inter(color: _darkText, fontSize: 15),
        bodyMedium: GoogleFonts.inter(color: _darkText, fontSize: 14),
        bodySmall: GoogleFonts.inter(color: _darkSubtext, fontSize: 12),
        titleLarge: GoogleFonts.inter(
            color: _darkText, fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.inter(
            color: _darkText, fontSize: 16, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.inter(
            color: _darkSubtext, fontSize: 14, fontWeight: FontWeight.w500),
        headlineMedium: GoogleFonts.inter(
            color: _darkText, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardTheme(
        color: _darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintStyle: GoogleFonts.inter(color: _darkSubtext),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
            color: _darkText, fontSize: 18, fontWeight: FontWeight.w600),
        iconTheme: const IconThemeData(color: _darkText),
      ),
      dividerColor: const Color(0xFF313244),
      iconTheme: const IconThemeData(color: _darkSubtext),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _accent,
        secondary: _accentLight,
        surface: _lightSurface,
        background: _lightBg,
        onBackground: _lightText,
        onSurface: _lightText,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: _lightBg,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        bodyLarge: GoogleFonts.inter(color: _lightText, fontSize: 15),
        bodyMedium: GoogleFonts.inter(color: _lightText, fontSize: 14),
        bodySmall: GoogleFonts.inter(color: _lightSubtext, fontSize: 12),
        titleLarge: GoogleFonts.inter(
            color: _lightText, fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.inter(
            color: _lightText, fontSize: 16, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.inter(
            color: _lightSubtext, fontSize: 14, fontWeight: FontWeight.w500),
        headlineMedium: GoogleFonts.inter(
            color: _lightText, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardTheme(
        color: _lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintStyle: GoogleFonts.inter(color: _lightSubtext),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _lightSurface,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
            color: _lightText, fontSize: 18, fontWeight: FontWeight.w600),
        iconTheme: const IconThemeData(color: _lightText),
      ),
      dividerColor: const Color(0xFFE0E0F0),
      iconTheme: const IconThemeData(color: _lightSubtext),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
