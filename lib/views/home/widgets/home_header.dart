import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/cart_viewmodel.dart';
import '../../../viewmodels/theme_viewmodel.dart';
import '../../../viewmodels/product_viewmodel.dart';
import '../../../utils/constants.dart';
import '../../cart/cart_screen.dart';
import '../../orders/orders_screen.dart';
import '../../wishlist/wishlist_screen.dart';
import '../../admin/admin_panel_screen.dart';
import '../../chat/support_chat_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final cartVM = context.watch<CartViewModel>();
    final themeVM = context.watch<ThemeViewModel>();
    final productVM = context.watch<ProductViewModel>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.lg, AppSizes.md, AppSizes.lg, AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // LEFT: Greeting Text section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hello, ${authVM.user?.name.split(' ').first ?? 'User'} 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Find your perfect product',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSizes.md),

          // RIGHT: Icons section
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Theme Toggle
              IconButton(
                onPressed: () => themeVM.toggleTheme(),
                icon: Icon(
                  themeVM.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  size: 22,
                ),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                tooltip: 'Toggle theme',
              ),

              // Wishlist
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WishlistScreen()),
                  );
                },
                icon: const Icon(Icons.favorite_border_rounded, size: 22),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                tooltip: 'Wishlist',
              ),

              // Cart with Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined, size: 22),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    tooltip: 'Cart',
                  ),
                  if (cartVM.itemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartVM.itemCount}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Menu for more options
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'view':
                      productVM.toggleViewMode();
                      break;
                    case 'chat':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SupportChatScreen()),
                      );
                      break;
                    case 'orders':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OrdersScreen()),
                      );
                      break;
                    case 'admin':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AdminPanelScreen()),
                      );
                      break;
                    case 'seed':
                      productVM.seedProducts();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sample products seeded!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      break;
                    case 'logout':
                      authVM.signOut();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'view',
                    child: ListTile(
                      leading: Icon(productVM.isGridView
                          ? Icons.view_list_rounded
                          : Icons.grid_view_rounded),
                      title: Text(productVM.isGridView
                          ? 'List View'
                          : 'Grid View'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'chat',
                    child: ListTile(
                      leading: Icon(Icons.chat_bubble_outline_rounded),
                      title: Text('Support Chat'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'orders',
                    child: ListTile(
                      leading: Icon(Icons.receipt_long_outlined),
                      title: Text('My Orders'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (authVM.isAdmin)
                    const PopupMenuItem(
                      value: 'admin',
                      child: ListTile(
                        leading: Icon(Icons.admin_panel_settings_outlined),
                        title: Text('Admin Panel'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'seed',
                    child: ListTile(
                      leading: Icon(Icons.dataset_outlined),
                      title: Text('Seed Products'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: AppColors.error),
                      title: Text('Logout',
                          style: TextStyle(color: AppColors.error)),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );


  }
}
