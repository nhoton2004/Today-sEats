import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../common_widgets/custom_button.dart';
import '../../common_widgets/custom_card.dart';
import '../../common_widgets/loading_indicator.dart';
import '../../common_widgets/empty_state.dart';
import 'fridge_ai_provider.dart';

class FridgeAIView extends StatefulWidget {
  const FridgeAIView({super.key});

  @override
  State<FridgeAIView> createState() => _FridgeAIViewState();
}

class _FridgeAIViewState extends State<FridgeAIView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    // Load saved ingredients
    Future.microtask(() => 
      context.read<FridgeAIProvider>().loadSavedIngredients()
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... no change to build method structure ...
    final provider = context.watch<FridgeAIProvider>();

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input section
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nguyên liệu trong tủ lạnh',
                  style: AppTextStyles.h5,
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                
                // Input field
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'VD: 3 quả trứng, 100g hành lá...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.largeBorderRadius,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      provider.addIngredient(value);
                      _controller.clear();
                    }
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Add button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        provider.addIngredient(_controller.text);
                        _controller.clear();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm nguyên liệu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Saved ingredients list
                if (provider.savedIngredients.isNotEmpty) ...[
                  const Text(
                    'Đã lưu:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      provider.savedIngredients.length,
                      (index) => Chip(
                        label: Text(provider.savedIngredients[index]),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => provider.removeIngredient(index),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        deleteIconColor: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                if (provider.errorMessage != null) ...[
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Gợi ý món ăn 🤖',
                        onPressed: () async {
                          if (!provider.isLoading) {
                            await provider.submit();
                          }
                        },
                        isLoading: provider.isLoading,
                        icon: Icons.auto_awesome,
                      ),
                    ),
                    if (provider.savedIngredients.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xóa tất cả?'),
                              content: const Text(
                                'Bạn có chắc muốn xóa tất cả nguyên liệu?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    provider.clearIngredients();
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Xóa',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'Xóa tất cả',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.largePadding),
          
          // Results section
          Expanded(
            child: provider.isLoading
                ? const LoadingIndicator(
                    message: 'AI đang suy nghĩ...',
                  )
                : provider.suggestedDishes.isNotEmpty
                    ? ListView.builder(
                        itemCount: provider.suggestedDishes.length,
                        itemBuilder: (context, index) {
                          final dish = provider.suggestedDishes[index];
                          return _buildDishCard(dish);
                        },
                      )
                    : const EmptyState(
                        message:
                            'Hãy thêm nguyên liệu để AI gợi ý món phù hợp.',
                        icon: Icons.kitchen_outlined,
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishCard(Map<String, dynamic> dish) {
    final double score = (dish['score'] as double?) ?? 0.0;
    final int percent = (score * 100).round();
    
    // Determine color based on score
    Color scoreColor = Colors.red;
    if (score >= 0.7) scoreColor = Colors.green;
    else if (score >= 0.4) scoreColor = Colors.orange;

    final List<String> missing = [];
    if (dish['missing'] != null) {
      missing.addAll(List<String>.from(dish['missing']));
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  dish['name'] ?? 'Món ăn',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scoreColor),
                ),
                child: Text(
                  '$percent% phù hợp',
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.timer, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('${dish['cookingTime'] ?? 0} phút'),
                    const SizedBox(width: 16),
                    const Icon(Icons.people, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('${dish['servings'] ?? 0} người'),
                  ],
                ),
              ),
              if (missing.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Thiếu: ${missing.join(', ')}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ]
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Additional ingredients section (Contextual depending on missing or not)
                  if (dish['additionalIngredients'] != null &&
                      (dish['additionalIngredients'] as List).isNotEmpty) ...[
                    const Text(
                      '➕ Nguyên liệu khác:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      (dish['additionalIngredients'] as List).length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '  • ${(dish['additionalIngredients'] as List)[index]}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Cooking instructions
                  if (dish['cookingInstructions'] != null &&
                      (dish['cookingInstructions'] as List).isNotEmpty) ...[
                    const Text(
                      '👨‍🍳 Cách làm:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(
                      (dish['cookingInstructions'] as List).length,
                      (index) {
                        final instruction =
                            (dish['cookingInstructions'] as List)[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${instruction['step']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (instruction['duration'] != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '⏱️ ${instruction['duration']}p',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                instruction['instruction'] ?? '',
                                style: const TextStyle(fontSize: 14, height: 1.4),
                              ),
                              if (instruction['tips'] != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[50],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.amber[200]!),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('💡 ', style: TextStyle(fontSize: 14)),
                                      Expanded(
                                        child: Text(
                                          instruction['tips'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.amber[900],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
