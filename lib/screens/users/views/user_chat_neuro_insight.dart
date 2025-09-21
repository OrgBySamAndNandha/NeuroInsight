import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ✅ Updated model with methods for Firestore
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  // ✅ Converts a Firestore document into a ChatMessage object
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      text: data['text'] ?? '',
      isUser: data['isUser'] ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // ✅ Converts a ChatMessage object into a map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class ChatWithNeuroInsightView extends StatefulWidget {
  const ChatWithNeuroInsightView({super.key});

  @override
  State<ChatWithNeuroInsightView> createState() =>
      _ChatWithNeuroInsightViewState();
}

class _ChatWithNeuroInsightViewState extends State<ChatWithNeuroInsightView> {
  final TextEditingController _textController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // ✅ Saves a new message to Firestore
  Future<void> _sendMessage(String text, bool isUser) async {
    if (text.trim().isEmpty || _currentUser == null) return;

    final message = ChatMessage(
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    );

    // Path: chats_of_neuro_insight -> {userId} -> messages -> {messageId}
    await FirebaseFirestore.instance
        .collection('chats_of_neuro_insight')
        .doc(_currentUser!.uid)
        .collection('messages')
        .add(message.toJson());
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    // 1. Save the user's message
    _sendMessage(text, true);

    // 2. Get and save the bot's response
    final String responseText = _getBotResponse(text);
    Future.delayed(const Duration(milliseconds: 500), () {
      _sendMessage(responseText, false);
    });
  }

  String _getBotResponse(String query) {
    String lowerCaseQuery = query.toLowerCase();

    if (lowerCaseQuery.contains('alzheimer')) {
      return "Alzheimer's disease is a progressive disorder that causes brain cells to waste away (degenerate) and die. It's the most common cause of dementia — a continuous decline in thinking, behavioral and social skills that disrupts a person's ability to function independently.";
    } else if (lowerCaseQuery.contains('parkinson')) {
      return "Parkinson's disease is a progressive nervous system disorder that affects movement. Symptoms start gradually, sometimes starting with a barely noticeable tremor in just one hand. Tremors are common, but the disorder also commonly causes stiffness or slowing of movement.";
    } else if (lowerCaseQuery.contains('normal') || lowerCaseQuery.contains('healthy')) {
      return "A healthy, or 'normal,' brain can perform all its mental, physical, and emotional functions effectively. This includes the ability to learn, remember, solve problems, and maintain emotional balance. Lifestyle factors like diet, exercise, and social engagement are key to brain health.";
    } else {
      return "I'm sorry, I can only provide information on simple queries about Alzheimer's, Parkinson's, or normal brain health. Please try rephrasing your question.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Chat with Neuro Insight',
          style: GoogleFonts.lora(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            // ✅ This StreamBuilder listens for messages in Firestore
            child: _currentUser == null
                ? const Center(child: Text("You must be logged in to chat."))
                : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats_of_neuro_insight')
                  .doc(_currentUser!.uid)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildInitialPrompt();
                }

                final messages = snapshot.data!.docs
                    .map((doc) => ChatMessage.fromFirestore(doc))
                    .toList();

                final chatItems = _buildChatList(messages);

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: chatItems.length,
                  itemBuilder: (context, index) {
                    final item = chatItems[index];
                    if (item is ChatMessage) {
                      return _buildMessageBubble(item);
                    } else if (item is DateTime) {
                      return _buildDateSeparator(item);
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  // Helper methods for building the UI (mostly unchanged)
  List<Object> _buildChatList(List<ChatMessage> messages) {
    List<Object> items = [];
    DateTime? lastDate;
    // Note: The loop is reversed because messages are fetched descending.
    for (var message in messages.reversed) {
      DateTime messageDate = DateTime(message.timestamp.year, message.timestamp.month, message.timestamp.day);
      if (lastDate == null || messageDate != lastDate) {
        items.add(messageDate);
        lastDate = messageDate;
      }
      items.add(message);
    }
    // Return the list reversed again to show newest at the bottom.
    return items.reversed.toList();
  }

  Widget _buildInitialPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          "Hello! Ask a simple query about Alzheimer's, Parkinson's, or the characteristics of a healthy brain to begin your chat.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
      ),
    );
  }

  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return DateFormat('MMMM d, yyyy').format(date);
  }

  Widget _buildDateSeparator(DateTime date) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Text(_formatDateSeparator(date), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF2DB8A1) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 1, blurRadius: 3)],
            ),
            child: Text(message.text, style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: [BoxShadow(offset: const Offset(0, -1), blurRadius: 3, color: Colors.black.withOpacity(0.05))]),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration(
                  hintText: 'Ask a simple query...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _handleSubmitted(_textController.text),
              color: const Color(0xFF2DB8A1),
            ),
          ],
        ),
      ),
    );
  }
}