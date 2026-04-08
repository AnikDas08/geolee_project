import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/message/data/model/chat_message.dart';
import 'package:giolee78/features/message/presentation/controller/chat_controller.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/socket/socket_service.dart';
import 'package:giolee78/utils/log/app_log.dart';
import 'package:image_picker/image_picker.dart';

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

  var isLoadingMore = false.obs;
  var hasMoreMessages = true.obs;

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
  RxString groupName = ''.obs;
  RxInt memberCount = 0.obs;

  /// Scroll Controller
  final ScrollController scrollController = ScrollController();

  int _currentPage = 1;
  final int _pageLimit = 20;

  static GroupMessageController get instance =>
      Get.put(GroupMessageController());

  /// Initialize with group data
  void initializeGroup(String id, String name, int members) {
    chatId = id;
    groupName.value = name;
    memberCount.value = members;
    if (Get.isRegistered<ChatController>()) {
      ChatController.instance.setOpenChat(chatId);
    }
    loadMessages(showLoading: true);
  }

  @override
  Future<void> onInit() async {
    super.onInit();

    scrollController.addListener(_onScroll);
    listenMessage();
    await fetchGroupDetails();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    // Since reverse: true, older messages are at maxScrollExtent
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 300) {
      loadMoreMessages();
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    if (chatId.isNotEmpty) {
      SocketServices.leaveRoom(chatId);
      if (Get.isRegistered<ChatController>()) {
        ChatController.instance.clearOpenChat();
      }
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
            // ✅ Handle encrypted messages (U2FsdGVk or hex-colon format)
            if (newMessage.isEncrypted) {
              loadMessages();
              return;
            }

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
        loadMessages();
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

    _currentPage = 1;
    hasMoreMessages.value = true;

    try {
      SocketServices.joinRoom(chatId);
      if (Get.isRegistered<ChatController>()) {
        ChatController.instance.markChatAsSeen(chatId);
      }

      final String url =
          "${ApiEndPoint.messages}/$chatId?page=1&limit=$_pageLimit";
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = response.data['data'] as List?;
        if (data != null) {
          final List<ChatMessage> newMessages = [];
          for (var json in data) {
            try {
              final msg = ChatMessage.fromJson(json);
              if (msg.isEncrypted) continue;
              newMessages.add(msg);
            } catch (_) {}
          }
          messages = newMessages
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

          if (data.length < _pageLimit) {
            hasMoreMessages.value = false;
          }
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

  // ─── Load More Messages (Pagination) ───────────────
  Future<void> loadMoreMessages() async {
    if (isLoadingMore.value || !hasMoreMessages.value || chatId.isEmpty) return;

    isLoadingMore.value = true;
    // update(); // Obx handles this usually, but update() helps if we use GetBuilder

    try {
      final int nextPage = _currentPage + 1;
      final String url =
          "${ApiEndPoint.messages}/$chatId?page=$nextPage&limit=$_pageLimit";

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = response.data['data'] as List?;
        if (data == null || data.isEmpty) {
          hasMoreMessages.value = false;
          return;
        }

        final List<ChatMessage> fetchedMessages = [];
        for (var json in data) {
          try {
            final msg = ChatMessage.fromJson(json);
            if (msg.isEncrypted) continue;
            fetchedMessages.add(msg);
          } catch (_) {}
        }

        if (fetchedMessages.isEmpty) {
          hasMoreMessages.value = false;
          return;
        }

        // Avoid duplicates
        final existingIds = messages.map((m) => m.id).toSet();
        final uniqueNew = fetchedMessages
            .where((m) => !existingIds.contains(m.id))
            .toList();

        if (uniqueNew.isEmpty) {
          hasMoreMessages.value = false;
          return;
        }

        messages = [...uniqueNew, ...messages]
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        _currentPage = nextPage;

        if (data.length < _pageLimit) {
          hasMoreMessages.value = false;
        }

        update();
      }
    } catch (e) {
      appLog("❌ Load more group messages error: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ─── Send All ─────────────────────────────────────
  Future<void> sendTextAndFile() async {
    if (isSendingText ||
        isUploadingImage ||
        isUploadingMedia ||
        isUploadingDocument) {
      return;
    }
    if (messageController.text.trim().isEmpty &&
        !hasPickedImage &&
        !hasPickedFile) {
      return;
    }

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
        // Wait a bit to ensure decryption is complete on server before GET
        await Future.delayed(const Duration(milliseconds: 500));
        await loadMessages();

        if (Get.isRegistered<ChatController>()) {
          ChatController.instance.getChatRepos(
            showLoading: false,
            isGroup: true,
          );
        }
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
      print("pickedFileType : $pickedFileType");
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
        await loadMessages();
        if (Get.isRegistered<ChatController>()) {
          ChatController.instance.getChatRepos(
            showLoading: false,
            isGroup: true,
          );
        }
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
        await loadMessages();
        if (Get.isRegistered<ChatController>()) {
          ChatController.instance.getChatRepos(
            showLoading: false,
            isGroup: true,
          );
        }
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
        await loadMessages();
        if (Get.isRegistered<ChatController>()) {
          ChatController.instance.getChatRepos(
            showLoading: false,
            isGroup: true,
          );
        }
      } else {
        _showError('Failed to send document');
      }
    } finally {
      isUploadingDocument = false;
      update();
    }
  }

  bool get isVideo =>
      ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv', '3gp'].contains(
        pickedImagePath?.toLowerCase().split('.').last.toLowerCase().trim(),
      );

  // ─── Pickers ──────────────────────────────────────
  Future<void> pickImageFromGallery() async {
    try {
      isPickingImage = true;
      update();
      final XFile? picked = await _picker.pickMedia();
      if (picked != null) {
        pickedImage = picked;
        pickedImagePath = picked.path;
        pickedFile = null;
        pickedFilePath = null;
        hasPickedImage = true;
        hasPickedFile = false;
        pickedFileType = isVideo ? 'media' : 'image';
        update();
      }
    } catch (e) {
      _showError('Failed to pick media: $e');
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
        pickedFileType = 'media';
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
          0.0,
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
