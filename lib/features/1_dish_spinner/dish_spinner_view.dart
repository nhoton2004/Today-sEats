import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/dish.dart';
import '../../core/models/meal_type.dart';
import '../../core/models/category_filter_type.dart';
import '../../core/services/ai_service.dart';
import '../../common_widgets/custom_button.dart';
import '../../common_widgets/custom_card.dart';
import '../../common_widgets/filter_chip.dart' as custom;
import '../../common_widgets/empty_state.dart';
import '../3_menu_management/menu_management_provider.dart';
import 'dish_spinner_provider.dart';
import 'widgets/recipe_modal.dart';

class DishSpinnerView extends StatefulWidget {
  const DishSpinnerView({Key? key}) : super(key: key);

  @override
  State<DishSpinnerView> createState() => _DishSpinnerViewState();
}

class _DishSpinnerViewState extends State<DishSpinnerView> {
  final AIService _aiService = AIService();
  final Random _random = Random();

  IconData _getMealIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.wb_sunny_outlined;
      case MealType.lunch:
        return Icons.wb_sunny;
      case MealType.dinner:
        return Icons.nightlight_outlined;
      case MealType.snack:
        return Icons.cookie_outlined;
    }
  }

  IconData _getCategoryIcon(CategoryFilterType category) {
    switch (category) {
      case CategoryFilterType.all:
        return Icons.restaurant;
      case CategoryFilterType.vietnamese:
        return Icons.rice_bowl;
      case CategoryFilterType.asian:
        return Icons.ramen_dining;
      case CategoryFilterType.western:
        return Icons.lunch_dining;
      case CategoryFilterType.other:
        return Icons.fastfood;
    }
  }

  Future<void> _spinWheel() async {
    final provider = context.read<DishSpinnerProvider>();
    final filteredDishes = provider.getFilteredDishes();

    if (filteredDishes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có món ăn nào phù hợp với bộ lọc!'),
        ),
      );
      return;
    }

    provider.setSpinning(true);

    // Animate through dishes
    for (int i = 0; i < AppConstants.spinnerCycleCount; i++) {
      final randomDish = filteredDishes[_random.nextInt(filteredDishes.length)];
      provider.setCurrentResult(randomDish);
      await Future.delayed(
        Duration(milliseconds: AppConstants.spinnerDelayMs + (i * 10)),
      );
    }

    // Final result
    final finalDish = filteredDishes[_random.nextInt(filteredDishes.length)];
    provider.setCurrentResult(finalDish);
    provider.setSpinning(false);
  }

  void _showRecipeModal() {
    final provider = context.read<DishSpinnerProvider>();
    if (provider.currentResult == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecipeModal(
        dishName: provider.currentResult!.name,
        aiService: _aiService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MenuManagementProvider, List<Dish>>(
      selector: (_, provider) => provider.dishes,
      builder: (context, dishes, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.read<DishSpinnerProvider>().setDishes(dishes);
        });

        return Consumer<DishSpinnerProvider>(
          builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Meal Type Filter
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bữa ăn',
                      style: AppTextStyles.h5,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Wrap(
                      spacing: AppConstants.smallPadding,
                      runSpacing: AppConstants.smallPadding,
                      children: [
                        // "All" option
                        custom.FilterChip(
                          label: 'Tất cả',
                          icon: Icons.all_inclusive,
                          isSelected: provider.selectedMealType == null,
                          onTap: () => provider.setMealType(null),
                        ),
                        ...MealType.values.map((type) {
                          return custom.FilterChip(
                            label: type.displayName,
                            icon: _getMealIcon(type),
                            isSelected: provider.selectedMealType == type,
                            onTap: () => provider.setMealType(type),
                            selectedColor: _getMealColor(type),
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Category Filter
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loại món',
                      style: AppTextStyles.h5,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Wrap(
                      spacing: AppConstants.smallPadding,
                      runSpacing: AppConstants.smallPadding,
                      children: CategoryFilterType.values.map((category) {
                        return custom.FilterChip(
                          label: category.displayName,
                          icon: _getCategoryIcon(category),
                          isSelected: provider.selectedCategory == category,
                          onTap: () => provider.setCategory(category),
                          selectedColor: AppColors.secondary,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),

              // Result Display
              CustomCard(
                color: AppColors.background,
                child: AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: AppConstants.shortAnimationDuration,
                  ),
                  child: provider.currentResult != null
                      ? Column(
                          key: ValueKey(provider.currentResult!.id),
                          children: [
                            Text(
                              provider.currentResult!.name,
                              style: AppTextStyles.spinnerResult,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppConstants.defaultPadding),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    provider.currentResult!.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                  onPressed: () => provider.toggleFavorite(
                                    provider.currentResult!.id,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : const EmptyState(
                          message: 'Nhấn "Quay ngay!" để bắt đầu',
                          icon: Icons.casino_outlined,
                        ),
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),

              // Spin Button
              CustomButton(
                text: 'Quay ngay!',
                onPressed: _spinWheel,
                isLoading: provider.isSpinning,
                icon: Icons.casino,
              ),
              const SizedBox(height: AppConstants.smallPadding),

              // Recipe Button
              if (provider.currentResult != null)
                TextButton.icon(
                  onPressed: _showRecipeModal,
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Xem công thức AI'),
                ),
            ],
          ),
        );
          },
        );
      },
    );
  }

  Color _getMealColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return AppColors.breakfast;
      case MealType.lunch:
        return AppColors.lunch;
      case MealType.dinner:
        return AppColors.dinner;
      case MealType.snack:
        return AppColors.snack;
    }
  }
}
