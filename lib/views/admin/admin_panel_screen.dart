import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../models/product_model.dart';
import '../../utils/constants.dart';
import 'add_edit_product_screen.dart';
import './widgets/admin_product_tile.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().fetchProducts();
    });
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final adminVM = context.read<AdminViewModel>();
      final success = await adminVM.deleteProduct(product);
      if (success && mounted) {
        context.read<ProductViewModel>().fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Product deleted'),
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productVM = context.watch<ProductViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final pVM = context.read<ProductViewModel>();
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddEditProductScreen()));
          if (mounted) pVM.fetchProducts();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: productVM.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary)))
          : productVM.products.isEmpty
              ? const Center(
                  child: Text('No products. Tap + to add.',
                      style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.md),
                  itemCount: productVM.products.length,
                  itemBuilder: (context, index) {
                    final product = productVM.products[index];
                    return AdminProductTile(
                      product: product,
                      onEdit: () async {
                        final pVM = context.read<ProductViewModel>();
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AddEditProductScreen(product: product)));
                        if (mounted) pVM.fetchProducts();
                      },
                      onDelete: () => _deleteProduct(product),
                    );
                  },
                ),
    );
  }
}
