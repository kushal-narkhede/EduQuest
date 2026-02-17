import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:student_learning_app/ai/models/chat_message_model.dart';
import 'package:student_learning_app/ai/utils/constants.dart';

/**
 * A repository class that handles communication with the OpenRouter AI API.
 * 
 * This class provides a clean interface for generating AI responses using
 * OpenRouter's GPT-3.5 Turbo model. It handles HTTP requests, response parsing,
 * and error handling for AI chat functionality.
 * 
 * The ChatRepo uses the Dio HTTP client for making API requests and provides
 * comprehensive logging for debugging and monitoring purposes.
 * 
 * Features:
 * - AI text generation using OpenRouter API
 * - Comprehensive error handling and logging
 * - Response validation and parsing
 * - Support for conversation context
 */
class ChatRepo {
  /**
   * Generates AI text responses using OpenRouter API.
   *
   * This method sends a conversation history to the configured OpenRouter
   * model and returns the generated response.
   *
   * @param previousMessage A list of previous chat messages providing context for the AI
   * @return A Future that completes with the generated AI response text.
   */
  static Future<String> chatTextGenerationRepo(
      List<ChatMessageModel> previousMessage) async {
    print('\n=== Starting AI Request ===');
    print('API Key status: ${apiKey.isEmpty ? "EMPTY" : "Present (${apiKey.length} chars)"}');
    
    try {
      // Check if API key is available; if missing try loading .env at runtime
      if (apiKey.isEmpty) {
        print('ERROR: API key is empty! Attempting to load .env at runtime...');
        try {
          await dotenv.load(fileName: '.env');
          print('[RuntimeEnv] dotenv.load succeeded');
        } catch (e) {
          print('[RuntimeEnv] dotenv.load failed: $e');
        }

        // If still empty, try reading bundled asset .env (if available)
        final rechecked = apiKey;
        if (rechecked.isEmpty) {
          try {
            final raw = await rootBundle.loadString('.env');
            final parsed = raw.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty && !l.trim().startsWith('#'));
            final inline = parsed.join('\n');
            if (inline.isNotEmpty) {
              dotenv.testLoad(fileInput: inline);
              print('[RuntimeEnv] Loaded .env from assets into dotenv');
            }
          } catch (e) {
            print('[RuntimeEnv] Reading asset .env failed: $e');
          }
        }

        // Final check
          if (apiKey.isEmpty) {
          print('ERROR: API key still empty after runtime load attempts. Current dotenv keys: ${dotenv.env.keys.toList()}');
          throw Exception('AI API key is not configured. Please add OPENROUTER_API_KEY to your .env file');
        }
      }

      Dio dio = Dio();

      // Trim history to speed up network payloads
      const maxMessages = 12;
      final recentMessages = previousMessage.length > maxMessages
          ? previousMessage.sublist(previousMessage.length - maxMessages)
          : previousMessage;

      // Debug logging to track what's being sent
      print('Sending ${recentMessages.length} (of ${previousMessage.length}) messages to AI');
      for (int i = 0; i < recentMessages.length; i++) {
        final msg = recentMessages[i];
        final text = msg.parts.isNotEmpty ? msg.parts.first.text : '';
        print('Message $i [${msg.role}]: ${text.length} chars - "${text.substring(0, text.length > 50 ? 50 : text.length)}..."');
      }

      // Map conversation into OpenRouter chat format
      final messages = recentMessages.map((e) {
        final text = e.parts.isNotEmpty ? e.parts.first.text : '';
        final role = e.role == 'model' ? 'assistant' : e.role;
        return {
          'role': role,
          'content': text,
        };
      }).toList();

      print('[OpenRouter] sending request to $defaultModel');
      Response response;
      try {
        response = await dio.post(
          apiEndpoint,
          data: {
            'model': defaultModel,
            'messages': messages,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            validateStatus: (_) => true,
          ),
        );
      } catch (e) {
        throw Exception('Network error: ${e.toString()}');
      }

      final status = response.statusCode ?? 0;
      print('[OpenRouter] response status: $status');
      
      if (status >= 200 && status < 300) {
        final data = response.data;
        if (data == null) {
          log('Response data is null');
          print('ERROR: Response data is null');
          throw Exception('Empty response from AI');
        }

        print('[OpenRouter] response: ${data.toString().substring(0, data.toString().length.clamp(0, 200))}');

        final choices = data['choices'];
        if (choices == null || choices.isEmpty) {
          log('No choices in response');
          print('ERROR: No choices in response. Full data: $data');
          throw Exception('No response choices from AI');
        }

        final firstChoice = choices.first;
        final message = firstChoice['message'];
        if (message == null) {
          log('No message in first choice');
          print('ERROR: No message in first choice. Choice: $firstChoice');
          throw Exception('Invalid response format from AI');
        }

        final content = message['content'];
        if (content is String && content.isNotEmpty) {
          print('[OpenRouter] returning response (${content.length} chars)');
          return content;
        }

        throw Exception('Empty or invalid content in AI response');
      } else {
        final data = response.data;
        String errMsg = 'Status $status';
        if (data is Map && data['error'] != null) {
          errMsg = data['error']['message']?.toString() ?? data['error'].toString();
        }
        print('[OpenRouter] ERROR: $errMsg');
        throw Exception('AI request failed: $errMsg');
      }
    } catch (e) {
      log('Error in chatTextGenerationRepo: ${e.toString()}');
      throw Exception('AI error: ${e.toString()}');
    }
  }
}
