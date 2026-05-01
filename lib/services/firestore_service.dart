/// Cloud Firestore service for SmartCart.
///
/// Handles CRUD operations for products, orders, and user data.
/// All Firestore logic is centralised here to keep ViewModels clean.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/wishlist_model.dart';
import '../models/message_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ──────────────────────────────────────────────
  // PRODUCTS
  // ──────────────────────────────────────────────

  /// Fetches all products ordered by creation date (newest first).
  Future<List<ProductModel>> getProducts() async {
    final snapshot = await _db
        .collection(FirestoreCollections.products)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }

  /// Fetches products filtered by [category].
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final snapshot = await _db
        .collection(FirestoreCollections.products)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }

  /// Fetches a single product by [id].
  Future<ProductModel?> getProductById(String id) async {
    final doc = await _db
        .collection(FirestoreCollections.products)
        .doc(id)
        .get();

    if (!doc.exists) return null;
    return ProductModel.fromFirestore(doc);
  }

  /// Adds a new product to Firestore. Returns the generated document ID.
  Future<String> addProduct(ProductModel product) async {
    final docRef = await _db
        .collection(FirestoreCollections.products)
        .add(product.toFirestore());
    return docRef.id;
  }

  /// Updates an existing product.
  Future<void> updateProduct(ProductModel product) async {
    await _db
        .collection(FirestoreCollections.products)
        .doc(product.id)
        .update(product.toFirestore());
  }

  /// Deletes a product by [id].
  Future<void> deleteProduct(String id) async {
    await _db.collection(FirestoreCollections.products).doc(id).delete();
  }

  // ──────────────────────────────────────────────
  // ORDERS
  // ──────────────────────────────────────────────

  /// Places a new order in Firestore.
  Future<String> placeOrder({
    required String userId,
    required String userName,
    required List<CartItemModel> items,
    required double totalPrice,
  }) async {
    final order = OrderModel(
      id: '', // will be assigned by Firestore
      userId: userId,
      userName: userName,
      items: items,
      totalPrice: totalPrice,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    final docRef = await _db
        .collection(FirestoreCollections.orders)
        .add(order.toFirestore());

    return docRef.id;
  }

  /// Fetches orders for a specific user.
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final snapshot = await _db
          .collection(FirestoreCollections.orders)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Fallback: If the above query fails (likely due to missing index),
      // fetch all orders for the user and sort them locally.
      final snapshot = await _db
          .collection(FirestoreCollections.orders)
          .where('userId', isEqualTo: userId)
          .get();

      final orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      // Sort locally: newest first
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    }
  }

  /// Fetches all orders (admin view).
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final snapshot = await _db
          .collection(FirestoreCollections.orders)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Fallback: fetch all and sort locally
      final snapshot =
          await _db.collection(FirestoreCollections.orders).get();

      final orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    }
  }

  /// Returns a stream of orders for a specific user.
  Stream<List<OrderModel>> getOrdersStream(String userId) {
    return _db
        .collection(FirestoreCollections.orders)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList());
  }

  /// Updates the status of an order.
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db
        .collection(FirestoreCollections.orders)
        .doc(orderId)
        .update({'status': status});
  }

  /// Updates an order with new data (e.g. status, paymentId).
  Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
    await _db
        .collection(FirestoreCollections.orders)
        .doc(orderId)
        .update(data);
  }

  // ──────────────────────────────────────────────
  // WISHLIST
  // ──────────────────────────────────────────────

  /// Adds a product to user's wishlist.
  Future<void> addToWishlist(WishlistModel item) async {
    await _db.collection(FirestoreCollections.wishlist).add(item.toFirestore());
  }

  /// Removes a product from user's wishlist.
  Future<void> removeFromWishlist(String userId, String productId) async {
    final snapshot = await _db
        .collection(FirestoreCollections.wishlist)
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: productId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Fetches the wishlist for a specific user.
  Future<List<WishlistModel>> getWishlist(String userId) async {
    final snapshot = await _db
        .collection(FirestoreCollections.wishlist)
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => WishlistModel.fromFirestore(doc))
        .toList();
  }

  // ──────────────────────────────────────────────
  // USER ACTIVITY & RECOMMENDATIONS
  // ──────────────────────────────────────────────

  /// Saves a product view event to Firestore.
  Future<void> saveUserActivity({
    required String userId,
    required String productId,
    required String category,
  }) async {
    await _db.collection(FirestoreCollections.userActivity).add({
      'userId': userId,
      'productId': productId,
      'category': category,
      'viewedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Gets categories recently viewed by the user.
  Future<List<String>> getRecentCategories(String userId) async {
    final snapshot = await _db
        .collection(FirestoreCollections.userActivity)
        .where('userId', isEqualTo: userId)
        .orderBy('viewedAt', descending: true)
        .limit(10)
        .get();

    final categories = snapshot.docs
        .map((doc) => doc.data()['category'] as String)
        .toSet()
        .toList();

    return categories;
  }

  /// Fetches recommended products based on user activity.
  Future<List<ProductModel>> getRecommendedProducts(String userId) async {
    final recentCategories = await getRecentCategories(userId);

    if (recentCategories.isEmpty) {
      // Fallback: Show popular/random products
      final snapshot = await _db
          .collection(FirestoreCollections.products)
          .limit(6)
          .get();
      return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    }

    // Match products from those categories
    final snapshot = await _db
        .collection(FirestoreCollections.products)
        .where('category', whereIn: recentCategories.take(10).toList())
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }

  // ──────────────────────────────────────────────
  // CHAT SUPPORT
  // ──────────────────────────────────────────────

  /// Sends a message in the support chat.
  Future<void> sendMessage(MessageModel message) async {
    await _db.collection(FirestoreCollections.messages).add(message.toFirestore());
  }

  /// Returns a real-time stream of messages for a user-admin conversation.
  /// Filters by user ID to ensure users only see their own support chat.
  Stream<List<MessageModel>> getChatStream(String userId) {
    return _db
        .collection(FirestoreCollections.messages)
        .where(Filter.or(
          Filter('senderId', isEqualTo: userId),
          Filter('receiverId', isEqualTo: userId),
        ))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  // ──────────────────────────────────────────────
  // CATEGORIES (derived from products)
  // ──────────────────────────────────────────────

  /// Gets distinct categories from existing products.
  Future<List<String>> getCategories() async {
    final snapshot =
        await _db.collection(FirestoreCollections.products).get();

    final categories = snapshot.docs
        .map((doc) => (doc.data()['category'] as String?) ?? 'General')
        .toSet()
        .toList();

    categories.sort();
    return categories;
  }

  // ──────────────────────────────────────────────
  // SEED DATA (for initial setup / demo)
  // ──────────────────────────────────────────────

  /// Seeds the database with sample products if the collection is empty.
  Future<void> seedProducts() async {
    final snapshot =
        await _db.collection(FirestoreCollections.products).limit(1).get();

    if (snapshot.docs.isNotEmpty) return; // already seeded

    final sampleProducts = [
      ProductModel(
        id: '',
        name: 'The Great Gatsby',
        description:
            'A classic novel by F. Scott Fitzgerald. A story of wealth, love, and the American Dream in the Roaring Twenties.',
        price: 599.0,
        imageUrl:
            'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=800',
        category: 'Books',
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'Silk Radiance Face Serum',
        description:
            'Premium hydrating face serum with hyaluronic acid and vitamin C for a glowing, youthful complexion.',
        price: 2499.0,
        imageUrl:
            'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=800',
        category: 'Beauty',
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'Vintage Wooden Train Set',
        description:
            'Classic 50-piece wooden train set with tracks, bridges, and magnetic train cars. Safe, durable, and perfect for imaginative play.',
        price: 3499.0,
        imageUrl:
            'https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?w=800',
        category: 'Toys',
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'Modern Table Lamp',
        description:
            'Minimalist LED table lamp with touch control and adjustable brightness. Perfect for any modern workspace or bedside table.',
        price: 1899.0,
        imageUrl:
            'https://images.unsplash.com/photo-1507473885765-e6ed057ab6fe?w=800',
        category: 'General',
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'Artisan Copper Espresso Machine',
        description:
            'The pinnacle of coffee craft. This manual lever espresso machine features a stunning copper finish and provides complete control over every shot of espresso.',
        price: 32999.0,
        imageUrl:
            'https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6?w=800',
        category: 'Home',
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'Nordic Minimalist Lounge Chair',
        description:
            'A blend of comfort and Scandinavian design. Crafted with sustainable oak and premium wool upholstery, this chair is a statement piece for any modern home.',
        price: 18499.0,
        imageUrl:
            'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=800',
        category: 'Home',
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'Pure Essence Matcha Set',
        description:
            'Everything you need for a traditional matcha ceremony. Includes ceremonial grade organic matcha, a bamboo whisk (chasen), a ceramic bowl, and a bamboo spoon.',
        price: 2499.0,
        imageUrl:
            'https://images.unsplash.com/photo-1582733315330-20230006734c?w=800',
        category: 'Food',
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'Titanium Road Bike',
        description:
            'Ultralight, ultra-strong, and built for speed. This titanium frame road bike offers a smooth ride across any terrain with top-tier electronic shifting and carbon fiber wheels.',
        price: 125999.0,
        imageUrl:
            'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=800',
        category: 'Sports',
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'Luxe Smart Watch Pro',
        description:
            'The ultimate fusion of luxury and technology. Sapphire glass, titanium casing, and a vibrant AMOLED display with advanced health tracking and 10-day battery life.',
        price: 15999.0,
        imageUrl:
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
        category: 'Beauty',
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        name: 'Obsidian Noir Fragrance',
        description:
            'A bold and mysterious scent with notes of sandalwood, black pepper, and aged leather. A long-lasting fragrance that leaves a powerful impression.',
        price: 4299.0,
        imageUrl:
            'https://images.unsplash.com/photo-1541643600914-78b084683601?w=800',
        category: 'Beauty',
        createdAt: DateTime.now(),
      ),
    ];

    final batch = _db.batch();
    for (final product in sampleProducts) {
      final docRef = _db.collection(FirestoreCollections.products).doc();
      batch.set(docRef, product.toFirestore());
    }
    await batch.commit();
  }
}
