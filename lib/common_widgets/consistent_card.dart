import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

// Nguyên tắc 8: Thiết kế nhất quán
// Card component chuẩn để sử dụng xuyên suốt app
class ConsistentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? elevation;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Border? border;

  const ConsistentCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.onTap,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: borderRadius ??
            BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: border,
        boxShadow: elevation != null
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: elevation!,
                  offset: Offset(0, elevation! / 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: AppConstants.cardElevation,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ??
              BorderRadius.circular(AppConstants.defaultBorderRadius),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

// Card với image header - Nhất quán cho dish cards
class ImageHeaderCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double imageHeight;
  final List<Widget>? actions;

  const ImageHeaderCard({
    super.key,
    this.imageUrl,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.imageHeight = 160,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return ConsistentCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header
          if (imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.defaultBorderRadius),
              ),
              child: Image.network(
                imageUrl!,
                height: imageHeight,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: imageHeight,
                  color: AppColors.background,
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: AppConstants.largeIconSize,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(
                                height: AppConstants.smallPadding / 2),
                            Text(
                              subtitle!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: AppConstants.smallPadding),
                      trailing!,
                    ],
                  ],
                ),
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.defaultPadding),
                  Row(
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Info card - Nhất quán cho thông tin
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? iconColor;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConsistentCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppConstants.defaultBorderRadius,
              ),
            ),
            child: Icon(
              icon,
              size: AppConstants.defaultIconSize,
              color: iconColor ?? AppColors.primary,
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }
}

// List tile card - Nhất quán cho list items
class ListTileCard extends StatelessWidget {
  final IconData? leadingIcon;
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ListTileCard({
    super.key,
    this.leadingIcon,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  }) : assert(
          leadingIcon == null || leading == null,
          'Cannot provide both leadingIcon and leading',
        );

  @override
  Widget build(BuildContext context) {
    return ConsistentCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.defaultPadding,
      ),
      onTap: onTap,
      child: Row(
        children: [
          if (leadingIcon != null)
            Container(
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppConstants.smallBorderRadius,
                ),
              ),
              child: Icon(
                leadingIcon,
                size: AppConstants.defaultIconSize,
                color: AppColors.primary,
              ),
            )
          else if (leading != null)
            leading!,
          if (leadingIcon != null || leading != null)
            const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppConstants.defaultPadding),
            trailing!,
          ],
        ],
      ),
    );
  }
}
