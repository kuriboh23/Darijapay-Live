// lib/app/config/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBackground = Color(0xFF1A3A3A);
  static const Color primaryAccent = Color(0xFFE56B20);
  static const Color positiveAccent = Color(0xFF66B8A0);
  static const Color textHeadings = Color(0xFFF0F2F2);
  static const Color textBody = Color(0xFFA8B5B5);

  static final ThemeData themeData = ThemeData(
    scaffoldBackgroundColor: primaryBackground,
    fontFamily: 'Inter',
    brightness: Brightness.dark, // Important for theme consistency
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textHeadings, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: textBody),
    ),
  );
}