import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

// Nguyên tắc 2: Các vùng cảm ứng phù hợp
// Đảm bảo mọi thành phần tương tác đều có vùng cảm ứng tối thiểu 48x48dp
class TouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? minWidth;
  final double? minHeight;
  final EdgeInsetsGeometry? padding;

  const TouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.minWidth,
    this.minHeight,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth ?? AppConstants.minTouchTargetSize,
          minHeight: minHeight ?? AppConstants.minTouchTargetSize,
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppConstants.smallPadding),
          child: child,
        ),
      ),
    );
  }
}

// Icon button với vùng cảm ứng tối thiểu
class TouchIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final String? tooltip;

  const TouchIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final iconButton = IconButton(
      icon: Icon(
        icon,
        size: size ?? AppConstants.defaultIconSize,
        color: color,
      ),
      onPressed: onPressed,
      // Đảm bảo vùng cảm ứng tối thiểu
      constraints: const BoxConstraints(
        minWidth: AppConstants.minTouchTargetSize,
        minHeight: AppConstants.minTouchTargetSize,
      ),
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      tooltip: tooltip,
    );

    return iconButton;
  }
}

// Chip với vùng cảm ứng phù hợp
class TouchChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? selectedColor;
  final Color? unselectedColor;
  final IconData? icon;

  const TouchChip({
    super.key,
    required this.label,
    this.onTap,
    this.isSelected = false,
    this.selectedColor,
    this.unselectedColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.extraLargeBorderRadius),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AppConstants.minTouchTargetSize,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.mediumPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (selectedColor ??
                  Theme.of(context).colorScheme.primaryContainer)
              : (unselectedColor ??
                  Theme.of(context).colorScheme.surfaceContainerHighest),
          borderRadius:
              BorderRadius.circular(AppConstants.extraLargeBorderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: AppConstants.smallIconSize,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: AppConstants.smallPadding),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
