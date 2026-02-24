class ChatModel {
  final String id;
  final bool isGroup;
  final String? chatName;
  final String? chatImage;
  final Participant participant;
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
    required this.latestMessage,
    required this.unreadCount,
    required this.isDeleted,
    required this.isOnline,
    required this.createdAt,
    required this.updatedAt,
    this.memberCount = 0,
  });

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

    print(
      ">>>>>>>>>>>> 👤 Parsing Chat: ID=${json['_id'] ?? 'N/A'}, isGroup=$isGroup, Name=${cName ?? "Single Chat"} <<<<<<<<<<<<",
    );

    var participantJson = json['anotherParticipant'];
    if (participantJson == null &&
        json['participants'] != null &&
        json['participants'] is List &&
        (json['participants'] as List).isNotEmpty) {
      participantJson = (json['participants'] as List).first;
    }

    // Log the raw unread count values for debugging
    final dynamic rawUnread = json['unreadCount'];
    final dynamic rawUnseen =
        json['unseenCount'] ?? json['unSeenCount'] ?? json['unseen_count'];

    print(
      ">>>>>>>>>>>> 📊 Unread Debug [ID=${json['_id']}]: unreadCount=$rawUnread, unseen=$rawUnseen <<<<<<<<<<<<",
    );

    // Prefer specific "unseen" count if available, otherwise fallback to unreadCount
    final int finalUnreadCount = rawUnseen != null
        ? int.tryParse(rawUnseen.toString()) ?? 0
        : (rawUnread != null ? int.tryParse(rawUnread.toString()) ?? 0 : 0);

    int mCount = 0;
    if (json['participants'] != null && json['participants'] is List) {
      mCount = (json['participants'] as List).length;
    }

    return ChatModel(
      id: json['_id']?.toString() ?? '',
      isGroup: isGroup,
      chatName: cName,
      chatImage: _parseStringOrFirstInList(json['image']),
      participant: Participant.fromJson(participantJson ?? {}),
      latestMessage: LatestMessage.fromJson(json['latestMessage'] ?? {}),
      unreadCount: finalUnreadCount,
      isDeleted: json['isDeleted'] ?? false,
      isOnline: json['isOnline'] ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      memberCount: mCount,
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
      id: json['_id']?.toString() ?? '',
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
    // Server may store message text in different fields
    final String rawText =
        json['text']?.toString() ??
        json['content']?.toString() ??
        json['message']?.toString() ??
        '';

    // Show friendly label for non-text messages
    final String type = json['type']?.toString() ?? 'text';
    String displayText = rawText;
    if (displayText.isEmpty || (type != 'text' && displayText.isNotEmpty)) {
      if (type == 'image')
        displayText = '📷 Image';
      else if (type == 'document')
        displayText = '📄 Document';
      else if (type == 'media')
        displayText = '🎥 Media';
      else if (type == 'audio')
        displayText = '🎵 Audio';
      else
        displayText = rawText;
    }

    return LatestMessage(
      id: json['_id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? '',
      text: displayText,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
