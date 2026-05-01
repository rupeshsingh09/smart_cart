import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  late Razorpay _razorpay;
  
  // Callbacks
  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onFailure;
  Function(ExternalWalletResponse)? onExternalWallet;

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onFailure?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onExternalWallet?.call(response);
  }

  void openCheckout({
    required String key,
    required double amount,
    required String name,
    required String description,
    required String email,
    required String contact,
  }) {
    var options = {
      'key': key,
      'amount': (amount * 100).toInt(), // amount in paise
      'name': name,
      'description': description,
      'prefill': {'contact': contact, 'email': email},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
