import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/wishlist_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../utils/constants.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      if (authVM.user != null) {
        context.read<WishlistViewModel>().fetchWishlist(authVM.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlistVM = context.watch<WishlistViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final cartVM = context.watch<CartViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      body: wishlistVM.isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primary)))
          : wishlistVM.wishlistItems.isEmpty
              ? _buildEmptyWishlist(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.md),
                  itemCount: wishlistVM.wishlistItems.length,
                  itemBuilder: (context, index) {
                    final item = wishlistVM.wishlistItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorWidget: (c, u, e) => Container(width: 80, height: 80, color: AppColors.scaffoldBg, child: const Icon(Icons.image)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text('₹${item.price.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite, color: AppColors.accent),
                            onPressed: () {
                              wishlistVM.removeWishlistItem(authVM.user!.uid, item.productId);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyWishlist(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text('Your wishlist is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text('Save items you like to see them here', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
