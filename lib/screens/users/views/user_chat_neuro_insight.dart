import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// A simple model for a chat message
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, this.isUser = false});
}

class ChatWithNeuroInsightView extends StatefulWidget {
  const ChatWithNeuroInsightView({super.key});

  @override
  State<ChatWithNeuroInsightView> createState() =>
      _ChatWithNeuroInsightViewState();
}

class _ChatWithNeuroInsightViewState extends State<ChatWithNeuroInsightView> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // Add the initial greeting message from the assistant
    _messages.add(
      ChatMessage(
        text:
        "Hello! I am Neuro Insight's AI assistant. You can ask me simple queries about Alzheimer's, Parkinson's, or the characteristics of a healthy brain.",
      ),
    );
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();

    // Add user's message
    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: true));
    });

    // Simulate AI response
    String response = _getBotResponse(text);
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.insert(0, ChatMessage(text: response));
      });
    });
  }

  // Simple keyword-based response logic
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
      backgroundColor: const Color(0xFFE1F7F5),
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
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final bubbleAlignment =
    message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor =
    message.isUser ? const Color(0xFF2DB8A1) : Colors.white;
    final textColor = message.isUser ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: bubbleAlignment,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 3,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration(
                  hintText: 'Ask a simple query...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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