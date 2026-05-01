import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../home/home_screen.dart';

class PaymentStatusScreen extends StatelessWidget {
  final bool isSuccess;
  final String? orderId;
  final String? errorMessage;

  const PaymentStatusScreen({
    super.key,
    required this.isSuccess,
    this.orderId,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    // Clear cart on success
    if (isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CartViewModel>().clearCart();
      });
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.xl),
                decoration: BoxDecoration(
                  color: (isSuccess ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                  size: 100,
                  color: isSuccess ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              Text(
                isSuccess ? 'Payment Successful!' : 'Payment Failed',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSuccess ? AppColors.success : AppColors.error,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                isSuccess
                    ? 'Your order has been placed successfully.\nOrder ID: #${orderId?.substring(0, 8) ?? "N/A"}'
                    : errorMessage ?? 'Something went wrong during payment.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.xl * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? AppColors.success : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue Shopping',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (!isSuccess) ...[
                const SizedBox(height: AppSizes.md),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Try Again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
