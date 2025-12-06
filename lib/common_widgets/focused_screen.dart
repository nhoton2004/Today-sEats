import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

// Nguyên tắc 9: Mỗi màn hình chỉ nên có một nhiệm vụ chính
// Giúp người dùng tập trung, không bị phân tâm
class FocusedScreen extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final Color? backgroundColor;

  const FocusedScreen({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: centerTitle,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: showBackButton
            ? IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                // Nguyên tắc 2: Vùng cảm ứng đủ lớn
                iconSize: AppConstants.defaultIconSize,
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
            : null,
        actions: actions,
      ),
      body: SafeArea(
        child: child,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

// Màn hình với một nút hành động chính ở dưới cùng
// Nguyên tắc 7: Thiết kế thân thiện với ngón cái
class FocusedScreenWithAction extends StatelessWidget {
  final String title;
  final Widget child;
  final String actionText;
  final VoidCallback onActionPressed;
  final bool isActionLoading;
  final bool isActionEnabled;
  final IconData? actionIcon;
  final List<Widget>? appBarActions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const FocusedScreenWithAction({
    super.key,
    required this.title,
    required this.child,
    required this.actionText,
    required this.onActionPressed,
    this.isActionLoading = false,
    this.isActionEnabled = true,
    this.actionIcon,
    this.appBarActions,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: showBackButton
            ? IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                iconSize: AppConstants.defaultIconSize,
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
            : null,
        actions: appBarActions,
      ),
      body: Column(
        children: [
          // Nội dung chính
          Expanded(
            child: SafeArea(
              bottom: false,
              child: child,
            ),
          ),
          // Nút hành động cố định ở dưới - thumb zone
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                height: AppConstants.buttonHeight,
                width: double.infinity,
                child: FilledButton(
                  onPressed: isActionEnabled && !isActionLoading
                      ? onActionPressed
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.defaultBorderRadius,
                      ),
                    ),
                  ),
                  child: isActionLoading
                      ? const SizedBox(
                          height: AppConstants.defaultIconSize,
                          width: AppConstants.defaultIconSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (actionIcon != null) ...[
                              Icon(
                                actionIcon,
                                size: AppConstants.defaultIconSize,
                              ),
                              const SizedBox(width: AppConstants.smallPadding),
                            ],
                            Text(
                              actionText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Màn hình trống với một hướng dẫn tập trung
// Nguyên tắc 3: Giao diện sạch sẽ, ngăn nắp
class EmptyFocusedScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const EmptyFocusedScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FocusedScreen(
      title: title,
      showBackButton: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 80,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppConstants.largePadding),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              if (actionText != null && onActionPressed != null) ...[
                const SizedBox(height: AppConstants.largePadding),
                SizedBox(
                  height: AppConstants.buttonHeight,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onActionPressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultBorderRadius,
                        ),
                      ),
                    ),
                    child: Text(
                      actionText!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
