import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../services/firestore_service.dart';

class ChatViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  /// Returns a stream of messages for the given user.
  Stream<List<MessageModel>> getChatStream(String userId) {
    return _firestoreService.getChatStream(userId);
  }

  /// Sends a message from the user to the admin.
  Future<void> sendMessage({
    required String senderId,
    required String messageText,
  }) async {
    if (messageText.trim().isEmpty) return;

    final message = MessageModel(
      id: '',
      senderId: senderId,
      receiverId: 'admin', // Fixed ID for admin in this simulated environment
      messageText: messageText,
      timestamp: DateTime.now(),
    );

    try {
      await _firestoreService.sendMessage(message);
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }
}
