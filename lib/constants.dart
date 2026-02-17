import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  
  static const Color background = Color(0xFFF5F5F5);
  static const Color white = Colors.white;
  static const Color surface = Color(0xFFFFFFFF);
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  static const Color accent = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
}



class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      
     
    );
  }
}