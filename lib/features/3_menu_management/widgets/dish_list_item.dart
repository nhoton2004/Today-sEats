import 'package:flutter/material.dart';
import '../../../core/models/dish.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

class DishListItem extends StatelessWidget {
  final Dish dish;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  const DishListItem({
    super.key,
    required this.dish,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: AppConstants.smallPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        title: Text(
          dish.name,
          style: AppTextStyles.h5,
        ),
        subtitle: Text(
          '${dish.type.displayName} • ${dish.category.displayName}',
          style: AppTextStyles.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                dish.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: AppColors.primary,
              ),
              onPressed: onToggleFavorite,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
