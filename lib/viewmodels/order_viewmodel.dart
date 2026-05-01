/// Order ViewModel for SmartCart.
///
/// Manages order placement and order history retrieval.
/// Interacts with [FirestoreService] for persistence.
library;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../services/firestore_service.dart';
import '../services/payment_service.dart';
import '../utils/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OrderViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final PaymentService _paymentService = PaymentService();

  OrderViewModel() {
    _paymentService.onSuccess = _onPaymentSuccess;
    _paymentService.onFailure = _onPaymentFailure;
    _paymentService.onExternalWallet = _onExternalWallet;
  }

  // ── State ──
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _orderPlaced = false;
  String? _pendingOrderId;
  Function(bool success, String? orderId, String? error)? _onPaymentComplete;

  // ── Getters ──
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get orderPlaced => _orderPlaced;

  // ──────────────────────────────────────────────
  // Place Order & Payment
  // ──────────────────────────────────────────────

  /// Places a new order and initiates payment.
  Future<bool> placeOrder({
    required String userId,
    required String userName,
    required String email,
    required List<CartItemModel> items,
    required double totalPrice,
    Function(bool, String?, String?)? onPaymentComplete,
  }) async {
    _setLoading(true);
    _clearError();
    _orderPlaced = false;
    _onPaymentComplete = onPaymentComplete;

    try {
      // 1. Create order with 'pending' status
      _pendingOrderId = await _firestoreService.placeOrder(
        userId: userId,
        userName: userName,
        items: items,
        totalPrice: totalPrice,
      );

      // 2. Open Razorpay Checkout
      _paymentService.openCheckout(
        key: 'rzp_test_YOUR_KEY_HERE', // User should replace with their key
        amount: totalPrice,
        name: 'SmartCart',
        description: 'Payment for Order #${_pendingOrderId!.substring(0, 8)}',
        email: email,
        contact: '9999999999',
      );

      return true;
    } catch (e) {
      _setError('Failed to initiate order: $e');
      _pendingOrderId = null;
      _setLoading(false);
      return false;
    }
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    if (_pendingOrderId != null) {
      try {
        await _firestoreService.updateOrder(_pendingOrderId!, {
          'status': OrderStatus.paid,
          'paymentId': response.paymentId,
          'orderId': response.orderId,
          'paidAt': FieldValue.serverTimestamp(),
        });

        _onPaymentComplete?.call(true, _pendingOrderId, null);
        _orderPlaced = true;
      } catch (e) {
        _setError('Payment succeeded but failed to update order: $e');
        _onPaymentComplete?.call(false, _pendingOrderId, 'Order update failed: $e');
      } finally {
        _pendingOrderId = null;
        _setLoading(false);
      }
    }
  }

  void _onPaymentFailure(PaymentFailureResponse response) async {
    if (_pendingOrderId != null) {
      try {
        await _firestoreService.updateOrderStatus(
            _pendingOrderId!, OrderStatus.failed);
      } catch (e) {
        debugPrint('Failed to mark order as failed: $e');
      } finally {
        _onPaymentComplete?.call(false, _pendingOrderId, response.message);
        _setError('Payment failed: ${response.message}');
        _pendingOrderId = null;
        _setLoading(false);
      }
    }
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: "External Wallet: ${response.walletName}",
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
    );
  }

  // ──────────────────────────────────────────────
  // Fetch Orders
  // ──────────────────────────────────────────────

  /// Returns a real-time stream of user orders.
  Stream<List<OrderModel>> getOrdersStream(String userId) {
    return _firestoreService.getOrdersStream(userId);
  }

  /// Fetches orders for a specific user.
  Future<void> fetchUserOrders(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _orders = await _firestoreService.getUserOrders(userId);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load orders: $e');
      _setLoading(false);
    }
  }

  /// Fetches all orders (admin use).
  Future<void> fetchAllOrders() async {
    _setLoading(true);
    _clearError();

    try {
      _orders = await _firestoreService.getAllOrders();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load orders: $e');
      _setLoading(false);
    }
  }

  // ──────────────────────────────────────────────
  // Update Order Status (Admin)
  // ──────────────────────────────────────────────

  /// Updates the status of an existing order (admin action).
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestoreService.updateOrderStatus(orderId, newStatus);
      // Refresh the list
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index >= 0) {
        // Re-fetch to get updated data
        await fetchAllOrders();
      }
    } catch (e) {
      _setError('Failed to update order: $e');
    }
  }

  /// Resets the order-placed flag.
  void resetOrderPlaced() {
    _orderPlaced = false;
    notifyListeners();
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

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }
}
