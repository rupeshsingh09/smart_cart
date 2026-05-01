/// Form field validators used across the app.
///
/// Provides reusable validation logic for email, password,
/// and generic required-field checks.
library;

class Validators {
  Validators._();

  /// Validates that a field is not empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates an email address format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates a password (minimum 6 characters).
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validates that the confirm-password matches the original.
  static String? confirmPassword(String? value, String original) {
    final error = password(value);
    if (error != null) return error;
    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates a price field (must be a positive number).
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Please enter a valid price';
    }
    return null;
  }
}
