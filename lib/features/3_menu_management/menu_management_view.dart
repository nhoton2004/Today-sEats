import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/meal_type.dart';
import '../../core/models/category_filter_type.dart';
import '../../core/services/ai_service.dart';
import '../../common_widgets/custom_button.dart';
import '../../common_widgets/custom_card.dart';
import '../../common_widgets/empty_state.dart';
import '../../common_widgets/loading_indicator.dart';
import 'menu_management_provider.dart';
import 'widgets/dish_list_item.dart';

class MenuManagementView extends StatefulWidget {
  const MenuManagementView({super.key});

  @override
  State<MenuManagementView> createState() => _MenuManagementViewState();
}

class _MenuManagementViewState extends State<MenuManagementView> {
  late final TextEditingController _dishNameController;
  final _formKey = GlobalKey<FormState>();
  MealType _selectedMealType = MealType.lunch;
  CategoryFilterType _selectedCategory = CategoryFilterType.vietnamese;
  final AIService _aiService = AIService();
  bool _isSuggesting = false;

  @override
  void initState() {
    super.initState();
    _dishNameController = TextEditingController();
  }

  @override
  void dispose() {
    _dishNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuManagementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: LoadingIndicator(message: 'Đang tải danh sách món...'),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (provider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.defaultPadding,
                      ),
                      child: MaterialBanner(
                        backgroundColor: AppColors.error.withValues(alpha: 0.1),
                        content: Text(provider.errorMessage!),
                        actions: [
                          TextButton(
                            onPressed: provider.initialize,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildFormCard(provider)),
                            const SizedBox(width: AppConstants.largePadding),
                            Expanded(child: _buildListArea(provider)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildFormCard(provider),
                            const SizedBox(height: AppConstants.largePadding),
                            _buildListArea(provider),
                          ],
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFormCard(MenuManagementProvider provider) {
    return CustomCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thêm món mới', style: AppTextStyles.h4),
            const SizedBox(height: AppConstants.defaultPadding),
            TextFormField(
              controller: _dishNameController,
              decoration: const InputDecoration(
                labelText: 'Tên món',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên món';
                }
                if (value.trim().length < AppConstants.minDishNameLength) {
                  return 'Tên món tối thiểu ${AppConstants.minDishNameLength} ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<MealType>(
                    initialValue: _selectedMealType,
                    decoration: const InputDecoration(
                      labelText: 'Bữa ăn',
                      border: OutlineInputBorder(),
                    ),
                    items: MealType.values
                        .map(
                          (meal) => DropdownMenuItem(
                            value: meal,
                            child: Text(meal.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedMealType = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: DropdownButtonFormField<CategoryFilterType>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Loại món',
                      border: OutlineInputBorder(),
                    ),
                    items: CategoryFilterType.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.largePadding),
            CustomButton(
              text: 'Lưu món',
              icon: Icons.save,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                try {
                  await provider.addDish(
                    name: _dishNameController.text,
                    mealType: _selectedMealType,
                    category: _selectedCategory,
                  );
                  _dishNameController.clear();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã lưu món mới!')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _isSuggesting ? null : _suggestWithAI,
                icon: const Icon(Icons.auto_fix_high),
                label: _isSuggesting
                    ? const Text('AI đang gợi ý...')
                    : const Text('AI gợi ý món mới'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListArea(MenuManagementProvider provider) {
    final dishes = provider.filteredDishes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Danh sách món', style: AppTextStyles.h4),
              const SizedBox(height: AppConstants.defaultPadding),
              Wrap(
                spacing: AppConstants.smallPadding,
                children: [
                  ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: provider.selectedMealFilter == null,
                    onSelected: (_) => provider.setMealFilter(null),
                  ),
                  ...MealType.values.map(
                    (meal) => ChoiceChip(
                      label: Text(meal.displayName),
                      selected: provider.selectedMealFilter == meal,
                      onSelected: (_) => provider.setMealFilter(meal),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              FilterChip(
                label: const Text('Chỉ hiển thị yêu thích'),
                selected: provider.showFavoritesOnly,
                onSelected: (_) => provider.toggleFavoritesFilter(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        if (dishes.isEmpty)
          const EmptyState(
            message: AppConstants.emptyDishListMessage,
            icon: Icons.receipt_long,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dishes.length,
            itemBuilder: (context, index) {
              final dish = dishes[index];
              return DishListItem(
                dish: dish,
                onToggleFavorite: () => provider.toggleFavorite(dish.id),
                onDelete: () => _confirmDelete(provider, dish.id),
              );
            },
          ),
      ],
    );
  }

  Future<void> _confirmDelete(MenuManagementProvider provider, String dishId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa món này?'),
        content: const Text('Bạn có chắc muốn xóa món ăn khỏi danh sách?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await provider.removeDish(dishId);
    }
  }

  Future<void> _suggestWithAI() async {
    setState(() => _isSuggesting = true);
    try {
      final suggestions = await _aiService.suggestNewDishes(
        mealType: _selectedMealType.value,
        category: _selectedCategory.value,
      );
      if (!mounted) return;
      if (suggestions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI chưa có gợi ý phù hợp.')), 
        );
      } else {
        await showModalBottomSheet(
          context: context,
          builder: (context) => Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Gợi ý món mới',
                  style: AppTextStyles.h4,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                ...suggestions.map(
                  (dish) => ListTile(
                    title: Text(dish),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        Navigator.pop(context);
                        _dishNameController.text = dish;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppConstants.aiErrorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSuggesting = false);
      }
    }
  }
}
