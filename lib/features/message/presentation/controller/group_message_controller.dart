import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:giolee78/features/message/data/model/chat_message.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/socket/socket_service.dart';
import 'package:giolee78/utils/log/app_log.dart';
import 'package:giolee78/config/api/api_end_point.dart';

class GroupMessageController extends GetxController {
  /// Text Controller
  final messageController = TextEditingController();

  /// Image Picker
  final ImagePicker _picker = ImagePicker();

  /// ========== PICKED FILES ==========
  XFile? pickedImage;
  PlatformFile? pickedFile;
  String? pickedImagePath;
  String? pickedFilePath;
  String? pickedFileName;
  String? pickedFileType;
  bool isPickingImage = false;
  bool isPickingFile = false;
  bool hasPickedImage = false;
  bool hasPickedFile = false;

  final RxString avatarFilePath = "".obs;

  /// ========== UPLOAD STATE ==========
  bool isUploadingImage = false;
  bool isUploadingMedia = false;
  bool isUploadingDocument = false;
  bool isSendingText = false;
  bool isLoading = false;

  /// Messages List (using shared model)
  List<ChatMessage> messages = [];

  /// Current Chat ID
  String chatId = '';

  /// Group Info
  String groupName = '';
  int memberCount = 0;

  /// Scroll Controller
  final ScrollController scrollController = ScrollController();

  static GroupMessageController get instance =>
      Get.put(GroupMessageController());

  /// Initialize with group data
  void initializeGroup(String id, String name, int members) {
    chatId = id;
    groupName = name;
    memberCount = members;
    loadMessages(showLoading: true);
  }

  @override
  void onInit() async{
    super.onInit();

    listenMessage();
     await fetchGroupDetails();

  }

  @override
  void onClose(){
    if (chatId.isNotEmpty) {
      SocketServices.leaveRoom(chatId);
    }
    messageController.dispose();
    scrollController.dispose();
    super.onClose();

  }


  Future<void> fetchGroupDetails() async {
    if (chatId.isEmpty) {
      appLog("⚠️ Cannot fetch group details: chatId is empty");
      return;
    }
    try {
      update();

      // Correct endpoint that works
      final url = "${ApiEndPoint.baseUrl}/chats/single/$chatId";
      appLog("📡 Fetching group details from: $url");

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = response.data['data'];

        // API uses 'avatarUrl' not 'image'
        if (data['avatarUrl'] != null && data['avatarUrl'].isNotEmpty) {
          avatarFilePath.value = data['avatarUrl'];
          appLog("✅ Avatar loaded: ${data['avatarUrl']}");
        }

      } else {
        appLog("❌ Failed to fetch group: ${response.statusCode}");
        Get.snackbar('Error', 'Failed to load group details');
      }
    } catch (e) {
      appLog("❌ Error fetching group details: $e");
      Get.snackbar('Error', 'Error loading group details');
    } finally {

      update();
    }
  }

  // ─── Socket ───────────────────────────────────────
  void listenMessage() {
    SocketServices.on("message:new", (data) {
      try {
        final String incomingChatId = data['chat'] is String
            ? data['chat']
            : data['chat']?['_id'] ?? '';
        if (chatId.isNotEmpty && incomingChatId == chatId) {
          final newMessage = ChatMessage.fromJson(data);
          if (!messages.any((m) => m.id == newMessage.id)) {
            messages.add(newMessage);
            update();
            _scrollToBottom();
          }
        }
      } catch (e) {
        appLog("❌ Error parsing group socket message: $e");
      }
    });

    SocketServices.on("chat:update", (data) {
      if (chatId.isNotEmpty) {
        loadMessages(showLoading: false);
      }
    });
  }

  // ─── Load Messages ────────────────────────────────
  Future<void> loadMessages({bool showLoading = false}) async {
    if (chatId.isEmpty) return;

    if (showLoading) {
      isLoading = true;
      update();
    }

    try {
      SocketServices.joinRoom(chatId);
      final String url = "${ApiEndPoint.messages}/$chatId";
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = response.data['data'] as List?;
        if (data != null) {
          messages.clear();
          for (var json in data) {
            messages.add(ChatMessage.fromJson(json));
          }
          messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        }
      }
    } catch (e) {
      appLog("❌ Load group messages error: $e");
    } finally {
      if (showLoading) isLoading = false;
      update();
      _scrollToBottom();
    }
  }

  // ─── Send All ─────────────────────────────────────
  Future<void> sendTextAndFile() async {
    if (isSendingText ||
        isUploadingImage ||
        isUploadingMedia ||
        isUploadingDocument)
      return;
    if (messageController.text.trim().isEmpty &&
        !hasPickedImage &&
        !hasPickedFile)
      return;

    if (messageController.text.trim().isNotEmpty) {
      await _sendTextMessage();
    }
    if (isImagePicked() || isFilePicked()) {
      await sendPickedFile();
    }
  }

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
        messageController.clear();
        await loadMessages(showLoading: false);
      } else {
        _showError('Failed to send message');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      isSendingText = false;
      update();
    }
  }

  Future<void> sendPickedFile() async {
    final filePath = getPickedFilePath();
    if (filePath == null || filePath.isEmpty) return;
    if (!File(filePath).existsSync()) {
      _showError('File not found');
      clearAllPicks();
      return;
    }
    try {
      switch (pickedFileType) {
        case 'image':
          await _sendImageMessage(filePath);
          break;
        case 'media':
          await _sendMediaMessage(filePath);
          break;
        default:
          await _sendDocumentMessage(filePath);
      }
    } catch (e) {
      _showError('Failed to send file: $e');
    } finally {
      clearAllPicks();
      update();
    }
  }

  Future<void> _sendImageMessage(String path) async {
    isUploadingImage = true;
    update();
    try {
      final response = await ApiService.multipart(
        ApiEndPoint.createMessage,
        imagePath: path,
        body: {"chat": chatId, "type": "image"},
      );
      if (response.statusCode == 200) {
        await loadMessages(showLoading: false);
      } else {
        _showError('Failed to send image');
      }
    } finally {
      isUploadingImage = false;
      update();
    }
  }

  Future<void> _sendMediaMessage(String path) async {
    isUploadingMedia = true;
    update();
    try {
      final response = await ApiService.multipart(
        ApiEndPoint.createMessage,
        imagePath: path,
        imageName: "media",
        body: {"chat": chatId, "type": "media"},
      );
      if (response.statusCode == 200) {
        await loadMessages(showLoading: false);
      } else {
        _showError('Failed to send media');
      }
    } finally {
      isUploadingMedia = false;
      update();
    }
  }

  Future<void> _sendDocumentMessage(String path) async {
    isUploadingDocument = true;
    update();
    try {
      final response = await ApiService.multipart(
        ApiEndPoint.createMessage,
        imagePath: path,
        imageName: "doc",
        body: {"chat": chatId, "type": "document"},
      );
      if (response.statusCode == 200) {
        await loadMessages(showLoading: false);
      } else {
        _showError('Failed to send document');
      }
    } finally {
      isUploadingDocument = false;
      update();
    }
  }

  // ─── Pickers ──────────────────────────────────────
  Future<void> pickImageFromGallery() async {
    try {
      isPickingImage = true;
      update();
      final XFile? image = await _picker.pickImage(
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
        update();
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    } finally {
      isPickingImage = false;
      update();
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      isPickingImage = true;
      update();
      final XFile? image = await _picker.pickImage(
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
        update();
      }
    } catch (e) {
      _showError('Failed to capture photo: $e');
    } finally {
      isPickingImage = false;
      update();
    }
  }

  Future<void> pickFile() async {
    try {
      isPickingFile = true;
      update();
      final result = await FilePicker.platform.pickFiles(
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
        update();
      }
    } catch (e) {
      _showError('Failed to pick file: $e');
    } finally {
      isPickingFile = false;
      update();
    }
  }

  void _detectFileType(String name) {
    final ext = name.toLowerCase().split('.').last;
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'].contains(ext)) {
      pickedFileType = 'image';
    } else if ([
      'mp3',
      'mp4',
      'avi',
      'mov',
      'mkv',
      'flv',
      'wav',
    ].contains(ext)) {
      pickedFileType = 'media';
    } else {
      pickedFileType = 'document';
    }
  }

  // ─── Clear ────────────────────────────────────────
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
    update();
  }

  // ─── Getters ──────────────────────────────────────
  bool isImagePicked() => hasPickedImage && pickedImage != null;
  bool isFilePicked() => hasPickedFile && pickedFile != null;

  String? getPickedFilePath() {
    if (isImagePicked()) return pickedImagePath;
    if (isFilePicked()) return pickedFilePath;
    return null;
  }

  String getPickedFileName() {
    if (isImagePicked() && pickedImage != null) return pickedImage!.name;
    if (isFilePicked() && pickedFile != null) return pickedFile!.name;
    return '';
  }

  String getPickedFileType() => pickedFileType ?? 'unknown';

  String getPickedFileSize() {
    if (isFilePicked() && pickedFile != null) {
      final sizeMB = (pickedFile!.size / (1024 * 1024)).toStringAsFixed(2);
      return '$sizeMB MB';
    }
    return '';
  }

  // ─── Helpers ──────────────────────────────────────
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

  void _showError(String msg) {
    Get.snackbar(
      'Error',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // Legacy method kept for any existing call sites
  Future<void> sendMessage() => sendTextAndFile();
  Future<void> pickAndSendImage() => pickImageFromGallery();
}
