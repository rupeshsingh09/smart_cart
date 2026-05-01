/// Wishlist data model for SmartCart.
///
/// Represents a product saved by a user to their wishlist.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistModel {
  final String id;
  final String userId;
  final String productId;
  final String name;
  final String imageUrl;
  final double price;

  const WishlistModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
  });

  /// Create a [WishlistModel] from a Firestore document snapshot.
  factory WishlistModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WishlistModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
    };
  }
}
