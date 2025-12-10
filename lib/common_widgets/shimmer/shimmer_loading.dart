import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Base shimmer loading widget
/// Wraps child with a shimmer effect during loading state
class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBaseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final defaultHighlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor ?? defaultBaseColor,
      highlightColor: highlightColor ?? defaultHighlightColor,
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

/// Simple shimmer box with rounded corners
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
