import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Global app configuration
class AppConfig {
  /// Toggle to switch between local SQLite and remote Mongo-backed API
  static const bool useRemoteDb = true; // set to true to use the cloud API

  /// Clerk publishable key for auth UI and email verification
  static String get clerkPublishableKey {
    const envKey = String.fromEnvironment('CLERK_PUBLISHABLE_KEY');
    if (envKey.isNotEmpty) return envKey;

    // Fallback placeholder; override via --dart-define=CLERK_PUBLISHABLE_KEY=pk_test_...
    return 'pk_test_YOUR_CLERK_KEY_HERE';
  }

  /// Base URL for the backend API. Uses Android emulator loopback when needed.
  static String get baseUrl {
    // If API_BASE_URL is set via --dart-define, use it
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // TEMPORARY: Use local server for testing
    return 'http://192.168.0.107:3000';

    // Production: use your deployed backend URL
    // const productionUrl = 'https://fbla-2025-5mb7.onrender.com';
    // if (productionUrl != 'https://your-backend.onrender.com') {
    //   return productionUrl; // Use production URL if configured
    // }

    // Development fallback: use your local machine's network IP for physical devices
    return 'http://192.168.0.107:3000';
  }
}
