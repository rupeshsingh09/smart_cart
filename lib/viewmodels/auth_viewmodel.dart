/// Authentication ViewModel for SmartCart.
library;

import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // ── State ──
  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  // ── Getters ──
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  // ──────────────────────────────────────────────
  // Initialize – check if user is already logged in
  // ──────────────────────────────────────────────

  Future<void> initialize() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      try {
        _user = await _authService.getUserData(firebaseUser.uid);
      } catch (e) {
        await _authService.signOut();
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  // Sign Up
  // ──────────────────────────────────────────────

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // Sign In
  // ──────────────────────────────────────────────

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.signIn(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // Sign Out
  // ──────────────────────────────────────────────

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}