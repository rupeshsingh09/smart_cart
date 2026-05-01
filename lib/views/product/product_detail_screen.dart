import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import './widgets/product_detail_content.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      final productVM = context.read<ProductViewModel>();
      if (authVM.user != null) {
        productVM.trackProductView(
          userId: authVM.user!.uid,
          product: widget.product,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartVM = context.watch<CartViewModel>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: size.height * 0.45,
            pinned: true,
            backgroundColor: Theme.of(context).cardTheme.color,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).cardTheme.color?.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: widget.product.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (c, u, e) => const Icon(Icons.image, size: 64),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ProductDetailContent(
              product: widget.product,
              cartVM: cartVM,
            ),
          ),
        ],
      ),
    );
  }
}
