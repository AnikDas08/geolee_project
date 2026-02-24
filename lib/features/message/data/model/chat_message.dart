class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String type;
  final String message;
  final List<String> seenBy;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCurrentUser;
  final bool isSeen;
  final String? imageUrl;
  final bool isImage;
  final bool isUploading;
  final bool isNotice;
  final String? fileUrl;
  final String? fileName;
  final String? fileExtension;
  final bool isFile;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.type,
    required this.message,
    required this.seenBy,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.isCurrentUser,
    required this.isSeen,
    this.imageUrl,
    this.isImage = false,
    this.isUploading = false,
    this.isNotice = false,
    this.fileUrl,
    this.fileName,
    this.fileExtension,
    this.isFile = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final String type = json['type'] ?? 'text';
    return ChatMessage(
      id: json['_id'] ?? '',
      chatId: json['chat'] ?? '',
      senderId: json['sender']?['_id'] ?? '',
      senderName: json['sender']?['name'] ?? '',
      senderImage: json['sender']?['image'] ?? '',
      type: type,
      message: json['content'] ?? '',
      seenBy: List<String>.from(json['seenBy'] ?? []),
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
      isCurrentUser: json['isMyMessage'] ?? false,
      isSeen: json['isSeen'] ?? false,
      imageUrl: type == 'image' ? json['content'] : null,
      isImage: type == 'image',
      fileUrl: type == 'file' ? json['content'] : null,
      fileName: json['fileName'],
      fileExtension: json['fileExtension'],
      isFile: type == 'document' || type == 'file' || type == 'media',
    );
  }
}
