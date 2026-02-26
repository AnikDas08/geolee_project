class TotalMemberResponseModelById {
  final bool success;
  final String message;
  final TotalMemberByIdData data;

  TotalMemberResponseModelById({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TotalMemberResponseModelById.fromJson(Map<String, dynamic> json) {
    return TotalMemberResponseModelById(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: TotalMemberByIdData.fromJson(json['data']),
    );
  }
}

class TotalMemberByIdData {
  final String id;
  final List<Participant> participants;
  final String author;
  final String chatName;
  final String description;
  final String avatarUrl;
  final bool isGroupChat;
  final String privacy;
  final String accessType;
  final String requestStatus;
  final LatestMessage latestMessage;
  final String status;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  TotalMemberByIdData({
    required this.id,
    required this.participants,
    required this.author,
    required this.chatName,
    required this.description,
    required this.avatarUrl,
    required this.isGroupChat,
    required this.privacy,
    required this.accessType,
    required this.requestStatus,
    required this.latestMessage,
    required this.status,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TotalMemberByIdData.fromJson(Map<String, dynamic> json) {
    return TotalMemberByIdData(
      id: json['_id'] ?? '',
      participants: (json['participants'] as List)
          .map((e) => Participant.fromJson(e))
          .toList(),
      author: json['author'] ?? '',
      chatName: json['chatName'] ?? '',
      description: json['description'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      isGroupChat: json['isGroupChat'] ?? false,
      privacy: json['privacy'] ?? '',
      accessType: json['accessType'] ?? '',
      requestStatus: json['requestStatus'] ?? '',
      latestMessage: LatestMessage.fromJson(json['latestMessage']),
      status: json['status'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Participant {
  final String id;
  final String name;
  final String image;

  Participant({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class LatestMessage {
  final String id;
  final String chat;
  final String sender;
  final String type;
  final String content;
  final List<String> seenBy;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  LatestMessage({
    required this.id,
    required this.chat,
    required this.sender,
    required this.type,
    required this.content,
    required this.seenBy,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LatestMessage.fromJson(Map<String, dynamic> json) {
    return LatestMessage(
      id: json['_id'] ?? '',
      chat: json['chat'] ?? '',
      sender: json['sender'] ?? '',
      type: json['type'] ?? '',
      content: json['content'] ?? '',
      seenBy: List<String>.from(json['seenBy'] ?? []),
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}