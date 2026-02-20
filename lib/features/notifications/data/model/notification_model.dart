class NotificationModel {
  final String id;
  final String title;
  final String message;
  final bool read;       // read = isRead from API
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
      read: json['isRead'] ?? false,   // 👈 Change here from 'read' to 'isRead'
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
