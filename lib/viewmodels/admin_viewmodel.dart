/// Admin ViewModel for SmartCart.
///
/// Manages admin-specific operations: adding, editing, and
/// deleting products. Handles image upload via [StorageService].
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class AdminViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  // ── State ──
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // ── Getters ──
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // ──────────────────────────────────────────────
  // Add Product
  // ──────────────────────────────────────────────

  /// Adds a new product. Uploads [imageFile] first, then
  /// saves the product to Firestore.
  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required String category,
    required File imageFile,
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      // Upload image
      final imageUrl = await _storageService.uploadProductImage(imageFile);

      // Create product
      final product = ProductModel(
        id: '',
        name: name.trim(),
        description: description.trim(),
        price: price,
        imageUrl: imageUrl,
        category: category.trim(),
        createdAt: DateTime.now(),
      );

      await _firestoreService.addProduct(product);

      _successMessage = 'Product added successfully!';
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to add product: $e');
      _setLoading(false);
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // Update Product
  // ──────────────────────────────────────────────

  /// Updates an existing product. If [newImageFile] is provided,
  /// uploads the new image and deletes the old one.
  Future<bool> updateProduct({
    required ProductModel existingProduct,
    required String name,
    required String description,
    required double price,
    required String category,
    File? newImageFile,
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      String imageUrl = existingProduct.imageUrl;

      // Upload new image if provided
      if (newImageFile != null) {
        imageUrl = await _storageService.uploadProductImage(newImageFile);
        // Delete old image
        await _storageService.deleteProductImage(existingProduct.imageUrl);
      }

      final updatedProduct = existingProduct.copyWith(
        name: name.trim(),
        description: description.trim(),
        price: price,
        category: category.trim(),
        imageUrl: imageUrl,
      );

      await _firestoreService.updateProduct(updatedProduct);

      _successMessage = 'Product updated successfully!';
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update product: $e');
      _setLoading(false);
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // Delete Product
  // ──────────────────────────────────────────────

  /// Deletes a product and its associated image.
  Future<bool> deleteProduct(ProductModel product) async {
    _setLoading(true);
    _clearMessages();

    try {
      // Delete image from Storage
      await _storageService.deleteProductImage(product.imageUrl);
      // Delete product document
      await _firestoreService.deleteProduct(product.id);

      _successMessage = 'Product deleted successfully!';
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete product: $e');
      _setLoading(false);
      return false;
    }
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

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  /// Clear messages (for dismissing snackbars).
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
