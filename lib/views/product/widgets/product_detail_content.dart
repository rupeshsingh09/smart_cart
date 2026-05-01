import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../../../viewmodels/cart_viewmodel.dart';
import '../../../widgets/custom_button.dart';
import '../../../utils/constants.dart';

class ProductDetailContent extends StatelessWidget {
  final ProductModel product;
  final CartViewModel cartVM;

  const ProductDetailContent({
    super.key,
    required this.product,
    required this.cartVM,
  });

  @override
  Widget build(BuildContext context) {
    final isInCart = cartVM.isInCart(product.id);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(product.category,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark)),
          ),
          const SizedBox(height: 12),
          Text(product.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('₹${product.price.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary)),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text('Description', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(product.description,
              style:
                  const TextStyle(color: AppColors.textSecondary, height: 1.6)),
          const SizedBox(height: 32),
          CustomButton(
            label: isInCart ? 'Already in Cart ✓' : 'Add to Cart',
            icon: isInCart
                ? Icons.check_circle_outline
                : Icons.add_shopping_cart_outlined,
            color: isInCart ? AppColors.success : AppColors.primary,
            onPressed: isInCart
                ? null
                : () {
                    cartVM.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${product.name} added!'),
                        behavior: SnackBarBehavior.floating));
                  },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
