import 'package:clora_user/network/network_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart'; // Import Stream Chat types
import '../main.dart'; // Import to access the global 'client' instance

// NOTE: In a production app, the token MUST be generated securely on a trusted backend.
// This local implementation using devToken is for temporary development ONLY.

Future<String> getStreamChatTokenApi(int userId) async {
  final userIdString = userId.toString();

  // Use the global client instance to generate the development token
  // The client must have been initialized with the API key in main.dart
  try {
    final token = client.devToken(userIdString).rawValue; // Using .rawValue as requested
    if (kDebugMode) {
      debugPrint("Generated Stream Chat Dev Token for user: $userIdString");
    }
    return token;
  } catch (e) {
    if (kDebugMode) {
      debugPrint("Error generating dev token for user $userIdString: $e");
    }
    // Re-throw or handle as required by the calling authentication flow
    throw Exception("Failed to generate Stream Chat authentication token.");
  }
}
