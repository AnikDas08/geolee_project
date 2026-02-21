import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/utils/log/app_log.dart';

class MessageController extends GetxController {
  /// ========== TEXT CONTROLLER ==========
  final messageController = TextEditingController();

  /// ========== IMAGE & FILE PICKERS ==========
  final ImagePicker _imagePicker = ImagePicker();

  /// ========== PICKED FILES VARIABLES ==========
  XFile? pickedImage;
  PlatformFile? pickedFile;
  String? pickedImagePath;
  String? pickedFilePath;
  String? pickedFileName;
  String? pickedFileType;

  /// ========== UI STATE VARIABLES ==========
  bool isPickingImage = false;
  bool isPickingFile = false;
  bool hasPickedImage = false;
  bool hasPickedFile = false;

  /// ========== LOADING STATES ==========
  bool isUploadingImage = false;
  bool isUploadingMedia = false;
  bool isUploadingDocument = false;
  bool isSendingText = false;

  /// ========== MESSAGES ==========
  List<ChatMessage> messages = [];

  /// ========== CHAT VARIABLES ==========
  String chatId = '';
  String chatRoomId = '';
  String name = '';
  String image = '';
  bool isActive = true;

  /// ========== SERVICE INFO ==========
  String serviceTitle = '';
  String serviceImage = '';
  num price = 0;
  String postId = '';
  String clientStatus = '';

  /// ========== GENERAL LOADING STATE ==========
  bool isLoading = false;

  /// ========== SCROLL CONTROLLER ==========
  final ScrollController scrollController = ScrollController();

  static MessageController get instance => Get.put(MessageController());

  /// ========== LIFECYCLE ==========
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ================================================
  // 1️⃣ PICK IMAGE FROM GALLERY
  // ================================================
  Future<void> pickImageFromGallery() async {
    try {
      isPickingImage = true;
      update();

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        pickedImage = image;
        pickedImagePath = image.path;
        pickedFile = null;
        pickedFilePath = null;
        hasPickedImage = true;
        hasPickedFile = false;
        pickedFileType = 'image';

        appLog("✅ Image picked from gallery: ${image.path}");
        update();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
      appLog("❌ Pick image error: $e");
    } finally {
      isPickingImage = false;
      update();
    }
  }

  // ================================================
  // 2️⃣ PICK IMAGE FROM CAMERA
  // ================================================
  Future<void> pickImageFromCamera() async {
    try {
      isPickingImage = true;
      update();

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        pickedImage = image;
        pickedImagePath = image.path;
        pickedFile = null;
        pickedFilePath = null;
        hasPickedImage = true;
        hasPickedFile = false;
        pickedFileType = 'image';

        appLog("✅ Image captured from camera: ${image.path}");
        update();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture photo: $e');
      appLog("❌ Camera error: $e");
    } finally {
      isPickingImage = false;
      update();
    }
  }

  // ================================================
  // 3️⃣ PICK FILE
  // ================================================
  Future<void> pickFile() async {
    try {
      isPickingFile = true;
      update();

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'csv',
          'jpg',
          'jpeg',
          'png',
          'gif',
          'webp',
          'bmp',
          'heic',
          'mp3',
          'mp4',
          'avi',
          'mov',
          'mkv',
          'flv',
          'wav',
        ],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        pickedFile = file;
        pickedFilePath = file.path;
        pickedFileName = file.name;
        pickedImage = null;
        pickedImagePath = null;
        hasPickedFile = true;
        hasPickedImage = false;

        _detectFileType(file.name);

        appLog("✅ File picked: ${file.name}");
        appLog("   Path: ${file.path}");
        appLog("   Size: ${file.size} bytes");
        appLog("   Type: $pickedFileType");

        update();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick file: $e');
      appLog("❌ File picker error: $e");
    } finally {
      isPickingFile = false;
      update();
    }
  }

  // ================================================
  // 4️⃣ DETECT FILE TYPE
  // ================================================
  void _detectFileType(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;

    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'].contains(ext)) {
      pickedFileType = 'image';
    } else if (['mp3', 'mp4', 'avi', 'mov', 'mkv', 'flv', 'wav']
        .contains(ext)) {
      pickedFileType = 'media';
    } else {
      pickedFileType = 'document';
    }
  }

  // ================================================
  // 5️⃣ CLEAR PICKED FILES
  // ================================================
  void clearPickedImage() {
    pickedImage = null;
    pickedImagePath = null;
    hasPickedImage = false;
    update();
  }

  void clearPickedFile() {
    pickedFile = null;
    pickedFilePath = null;
    pickedFileName = null;
    pickedFileType = null;
    hasPickedFile = false;
    update();
  }

  void clearAllPicks() {
    pickedImage = null;
    pickedImagePath = null;
    pickedFile = null;
    pickedFilePath = null;
    pickedFileName = null;
    pickedFileType = null;
    hasPickedImage = false;
    hasPickedFile = false;
    messageController.clear();
    update();
  }

  // ================================================
  // 6️⃣ GETTER METHODS
  // ================================================
  String getPickedFileName() {
    if (hasPickedImage && pickedImage != null) {
      return pickedImage!.name;
    }
    if (hasPickedFile && pickedFile != null) {
      return pickedFile!.name;
    }
    return '';
  }

  String getPickedFileType() {
    return pickedFileType ?? 'unknown';
  }

  String getPickedFileSize() {
    if (hasPickedFile && pickedFile != null) {
      final sizeMB = (pickedFile!.size / (1024 * 1024)).toStringAsFixed(2);
      return '$sizeMB MB';
    }
    return '';
  }

  bool isImagePicked() => hasPickedImage && pickedImage != null;
  bool isFilePicked() => hasPickedFile && pickedFile != null;

  String? getPickedFilePath() {
    if (hasPickedImage && pickedImagePath != null) {
      return pickedImagePath;
    }
    if (hasPickedFile && pickedFilePath != null) {
      return pickedFilePath;
    }
    return null;
  }

  // ================================================
  // 7️⃣ LOAD MESSAGES
  // ================================================
  Future<void> loadMessages() async {
    isLoading = true;
    update();

    try {
      final String url = "${ApiEndPoint.messages}/$chatId";
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = response.data['data'] as List?;
        if (data != null) {
          messages.clear();
          for (var json in data) {
            final message = ChatMessage.fromJson(json);
            messages.add(message);
          }
        }
      }
    } catch (e) {
      appLog("❌ Load messages error: $e");
    } finally {
      isLoading = false;
      update();
      _scrollToBottom();
    }
  }

  // ================================================
  // 8️⃣ SEND METHODS
  // ================================================

  // ===================main send message method===================
  Future<void> sendMessage() async {
    await sendTextAndFile();
  }

  //==================== Send text and file ===============================
  Future<void> sendTextAndFile() async {
    if (messageController.text.trim().isEmpty &&
        !isImagePicked() &&
        !isFilePicked()) {
      _showErrorSnackBar('Nothing to send');
      return;
    }

    // Send text first
    if (messageController.text.trim().isNotEmpty) {
      await _sendTextMessage();
    }

    // Then send file
    if (isImagePicked() || isFilePicked()) {
      await sendPickedFile();
    }
  }

  //====================this one for send text message==================================
  Future<void> _sendTextMessage() async {
    isSendingText = true;
    update();

    try {
      final response = await ApiService.post(
        ApiEndPoint.createMessage,
        body: {
          "chat": chatId,
          "type": "text",
          "text": messageController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        appLog("✅ Text sent successfully");
        messageController.clear();
      } else {
        _showErrorSnackBar('Failed to send message');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
      appLog("❌ Send text error: $e");
    } finally {
      isSendingText = false;
      update();
    }
  }

  //==========================this one for send file =================================
  Future<void> sendPickedFile() async {
    final filePath = getPickedFilePath();
    final fileType = pickedFileType;

    if (filePath == null || filePath.isEmpty) {
      _showErrorSnackBar('No file picked');
      return;
    }

    // Validate file exists
    if (!File(filePath).existsSync()) {
      _showErrorSnackBar('File not found or deleted');
      clearAllPicks();
      return;
    }

    try {
      switch (fileType) {
        case 'image':
          await _sendImageMessage(filePath);
          break;
        case 'media':
          await _sendMediaMessage(filePath);
          break;
        case 'document':
        default:
          await _sendDocumentMessage(filePath);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to send file: $e');
    } finally {
      clearAllPicks();
      update();
    }
  }

  // =======================this one for send image====================================
  Future<void> _sendImageMessage(String imagePath) async {
    isUploadingImage = true;
    update();

    try {
      final response = await ApiService.multipart(
        ApiEndPoint.createMessage,
        imagePath: imagePath,
        body: {
          "chat": chatId,
          "type": "image",
        },
      );

      if (response.statusCode == 200) {
        appLog("✅ Image sent successfully");
        _showSuccessSnackBar('Image sent');
        await loadMessages();
      } else {
        _showErrorSnackBar('Failed to send image');
      }
    } catch (e) {
      _showErrorSnackBar('Error sending image: $e');
      appLog("❌ Send image error: $e");
    } finally {
      isUploadingImage = false;
      update();
    }
  }

  //==================this one for send media (audio and video)================

  Future<void> _sendMediaMessage(String mediaPath) async {
    isUploadingMedia = true;
    update();

    try {
      final response = await ApiService.multipart(
        ApiEndPoint.createMessage,
        imagePath: mediaPath,
        imageName: "media",
        body: {
          "chat": chatId,
          "type": "media",
        },
      );

      if (response.statusCode == 200) {
        appLog("✅ Media sent successfully");
        _showSuccessSnackBar('Media sent');
        await loadMessages();
      } else {
        _showErrorSnackBar('Failed to send media');
      }
    } catch (e) {
      _showErrorSnackBar('Error sending media: $e');
      appLog("❌ Send media error: $e");
    } finally {
      isUploadingMedia = false;
      update();
    }
  }

  //=================this one for send document =========================
  Future<void> _sendDocumentMessage(String docPath) async {
    isUploadingDocument = true;
    update();

    try {
      final response = await ApiService.multipart(
        ApiEndPoint.createMessage,
        imagePath: docPath,
        imageName: "doc",
        body: {
          "chat": chatId,
          "type": "document",
        },
      );

      if (response.statusCode == 200) {
        appLog("Document sent successfully");
        _showSuccessSnackBar('Document sent');
        await loadMessages();
      } else {
        _showErrorSnackBar('Failed to send document');
      }
    } catch (e) {
      _showErrorSnackBar('Error sending document: $e');
      appLog("❌ Send document error: $e");
    } finally {
      isUploadingDocument = false;
      update();
    }
  }



  void _showSuccessSnackBar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

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
}

// ================================================ CHAT MESSAGE MODEL

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