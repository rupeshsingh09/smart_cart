import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/product_viewmodel.dart';
import '../../../utils/constants.dart';

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({super.key});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productVM = context.read<ProductViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.lg, vertical: AppSizes.sm),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).cardTheme.color!,
                  Theme.of(context).cardTheme.color!.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                productVM.setSearchQuery(value);
                setState(() {}); // For suffix icon toggle
              },
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Ask AI to find products...',
                hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w400),
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.auto_awesome_rounded,
                      color: AppColors.primary, size: 24),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            size: 20, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          productVM.setSearchQuery('');
                          setState(() {});
                        },
                      )
                    : const Icon(Icons.mic_none_rounded,
                        color: AppColors.primary, size: 22),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
              ),
            ),
          ),
        ),

        // AI Thinking Indicator
        if (productVM.isAISearching)
          Padding(
            padding: const EdgeInsets.only(left: AppSizes.lg, bottom: AppSizes.sm),
            child: Row(
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Thinking...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

        // Suggestion Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
          child: Row(
            children: [
              _buildSuggestionChip('iPhone under 50k', productVM),
              _buildSuggestionChip('Best shoes', productVM),
              _buildSuggestionChip('Gaming laptop', productVM),
              _buildSuggestionChip('Smart watch', productVM),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String label, ProductViewModel productVM) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        onPressed: () {
          _searchController.text = label;
          productVM.setSearchQuery(label);
          setState(() {});
        },
      ),
    );
  }
}
