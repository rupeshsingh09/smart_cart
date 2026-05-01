/// Order data model for SmartCart.
///
/// Represents an order document stored in the Firestore `orders` collection.
/// Contains order items, total price, status, and timestamps.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final List<CartItemModel> items;
  final double totalPrice;
  final String status;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  /// Create an [OrderModel] from a Firestore document snapshot.
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      items: (data['products'] as List<dynamic>?)
              ?.map((item) =>
                  CartItemModel.fromMap(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      totalPrice: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'products': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalPrice,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
