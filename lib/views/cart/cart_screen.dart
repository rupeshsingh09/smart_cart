import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../utils/constants.dart';
import './widgets/empty_cart_view.dart';
import './widgets/cart_item_tile.dart';
import './widgets/cart_checkout_bar.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartVM = context.watch<CartViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cartVM.isEmpty
          ? const EmptyCartView()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.md),
                    itemCount: cartVM.items.length,
                    itemBuilder: (context, index) {
                      return CartItemTile(
                        item: cartVM.items[index],
                        cartVM: cartVM,
                      );
                    },
                  ),
                ),
                const CartCheckoutBar(),
              ],
            ),
    );
  }
}
