class ChatModel {
  final String id;
  final Participant participant;
  final bool status;
  final LatestMessage latestMessage;
  final int unreadCount; // Add this field
  final bool isSeen; // Add this field to track if message is seen

  ChatModel({
    required this.id,
    required this.participant,
    required this.status,
    required this.latestMessage,
    required this.unreadCount,
    required this.isSeen
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    List participants = json['participants'] ?? [];

    Map<String, dynamic> participantData =
        (participants.isNotEmpty && participants[0] is Map)
        ? Map<String, dynamic>.from(participants[0])
        : {};

    var lastMessageData = json['lastMessage'];
    if (lastMessageData is Map) {
      lastMessageData = Map<String, dynamic>.from(lastMessageData);
    } else {
      lastMessageData = {};
    }

    // FIX: check for map and convert safely
    lastMessageData = Map<String, dynamic>.from(lastMessageData);

    return ChatModel(
      id: json['_id'] ?? '',
      participant: Participant.fromJson(participantData),
      status: json['status'] ?? false,
      latestMessage: LatestMessage.fromJson(
        lastMessageData as Map<String, dynamic>,
      ),
      unreadCount: json['unreadCount'] ?? 0,
      isSeen: json['isSeen'] ?? true,
    );
  }
}

class Participant {
  final String id;
  final String fullName;
  final String image;
  final List<String> skill;

  Participant({
    required this.id,
    required this.fullName,
    required this.image,
    required this.skill,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['_id'] ?? '',
      fullName: json['name'] ?? '',
      image: json['image'] ?? '',
      skill: List<String>.from(json['skill'] ?? []),
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
    this.text="",
    required this.createdAt,
  });

  factory LatestMessage.fromJson(Map<String, dynamic> json) {
    return LatestMessage(
      id: json['_id'] ?? '',
      sender: json['sender'] ?? '',
      text: json['text'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
