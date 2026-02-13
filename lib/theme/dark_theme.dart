import 'package:flutter/material.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

ThemeData dark = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: const Color(0xFFF97A00), // Updated to brand orange
  secondaryHeaderColor: const Color(0xFF9112BC), // Updated to brand purple
  disabledColor: const Color(0xFF6f7275),
  brightness: Brightness.dark,
  hintColor: const Color(0xFFbebebe),
  cardColor: Colors.black,
  shadowColor: Colors.white.withValues(alpha: 0.03),
  scaffoldBackgroundColor: const Color(0xFF161617),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFFF97A00), // brand orange
    ),
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFF97A00), // brand orange
    secondary: Color(0xFF9112BC), // brand purple
  ).copyWith(
    error: const Color(0xFFdd3135),
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: Color(0xFF29292D),
    surfaceTintColor: Color(0xFF29292D),
  ),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white10),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
  ),
  bottomAppBarTheme: const BottomAppBarThemeData(
    color: Colors.black,
    height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: const DividerThemeData(
    thickness: 0.2,
    color: Color(0xFFA0A4A8),
  ),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);
