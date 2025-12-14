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
    final provider = context.watch<FridgeAIProvider>();
    final bool hasIngredients = provider.savedIngredients.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Connection Check (Debug) ---


          // --- 1. Control Card (Input & Management) ---
          CustomCard(
            child: Column(
              children: [
                // Input Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Nhập nguyên liệu (VD: thịt bò, sả...)',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, 
                            vertical: 12
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            color: AppColors.primary,
                            onPressed: () {
                              if (_controller.text.trim().isNotEmpty) {
                                provider.addIngredient(_controller.text);
                                _controller.clear();
                              }
                            },
                          ),
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            provider.addIngredient(value);
                            _controller.clear();
                          }
                        },
                      ),
                    ),
                  ],
                ),

                // Chip List
                if (hasIngredients) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        provider.savedIngredients.length,
                        (index) => Chip(
                          label: Text(
                            provider.savedIngredients[index],
                            style: const TextStyle(fontSize: 13),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => provider.removeIngredient(index),
                          backgroundColor: Colors.orange.shade50,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Action Buttons Row
                Row(
                  children: [
                    // Clear Button (Text only)
                    if (hasIngredients)
                      TextButton.icon(
                        onPressed: provider.isLoading 
                            ? null 
                            : () => provider.clearIngredients(),
                        icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                        label: const Text('Xóa hết'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                      ),
                    
                    const Spacer(),

                    // Main Action Button (Primary)
                    // "Thêm" button is integrated in TextField suffix or secondary below if needed.
                    // But user asked for "Add" as secondary. Logic above uses Suffix.
                    // Let's add a comprehensive "Suggest" button here.
                    
                    FilledButton.icon(
                      onPressed: (hasIngredients && !provider.isLoading && provider.cooldownSeconds == 0)
                          ? () async {
                              FocusScope.of(context).unfocus(); // Close keyboard
                              await provider.submit();
                            }
                          : null,
                      icon: provider.isLoading 
                          ? const SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(
                                strokeWidth: 2, 
                                color: Colors.white
                              )
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                        provider.cooldownSeconds > 0 
                            ? 'Vui lòng đợi (${provider.cooldownSeconds}s)' 
                            : (provider.isLoading ? 'Đang suy nghĩ...' : 'Gợi ý món ăn')
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: (provider.cooldownSeconds > 0) ? Colors.grey : AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24, 
                          vertical: 12
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- 2. Dynamic State Area ---
          Expanded(
            child: _buildResultArea(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildResultArea(BuildContext context, FridgeAIProvider provider) {
    // STATE 1: Loading
    if (provider.isLoading) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingIndicator(message: 'AI đang phân tích nguyên liệu...'),
          SizedBox(height: 16),
           Text(
            'Mẹo: Kết quả sẽ có ngay sau vài giây',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      );
    }

    // STATE 2: Error
    if (provider.errorMessage != null) {
      // Check if it's a validation error (user side) or technical (system side)
      final bool isTechnical = provider.errorMessage!.toLowerCase().contains('connect') || 
                               provider.errorMessage!.toLowerCase().contains('lỗi');
      
      if (isTechnical) {
        // Log debug info
        debugPrint('FridgeAI Error: ${provider.errorMessage}');

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'Không kết nối được với Bếp trưởng AI',
                style: AppTextStyles.h5,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Vui lòng kiểm tra kết nối mạng hoặc thử lại sau.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => provider.submit(),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        );
      } else {
        // Validation msg (e.g. empty list)
        return Center(
          child: Text(
            provider.errorMessage!,
            style: const TextStyle(color: Colors.orange),
          ),
        );
      }
    }

    // STATE 3: Results
    if (provider.suggestedDishes.isNotEmpty) {
      return ListView.separated(
        itemCount: provider.suggestedDishes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildDishCard(context, provider.suggestedDishes[index]);
        },
      );
    }

    // STATE 4: Empty (Initial)
    return const EmptyState(
      message: 'Thêm nguyên liệu có sẵn trong tủ lạnh\nđể nhận gợi ý món ngon mỗi ngày! 🥬🥩🥚',
      icon: Icons.kitchen,
    );
  }

  Widget _buildDishCard(BuildContext context, Map<String, dynamic> dish) {
    final double score = (dish['score'] as double?) ?? 0.0;
    final int percent = (score * 100).round();
    
    // Color coding
    Color statusColor;
    String statusText;
    if (percent >= 80) {
      statusColor = Colors.green;
      statusText = 'Tuyệt vời';
    } else if (percent >= 50) {
      statusColor = Colors.orange;
      statusText = 'Khá phù hợp';
    } else {
      statusColor = Colors.red;
      statusText = 'Thiếu nhiều';
    }

    final List<String> missing = [];
    if (dish['missing'] != null) {
      missing.addAll(List<String>.from(dish['missing']));
    }

    final List<String> quickSteps = [];
    if (dish['quick_steps'] != null) {
      quickSteps.addAll(List<String>.from(dish['quick_steps']));
    }

    final String? difficulty = dish['difficulty'];
    final String? note = dish['note'];

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          // Header: Name + Badge
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish['name'] ?? 'Món chưa đặt tên',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (difficulty != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          difficulty,
                          style: TextStyle(
                            fontSize: 11, 
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Text(
                      '$percent%',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Subtitle: Time + Missing info
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${dish['cookingTime'] ?? '?'}p', 
                      style: TextStyle(color: Colors.grey[800])),
                ],
              ),
              if (missing.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shopping_basket_outlined, size: 16, color: Colors.redAccent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                          children: [
                            const TextSpan(text: 'Cần thêm: '),
                            TextSpan(
                              text: missing.join(', '),
                              style: const TextStyle(
                                color: Colors.redAccent, 
                                fontWeight: FontWeight.w600
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          
          // Expanded Content
          children: [
             Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  
                  // Note Alert
                  if (note != null && note.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 20, color: Colors.amber.shade800),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              note,
                              style: TextStyle(color: Colors.amber.shade900, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (quickSteps.isNotEmpty) ...[
                    const Text(
                      '⚡ Cách làm nhanh:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ...quickSteps.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            alignment: Alignment.center,
                            child: Text('${entry.key + 1}.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(entry.value, style: const TextStyle(height: 1.4))),
                        ],
                      ),
                    )),
                  ],
                  
                  // Hide detailed instructions if empty
                  if (dish['cookingInstructions'] != null && (dish['cookingInstructions'] as List).isNotEmpty)
                     _buildDetailedSteps(dish['cookingInstructions']),
                ],
              ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedSteps(List<dynamic> instructions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                   Icon(Icons.menu_book, size: 16, color: AppColors.primary),
                   SizedBox(width: 8),
                   Text('Chi tiết cách làm', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ...instructions.map((step) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          step['instruction'] ?? '',
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
