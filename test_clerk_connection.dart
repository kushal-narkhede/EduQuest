// Quick test to verify Clerk configuration
// Run this with: dart run test_clerk_connection.dart

import 'package:http/http.dart' as http;

void main() async {
  // Replace with your actual Clerk publishable key
  const clerkKey = 'pk_test_c2FmZS1odW1wYmFjay0zOS5jbGVyay5hY2NvdW50cy5kZXYk';
  
  print('Testing Clerk connectivity...');
  print('Using key: $clerkKey');
  
  // Extract domain from the key (it's base64 encoded)
  try {
    // Test if we can reach Clerk's API
    final response = await http.get(
      Uri.parse('https://api.clerk.com/v1/client'),
      headers: {
        'Authorization': 'Bearer $clerkKey',
      },
    );
    
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 401) {
      print('✅ Can reach Clerk API');
    } else {
      print('❌ Unexpected response from Clerk');
    }
  } catch (e) {
    print('❌ Error connecting to Clerk: $e');
    print('This suggests a network or configuration issue');
  }
}
