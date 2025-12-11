import 'package:flutter_dotenv/flutter_dotenv.dart';

/**
 * API Configuration for OpenRouter service
 */
String get apiKey {
  try {
    final key = dotenv.maybeGet('OPENROUTER_API_KEY') ?? '';
    if (key.isEmpty) {
      print('WARNING: OPENROUTER_API_KEY not found in .env file');
    } else {
      print('✓ API key loaded: ${key.substring(0, 20)}... (${key.length} chars)');
    }
    return key;
  } catch (e) {
    print('ERROR: Failed to get API key: $e');
    return '';
  }
}

/**
 * List of reliable free models from OpenRouter
 */
// Ordered fallbacks; keep IDs that currently have endpoints
const List<String> availableModels = [
	"meta-llama/llama-3.2-3b-instruct:free",
	"meta-llama/llama-3.1-8b-instruct:free",
	"mistralai/mistral-7b-instruct:free",
];

/**
 * Default model - using the most stable one
 */
const String defaultModel = "meta-llama/llama-3.2-3b-instruct:free";

/**
 * OpenRouter API endpoint
 */
const String apiEndpoint = "https://openrouter.ai/api/v1/chat/completions";