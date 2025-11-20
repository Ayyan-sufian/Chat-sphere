import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme{
  static const Color primaryColor = Color(0XFF6C5CE7 );
  static const Color secondaryColor = Color(0XFF74B9FF );
  static const Color accentColor = Color(0XFFFD79A8 );
  static const Color backgroundColor = Color(0XFFF8F9Fa );
  static const Color cardColor = Color(0XFFFFFFFF );
  static const Color textPrimaryTheme = Color(0XFF2D3436 );
  static const Color textSceTheme = Color(0XFF636E72 );
  static const Color borderColor = Color(0XFFDDD6FE );
  static const Color errorColor = Colors.red;
  static const Color successColor = Color(0XFF00B894);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light( primary: primaryColor,onPrimary: Colors.white, surface: backgroundColor, secondary: secondaryColor, onSecondary: Colors.white, error: errorColor, onSurface: textPrimaryTheme, onBackground: textPrimaryTheme),textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimaryTheme
  ),
    headlineMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimaryTheme
    ),
    headlineSmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textPrimaryTheme
    ),
    bodyLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: textPrimaryTheme),
    bodyMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textPrimaryTheme),
    bodySmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textPrimaryTheme),
  ),
appBarTheme: AppBarTheme(
  backgroundColor: Colors.transparent,
  titleTextStyle: TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 18,
    color: textPrimaryTheme,
  ),
  iconTheme: IconThemeData(color: textPrimaryTheme),
),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsetsGeometry.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,fontWeight: FontWeight.w600
        ),
      ),
    ),cardTheme: CardThemeData(
    color: cardColor,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: borderColor,width: 1)
    )
  ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorColor,),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: 16,horizontal: 16
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    )
  );
}