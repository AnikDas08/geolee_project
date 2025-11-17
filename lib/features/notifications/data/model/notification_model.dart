class NotificationModel {
  final String id;
  final String title;
  final String text;
  final String receiver;
  final String? referenceId;
  final NotificationSender? sender;
  final String? screen;
  final bool read;
  final int v;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.text,
    required this.receiver,
    this.referenceId,
    this.sender,
    this.screen,
    required this.read,
    required this.v,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? "",
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      receiver: json['receiver'] ?? '',
      referenceId: json['referenceId'],
      sender: json['sender'] != null
          ? NotificationSender.fromJson(json['sender'])
          : null,
      screen: json['screen'],
      read: json['read'] ?? false,
      v: json['__v'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class NotificationSender {
  final String id;
  final String name;
  final String image;

  NotificationSender({
    required this.id,
    required this.name,
    required this.image,
  });

  factory NotificationSender.fromJson(Map<String, dynamic> json) {
    return NotificationSender(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
