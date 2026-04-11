import 'dart:convert';
import 'package:http/http.dart' as http;

class UserApiService {
  static Future<void> sendTokenToServer({
    required String userId,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("https://yourapi.com/save-fcm-token"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_id": userId,
          "fcm_token": token,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Token sent successfully");
      } else {
        print("❌ Failed to send token: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending token: $e");
    }
  }
}