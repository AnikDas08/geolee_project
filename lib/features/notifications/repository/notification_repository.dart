import 'package:flutter/material.dart';
import 'package:giolee78/services/api/api_service.dart';
import '../../../config/api/api_end_point.dart';
import '../data/model/notification_model.dart';

class NotificationRepository {
  /// Get notifications (pagination)
  Future<NotificationResponse> getNotifications(int page) async {
    final response = await ApiService.get(
      "/notifications/me?page=$page&limit=10",
    );

    return NotificationResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Mark single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await ApiService.patch(
        "${ApiEndPoint.readNotificationById}/$notificationId",
        body: {"isRead": true},
      );
      debugPrint("markAsRead response: ${response.statusCode}");
    } catch (e) {
      debugPrint("markAsRead error: $e");
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await ApiService.patch(
        ApiEndPoint.readAllNotification,
        body: {},
      );
    } catch (e) {
      debugPrint("markAllAsRead error: $e");
      rethrow;
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
