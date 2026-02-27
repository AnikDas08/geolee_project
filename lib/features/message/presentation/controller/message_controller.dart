import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/friend/presentation/controller/my_friend_controller.dart';
import 'package:giolee78/features/message/data/model/chat_message.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/socket/socket_service.dart';
import 'package:giolee78/utils/log/app_log.dart';

import '../../../../utils/app_utils.dart';

class MessageController extends GetxController {
  // ================================================
  // FRIEND STATUS
  // ================================================
  RxBool isFriend = false.obs;
  RxBool hasPendingRequest = false.obs;
  RxString otherUserId = ''.obs;
  RxString friendStatusValue = ''.obs;

  /// Whether friendship status has been loaded (to avoid showing sheet before we know)
  RxBool friendStatusLoaded = false.obs;

  // ================================================
  // TEXT CONTROLLER
  // ================================================
  final messageController = TextEditingController();

  // ================================================
  // IMAGE & FILE PICKERS
  // ================================================
  final ImagePicker _imagePicker = ImagePicker();

  // ------------------------------------------------
  // PICKED FILES VARIABLES
  // ------------------------------------------------
  XFile? pickedImage;
  PlatformFile? pickedFile;
  String? pickedImagePath;
  String? pickedFilePath;
  String? pickedFileName;
  String? pickedFileType;

  // ------------------------------------------------
  // UI STATE VARIABLES
  // ------------------------------------------------
  bool isPickingImage = false;
  bool isPickingFile = false;
  bool hasPickedImage = false;
  bool hasPickedFile = false;

  // ------------------------------------------------
  // LOADING STATES
  // ------------------------------------------------
  bool isUploadingImage = false;
  bool isUploadingMedia = false;
  bool isUploadingDocument = false;
  bool isSendingText = false;

  // ------------------------------------------------
  // MESSAGES
  // ------------------------------------------------
  List<ChatMessage> messages = [];

  // ------------------------------------------------
  // CHAT VARIABLES
  // ------------------------------------------------
  String chatId = '';
  String chatRoomId = '';
  String name = '';
  String image = '';
  bool isActive = true;
  String userId = '';

  // ------------------------------------------------
  // SERVICE INFO
  // ------------------------------------------------
  String serviceTitle = '';
  String serviceImage = '';
  num price = 0;
  String postId = '';
  String clientStatus = '';

  // ------------------------------------------------
  // GENERAL LOADING STATE
  // ------------------------------------------------
  bool isLoading = false;

  // ------------------------------------------------
  // SCROLL CONTROLLER
  // ------------------------------------------------
  final ScrollController scrollController = ScrollController();

  static MessageController get instance => Get.put(MessageController());

  // ================================================
  // LIFECYCLE
  // ================================================
  @override
  void onInit() {
    super.onInit();
    listenMessage();
    // NOTE: checkFriendshipStatus is called from MessageScreen.initState()
    // after chatId and userId have been set from route parameters.
  }

  @override
  void onClose() {
    if (chatId.isNotEmpty) {
      SocketServices.leaveRoom(chatId);
    }
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ================================================
  // 0. LISTEN FOR NEW MESSAGES VIA SOCKET
  // ================================================
  void listenMessage() {
    SocketServices.on("message:new", (data) {
      appLog(">>>>>>>>>>>> 📩 New Message received via socket: $data <<<<<<<<<<<<");

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
        appLog("❌ Error parsing incoming socket message: $e");
      }
    });

    SocketServices.on("chat:update", (data) {
      if (chatId.isNotEmpty) {
        appLog(">>>>>>>>>>>> 🔄 chat:update received — reloading messages <<<<<<<<<<<<");
        loadMessages(showLoading: false);
      }
    });
  }

  // ================================================
  // 1. PICK IMAGE FROM GALLERY
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
  // 2. PICK IMAGE FROM CAMERA
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
  // 3. PICK FILE
  // ================================================
  Future<void> pickFile() async {
    try {
      isPickingFile = true;
      update();

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
          'txt', 'csv', 'jpg', 'jpeg', 'png', 'gif', 'webp',
          'bmp', 'heic', 'mp3', 'mp4', 'avi', 'mov', 'mkv', 'flv', 'wav',
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
  // 4. DETECT FILE TYPE
  // ================================================
  void _detectFileType(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;

    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'].contains(ext)) {
      pickedFileType = 'image';
    } else if (['mp3', 'mp4', 'avi', 'mov', 'mkv', 'flv', 'wav'].contains(ext)) {
      pickedFileType = 'media';
    } else {
      pickedFileType = 'document';
    }
  }

  // ================================================
  // 5. CLEAR PICKED FILES
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
  // 6. GETTER METHODS
  // ================================================
  String getPickedFileName() {
    if (hasPickedImage && pickedImage != null) return pickedImage!.name;
    if (hasPickedFile && pickedFile != null) return pickedFile!.name;
    return '';
  }

  String getPickedFileType() => pickedFileType ?? 'unknown';

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
    if (hasPickedImage && pickedImagePath != null) return pickedImagePath;
    if (hasPickedFile && pickedFilePath != null) return pickedFilePath;
    return null;
  }

  // ================================================
  // 7. LOAD MESSAGES
  // ================================================
  Future<void> loadMessages({bool showLoading = true}) async {
    if (showLoading) {
      isLoading = true;
      update();
    }

    try {
      if (chatId.isNotEmpty) {
        SocketServices.joinRoom(chatId);
      }

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
          messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        }
      }
    } catch (e) {
      appLog("❌ Load messages error: $e");
    } finally {
      if (showLoading) isLoading = false;
      update();
      _scrollToBottom();
    }
  }

  // ================================================
  // 8. SEND METHODS
  // ================================================
  Future<void> sendMessage() async {
    await sendTextAndFile();
  }

  Future<void> sendTextAndFile() async {
    if (messageController.text.trim().isEmpty &&
        !isImagePicked() &&
        !isFilePicked()) {
      _showErrorSnackBar('Nothing to send');
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
        appLog("✅ Text sent successfully");
        messageController.clear();
        await loadMessages(showLoading: false);
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

  Future<void> sendPickedFile() async {
    final filePath = getPickedFilePath();
    final fileType = pickedFileType;

    if (filePath == null || filePath.isEmpty) {
      _showErrorSnackBar('No file picked');
      return;
    }

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

  Future<void> _sendImageMessage(String imagePath) async {
    isUploadingImage = true;
    update();

    try {
      final response = await ApiService.multipart(
        ApiEndPoint.createMessage,
        imagePath: imagePath,
        body: {"chat": chatId, "type": "image"},
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

  Future<void> _sendMediaMessage(String mediaPath) async {
    isUploadingMedia = true;
    update();

    try {
      final response = await ApiService.multipart(
        ApiEndPoint.createMessage,
        imagePath: mediaPath,
        imageName: "media",
        body: {"chat": chatId, "type": "media"},
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

  Future<void> _sendDocumentMessage(String docPath) async {
    isUploadingDocument = true;
    update();

    try {
      final response = await ApiService.multipart(
        ApiEndPoint.createMessage,
        imagePath: docPath,
        imageName: "doc",
        body: {"chat": chatId, "type": "document"},
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

  // ================================================
  // 9. FRIENDSHIP METHODS
  // ================================================

  /// Call this after setting userId from route params
  Future<void> checkFriendshipStatus(String targetUserId) async {
    if (targetUserId.isEmpty) {
      friendStatusLoaded.value = true;
      return;
    }

    try {
      debugPrint("🔍 Checking friendship with: $targetUserId");
      otherUserId.value = targetUserId;

      final response = await ApiService.get(
        "${ApiEndPoint.checkFriendStatus}$targetUserId",
      );

      debugPrint("📦 Friendship check response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (data['isAlreadyFriend'] == true) {
          debugPrint("✅ Already Friends");
          isFriend.value = true;
          hasPendingRequest.value = false;
          friendStatusValue.value = 'friends';
        } else if (data['pendingFriendRequest'] != null) {
          debugPrint("⏳ Pending Friend Request");
          isFriend.value = false;
          hasPendingRequest.value = true;
          friendStatusValue.value = 'pending';
        } else {
          debugPrint("❌ Not Friends");
          isFriend.value = false;
          hasPendingRequest.value = false;
          friendStatusValue.value = 'none';
        }
      } else {
        debugPrint("❌ Error checking friendship: ${response.message}");
        // Default to not friends on error so sheet shows
        isFriend.value = false;
        friendStatusValue.value = 'none';
      }
    } catch (e) {
      debugPrint("❌ Friendship check error: $e");
      isFriend.value = false;
      friendStatusValue.value = 'none';
    } finally {
      friendStatusLoaded.value = true;
    }
  }

  Future<void> sendFriendRequest(String targetUserId) async {
    try {
      debugPrint("📤 Sending friend request to: $targetUserId");

      final response = await ApiService.post(
        ApiEndPoint.createFriendRequest,
        body: {"receiver": targetUserId},
      );

      debugPrint("📦 Friend request response: ${response.statusCode}");

      if (response.statusCode == 200) {
        debugPrint("✅ Friend request sent");
        hasPendingRequest.value = true;
        friendStatusValue.value = 'pending';
        Utils.successSnackBar("Sent", "Friend request sent successfully");

        // 🔄 Refresh friend requests in MyFriendController so badge updates on home screen
        if (Get.isRegistered<MyFriendController>()) {
          Get.find<MyFriendController>().fetchFriendRequests();
        }
      } else {
        debugPrint("❌ Error sending friend request: ${response.message}");
        Utils.errorSnackBar(
          "Error",
          response.message ?? "Failed to send friend request",
        );
      }
    } catch (e) {
      debugPrint("❌ Friend request error: $e");
      Utils.errorSnackBar("Error", "Something went wrong");
    }
  }

  Future<void> cancelFriendRequest(String targetUserId) async {
    try {
      debugPrint("❌ Canceling friend request for: $targetUserId");

      final response = await ApiService.patch(
        "${ApiEndPoint.cancelFriendRequest}$targetUserId",
        body: {"status": "cancelled"},
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Friend request cancelled");
        hasPendingRequest.value = false;
        friendStatusValue.value = 'none';
        Utils.successSnackBar("Cancelled", "Friend request cancelled");
      }
    } catch (e) {
      debugPrint("❌ Cancel error: $e");
    }
  }
}