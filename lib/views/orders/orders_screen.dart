import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart';
import './widgets/order_empty_view.dart';
import './widgets/order_item_tile.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      final orderVM = context.read<OrderViewModel>();
      if (authVM.user != null) {
        orderVM.fetchUserOrders(authVM.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final orderVM = context.watch<OrderViewModel>();

    if (authVM.user == null) {
      return const Scaffold(
          body: Center(child: Text('Please login to view orders')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderVM.getOrdersStream(authVM.user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primary)));
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const OrderEmptyView();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return OrderItemTile(order: orders[index]);
            },
          );
        },
      ),
    );
  }
}
