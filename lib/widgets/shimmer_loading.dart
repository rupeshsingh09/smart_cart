import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/constants.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerLoading.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
  }) : shapeBorder = const RoundedRectangleBorder();

  const ShimmerLoading.circular({
    super.key,
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(),
  });

  ShimmerLoading.rounded({
    super.key,
    this.width = double.infinity,
    required this.height,
    double borderRadius = AppSizes.borderRadiusSm,
  }) : shapeBorder = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.grey,
          shape: shapeBorder,
        ),
      ),
    );
  }
}

class ProductCardShimmer extends StatelessWidget {
  final bool isGridView;

  const ProductCardShimmer({super.key, this.isGridView = true});

  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerLoading.rounded(
              height: 140,
              borderRadius: AppSizes.borderRadius,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoading.rounded(height: 12, width: 60),
                  const SizedBox(height: 8),
                  ShimmerLoading.rounded(height: 16),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerLoading.rounded(height: 20, width: 50),
                      const ShimmerLoading.circular(width: 32, height: 32),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Row(
          children: [
            ShimmerLoading.rounded(width: 100, height: 100),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoading.rounded(height: 12, width: 60),
                  const SizedBox(height: 8),
                  ShimmerLoading.rounded(height: 16),
                  const SizedBox(height: 8),
                  ShimmerLoading.rounded(height: 16, width: 100),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerLoading.rounded(height: 20, width: 60),
                      const ShimmerLoading.circular(width: 32, height: 32),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
