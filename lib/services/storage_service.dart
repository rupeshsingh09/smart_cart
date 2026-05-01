/// Firebase Storage service for SmartCart.
///
/// Handles uploading and deleting product images
/// in Firebase Cloud Storage.
library;

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../utils/constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Uploads an image [file] to Firebase Storage under product_images/.
  /// Returns the download URL of the uploaded image.
  Future<String> uploadProductImage(File file) async {
    try {
      // Generate a unique filename
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage
          .ref()
          .child(StoragePaths.productImages)
          .child(fileName);

      // Upload the file
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Return the download URL
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Deletes an image from Firebase Storage using its [imageUrl].
  /// Silently ignores errors (e.g., if the file doesn't exist).
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (_) {
      // Image might not exist; safe to ignore
    }
  }
}
