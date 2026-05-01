import 'package:flutter/material.dart';
import '../../../widgets/custom_button.dart';
import '../../../utils/constants.dart';

class EmptyCartView extends StatelessWidget {
  const EmptyCartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text('Your cart is empty',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text('Add some products to get started',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          CustomButton(
              label: 'Browse Products',
              width: 200,
              onPressed: () => Navigator.pop(context),
              icon: Icons.shopping_bag_outlined),
        ],
      ),
    );
  }
}
