import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/cart_item_model.dart';
import '../../../viewmodels/cart_viewmodel.dart';
import '../../../utils/constants.dart';

class CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final CartViewModel cartVM;

  const CartItemTile({
    super.key,
    required this.item,
    required this.cartVM,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: AppColors.error, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => cartVM.removeFromCart(item.product.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                  imageUrl: item.product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorWidget: (c, u, e) => Container(
                      width: 80,
                      height: 80,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: const Icon(Icons.image))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('₹${item.product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    _quantityBtn(Icons.remove,
                        () => cartVM.decreaseQuantity(item.product.id)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${item.quantity}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                    _quantityBtn(Icons.add,
                        () => cartVM.increaseQuantity(item.product.id)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('₹${item.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: AppColors.scaffoldBg,
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}
