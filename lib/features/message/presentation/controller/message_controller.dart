import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/socket/socket_service.dart';
import 'package:giolee78/utils/log/app_log.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class MessageController extends GetxController {
  /// Text Controller
  final messageController = TextEditingController();

  /// Image Picker
  final ImagePicker _picker = ImagePicker();

  /// Messages List
  List<ChatMessage> messages = [];

  /// Current User ID
  final String currentUserId = 'current_user';

  /// Chat Info
  String chatId = '';
  String chatRoomId = '';
  String name = '';
  String image = '';
  bool isActive = true;

  /// Service Info (for banner)
  String serviceTitle = '';
  String serviceImage = '';
  num price = 0;
  String postId = '';
  String clientStatus = '';

  /// Loading States
  bool isLoading = false;
  bool isUploadingImage = false;
  bool isUploadingFile = false;

  /// Scroll Controller
  final ScrollController scrollController = ScrollController();

  static MessageController get instance => Get.put(MessageController());

  void joinRoom() {
    final body = {chatId};
    SocketServices.emitWithAck('room:join', body, (data) {});
  }

  void leaveRoom() {
    final body = {chatId};
    SocketServices.emitWithAck('room:leave', body, (data) {});
  }

  @override
  void onInit() {
    super.onInit();

    // Get arguments from previous screen
    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null) {
      chatId = args['chatId'] ?? '';
      chatRoomId = args['chatId'] ?? '';
      name = args['name'] ?? '';
      image = args['image'] ?? '';
      isActive = args['isActive'] ?? true;

      appLog("chat id 😍😍😍😍 $chatId");
      appLog("chat room id 😍😍😍😍 $chatRoomId");
    }

    loadMessages();
  }

  /// Load Messages
  Future<void> loadMessages() async {
    isLoading = true;
    update();

    final String url = "${ApiEndPoint.messages}/$chatId";
    final response = await ApiService.get(url);

    if (response.statusCode == 200) {
      final data = response.data['data'];
      for (var json in data) {
        final message = ChatMessage.fromJson(json);
        messages.add(message);
      }
    }

    isLoading = false;
    update();
    _scrollToBottom();
  }

  /// Send Text Message
  Future<void> sendMessage() async {
    if (messageController.text.trim().isNotEmpty) {
      final body = {
        "chat": chatId,
        "text": messageController.text.trim(),
        "type": "text",
      };

      final url = ApiEndPoint.createMessage;
      final ApiResponseModel response = await ApiService.post(url, body: body);

      if (response.statusCode == 200) {
        debugPrint("========================${response.message}");
      }
    }

    messageController.clear();
    update();
    _scrollToBottom();
  }

  /// Pick Image from Gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await _sendImageMessage(image.path);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image: $e');
    }
  }

  /// Pick Image from Camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        await _sendImageMessage(image.path);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to capture photo: $e');
    }
  }

  /// Pick File (PDF, DOC, DOCX, XLS, XLSX, TXT, PNG, JPG, etc.)
  Future<void> pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          // Documents
          'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'csv',
          // Images
          'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic',
        ],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile pickedFile = result.files.first;
        final String filePath = pickedFile.path!;
        final String fileName = pickedFile.name;
        final String extension = path.extension(fileName).toLowerCase().replaceAll('.', '');

        // Decide type: image vs document
        const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'];

        if (imageExtensions.contains(extension)) {
          await _sendImageMessage(filePath);
        } else {
          await _sendFileMessage(filePath, fileName, extension);
        }
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick file: $e');
    }
  }

  /// Send Image Message
  Future<void> _sendImageMessage(String imagePath) async {
    isUploadingImage = true;
    update();
    _scrollToBottom();

    try {
      // TODO: Upload image to server and get URL, then post via API
      // Example:
      // final uploadedUrl = await ApiService.uploadFile(imagePath);
      // final body = { "chat": chatId, "content": uploadedUrl, "type": "image" };
      // await ApiService.post(ApiEndPoint.createMessage, body: body);

      await Future.delayed(const Duration(seconds: 2)); // Simulate upload

      Get.snackbar(
        'Success',
        'Image sent successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _showErrorSnackbar('Failed to send image: $e');
    } finally {
      isUploadingImage = false;
      update();
      _scrollToBottom();
    }
  }

  /// Send File (Document) Message
  Future<void> _sendFileMessage(
      String filePath,
      String fileName,
      String extension,
      ) async {
    isUploadingFile = true;
    update();
    _scrollToBottom();

    try {

      final uploadedUrl = await ApiService.multipartUpdate(filePath);
      final body = {
        "chat": chatId,
        "content": uploadedUrl,
        "type": "file",
        "fileName": fileName,
      };
     ApiResponseModel response= await ApiService.post(ApiEndPoint.createMessage, body: body);

     if (response.statusCode == 200) {
        debugPrint("========================${response.message}");
      }



      Get.snackbar(
        'Success',
        'File "$fileName" sent successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _showErrorSnackbar('Failed to send file: $e');
    } finally {
      isUploadingFile = false;
      update();
      _scrollToBottom();
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  /// Scroll to Bottom
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

// ============================================
// CHAT MESSAGE MODEL
// ============================================
class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String type; // text / image / file
  final String message;
  final List<String> seenBy;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCurrentUser;
  final bool isSeen;

  // UI helper fields
  final String? imageUrl;
  final bool isImage;
  final bool isUploading;
  final bool isNotice;

  // File-specific fields
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
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isCurrentUser: json['isMyMessage'] ?? false,
      isSeen: json['isSeen'] ?? false,

      // Image
      imageUrl: type == 'image' ? json['content'] : null,
      isImage: type == 'image',

      // File
      fileUrl: type == 'file' ? json['content'] : null,
      fileName: json['fileName'],
      fileExtension: json['fileExtension'],
      isFile: type == 'file',
    );
  }
}