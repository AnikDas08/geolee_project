import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/storage/storage_services.dart';

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

  bool get isEncrypted {
    if (type != 'text') return false;
    if (message.isEmpty) return false;
    if (message.startsWith("U2FsdGVk")) return true;
    final regex = RegExp(r'^[0-9a-fA-F]+:[0-9a-fA-F]+:[0-9a-fA-F]+$');
    return regex.hasMatch(message);
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  /// Builds a full URL from a relative path returned by the server
  static String _buildUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final clean = path.startsWith('/') ? path.substring(1) : path;
    return '${ApiEndPoint.imageUrl}/$clean';
  }

  /// Extracts the file name from a URL/path
  static String? _extractFileName(String? path, String? explicit) {
    if (explicit != null && explicit.isNotEmpty) return explicit;
    if (path == null || path.isEmpty) return null;
    return path.split('/').last;
  }

  /// Extracts the extension from a URL/path
  static String? _extractExtension(String? path, String? explicit) {
    if (explicit != null && explicit.isNotEmpty) return explicit;
    if (path == null || path.isEmpty) return null;
    final name = path.split('/').last;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1) return null;
    return name.substring(dotIndex + 1).toLowerCase();
  }

  // ─────────────────────────────────────────────
  // fromJson
  // ─────────────────────────────────────────────
  factory ChatMessage.fromJson(Map<dynamic, dynamic> json) {
    final String type = json['type'] ?? 'text';
    final String? content = json['content'];
    final bool isImageType = type == 'image';
    final bool isFileType =
        type == 'document' || type == 'file' || type == 'media';

    // ✅ sender ID বের করুন
    final String senderId =
        json['sender']?['_id']?.toString() ?? '';

    // ✅ LocalStorage.userId দিয়ে compare — সবসময় সঠিক result দেবে
    final bool isCurrentUser =
        senderId.isNotEmpty && senderId == LocalStorage.userId;

    return ChatMessage(
      id: json['_id'] ?? '',
      chatId: json['chat'] is String
          ? json['chat']
          : json['chat']?['_id'] ?? '',
      senderId: senderId,
      senderName: json['sender']?['name'] ?? '',
      senderImage: json['sender']?['image'] ?? '',
      type: type,
      message: content ?? '',
      seenBy: List<String>.from(json['seenBy'] ?? []),
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ).toLocal(),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ).toLocal(),
      isCurrentUser: isCurrentUser, // ✅ Fixed
      isSeen: json['isSeen'] ?? false,
      imageUrl: isImageType ? _buildUrl(content) : null,
      isImage: isImageType,
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

// ─────────────────────────────────────────────
// ChatMessageModel (UI helper)
// ─────────────────────────────────────────────
class ChatMessageModel {
  final DateTime time;
  final String text;
  final String image;
  final String? messageImage;
  final bool isMe;
  final String? clientStatus;
  final bool isNotice;
  final bool isUploading;

  ChatMessageModel({
    required this.time,
    required this.text,
    required this.image,
    this.messageImage,
    this.isMe = false,
    this.clientStatus = "",
    this.isNotice = false,
    this.isUploading = false,
  });
}