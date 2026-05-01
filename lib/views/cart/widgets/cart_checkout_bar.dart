import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/cart_viewmodel.dart';
import '../../../viewmodels/order_viewmodel.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../widgets/custom_button.dart';
import '../../../utils/constants.dart';
import '../../payment/payment_status_screen.dart';

class CartCheckoutBar extends StatelessWidget {
  const CartCheckoutBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cartVM = context.watch<CartViewModel>();
    final authVM = context.watch<AuthViewModel>();

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? const Color(0xFF2A2A3D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total',
                    style: TextStyle(
                        fontSize: 16, color: Colors.white.withOpacity(0.6))),
                Text('₹${cartVM.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<OrderViewModel>(
              builder: (context, orderVM, _) {
                return CustomButton(
                  label: 'Place Order',
                  isLoading: orderVM.isLoading,
                  icon: Icons.payment_outlined,
                  onPressed: () async {
                    if (authVM.user == null) return;
                    
                    final success = await orderVM.placeOrder(
                      userId: authVM.user!.uid,
                      userName: authVM.user!.name,
                      email: authVM.user!.email,
                      items: cartVM.items,
                      totalPrice: cartVM.totalPrice,
                      onPaymentComplete: (isSuccess, orderId, error) {
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentStatusScreen(
                                isSuccess: isSuccess,
                                orderId: orderId,
                                errorMessage: error,
                              ),
                            ),
                          );
                        }
                      },
                    );

                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
