import 'package:flutter/material.dart';
import '../../config/api/api_end_point.dart';
import 'api_service.dart';

class UserApiService {
  static Future<void> sendTokenToServer({
    required String userId,
    required String token,
  }) async {
    try {
      final response = await ApiService.multipartUpdate(
        ApiEndPoint.fcmTokenUpdate,
        body: {"fcmToken": token},
      );

      if (response.isSuccess) {
        debugPrint("✅ FCM Token updated successfully");
      } else {
        debugPrint("❌ Failed to update FCM Token: ${response.message}");
      }
    } catch (e) {
      debugPrint("❌ Error updating token: $e");
    }
  }
}