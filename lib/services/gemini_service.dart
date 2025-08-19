import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  // TODO: Replace with your actual Gemini API key
  // Get your API key from: https://makersuite.google.com/app/apikey
  static const String _apiKey = 'AIzaSyDaxQ9mFhZQsnnbCOw_9dDuiTyQgEoV9U4';

  static const String _modelName = 'gemini-1.5-flash';

  GenerativeModel? _model;
  ChatSession? _chat;
  bool _isInitialized = false;

  GeminiService() {
    _initializeModel();
  }

  void _initializeModel() {
    try {
      if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
        debugPrint(
            'Warning: Please set your Gemini API key in gemini_service.dart');
        return;
      }

      _model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
      );
      if (_model != null) {
        _chat = _model!.startChat();
        _isInitialized = true;
        debugPrint('Gemini service initialized successfully');
      }
    } catch (e) {
      debugPrint('Error initializing Gemini service: $e');
      _isInitialized = false;
    }
  }

  Future<String> sendMessage(String message) async {
    try {
      // Check if service is initialized
      if (!_isInitialized || _model == null || _chat == null) {
        debugPrint(
            'Gemini service not initialized, attempting to reinitialize...');
        _initializeModel();

        if (!_isInitialized) {
          return 'Sorry, the AI service is not available. Please check your API key configuration.';
        }
      }

      // Add context about the car trading app
      final enhancedMessage = '''
You are a helpful AI assistant for a car trading app called "Apex". 
You help users with car-related questions, buying advice, selling tips, and general automotive knowledge.

User message: $message

Please provide a helpful, informative response related to cars, car trading, or automotive topics. 
Keep responses concise but informative. If the user asks about something not car-related, politely redirect them to car-related topics.
''';

      debugPrint(
          'Sending message to Gemini: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');

      final response = await _chat!.sendMessage(Content.text(enhancedMessage));

      if (response.text != null && response.text!.isNotEmpty) {
        debugPrint('Received response from Gemini');
        return response.text!;
      } else {
        debugPrint('Empty response from Gemini');
        return 'Sorry, I couldn\'t generate a response. Please try again.';
      }
    } catch (e) {
      debugPrint('Error in Gemini service sendMessage: $e');

      // Try to reinitialize on error
      if (e.toString().contains('API_KEY') ||
          e.toString().contains('unauthorized')) {
        return 'Sorry, there\'s an issue with the API configuration. Please check your API key.';
      } else if (e.toString().contains('quota') ||
          e.toString().contains('rate limit')) {
        return 'Sorry, the service is currently busy. Please try again in a moment.';
      } else {
        // Try to reset the chat session
        try {
          _chat = _model?.startChat();
          debugPrint('Chat session reset after error');
        } catch (resetError) {
          debugPrint('Error resetting chat session: $resetError');
        }

        return 'Sorry, there was an error processing your request. Please try again.';
      }
    }
  }

  // Reset chat session
  void resetChat() {
    try {
      if (_model != null) {
        _chat = _model!.startChat();
        debugPrint('Chat session reset successfully');
      }
    } catch (e) {
      debugPrint('Error resetting chat: $e');
      // Try to reinitialize the entire service
      _initializeModel();
    }
  }

  // Get chat history (if needed)
  List<Content> getChatHistory() {
    try {
      return _chat?.history.toList() ?? [];
    } catch (e) {
      debugPrint('Error getting chat history: $e');
      return [];
    }
  }

  // Check if service is available
  bool get isAvailable => _isInitialized && _model != null && _chat != null;

  // Get initialization status
  bool get isInitialized => _isInitialized;
}
