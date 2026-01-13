import 'package:flutter/material.dart';

class AppTheme {
  static const Color yaleBlue = Color(0xFF004A98);
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color borderGray = Color(0xFFE0E0E0);
  static const Color textGray = Color(0xFF6C757D);
  static const Color textBlack = Color(0xFF212529);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2A2A2A);
  static const Color accentBlue = Color(0xFF5B9FFF);
  static const Color darkBorder = Color(0xFF3A3A3A);

  static const double _buttonRadius = 12;
  static const double _cardRadius = 16;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: offWhite,
    colorScheme: const ColorScheme.light(
      primary: yaleBlue,
      secondary: yaleBlue,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: textBlack,
      error: Color(0xFFDC3545),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: yaleBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: yaleBlue,
      unselectedItemColor: textGray,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: yaleBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: yaleBlue,
        side: const BorderSide(color: borderGray),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: yaleBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: textGray, fontWeight: FontWeight.w500),
      hintStyle: const TextStyle(color: textGray),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: const BorderSide(color: borderGray, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: const BorderSide(color: borderGray, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: const BorderSide(color: yaleBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.all(12),
    ),
    dividerTheme: const DividerThemeData(
      color: borderGray,
      thickness: 1,
      space: 1,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textBlack, fontSize: 16, height: 1.3),
      bodyMedium: TextStyle(color: textBlack, fontSize: 14, height: 1.3),
      bodySmall: TextStyle(color: textGray, fontSize: 12, height: 1.3),
      titleLarge: TextStyle(
        color: textBlack,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: textBlack,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: textBlack,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: accentBlue,
      secondary: accentBlue,
      surface: darkSurface,
      onPrimary: Colors.white,
      onSurface: Colors.white,
      onSecondary: Colors.white,
      error: Color(0xFFFF5555),
      outline: darkBorder,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: accentBlue,
      unselectedItemColor: Colors.white70,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 4,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: darkBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      labelStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
      hintStyle: const TextStyle(color: Colors.white54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: const BorderSide(color: darkBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: const BorderSide(color: darkBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: const BorderSide(color: accentBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.all(12),
    ),
    dividerTheme: const DividerThemeData(
      color: darkBorder,
      thickness: 1,
      space: 1,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16, height: 1.3),
      bodyMedium: TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
      bodySmall: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
