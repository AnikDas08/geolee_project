
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
      notifications: list.map((e) => NotificationModel.fromJson(e)).toList(),
      unreadCount: data['unreadCount'] ?? 0,
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      read: json['isRead'] ?? false,
      // ✅ UTC → local time convert
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
    );
  }

  // ✅ copyWith — markAsRead এ কাজে লাগবে
  NotificationModel copyWith({bool? read}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }
}