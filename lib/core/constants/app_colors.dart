import 'package:flutter/material.dart';

// Nguyên tắc 10: Sử dụng bảng màu phù hợp, hài hòa, dịu mắt
// Bảng màu được thiết kế theo nguyên tắc 60-30-10 và WCAG accessibility
// Hỗ trợ cả Light và Dark mode
class AppColors {
  // ==================== LIGHT THEME ====================
  
  // Primary colors - Màu chính (60%)
  // Sử dụng màu cam đỏ ấm áp, gợi cảm giác thân thiện và ngon miệng
  static const Color lightPrimary = Color(0xFFFF6B6B); // Coral Red
  static const Color lightPrimaryLight = Color(0xFFFF8787);
  static const Color lightPrimaryDark = Color(0xFFEE5A52);

  // Secondary colors - Màu phụ (30%)
  static const Color lightSecondary = Color(0xFF4ECDC4); // Turquoise
  static const Color lightSecondaryLight = Color(0xFF6FE5DC);
  static const Color lightSecondaryDark = Color(0xFF3DBDB5);

  // Accent colors - Màu nhấn (10%)
  static const Color lightAccent = Color(0xFFFFA07A); // Light salmon
  static const Color lightAccentLight = Color(0xFFFFB799);
  static const Color lightAccentDark = Color(0xFFFF8A5B);

  // Neutral colors
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Colors.white;
  static const Color lightCardBackground = Colors.white;

  // Text colors
  static const Color lightTextPrimary = Color(0xFF2D3748);
  static const Color lightTextSecondary = Color(0xFF718096);
  static const Color lightTextLight = Color(0xFFA0AEC0);

  // ==================== DARK THEME ====================
  
  // Primary colors - Lighter coral for dark mode
  static const Color darkPrimary = Color(0xFFFF8787);
  static const Color darkPrimaryLight = Color(0xFFFF9E9E);
  static const Color darkPrimaryDark = Color(0xFFFF6B6B);

  // Secondary colors - Brighter turquoise for visibility
  static const Color darkSecondary = Color(0xFF5FD9D0);
  static const Color darkSecondaryLight = Color(0xFF7FE4DC);
  static const Color darkSecondaryDark = Color(0xFF4ECDC4);

  // Accent colors
  static const Color darkAccent = Color(0xFFFFB799);
  static const Color darkAccentLight = Color(0xFFFFC8A8);
  static const Color darkAccentDark = Color(0xFFFFA07A);

  // Neutral colors - Dark mode backgrounds
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkCardBackground = Color(0xFF2D2D2D);

  // Text colors - Light colors for dark backgrounds
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextLight = Color(0xFF808080);

  // ==================== SHARED COLORS ====================
  
  // Status colors (same for both themes)
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFF56565);
  static const Color info = Color(0xFF4299E1);

  // Meal type colors (same for both themes)
  static const Color breakfast = Color(0xFFFED766);
  static const Color lunch = Color(0xFF4ECDC4);
  static const Color dinner = Color(0xFFFF6B6B);
  static const Color snack = Color(0xFFAB83A1);

  // ==================== HELPER METHODS ====================
  
  /// Get primary color based on theme
  static Color getPrimary(bool isDark) => isDark ? darkPrimary : lightPrimary;
  
  /// Get background color based on theme
  static Color getBackground(bool isDark) => isDark ? darkBackground : lightBackground;
  
  /// Get surface color based on theme
  static Color getSurface(bool isDark) => isDark ? darkSurface : lightSurface;
  
  /// Get card background color based on theme
  static Color getCardBackground(bool isDark) => isDark ? darkCardBackground : lightCardBackground;
  
  /// Get text primary color based on theme
  static Color getTextPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  
  /// Get text secondary color based on theme
  static Color getTextSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  
  /// Get text light color based on theme
  static Color getTextLight(bool isDark) => isDark ? darkTextLight : lightTextLight;

  // ==================== GRADIENTS ====================
  
  // Primary gradient - light theme
  static const LinearGradient lightPrimaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8787)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Primary gradient - dark theme
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFFFF8787), Color(0xFFFF9E9E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Header gradient (for image overlays)
  static const LinearGradient headerGradient = LinearGradient(
    colors: [
      Color(0x00000000),
      Color(0x99000000),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Get primary gradient based on theme
  static LinearGradient getPrimaryGradient(bool isDark) => 
      isDark ? darkPrimaryGradient : lightPrimaryGradient;

  // ==================== BACKWARD COMPATIBILITY ====================
  // Keep old static references for gradual migration
  
  static const Color primary = lightPrimary;
  static const Color primaryLight = lightPrimaryLight;
  static const Color primaryDark = lightPrimaryDark;
  static const Color secondary = lightSecondary;
  static const Color secondaryLight = lightSecondaryLight;
  static const Color secondaryDark = lightSecondaryDark;
  static const Color accent = lightAccent;
  static const Color accentLight = lightAccentLight;
  static const Color accentDark = lightAccentDark;
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color cardBackground = lightCardBackground;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textLight = lightTextLight;
  static const LinearGradient primaryGradient = lightPrimaryGradient;
}
