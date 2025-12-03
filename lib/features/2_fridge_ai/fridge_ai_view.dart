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
  const FridgeAIView({Key? key}) : super(key: key);

  @override
  State<FridgeAIView> createState() => _FridgeAIViewState();
}

class _FridgeAIViewState extends State<FridgeAIView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FridgeAIProvider>();

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nguyên liệu trong tủ lạnh',
                  style: AppTextStyles.h5,
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                TextField(
                  controller: _controller,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText:
                        'Ví dụ: ức gà, cà chua, hành tây, mì spaghetti...\nNhập mỗi nguyên liệu cách nhau bởi dấu phẩy.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.largeBorderRadius,
                      ),
                    ),
                    errorText: provider.errorMessage,
                  ),
                  onChanged: provider.updateIngredients,
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                CustomButton(
                  text: 'Gợi ý món ăn',
                  onPressed: () async {
                    if (provider.isLoading) {
                      return;
                    }
                    provider.updateIngredients(_controller.text);
                    await provider.submit();
                  },
                  isLoading: provider.isLoading,
                  icon: Icons.auto_awesome,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          Expanded(
            child: provider.isLoading
                ? const LoadingIndicator(
                    message: 'AI đang suy nghĩ...',
                  )
                : provider.suggestion != null
                    ? CustomCard(
                        color: AppColors.surface,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Gợi ý từ AI',
                                    style: AppTextStyles.h4,
                                  ),
                                  IconButton(
                                    onPressed: provider.clearSuggestion,
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: AppConstants.defaultPadding,
                              ),
                              Text(
                                provider.suggestion!,
                                style: AppTextStyles.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      )
                    : const EmptyState(
                        message:
                            'Hãy nhập nguyên liệu để AI gợi ý món phù hợp.',
                        icon: Icons.kitchen_outlined,
                      ),
          ),
        ],
      ),
    );
  }
}
