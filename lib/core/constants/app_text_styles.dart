import 'package:flutter/material.dart';
import 'app_colors.dart';

// Nguyên tắc 4: Sử dụng font chữ phù hợp
// - Kích thước: 14-16px cho body text, 18-24px cho heading
// - Line height: 1.5 cho dễ đọc
// - Font weight: Regular (400), Medium (500), SemiBold (600), Bold (700)
// - Tránh sử dụng quá nhiều font weight khác nhau (Nguyên tắc 8: Thiết kế nhất quán)
class AppTextStyles {
  // Heading styles - Phân cấp rõ ràng để dễ đọc
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2, // Tight line height for headings
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body text styles - Tối ưu cho khả năng đọc
  // 16px là kích thước tốt nhất cho body text trên mobile
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5, // Line height 1.5 cho khả năng đọc tốt
  );

  // 14px cho text phụ, vẫn đọc được dễ dàng
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // 12px là minimum cho text trên mobile
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Special text styles - Sử dụng nhất quán
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
    height: 1.4,
  );

  // Button text - Rõ ràng và dễ đọc
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.0, // Tight for buttons
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.0,
  );

  // Header styles
  static const TextStyle headerTitle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: -0.5,
    shadows: [
      Shadow(
        offset: Offset(0, 2),
        blurRadius: 4,
        color: Color(0x40000000),
      ),
    ],
  );

  static const TextStyle headerSubtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    letterSpacing: 1.0,
    shadows: [
      Shadow(
        offset: Offset(0, 1),
        blurRadius: 2,
        color: Color(0x40000000),
      ),
    ],
  );

  // Spinner result style
  static const TextStyle spinnerResult = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    letterSpacing: -1,
  );

  static const TextStyle chipText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}
