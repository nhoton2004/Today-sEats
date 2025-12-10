import 'package:flutter/material.dart';
import 'shimmer_loading.dart';

/// Shimmer skeleton for dish card in list view
/// Matches the layout of actual dish cards
class DishCardShimmer extends StatelessWidget {
  const DishCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            const ShimmerBox(
              width: 100,
              height: 100,
              borderRadius: 12,
            ),
            const SizedBox(width: 12),
            // Content placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const ShimmerBox(
                    width: double.infinity,
                    height: 20,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  ShimmerBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 16,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 12),
                  // Tags row
                  Row(
                    children: [
                      const ShimmerBox(
                        width: 60,
                        height: 24,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 8),
                      const ShimmerBox(
                        width: 60,
                        height: 24,
                        borderRadius: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for grid item (menu management)
class GridItemShimmer extends StatelessWidget {
  const GridItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image placeholder (square aspect ratio)
          const Expanded(
            child: ShimmerBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 0,
            ),
          ),
          // Title placeholder
          const Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  width: double.infinity,
                  height: 16,
                  borderRadius: 4,
                ),
                SizedBox(height: 8),
                ShimmerBox(
                  width: 80,
                  height: 14,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// List of shimmer cards
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) shimmerBuilder;

  const ShimmerList({
    super.key,
    this.itemCount = 3,
    required this.shimmerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: shimmerBuilder,
      ),
    );
  }
}

/// Grid of shimmer items
class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => const GridItemShimmer(),
      ),
    );
  }
}
