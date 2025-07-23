
import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppTheme {
  static ThemeData lightTheme({Color? seedColor}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor ?? const Color(0xFF6750A4),
        brightness: Brightness.light,
      ),
      textTheme: _buildTextTheme(Brightness.light),
       fontFamily: AppTypographyTokens.fontFamilyRoboto,
    );
  }

  static ThemeData darkTheme({Color? seedColor}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor ?? const Color(0xFF6750A4),
        brightness: Brightness.dark,
      ),
      textTheme: _buildTextTheme(Brightness.dark),
       fontFamily: AppTypographyTokens.fontFamilyRoboto,
    );
  }


  static TextTheme _buildTextTheme(Brightness brightness) {
    final textColor = brightness == Brightness.light
        ? Colors.black87
        : Colors.white70;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
         fontFamily: AppTypographyTokens.fontFamilyRoboto,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
         fontFamily: AppTypographyTokens.fontFamilyRoboto,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
         fontFamily: AppTypographyTokens.fontFamilyRoboto,
        color: textColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
         fontFamily: AppTypographyTokens.fontFamilyRoboto,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
         fontFamily: AppTypographyTokens.fontFamilyRoboto,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
         fontFamily: AppTypographyTokens.fontFamilyRoboto,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
         fontFamily: AppTypographyTokens.fontFamilyRoboto,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
         fontFamily: AppTypographyTokens.fontFamilyRoboto,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
         fontFamily: AppTypographyTokens.fontFamilyRoboto,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
         fontFamily: AppTypographyTokens.fontFamilyRoboto,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
         fontFamily: AppTypographyTokens.fontFamilyRoboto,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
         fontFamily: AppTypographyTokens.fontFamilyRoboto,
        color: textColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
         fontFamily: AppTypographyTokens.fontFamilyRoboto,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
         fontFamily: AppTypographyTokens.fontFamilyRoboto,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
         fontFamily: AppTypographyTokens.fontFamilyRoboto,
        color: textColor,
      ),
    );
  }
}