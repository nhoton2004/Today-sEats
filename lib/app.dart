import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_text_styles.dart';
import 'core/constants/app_constants.dart';
import 'core/services/ai_service.dart';
import 'core/services/storage_service.dart';
import 'features/1_dish_spinner/dish_spinner_provider.dart';
import 'features/2_fridge_ai/fridge_ai_provider.dart';
import 'features/3_menu_management/menu_management_provider.dart';
import 'features/home/home_view.dart';

class TodaysEatsApp extends StatelessWidget {
  const TodaysEatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DishSpinnerProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => FridgeAIProvider(AIService()),
        ),
        ChangeNotifierProvider(
          create: (_) => MenuManagementProvider(StorageService())..initialize(),
        ),
      ],
      child: MaterialApp(
        title: "Today's Eats",
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const HomeView(),
      ),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        titleLarge: AppTextStyles.h4,
        titleMedium: AppTextStyles.h5,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.defaultPadding,
            horizontal: AppConstants.largePadding,
          ),
        ),
      ),
      tabBarTheme: const TabBarTheme(
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
      ),
    );
  }
}
