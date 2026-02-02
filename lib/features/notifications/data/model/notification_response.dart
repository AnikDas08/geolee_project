import 'notification_model.dart';

class NotificationResponse {
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotificationResponse({
    required this.notifications,
    required this.unreadCount,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final List list = data['data'] ?? [];

    return NotificationResponse(
      notifications:
      list.map((e) => NotificationModel.fromJson(e)).toList(),
      unreadCount: data['unreadCount'] ?? 0,
    );
  }
}
