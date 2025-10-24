import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      labelMedium: TextStyle(
        fontFamily: 'Inter',
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
  );
}