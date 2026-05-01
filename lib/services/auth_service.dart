/// Firebase Authentication service.
///
/// Handles sign up, sign in, sign out, and current-user queries
/// using Firebase Auth. Also creates/fetches user documents in Firestore.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// The currently signed-in Firebase user (null if signed out).
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes (used to react to login/logout).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ──────────────────────────────────────────────
  // Sign Up
  // ──────────────────────────────────────────────

  /// Creates a new user with [email] and [password], then stores
  /// a user document in Firestore with the given [name].
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create the Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;

      // Build the user model
      final userModel = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        role: UserRoles.customer, // default role
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  // ──────────────────────────────────────────────
  // Sign In
  // ──────────────────────────────────────────────

  /// Signs in a user with [email] and [password].
  /// Returns the corresponding [UserModel] from Firestore.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Fetch the user document
      return await getUserData(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  // ──────────────────────────────────────────────
  // Sign Out
  // ──────────────────────────────────────────────

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ──────────────────────────────────────────────
  // Fetch User Data
  // ──────────────────────────────────────────────

  /// Retrieves the [UserModel] for the given [uid] from Firestore.
  Future<UserModel> getUserData(String uid) async {
    final doc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .get();

    if (!doc.exists) {
      throw Exception('User document not found');
    }

    return UserModel.fromFirestore(doc);
  }

  // ──────────────────────────────────────────────
  // Error Mapping
  // ──────────────────────────────────────────────

  /// Maps Firebase Auth error codes to user-friendly messages.
  String _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
