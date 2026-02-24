import 'package:giolee78/config/api/api_end_point.dart';

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

  /// Builds a full URL from a relative path returned by the server
  static String _buildUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    // Remove leading slash to avoid double-slash
    final clean = path.startsWith('/') ? path.substring(1) : path;
    return '${ApiEndPoint.imageUrl}/$clean';
  }

  /// Extracts the file name from a URL/path (e.g. "/uploads/doc_abc.pdf" → "doc_abc.pdf")
  static String? _extractFileName(String? path, String? explicit) {
    if (explicit != null && explicit.isNotEmpty) return explicit;
    if (path == null || path.isEmpty) return null;
    return path.split('/').last;
  }

  /// Extracts the extension from a URL/path (e.g. "doc.pdf" → "pdf")
  static String? _extractExtension(String? path, String? explicit) {
    if (explicit != null && explicit.isNotEmpty) return explicit;
    if (path == null || path.isEmpty) return null;
    final name = path.split('/').last;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1) return null;
    return name.substring(dotIndex + 1).toLowerCase();
  }

  factory ChatMessage.fromJson(Map<dynamic, dynamic> json) {
    final String type = json['type'] ?? 'text';
    final String? content = json['content'];
    final bool isImageType = type == 'image';
    final bool isFileType =
        type == 'document' || type == 'file' || type == 'media';

    return ChatMessage(
      id: json['_id'] ?? '',
      chatId: json['chat'] is String
          ? json['chat']
          : json['chat']?['_id'] ?? '',
      senderId: json['sender']?['_id'] ?? '',
      senderName: json['sender']?['name'] ?? '',
      senderImage: json['sender']?['image'] ?? '',
      type: type,
      message: content ?? '',
      seenBy: List<String>.from(json['seenBy'] ?? []),
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      isCurrentUser: json['isMyMessage'] ?? false,
      isSeen: json['isSeen'] ?? false,
      // Image
      imageUrl: isImageType ? _buildUrl(content) : null,
      isImage: isImageType,
      // File / document / media
      fileUrl: isFileType ? _buildUrl(content) : null,
      fileName: _extractFileName(isFileType ? content : null, json['fileName']),
      fileExtension: _extractExtension(
        isFileType ? content : null,
        json['fileExtension'],
      ),
      isFile: isFileType,
    );
  }
}
