import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../1_dish_spinner/dish_spinner_view.dart';
import '../2_fridge_ai/fridge_ai_view.dart';
import '../3_menu_management/menu_management_provider.dart';
import '../3_menu_management/menu_management_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: 260,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsetsDirectional.only(
                  start: AppConstants.defaultPadding,
                  bottom: 72,
                ),
                title: Text(
                  "Today's Eats",
                  style: AppTextStyles.headerTitle,
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      AppConstants.defaultHeaderImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: AppColors.primaryDark),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.headerGradient,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.defaultPadding,
                          vertical: AppConstants.largePadding,
                        ),
                        child: Consumer<MenuManagementProvider>(
                          builder: (context, provider, _) {
                            final totalDishes = provider.dishes.length;
                            final favorites = provider.dishes
                                .where((dish) => dish.isFavorite)
                                .length;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Xin chào! Hôm nay ăn gì?',
                                  style: AppTextStyles.headerSubtitle,
                                ),
                                const SizedBox(height: AppConstants.smallPadding),
                                Wrap(
                                  spacing: AppConstants.smallPadding,
                                  children: [
                                    _HeaderChip(
                                      icon: Icons.restaurant_menu,
                                      label: 'Tổng món: $totalDishes',
                                    ),
                                    _HeaderChip(
                                      icon: Icons.favorite,
                                      label: 'Ưa thích: $favorites',
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(64),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  child: TabBar(
                    indicatorColor: Colors.white,
                    labelStyle: AppTextStyles.buttonSmall,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.casino_outlined),
                        text: 'Quay món',
                      ),
                      Tab(
                        icon: Icon(Icons.kitchen_outlined),
                        text: 'Fridge AI',
                      ),
                      Tab(
                        icon: Icon(Icons.list_alt),
                        text: 'Quản lý món',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: const TabBarView(
            children: [
              DishSpinnerView(),
              FridgeAIView(),
              MenuManagementView(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
