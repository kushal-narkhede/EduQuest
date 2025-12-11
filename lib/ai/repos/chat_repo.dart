import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:student_learning_app/ai/models/chat_message_model.dart';
import 'package:student_learning_app/ai/utils/constants.dart';

/**
 * A repository class that handles communication with the Google Gemini AI API.
 * 
 * This class provides a clean interface for generating AI responses using the
 * Google Gemini 2.0 Flash model. It handles HTTP requests, response parsing,
 * and error handling for AI chat functionality.
 * 
 * The ChatRepo uses the Dio HTTP client for making API requests and provides
 * comprehensive logging for debugging and monitoring purposes.
 * 
 * Features:
 * - AI text generation using Google Gemini API
 * - Comprehensive error handling and logging
 * - Response validation and parsing
 * - Support for conversation context
 */
class ChatRepo {
  /**
   * Generates AI text responses using the OpenRouter API.
   *
   * This method sends a conversation history to the configured OpenRouter
   * model and returns the generated response. It handles the complete API
   * communication flow including request formatting, response parsing, and
   * error handling.
   *
   * @param previousMessage A list of previous chat messages providing context for the AI
   * @return A Future that completes with the generated AI response text, or empty string on error
   */
  static Future<String> chatTextGenerationRepo(
      List<ChatMessageModel> previousMessage) async {
    print('\n=== Starting AI Request ===');
    print('API Key status: ${apiKey.isEmpty ? "EMPTY" : "Present (${apiKey.length} chars)"}');
    
    try {
      // Check if API key is available
      if (apiKey.isEmpty) {
        print('ERROR: API key is empty!');
        throw Exception('OpenRouter API key is not configured. Please add OPENROUTER_API_KEY to your .env file');
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

      // Try default model first, then remaining available models (deduped)
      final modelsToTry = <String>{
        defaultModel,
        ...availableModels.where((m) => m != defaultModel),
      }.toList();
      final errors = <String>[];

      for (final model in modelsToTry) {
        print('Attempting model: $model');
        Response response;
        try {
          response = await dio.post(
            apiEndpoint,
            data: {
              'model': model,
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
          errors.add('$model -> network error: ${e.toString()}');
          continue;
        }

        final status = response.statusCode ?? 0;
        if (status >= 200 && status < 300) {
          final data = response.data;
          if (data == null) {
            log('Response data is null');
            print('ERROR: Response data is null');
            continue;
          }

          // Log full response for debugging
          print('Full API response: ${data.toString()}');

          final choices = data['choices'];
          if (choices == null || choices.isEmpty) {
            log('No choices in response');
            print('ERROR: No choices in response. Full data: $data');
            continue;
          }

          final firstChoice = choices.first;
          final message = firstChoice['message'];
          if (message == null) {
            log('No message in first choice');
            print('ERROR: No message in first choice. Choice: $firstChoice');
            continue;
          }

          final content = message['content'];

          // OpenRouter may return content as a plain string or a list of parts
          if (content is String) {
            if (content.isNotEmpty) {
              print('Using model (string content): $model');
              return content;
            }
            log('Empty string content in message');
            print('ERROR: Empty string content in message. Message: $message');
            continue;
          }

          if (content is List && content.isNotEmpty) {
            // Find first text part
            final first = content.first;
            if (first is Map && first['text'] != null) {
              final text = first['text'].toString();
              if (text.isNotEmpty) {
                print('Using model (list text content): $model');
                return text;
              }
            }
            // If not text, try stringifying non-empty map
            final asString = first.toString();
            if (asString.isNotEmpty) {
              print('Using model (list map content): $model');
              return asString;
            }
          }

          log('Unhandled content format');
          print('ERROR: Unhandled content format. Message: $message');
          continue;
        }

        // Non-2xx: capture error message and maybe retry next model
        final data = response.data;
        String errMsg = 'Status $status';
        if (data is Map && data['error'] != null) {
          errMsg = data['error']['message']?.toString() ?? errMsg;
        }

        errors.add('$model -> $errMsg');

        // Skip to next model on rate-limit/busy or missing endpoints
        if (status == 429 || status == 503 || errMsg.contains('No endpoints found')) {
          print('Model $model unavailable ($errMsg), trying next model...');
          await Future.delayed(const Duration(milliseconds: 300));
          continue;
        }

        // Other errors: keep collecting but try remaining models
        continue;
      }

      throw Exception(errors.isNotEmpty
          ? 'AI request failed: ${errors.join(' | ')}'
          : 'AI request failed with no response');
    } catch (e) {
      log('Error in chatTextGenerationRepo: ${e.toString()}');
      throw Exception('AI error: ${e.toString()}');
    }
  }
}
