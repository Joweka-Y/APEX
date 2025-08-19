import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';

class ChatProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _lastError;

  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get isServiceAvailable => _geminiService.isAvailable;

  // Initialize with welcome message
  void initializeChat() {
    _messages = [
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message:
            'Hello! I\'m your AI car trading assistant. I can help you with:\n\n• Car buying and selling advice\n• Vehicle specifications and comparisons\n• Market trends and pricing\n• Maintenance tips\n• And much more!\n\nWhat would you like to know about cars today?',
        type: MessageType.bot,
        timestamp: DateTime.now(),
      ),
    ];
    _lastError = null;
    notifyListeners();
  }

  // Send user message
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Check if service is available
    if (!_geminiService.isAvailable) {
      _addErrorMessage(
          'Sorry, the AI service is not available. Please check your API key configuration.');
      return;
    }

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message.trim(),
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _lastError = null;
    notifyListeners();

    // Add loading message
    final loadingMessage = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      message: 'Thinking...',
      type: MessageType.bot,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    _messages.add(loadingMessage);
    _isLoading = true;
    notifyListeners();

    try {
      // Get AI response
      final response = await _geminiService.sendMessage(message.trim());

      // Remove loading message and add AI response
      _messages.removeLast();
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: response,
        type: MessageType.bot,
        timestamp: DateTime.now(),
      );

      _messages.add(aiMessage);
      _lastError = null;
    } catch (e) {
      debugPrint('Error in ChatProvider sendMessage: $e');

      // Remove loading message and add error message
      _messages.removeLast();
      _addErrorMessage('Sorry, I encountered an error. Please try again.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add error message
  void _addErrorMessage(String errorMessage) {
    final errorMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: errorMessage,
      type: MessageType.bot,
      timestamp: DateTime.now(),
    );

    _messages.add(errorMsg);
    _lastError = errorMessage;
    notifyListeners();
  }

  // Retry last message
  Future<void> retryLastMessage() async {
    if (_messages.isEmpty) return;
    
    // Find the last user message
    ChatMessage? lastUserMessage;
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].type == MessageType.user) {
        lastUserMessage = _messages[i];
        break;
      }
    }
    
    if (lastUserMessage != null) {
      // Remove error messages after the last user message
      final lastUserIndex = _messages.indexOf(lastUserMessage);
      _messages.removeRange(lastUserIndex + 1, _messages.length);
      
      // Don't add the user message again, just retry the AI response
      await _sendMessageInternal(lastUserMessage.message);
    }
  }

  // Internal method to send message without adding user message again
  Future<void> _sendMessageInternal(String message) async {
    // Check if service is available
    if (!_geminiService.isAvailable) {
      _addErrorMessage('Sorry, the AI service is not available. Please check your API key configuration.');
      return;
    }

    // Add loading message
    final loadingMessage = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      message: 'Thinking...',
      type: MessageType.bot,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    _messages.add(loadingMessage);
    _isLoading = true;
    notifyListeners();

    try {
      // Get AI response
      final response = await _geminiService.sendMessage(message.trim());
      
      // Remove loading message and add AI response
      _messages.removeLast();
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: response,
        type: MessageType.bot,
        timestamp: DateTime.now(),
      );
      
      _messages.add(aiMessage);
      _lastError = null;
    } catch (e) {
      debugPrint('Error in ChatProvider _sendMessageInternal: $e');
      
      // Remove loading message and add error message
      _messages.removeLast();
      _addErrorMessage('Sorry, I encountered an error. Please try again.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear chat history
  void clearChat() {
    _messages.clear();
    _lastError = null;
    _geminiService.resetChat();
    initializeChat();
  }

  // Get last message (useful for scroll to bottom)
  ChatMessage? get lastMessage {
    if (_messages.isEmpty) return null;
    return _messages.last;
  }

  // Check if there are messages
  bool get hasMessages => _messages.isNotEmpty;

  // Get message count
  int get messageCount => _messages.length;

  // Check if last message was an error
  bool get hasError => _lastError != null;

  // Clear error
  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}
