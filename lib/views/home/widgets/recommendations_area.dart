import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/product_viewmodel.dart';
import '../../../viewmodels/cart_viewmodel.dart';
import '../../../widgets/product_card.dart';
import '../../../utils/constants.dart';
import '../../product/product_detail_screen.dart';
import 'recommendation_shimmer.dart';

class RecommendationsArea extends StatelessWidget {
  const RecommendationsArea({super.key});

  @override
  Widget build(BuildContext context) {
    final productVM = context.watch<ProductViewModel>();
    final cartVM = context.watch<CartViewModel>();

    if (!productVM.isRecommendationsLoading && productVM.recommendedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.md, AppSizes.lg, AppSizes.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Recommended for You',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  const Icon(Icons.auto_awesome,
                      color: AppColors.primary, size: 18),
                ],
              ),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: productVM.isRecommendationsLoading
              ? const RecommendationShimmer()
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                  itemCount: productVM.recommendedProducts.length,
                  itemBuilder: (context, index) {
                    final product = productVM.recommendedProducts[index];
                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 12, bottom: 8),
                      child: ProductCard(
                        product: product,
                        isGridView: true,
                        isInCart: cartVM.isInCart(product.id),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                          );
                        },
                        onAddToCart: () {
                          cartVM.addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added!'), 
                              behavior: SnackBarBehavior.floating
                            )
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
