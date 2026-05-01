/// Product ViewModel for SmartCart.
///
/// Manages product listing, filtering by category,
/// and search. Fetches data from [FirestoreService].
library;

import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../services/openai_service.dart';
import 'dart:async';

class ProductViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final OpenAIService _openAIService = OpenAIService();
  Timer? _debounce;

  // ── State ──
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGridView = true;
  List<ProductModel> _recommendedProducts = [];
  bool _isRecommendationsLoading = false;
  bool _isAISearching = false;
  List<String> _aiKeywords = [];

  // ── Getters ──
  List<ProductModel> get products => _filteredProducts;
  List<String> get categories => ['All', 'Books', 'Beauty', 'Toys', 'General'];
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isGridView => _isGridView;
  List<ProductModel> get recommendedProducts => _recommendedProducts;
  bool get isRecommendationsLoading => _isRecommendationsLoading;
  bool get isAISearching => _isAISearching;

  // ──────────────────────────────────────────────
  // Fetch Products
  // ──────────────────────────────────────────────

  /// Loads all products from Firestore and extracts categories.
  Future<void> fetchProducts() async {
    _setLoading(true);
    _clearError();

    try {
      _products = await _firestoreService.getProducts();
      
      // If no products found, try to seed with sample data
      if (_products.isEmpty) {
        await _firestoreService.seedProducts();
        _products = await _firestoreService.getProducts();
      }

      _categories = await _firestoreService.getCategories();
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load products: $e');
      _setLoading(false);
    }
  }

  /// Seeds sample products (only if the collection is empty).
  Future<void> seedProducts() async {
    try {
      await _firestoreService.seedProducts();
      await fetchProducts();
    } catch (e) {
      _setError('Failed to seed products: $e');
    }
  }

  /// Fetches recommended products for the user.
  Future<void> fetchRecommendations(String userId) async {
    _isRecommendationsLoading = true;
    notifyListeners();
    try {
      _recommendedProducts = await _firestoreService.getRecommendedProducts(userId);
    } catch (e) {
      debugPrint('Failed to fetch recommendations: $e');
    } finally {
      _isRecommendationsLoading = false;
      notifyListeners();
    }
  }

  /// Tracks a product view event.
  Future<void> trackProductView({
    required String userId,
    required ProductModel product,
  }) async {
    try {
      await _firestoreService.saveUserActivity(
        userId: userId,
        productId: product.id,
        category: product.category,
      );
      // Refresh recommendations after tracking
      await fetchRecommendations(userId);
    } catch (e) {
      debugPrint('Failed to track product view: $e');
    }
  }

  // ──────────────────────────────────────────────
  // Filters
  // ──────────────────────────────────────────────

  /// Sets the active category filter.
  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  /// Sets the search query with debouncing and AI processing.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _aiKeywords = []; // Reset previous keywords
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      _isAISearching = false;
      _applyFilters();
      return;
    }

    _isAISearching = true;
    _applyFilters(); // Apply normal search immediately while waiting
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performAISearch(query.trim());
    });
  }

  Future<void> _performAISearch(String query) async {
    try {
      final aiResponse = await _openAIService.getSearchKeywords(query);
      if (aiResponse.isNotEmpty) {
        // Split by comma and clean up
        _aiKeywords = aiResponse
            .split(',')
            .map((e) => e.trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('AI Search failed, falling back to normal search: $e');
      _aiKeywords = [];
    } finally {
      _isAISearching = false;
      _applyFilters();
    }
  }

  /// Toggles between grid and list view.
  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  /// Applies category + search filters to the product list.
  void _applyFilters() {
    var result = List<ProductModel>.from(_products);

    // Category filter
    if (_selectedCategory != 'All') {
      result = result
          .where((p) => p.category == _selectedCategory)
          .toList();
    }

    // Search filter (Normal + AI)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      
      result = result.where((p) {
        // 1. Check normal substring match
        final normalMatch = p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query);

        if (normalMatch) return true;

        // 2. Check AI keywords match
        if (_aiKeywords.isNotEmpty) {
          final productText = '${p.name} ${p.category} ${p.description}'.toLowerCase();
          for (final keyword in _aiKeywords) {
            if (productText.contains(keyword)) {
              return true;
            }
          }
        }
        return false;
      }).toList();
    }

    _filteredProducts = result;
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
