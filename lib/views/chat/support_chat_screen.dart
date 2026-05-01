import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/message_model.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/constants.dart';
import './widgets/chat_bubble.dart';
import './widgets/chat_input_area.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authVM = context.read<AuthViewModel>();
    if (authVM.user == null) return;

    context.read<ChatViewModel>().sendMessage(
          senderId: authVM.user!.uid,
          messageText: text,
        );

    _messageController.clear();
    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final chatVM = context.watch<ChatViewModel>();
    final userId = authVM.user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chatVM.getChatStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 64,
                            color: AppColors.textSecondary.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text('How can we help you today?',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == userId;
                    return ChatBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),

          // Input field
          ChatInputArea(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
