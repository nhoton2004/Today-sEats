import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFFFF6B6B);
  static const Color primaryLight = Color(0xFFFF8787);
  static const Color primaryDark = Color(0xFFEE5A52);
  
  // Secondary colors
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color secondaryLight = Color(0xFF6FE5DC);
  static const Color secondaryDark = Color(0xFF3DBDB5);
  
  // Accent colors
  static const Color accent = Color(0xFFFFA07A);
  static const Color accentLight = Color(0xFFFFB799);
  static const Color accentDark = Color(0xFFFF8A5B);
  
  // Neutral colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  
  // Text colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);
  
  // Status colors
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFF56565);
  static const Color info = Color(0xFF4299E1);
  
  // Meal type colors
  static const Color breakfast = Color(0xFFFED766);
  static const Color lunch = Color(0xFF4ECDC4);
  static const Color dinner = Color(0xFFFF6B6B);
  static const Color snack = Color(0xFFAB83A1);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8787)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient headerGradient = LinearGradient(
    colors: [
      Color(0x00000000),
      Color(0x99000000),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
