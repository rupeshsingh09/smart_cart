/// Cart item model for SmartCart.
///
/// Wraps a [ProductModel] with a quantity field
/// to represent items in the shopping cart.
library;

import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  /// Total price for this cart line item.
  double get totalPrice => product.price * quantity;

  /// Convert to a map for Firestore order storage.
  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productName': product.name,
      'productImage': product.imageUrl,
      'price': product.price,
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }

  /// Create from a Firestore order item map.
  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      product: ProductModel(
        id: map['productId'] ?? '',
        name: map['productName'] ?? '',
        description: '',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: map['productImage'] ?? '',
        category: '',
        createdAt: DateTime.now(),
      ),
      quantity: map['quantity'] ?? 1,
    );
  }
}
