class ChatModel {
  final String id;
  final bool isGroup;
  final String? chatName;
  final String? chatImage;
  final Participant participant;
  final List<Participant> participants; // ✅ Added full participants list
  final LatestMessage latestMessage;
  final int unreadCount;
  final bool isDeleted;
  final bool isOnline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int memberCount;

  ChatModel({
    required this.id,
    required this.isGroup,
    this.chatName,
    this.chatImage,
    required this.participant,
    required this.participants, // ✅ Added to constructor
    required this.latestMessage,
    required this.unreadCount,
    required this.isDeleted,
    required this.isOnline,
    required this.createdAt,
    required this.updatedAt,
    this.memberCount = 0,
  });

  // ✅ Added copyWith for state updates
  ChatModel copyWith({
    String? id,
    bool? isGroup,
    String? chatName,
    String? chatImage,
    Participant? participant,
    List<Participant>? participants,
    LatestMessage? latestMessage,
    int? unreadCount,
    bool? isDeleted,
    bool? isOnline,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? memberCount,
  }) {
    return ChatModel(
      id: id ?? this.id,
      isGroup: isGroup ?? this.isGroup,
      chatName: chatName ?? this.chatName,
      chatImage: chatImage ?? this.chatImage,
      participant: participant ?? this.participant,
      participants: participants ?? this.participants,
      latestMessage: latestMessage ?? this.latestMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isDeleted: isDeleted ?? this.isDeleted,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memberCount: memberCount ?? this.memberCount,
    );
  }

  static String? _parseStringOrFirstInList(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      return first is String ? first : first.toString();
    }
    return value.toString();
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    bool isGroupFromFlag = json['isGroup'] ?? json['isGroupChat'] ?? false;
    String? cName = _parseStringOrFirstInList(json['chatName']);
    bool isGroup = isGroupFromFlag || (cName != null && cName.isNotEmpty);

    var participantJson = json['anotherParticipant'];
    if (participantJson == null &&
        json['participants'] != null &&
        json['participants'] is List &&
        (json['participants'] as List).isNotEmpty) {
      participantJson = (json['participants'] as List).first;
    }

    // ✅ Parse full participants list
    List<Participant> allParticipants = [];
    if (json['participants'] != null && json['participants'] is List) {
      allParticipants = (json['participants'] as List)
          .map((p) => Participant.fromJson(p is Map<String, dynamic> ? p : {"_id": p.toString()}))
          .toList();
    }

    final dynamic rawUnseen = json['unseenCount'] ?? json['unSeenCount'] ?? json['unseen_count'] ?? json['unreadCount'];
    final int finalUnreadCount = rawUnseen != null ? int.tryParse(rawUnseen.toString()) ?? 0 : 0;

    return ChatModel(
      id: json['_id']?.toString() ?? '',
      isGroup: isGroup,
      chatName: cName,
      chatImage: _parseStringOrFirstInList(json['avatarUrl'] ?? json['image']),
      participant: Participant.fromJson(participantJson ?? {}),
      participants: allParticipants, // ✅ Correctly assigned
      latestMessage: LatestMessage.fromJson(json['latestMessage'] ?? {}),
      unreadCount: finalUnreadCount,
      isDeleted: json['isDeleted'] ?? false,
      isOnline: json['isOnline'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      memberCount: allParticipants.length,
    );
  }
}

class Participant {
  final String sId; // Match your filter property name
  final String fullName;
  final String image;

  Participant({required this.sId, required this.fullName, required this.image});

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      sId: json['_id']?.toString() ?? '',
      fullName: json['name']?.toString() ?? '',
      image: ChatModel._parseStringOrFirstInList(json['image']) ?? '',
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
    final String rawText = json['text']?.toString() ?? json['content']?.toString() ?? json['message']?.toString() ?? '';
    final String type = json['type']?.toString() ?? 'text';
    String displayText = rawText;
    
    if (type == 'image') displayText = '📷 Image';
    else if (type == 'document') displayText = '📄 Document';
    else if (type == 'media') displayText = '🎥 Media';
    else if (type == 'audio') displayText = '🎵 Audio';

    return LatestMessage(
      id: json['_id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? '',
      text: displayText,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
