/// Application-wide constants for SmartCart.
///
/// Contains color definitions, text styles, padding values,
/// and Firestore collection names used throughout the app.
library;

import 'package:flutter/material.dart';

// ──────────────────────────────────────────────
// Brand Colors
// ──────────────────────────────────────────────

class AppColors {
  AppColors._(); // prevent instantiation

  // Primary palette – rich indigo / violet tones
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4A42D1);
  static const Color primaryLight = Color(0xFFB8B3FF);

  // Accent
  static const Color accent = Color(0xFFFF6584);
  static const Color accentLight = Color(0xFFFFB3C1);

  // Backgrounds
  static const Color scaffoldBg = Color(0xFFF5F6FA);
  static const Color cardBg = Colors.white;
  static const Color darkBg = Color(0xFF1E1E2C);

  // Text
  static const Color textPrimary = Color(0xFF2D2D3A);
  static const Color textSecondary = Color(0xFF7C7C8A);
  static const Color textOnPrimary = Colors.white;

  // Status
  static const Color success = Color(0xFF00C48C);
  static const Color error = Color(0xFFFF647C);
  static const Color warning = Color(0xFFFFBB33);

  // Misc
  static const Color divider = Color(0xFFE8E8EE);
  static const Color shadow = Color(0x1A6C63FF);
}

// ──────────────────────────────────────────────
// Spacing & Sizing
// ──────────────────────────────────────────────

class AppSizes {
  AppSizes._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const double borderRadius = 16;
  static const double borderRadiusSm = 8;
  static const double borderRadiusLg = 24;

  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;

  static const double productCardHeight = 250;
  static const double productImageHeight = 150;
}

// ──────────────────────────────────────────────
// Firestore Collection Names
// ──────────────────────────────────────────────

class FirestoreCollections {
  FirestoreCollections._();

  static const String users = 'users';
  static const String products = 'products';
  static const String orders = 'orders';
  static const String cart = 'cart';
  static const String wishlist = 'wishlist';
  static const String userActivity = 'user_activity';
  static const String messages = 'messages';
}

// ──────────────────────────────────────────────
// Firebase Storage Paths
// ──────────────────────────────────────────────

class StoragePaths {
  StoragePaths._();

  static const String productImages = 'product_images';
}

// ──────────────────────────────────────────────
// User Roles
// ──────────────────────────────────────────────

class UserRoles {
  UserRoles._();

  static const String admin = 'admin';
  static const String customer = 'customer';
}

// ──────────────────────────────────────────────
// Order Statuses
// ──────────────────────────────────────────────

class OrderStatus {
  OrderStatus._();

  static const String pending = 'pending';
  static const String paid = 'paid';
  static const String failed = 'failed';
  static const String confirmed = 'confirmed';
  static const String shipped = 'shipped';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';
}
