/// Wishlist ViewModel for SmartCart.
///
/// Manages user's wishlist state and persistence.
library;

import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/wishlist_model.dart';
import '../services/firestore_service.dart';

class WishlistViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // ── State ──
  List<WishlistModel> _wishlistItems = [];
  bool _isLoading = false;

  // ── Getters ──
  List<WishlistModel> get wishlistItems => _wishlistItems;
  bool get isLoading => _isLoading;

  /// Fetches user's wishlist from Firestore.
  Future<void> fetchWishlist(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _wishlistItems = await _firestoreService.getWishlist(userId);
    } catch (e) {
      debugPrint('Error fetching wishlist: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggles wishlist status for a product.
  Future<void> toggleWishlist(String userId, ProductModel product) async {
    final index = _wishlistItems.indexWhere((item) => item.productId == product.id);

    if (index >= 0) {
      // Remove
      await _firestoreService.removeFromWishlist(userId, product.id);
      _wishlistItems.removeAt(index);
    } else {
      // Add
      final newItem = WishlistModel(
        id: '',
        userId: userId,
        productId: product.id,
        name: product.name,
        imageUrl: product.imageUrl,
        price: product.price,
      );
      await _firestoreService.addToWishlist(newItem);
      _wishlistItems.add(newItem);
    }
    notifyListeners();
  }

  /// Removes an item from wishlist by ID.
  Future<void> removeWishlistItem(String userId, String productId) async {
    await _firestoreService.removeFromWishlist(userId, productId);
    _wishlistItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  /// Checks if a product is in the wishlist.
  bool isWishlisted(String productId) {
    return _wishlistItems.any((item) => item.productId == productId);
  }
}
