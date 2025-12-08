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

    // TODO: Replace with your actual Clerk Publishable Key from https://dashboard.clerk.com
    // Get it from: Dashboard -> API Keys -> Publishable Key (starts with pk_test_ or pk_live_)
    return 'pk_test_c2FmZS1odW1wYmFjay0zOS5jbGVyay5hY2NvdW50cy5kZXYk';
  }

  /// Base URL for the backend API. Uses Android emulator loopback when needed.
  static String get baseUrl {
    // If API_BASE_URL is set via --dart-define, use it
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // DEVELOPMENT MODE: Using local server
    // Change this to your production URL when deploying
    // const productionUrl = 'https://fbla-2025-5mb7.onrender.com';
    
    // Development fallback: Web uses localhost
    if (kIsWeb) return 'http://localhost:3000';

    try {
      if (Platform.isAndroid) {
        // Use your computer's local IP address for Android emulator/device
        // If 10.0.2.2 doesn't work, use your computer's actual IP
        return 'http://192.168.0.104:3000';
      }
    } catch (_) {
      // Platform may not be available in all contexts
    }

    return 'http://localhost:3000';
  }
}
