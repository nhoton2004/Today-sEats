import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/ai_service.dart';
import '../../../common_widgets/loading_indicator.dart';

class RecipeModal extends StatefulWidget {
  final String dishName;
  final AIService aiService;

  const RecipeModal({
    super.key,
    required this.dishName,
    required this.aiService,
  });

  @override
  State<RecipeModal> createState() => _RecipeModalState();
}

class _RecipeModalState extends State<RecipeModal> {
  late Future<String> _recipeFuture;

  @override
  void initState() {
    super.initState();
    _recipeFuture = widget.aiService.getRecipeFromDish(widget.dishName);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.largeBorderRadius),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: AppConstants.smallPadding,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Công thức: ${widget.dishName}',
                    style: AppTextStyles.h4,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),

          // Content
          Expanded(
            child: FutureBuilder<String>(
              future: _recipeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator(
                    message: 'Đang tìm công thức...',
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.largePadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          const Text(
                            AppConstants.aiErrorMessage,
                            style: AppTextStyles.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppConstants.largePadding),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _recipeFuture = widget.aiService
                                    .getRecipeFromDish(widget.dishName);
                              });
                            },
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Text(
                    snapshot.data ?? 'Không có công thức',
                    style: AppTextStyles.bodyLarge,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
