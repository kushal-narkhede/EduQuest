import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../utils/config.dart';

class ClerkService {
  static const String _baseUrl = 'https://api.clerk.com/v1';
  static String? _clientToken; // Store the client token
  
  /// Extract the Clerk frontend API domain from the publishable key
  static String _extractDomain() {
    final key = AppConfig.clerkPublishableKey;
    // Publishable key format: pk_test_base64encodedstring
    // The base64 string decodes to the domain
    try {
      final parts = key.split('_');
      if (parts.length >= 3) {
        final encoded = parts[2];
        final decoded = utf8.decode(base64.decode(encoded));
        return decoded;
      }
    } catch (e) {
      print('[Clerk] Error extracting domain: $e');
    }
    // Fallback to a default
    return 'safe-humpback-39.clerk.accounts.dev';
  }
  
  /// Get common headers with client token if available
  static Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_clientToken != null) {
      headers['Authorization'] = 'Bearer $_clientToken';
    }
    return headers;
  }
  
  /// Create a new sign-up with email
  static Future<Map<String, dynamic>> createSignUp({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      // Use the client endpoint which doesn't require authentication
      final response = await http.post(
        Uri.parse('https://${_extractDomain()}/v1/client/sign_ups'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email_address': email,
          'username': username,
          'password': password,
        }),
      );

      print('[Clerk] Create sign-up response: ${response.statusCode}');
      print('[Clerk] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Extract and store the client token from cookies or response
        final setCookie = response.headers['set-cookie'];
        if (setCookie != null) {
          print('[Clerk] Set-Cookie header: $setCookie');
          // Extract __client token from cookies
          final clientMatch = RegExp(r'__client=([^;]+)').firstMatch(setCookie);
          if (clientMatch != null) {
            _clientToken = clientMatch.group(1);
            print('[Clerk] Extracted client token');
          }
        }
        
        // Also check if client ID is in the response
        final client = data['client'];
        if (client != null && client['id'] != null) {
          print('[Clerk] Client ID: ${client['id']}');
        }
        
        // Return the response object which contains the sign_up
        return data['response'] ?? data;
      } else {
        throw Exception('Failed to create sign-up: ${response.body}');
      }
    } catch (e) {
      print('[Clerk] Error creating sign-up: $e');
      rethrow;
    }
  }

  /// Prepare email verification
  static Future<Map<String, dynamic>> prepareEmailVerification({
    required String signUpId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://${_extractDomain()}/v1/client/sign_ups/$signUpId/prepare_verification'),
        headers: _getHeaders(),
        body: jsonEncode({
          'strategy': 'email_code',
        }),
      );

      print('[Clerk] Prepare verification response: ${response.statusCode}');
      print('[Clerk] Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to prepare verification: ${response.body}');
      }
    } catch (e) {
      print('[Clerk] Error preparing verification: $e');
      rethrow;
    }
  }

  /// Verify email with code
  static Future<Map<String, dynamic>> verifyEmail({
    required String signUpId,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://${_extractDomain()}/v1/client/sign_ups/$signUpId/attempt_verification'),
        headers: _getHeaders(),
        body: jsonEncode({
          'strategy': 'email_code',
          'code': code,
        }),
      );

      print('[Clerk] Verify email response: ${response.statusCode}');
      print('[Clerk] Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify email: ${response.body}');
      }
    } catch (e) {
      print('[Clerk] Error verifying email: $e');
      rethrow;
    }
  }

  /// Get user session after successful verification
  static Future<Map<String, dynamic>> getSession({
    required String sessionId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('https://${_extractDomain()}/v1/client/sessions/$sessionId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get session: ${response.body}');
      }
    } catch (e) {
      print('[Clerk] Error getting session: $e');
      rethrow;
    }
  }
}
