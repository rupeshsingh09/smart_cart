import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../viewmodels/product_viewmodel.dart';
import '../../../viewmodels/cart_viewmodel.dart';
import '../../../widgets/product_card.dart';
import '../../../widgets/shimmer_loading.dart';
import '../../../widgets/state_widgets.dart';
import '../../../utils/constants.dart';
import '../../product/product_detail_screen.dart';

class ProductGridArea extends StatelessWidget {
  const ProductGridArea({super.key});

  @override
  Widget build(BuildContext context) {
    final productVM = context.watch<ProductViewModel>();
    final cartVM = context.watch<CartViewModel>();

    if (productVM.isLoading) {
      return _buildShimmer(productVM.isGridView);
    }

    if (productVM.errorMessage != null) {
      return ErrorStateWidget(
        message: productVM.errorMessage!,
        onRetry: () => productVM.fetchProducts(),
      );
    }

    if (productVM.isAISearching) {
      return _buildShimmer(productVM.isGridView);
    }

    if (productVM.products.isEmpty) {
      return const EmptyStateWidget(
        message: 'No relevant products found',
      );
    }

    // Grid or List view
    if (productVM.isGridView) {
      return AnimationLimiter(
        child: GridView.builder(
          padding: const EdgeInsets.all(AppSizes.lg),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemCount: productVM.products.length,
          itemBuilder: (context, index) {
            final product = productVM.products[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              columnCount: 2,
              duration: const Duration(milliseconds: 400),
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: ProductCard(
                    product: product,
                    isGridView: true,
                    isInCart: cartVM.isInCart(product.id),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    onAddToCart: () {
                      cartVM.addToCart(product);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // List view
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.lg),
        itemCount: productVM.products.length,
        itemBuilder: (context, index) {
          final product = productVM.products[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: ProductCard(
                  product: product,
                  isGridView: false,
                  isInCart: cartVM.isInCart(product.id),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  onAddToCart: () {
                    cartVM.addToCart(product);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmer(bool isGridView) {
    if (isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(AppSizes.lg),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemCount: 6,
        itemBuilder: (context, index) =>
            const ProductCardShimmer(isGridView: true),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSizes.lg),
        itemCount: 6,
        itemBuilder: (context, index) =>
            const ProductCardShimmer(isGridView: false),
      );
    }
  }
}
