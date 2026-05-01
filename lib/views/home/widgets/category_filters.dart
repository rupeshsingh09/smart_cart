import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/product_viewmodel.dart';
import '../../../utils/constants.dart';

class CategoryFilters extends StatelessWidget {
  const CategoryFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final productVM = context.watch<ProductViewModel>();

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        itemCount: productVM.categories.length,
        itemBuilder: (context, index) {
          final category = productVM.categories[index];
          final isSelected = category == productVM.selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => productVM.setCategory(category),
              backgroundColor: Theme.of(context).cardTheme.color,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                ),
              ),
              checkmarkColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            ),
          );
        },
      ),
    );
  }
}
