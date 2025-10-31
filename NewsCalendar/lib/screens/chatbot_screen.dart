import 'package:flutter/material.dart';
import 'package:newscalendar/services/chatbot_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  String? _sessionId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(
      ChatMessage(
        text: 'Hello! I\'m your agriculture assistant. How can I help you with farming today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Add user message to UI immediately
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    final userMessage = text;
    _messageController.clear();
    _scrollToBottom();

    try {
      // Call backend API
      final response = await ChatbotService.sendMessage(
        context,
        userMessage,
        sessionId: _sessionId,
      );

      // Update session ID if this is a new conversation
      if (_sessionId == null && response['sessionId'] != null) {
        _sessionId = response['sessionId'] as String;
      }

      // Add bot response
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: response['response'] as String,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: 'Sorry, I encountered an error: ${e.toString().replaceAll("Exception: ", "")}. Please try again.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();

        // Show snackbar with error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get keyboard height to adjust input area
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Messages list
          Expanded(
            child:
                _messages.isEmpty
                    ? Center(
                      child: Text(
                        'Start a conversation',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
          ),
          // Input area - moves up with keyboard
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            padding: EdgeInsets.only(
              left: 8,
              right: 8,
              top: 8,
              bottom: keyboardHeight > 0 ? keyboardHeight : 8,
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: _sendMessage,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              message.isUser
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[200],
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight:
                message.isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(18),
            bottomLeft:
                message.isUser
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
          ),
        ),
        child: MarkdownBody(
          data: message.text,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              color: message.isUser ? Colors.white : Colors.black87,
              fontSize: 15,
              height: 1.4,
            ),
            strong: TextStyle(
              fontWeight: FontWeight.bold,
              color: message.isUser ? Colors.white : Colors.black87,
            ),
            em: TextStyle(
              fontStyle: FontStyle.italic,
              color: message.isUser ? Colors.white : Colors.black87,
            ),
            listBullet: TextStyle(
              color: message.isUser ? Colors.white : Colors.black87,
              fontSize: 15,
            ),
            listIndent: 24.0,
            h1: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: message.isUser ? Colors.white : Colors.black87,
            ),
            h2: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: message.isUser ? Colors.white : Colors.black87,
            ),
            h3: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: message.isUser ? Colors.white : Colors.black87,
            ),
            code: TextStyle(
              backgroundColor: message.isUser 
                  ? Colors.white.withOpacity(0.2) 
                  : Colors.grey[300],
              color: message.isUser ? Colors.white : Colors.black87,
              fontFamily: 'monospace',
            ),
            codeblockDecoration: BoxDecoration(
              color: message.isUser 
                  ? Colors.white.withOpacity(0.2) 
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            blockquote: TextStyle(
              color: message.isUser ? Colors.white70 : Colors.black54,
              fontStyle: FontStyle.italic,
            ),
            blockquoteDecoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: message.isUser ? Colors.white70 : Colors.grey[400]!,
                  width: 4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
