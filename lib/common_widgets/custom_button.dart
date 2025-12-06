import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

// Nguyên tắc 2, 7: Vùng cảm ứng phù hợp & thân thiện với ngón tay cái
class CustomButton extends StatelessWidget {
  final String text;
  final Future<void> Function() onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? AppConstants.buttonHeight, // Vùng cảm ứng tối ưu 56dp
      child: FilledButton(
        onPressed: isLoading ? null : () async => await onPressed(),
        style: FilledButton.styleFrom(
          backgroundColor:
              isSecondary ? AppColors.secondary : AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding,
          ),
          // Đảm bảo vùng cảm ứng tối thiểu
          minimumSize: const Size(
            AppConstants.minTouchTargetSize,
            AppConstants.minTouchTargetSize,
          ),
          elevation: AppConstants.buttonElevation,
        ),
        child: isLoading
            ? const SizedBox(
                height: AppConstants.defaultIconSize,
                width: AppConstants.defaultIconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppConstants.defaultIconSize),
                    const SizedBox(width: AppConstants.smallPadding),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
