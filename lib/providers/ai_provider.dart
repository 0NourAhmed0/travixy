import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

class AiProvider extends ChangeNotifier {
  final AiService _aiService = AiService();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> sendMessage(String userText) async {
    if (userText.trim().isEmpty) return;

    _messages.add(ChatMessage(
      content: userText.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final history = _messages.map((m) => {
        'role': m.isUser ? 'user' : 'assistant',
        'content': m.content,
      }).toList();

      final reply = await _aiService.sendMessage(history);

      _messages.add(ChatMessage(
        content: reply,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _error = e.toString();
      // Add error message in chat so user sees it
      _messages.add(ChatMessage(
        content: 'Sorry, I had trouble responding. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }
}