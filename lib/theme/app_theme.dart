import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Manus AI Brand Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFFF8F8F8);
  static const Color black = Color(0xFF34322D);
  
  // Additional colors
  static const Color mutedText = Color(0xFF7A7A7A);
  static const Color border = Color(0xFFE8E8E8);
  static const Color error = Color(0xFFDC3545);
  static const Color success = Color(0xFF28A745);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: gray,
      colorScheme: const ColorScheme.light(
        primary: black,
        onPrimary: white,
        secondary: gray,
        onSecondary: black,
        surface: white,
        onSurface: black,
        error: error,
        onError: white,
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.dmSans(color: black, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.dmSans(color: black, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.dmSans(color: black, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.dmSans(color: black, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.dmSans(color: black, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.dmSans(color: black, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.dmSans(color: black, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.dmSans(color: black, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.dmSans(color: black, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.dmSans(color: black),
        bodyMedium: GoogleFonts.dmSans(color: black),
        bodySmall: GoogleFonts.dmSans(color: mutedText),
        labelLarge: GoogleFonts.dmSans(color: black, fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.dmSans(color: black),
        labelSmall: GoogleFonts.dmSans(color: mutedText),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSans(
          color: black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: black,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: black,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: black,
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: black, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.dmSans(color: mutedText),
        labelStyle: GoogleFonts.dmSans(color: black),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: black,
        foregroundColor: white,
        elevation: 2,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return black;
          }
          return white;
        }),
        checkColor: WidgetStateProperty.all(white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: border, width: 2),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: GoogleFonts.dmSans(
          color: black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: black,
        contentTextStyle: GoogleFonts.dmSans(color: white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}
