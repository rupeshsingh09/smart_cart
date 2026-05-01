/// Cart ViewModel for SmartCart.
///
/// Manages the shopping cart state. Cart is kept in memory
/// and cleared on order placement. Provides add, remove,
/// update quantity, and total price calculations.
library;

import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';

class CartViewModel extends ChangeNotifier {
  // ── State ──
  final List<CartItemModel> _items = [];

  // ── Getters ──
  List<CartItemModel> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;

  /// Total number of individual units in the cart.
  int get totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  /// Total price of all items in the cart.
  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  // ──────────────────────────────────────────────
  // Add to Cart
  // ──────────────────────────────────────────────

  /// Adds a [product] to the cart. If the product already exists,
  /// its quantity is incremented.
  void addToCart(ProductModel product) {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItemModel(product: product));
    }

    notifyListeners();
  }

  // ──────────────────────────────────────────────
  // Remove from Cart
  // ──────────────────────────────────────────────

  /// Removes a product entirely from the cart.
  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  // Update Quantity
  // ──────────────────────────────────────────────

  /// Increases the quantity of a cart item.
  void increaseQuantity(String productId) {
    final index =
        _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  /// Decreases the quantity. Removes the item if quantity reaches 0.
  void decreaseQuantity(String productId) {
    final index =
        _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // Check if product is in cart
  // ──────────────────────────────────────────────

  /// Returns true if the product with [productId] is already in the cart.
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // ──────────────────────────────────────────────
  // Clear Cart
  // ──────────────────────────────────────────────

  /// Clears all items from the cart (e.g., after placing an order).
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
