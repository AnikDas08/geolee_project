class ChatModel {
  final String id;
  final Participant participant;
  final LatestMessage latestMessage; // nullable
  final int unreadCount;
  final bool isDeleted;
  final bool isOnline;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatModel({
    required this.id,
    required this.participant,
    required this.latestMessage,
    required this.unreadCount,
    required this.isDeleted,
    required this.isOnline,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['_id'] ?? '',
      participant: Participant.fromJson(json['anotherParticipant'] ?? {}),
      latestMessage: LatestMessage.fromJson(json['latestMessage'] ?? {}),
      unreadCount: json['unreadCount'] ?? 0,
      isDeleted: json['isDeleted'] ?? false,
      isOnline: json['isOnline'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class Participant {
  final String id;
  final String fullName;
  final String image;

  Participant({required this.id, required this.fullName, required this.image});

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['_id'] ?? '',
      fullName: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class LatestMessage {
  final String id;
  final String sender;
  final String text;
  final DateTime createdAt;

  LatestMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
  });

  factory LatestMessage.fromJson(Map<String, dynamic> json) {
    return LatestMessage(
      id: json['_id'] ?? '',
      sender: json['sender'] ?? '',
      text: json['text'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
