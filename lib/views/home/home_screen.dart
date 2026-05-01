import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/product_viewmodel.dart';
import './widgets/home_header.dart';
import './widgets/home_search_bar.dart';
import './widgets/category_filters.dart';
import './widgets/product_grid_area.dart';
import './widgets/recommendations_area.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch products on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      final productVM = context.read<ProductViewModel>();
      productVM.fetchProducts();
      productVM.fetchRecommendations(authVM.user?.uid ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            HomeHeader(),

            // ── Search Bar ──
            HomeSearchBar(),

            // ── Category Chips ──
            CategoryFilters(),

            // ── Recommended for You ──
            RecommendationsArea(),

            // ── Products ──
            Expanded(
              child: ProductGridArea(),
            ),
          ],
        ),
      ),
    );
  }
}
