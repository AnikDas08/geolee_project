import 'package:giolee78/services/api/api_service.dart';
import '../data/model/notification_response.dart';

class NotificationRepository {
  /// Get notifications (pagination)
  Future<NotificationResponse> getNotifications(int page) async {
    final response = await ApiService.get(
      "/notifications/me?page=$page&limit=10",
    );

    return NotificationResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Mark single notification as read
  Future<bool> markNotificationAsRead(String id) async {
    try {
      final response = await ApiService.patch(
        "/notifications/$id",
        body: {"isRead": true},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error marking notification read: $e");
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllNotificationsAsRead() async {
    try {
      final response = await ApiService.patch("/notifications/mark-all-read");
      return response.statusCode == 200;
    } catch (e) {
      print("Error marking all notifications read: $e");
      return false;
    }
  }
}
