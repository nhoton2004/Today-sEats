import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../common_widgets/swipeable_card.dart';
import '../3_menu_management/menu_management_api_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Món Yêu Thích',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<MenuManagementApiProvider>(
        builder: (context, provider, _) {
          final favoriteDishes =
              provider.dishes.where((dish) => dish.isFavorite).toList();

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favoriteDishes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_outline,
                      size: 80,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có món yêu thích',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thêm món ăn vào danh sách yêu thích để xem tại đây',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteDishes.length,
            itemBuilder: (context, index) {
              final dish = favoriteDishes[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SwipeableCard(
                  onSwipeLeft: () async {
                    await provider.toggleFavorite(dish.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã xóa "${dish.name}" khỏi yêu thích'),
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                            label: 'Hoàn tác',
                            onPressed: () => provider.toggleFavorite(dish.id),
                          ),
                        ),
                      );
                    }
                  },
                  leftSwipeColor: Colors.red,
                  leftSwipeIcon: Icons.favorite_border,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        dish.name[0],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    title: Text(
                      dish.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${dish.type.displayName} • ${dish.category.displayName}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
