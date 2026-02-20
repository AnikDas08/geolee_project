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

  // ✅ Add this
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    bool? read,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      read: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}