import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../utils/constants.dart';

class RecommendationShimmer extends StatelessWidget {
  const RecommendationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]!
              : Colors.grey[300]!,
          highlightColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[700]!
              : Colors.grey[100]!,
          child: Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
          ),
        );
      },
    );
  }
}
