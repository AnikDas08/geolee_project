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
    // Handle nested 'data' if it exists in the response
    final Map<String, dynamic> data = (json.containsKey('data') && json['data'] is Map)
        ? json['data'] as Map<String, dynamic>
        : json;

    return NotificationModel(
      id: data['_id'] ?? data['id'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      read: data['isRead'] ?? data['read'] ?? false,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'].toString())
          : DateTime.now(),
    );
  }
}
