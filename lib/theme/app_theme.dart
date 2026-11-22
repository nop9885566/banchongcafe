import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand Color Tokens
  static const Color primaryDarkGreen = Color(0xFF1F493A);
  static const Color sageGreen = Color(0xFF7E946F);
  static const Color lightGreen = Color(0xFFE5EEE8);
  static const Color warmCream = Color(0xFFF7F4ED);
  static const Color background = Color(0xFFFAF9F6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color coffeeBrown = Color(0xFF76583D);
  static const Color darkText = Color(0xFF2F332F);
  static const Color secondaryText = Color(0xFF7C817C);
  static const Color border = Color(0xFFE8ECE9);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color statusPending = Color(0xFFC4883B); // Warm Amber/Coffee
  static const Color statusPreparing = Color(0xFF4A7C59);
  static const Color statusReady = Color(0xFF1F493A); // Dark Green for Ready
}

class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 12,
      offset: Offset(0, 2),
    ),
  ];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryDarkGreen,
        onPrimary: AppColors.white,
        secondary: AppColors.sageGreen,
        onSecondary: AppColors.white,
        error: AppColors.errorRed,
        onError: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.darkText,
      ),
      textTheme: GoogleFonts.notoSansThaiTextTheme().copyWith(
        displayLarge: GoogleFonts.notoSansThai(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        displayMedium: GoogleFonts.notoSansThai(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        titleLarge: GoogleFonts.notoSansThai(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        titleMedium: GoogleFonts.notoSansThai(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        bodyLarge: GoogleFonts.notoSansThai(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.darkText,
        ),
        bodyMedium: GoogleFonts.notoSansThai(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.secondaryText,
        ),
        labelLarge: GoogleFonts.notoSansThai(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primaryDarkGreen,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSansThai(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDarkGreen,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkGreen,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.notoSansThai(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDarkGreen,
          side: const BorderSide(color: AppColors.primaryDarkGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.notoSansThai(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryDarkGreen, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        hintStyle: GoogleFonts.notoSansThai(
          color: AppColors.secondaryText.withAlpha(150),
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.notoSansThai(
          color: AppColors.secondaryText,
          fontSize: 14,
        ),
      ),
    );
  }
}
