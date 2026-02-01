import 'package:dio/dio.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import '../data/model/notification_response.dart';

class NotificationRepository {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://10.10.7.7:5006/api/v1",
      headers: {
        "Authorization": "Bearer ${LocalStorage.token}",
      },
    ),
  );

  /// Get notifications (pagination)
  Future<NotificationResponse> getNotifications(int page) async {
    final response = await dio.get(
      "/notifications/me",
      queryParameters: {
        "page": page,
        "limit": 10,
      },
    );

    return NotificationResponse.fromJson(response.data);
  }

  /// Mark single notification as read
  Future<bool> markNotificationAsRead(String id) async {
    try {
      final response = await dio.patch(
        "/notifications/$id",
        data: {"isRead": true},
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
      final response = await dio.patch("/notifications/mark-all-read");
      return response.statusCode == 200;
    } catch (e) {
      print("Error marking all notifications read: $e");
      return false;
    }
  }
}
