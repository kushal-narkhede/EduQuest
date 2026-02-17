import 'package:flutter_dotenv/flutter_dotenv.dart';

/**
 * API Configuration for OpenRouter usage.
 */
String get apiKey {
  try {
    final key = dotenv.maybeGet('OPENROUTER_API_KEY') ?? '';
    if (key.isEmpty) {
      print('WARNING: OPENROUTER_API_KEY not found in .env file');
    } else {
      print('✓ API key loaded from OPENROUTER_API_KEY: ${key.substring(0, key.length.clamp(0, 20))}... (${key.length} chars)');
    }
    return key;
  } catch (e) {
    print('ERROR: Failed to get OPENROUTER_API_KEY: $e');
    return '';
  }
}

/// Default OpenRouter model
const String defaultModel = 'openai/gpt-3.5-turbo';

/// OpenRouter API endpoint
const String apiEndpoint = 'https://openrouter.ai/api/v1/chat/completions';