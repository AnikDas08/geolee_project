import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/friend/presentation/controller/my_friend_controller.dart';
import 'package:giolee78/features/message/data/model/chat_message.dart';
import 'package:giolee78/features/message/presentation/controller/chat_controller.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/socket/socket_service.dart';
import 'package:giolee78/utils/log/app_log.dart';

import '../../../../services/storage/storage_services.dart';
import '../../../../utils/app_utils.dart';

enum FriendStatus { none, requested, friends }

class MessageController extends GetxController {
  RxBool isActive = false.obs;
  RxString distance = ''.obs;

  var error = ''.obs;
  var friendStatus = FriendStatus.none.obs;
  var pendingRequestId = ''.obs;

  // ================================================
  // FRIEND STATUS
  // ================================================
  RxBool isFriend = false.obs;
  RxBool hasPendingRequest = false.obs;
  RxString otherUserId = ''.obs;
  RxString friendStatusValue = ''.obs;
  RxBool friendStatusLoaded = false.obs;

  // ================================================
  // TEXT CONTROLLER
  // ================================================
  final messageController = TextEditingController();

  // ================================================
  // IMAGE & FILE PICKERS
  // ================================================
  final ImagePicker _imagePicker = ImagePicker();

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
  RxBool isInitialLoading = true.obs;

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
    listenOnlineStatus();
  }

  @override
  void onClose() {
    if (chatId.isNotEmpty) {
      SocketServices.leaveRoom(chatId);
    }
    // Remove individual listeners to prevent memory leaks and duplicate triggers
    SocketServices.off("message:new");
    SocketServices.off("chat:update");
    SocketServices.off("user:online");
    SocketServices.off("user:offline");

    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ================================================
  // 0. LISTEN FOR NEW MESSAGES VIA SOCKET
  // ================================================
  void listenMessage() {
    SocketServices.on("message:new", (data) {
      appLog("📩 New Message received via socket: $data");
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
            if (Get.isRegistered<ChatController>()) {
              Get.find<ChatController>().markChatAsSeen(chatId);
            }
          }
        }
      } catch (e) {
        appLog("❌ Error parsing incoming socket message: $e");
      }
    });

    SocketServices.on("chat:update", (data) {
      if (chatId.isNotEmpty) {
        loadMessages(showLoading: false);
      }
    });
  }

  // ================================================
  // ONLINE STATUS
  // ================================================
  void listenOnlineStatus() {
    SocketServices.on("user:online", (data) {
      final String onlineUserId =
          data['userId']?.toString() ?? data['_id']?.toString() ?? '';
      if (onlineUserId.isNotEmpty && onlineUserId == userId) {
        isActive.value = true;
      }
    });

    SocketServices.on("user:offline", (data) {
      final String offlineUserId =
          data['userId']?.toString() ?? data['_id']?.toString() ?? '';
      if (offlineUserId.isNotEmpty && offlineUserId == userId) {
        isActive.value = false;
      }
    });
  }

  // ================================================
  // PICKER METHODS
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
        update();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    } finally {
      isPickingImage = false;
      update();
    }
  }

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
        update();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture photo: $e');
    } finally {
      isPickingImage = false;
      update();
    }
  }

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
        update();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick file: $e');
    } finally {
      isPickingFile = false;
      update();
    }
  }

  void _detectFileType(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
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

  String getPickedFileSize() {
    if (hasPickedFile && pickedFile != null) {
      final sizeMB = (pickedFile!.size / (1024 * 1024)).toStringAsFixed(2);
      return '$sizeMB MB';
    }
    return '';
  }

  String? getPickedFilePath() {
    if (hasPickedImage && pickedImagePath != null) return pickedImagePath;
    if (hasPickedFile && pickedFilePath != null) return pickedFilePath;
    return null;
  }

  // ================================================
  // INITIALIZATION
  // ================================================
  Future<void> initializeChat(String targetUserId) async {
    isInitialLoading.value = true;
    update();

    try {
      if (targetUserId.isNotEmpty) {
        await checkFriendshipStatus(targetUserId);
      } else {
        isFriend.value = true;
        friendStatus.value = FriendStatus.friends;
        friendStatusLoaded.value = true;
      }
      await loadMessages(showLoading: false);
    } catch (e) {
      appLog("❌ Initialization error: $e");
    } finally {
      isInitialLoading.value = false;
      update();
    }
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
        if (Get.isRegistered<ChatController>()) {
          Get.find<ChatController>().markChatAsSeen(chatId);
        }
      }

      final response = await ApiService.get("${ApiEndPoint.messages}/$chatId");

      if (response.statusCode == 200) {
        final data = response.data['data'] as List?;
        if (data != null) {
          messages =
              data
                  .map((json) {
                    try {
                      return ChatMessage.fromJson(json);
                    } catch (_) {
                      return null;
                    }
                  })
                  .whereType<ChatMessage>()
                  .toList()
                ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        }

        // ✅ Panel Visibility Logic: If not friends, check who sent the last interaction
        if (friendStatus.value != FriendStatus.friends) {
          if (friendStatusValue.value == 'pending') {
            // I sent the request — I am the sender, show input
            isFriend.value = true;
          } else if (friendStatusValue.value == 'received') {
            // They sent the request — I am the receiver, show panel
            if (friendStatusValue.value != 'none_continued') {
              isFriend.value = false;
            }
          } else if (messages.isEmpty) {
            // No messages yet — I am starting the chat, show input
            isFriend.value = true;
          } else {
            // No request — check who sent the last message
            final lastMsg = messages.last;
            if (lastMsg.isCurrentUser) {
              // I sent the last message — I am the sender, show input
              isFriend.value = true;
            } else {
              // They sent the last message — I am the receiver, show panel
              if (friendStatusValue.value != 'none_continued') {
                isFriend.value = false;
              }
            }
          }
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
  Future<void> sendMessage() async => await sendTextAndFile();

  Future<void> sendTextAndFile() async {
    if (messageController.text.trim().isEmpty &&
        !hasPickedImage &&
        !hasPickedFile) {
      return;
    }
    if (messageController.text.trim().isNotEmpty) await _sendTextMessage();
    if (hasPickedImage || hasPickedFile) await _sendPickedFile();
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
        _showErrorSnackBar('Failed to send message');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      isSendingText = false;
      update();
    }
  }

  Future<void> _sendPickedFile() async {
    final filePath = getPickedFilePath();
    if (filePath == null || !File(filePath).existsSync()) return;

    try {
      if (pickedFileType == 'image') {
        isUploadingImage = true;
      } else {
        isUploadingMedia = true;
      }
      update();

      // ✅ type অনুযায়ী আলাদা imageName পাঠাচ্ছি
      String imageName;
      String messageType;

      switch (pickedFileType) {
        case 'image':
          imageName = "image";
          messageType = "image";
          break;
        case 'media':
          imageName = "media";
          messageType = "media";
          break;
        case 'document':
        default:
          imageName = "doc"; // ✅ server এ "doc" field expect করে
          messageType = "document";
          break;
      }

      final response = await ApiService.multipart(
        ApiEndPoint.createMessage,
        imagePath: filePath,
        imageName: imageName,
        body: {"chat": chatId, "type": messageType},
      );

      if (response.statusCode == 200) {
        clearAllPicks();
        await loadMessages();
      } else {
        _showErrorSnackBar('Failed to send file');
      }
    } catch (e) {
      appLog("❌ Send file error: $e");
      _showErrorSnackBar('Failed to send file');
    } finally {
      isUploadingImage = false;
      isUploadingMedia = false;
      update();
    }
  }

  // ================================================
  // 9. FRIENDSHIP METHODS
  // ================================================
  Future<void> checkFriendshipStatus(String targetUserId) async {
    if (targetUserId.isEmpty) {
      isFriend.value = true;
      friendStatus.value = FriendStatus.friends;
      friendStatusLoaded.value = true;
      return;
    }

    friendStatusLoaded.value = false;
    otherUserId.value = targetUserId;

    try {
      final response = await ApiService.get(
        "${ApiEndPoint.checkFriendStatus}$targetUserId",
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (data['isAlreadyFriend'] == true) {
          // ✅ বন্ধু — normal input দেখাবে
          isFriend.value = true;
          hasPendingRequest.value = false;
          friendStatusValue.value = 'friends';
          friendStatus.value = FriendStatus.friends;
          pendingRequestId.value = '';
        } else if (data['pendingFriendRequest'] != null) {
          final pendingRequest = data['pendingFriendRequest'];
          final String requestSenderId =
              pendingRequest['sender']?['_id']?.toString() ??
              pendingRequest['sender']?.toString() ??
              '';

          // ✅ AppBar এর জন্য
          friendStatus.value = FriendStatus.requested;
          pendingRequestId.value = pendingRequest['_id']?.toString() ?? '';

          if (requestSenderId == LocalStorage.userId) {
            // আমি পাঠিয়েছি — normal input দেখাবে
            isFriend.value = true;
            hasPendingRequest.value = true;
            friendStatusValue.value = 'pending';
          } else {
            // অন্যজন পাঠিয়েছে — non-friend panel দেখাবে
            isFriend.value = false;
            hasPendingRequest.value = false;
            friendStatusValue.value = 'received';
          }
        } else {
          // ✅ কোনো relation নেই
          // Default এ isFriend = true থাকবে কারণ আমি message পাঠাতে এসেছি
          // loadMessages এ চেক হবে যদি অন্যজন লাস্ট মেসেজ দেয় তবে প্যানেল আসবে
          isFriend.value = true;
          hasPendingRequest.value = false;
          friendStatusValue.value = 'none';
          friendStatus.value = FriendStatus.none;
          pendingRequestId.value = '';
        }
      } else {
        isFriend.value = false;
        friendStatus.value = FriendStatus.none;
        friendStatusValue.value = 'none';
      }
    } catch (e) {
      debugPrint("❌ Friendship check error: $e");
      isFriend.value = false;
      friendStatus.value = FriendStatus.none;
      friendStatusValue.value = 'none';
    } finally {
      friendStatusLoaded.value = true;
    }
  }

  Future<void> sendFriendRequest(String targetUserId) async {
    try {
      final response = await ApiService.post(
        ApiEndPoint.createFriendRequest,
        body: {"receiver": targetUserId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final reqData = response.data['data'];
        pendingRequestId.value = (reqData?['_id'] ?? '').toString();
        friendStatusValue.value = 'pending';
        friendStatus.value = FriendStatus.requested;
        isFriend.value = true;
        hasPendingRequest.value = true;
        Utils.successSnackBar("Sent", "Friend request sent successfully");
        if (Get.isRegistered<MyFriendController>()) {
          Get.find<MyFriendController>().fetchFriendRequests();
        }
        update();
      } else {
        Utils.errorSnackBar("Error", response.message);
      }
    } catch (e) {
      debugPrint("❌ Friend request error: $e");
      Utils.errorSnackBar("Error", "Something went wrong");
    }
  }

  Future<void> cancelFriendRequest(String targetUserId) async {
    try {
      final idToUse = pendingRequestId.value.isNotEmpty
          ? pendingRequestId.value
          : targetUserId;

      final response = await ApiService.patch(
        "${ApiEndPoint.cancelFriendRequest}$idToUse",
        body: {"status": "cancelled"},
      );

      if (response.statusCode == 200) {
        // ✅ Cancel হলে non-friend panel দেখাবে
        isFriend.value = false;
        hasPendingRequest.value = false;
        friendStatusValue.value = 'none';
        friendStatus.value = FriendStatus.none;
        pendingRequestId.value = '';
        Utils.successSnackBar("Cancelled", "Friend request cancelled");
        update();
      } else {
        Utils.errorSnackBar("Error", response.message);
      }
    } catch (e) {
      debugPrint("❌ Cancel error: $e");
    }
  }

  Future<void> acceptFriendRequest(String userId) async {
    try {
      final url = ApiEndPoint.friendStatusUpdate + userId;
      final response = await ApiService.patch(
        url,
        body: {"status": 'accepted'},
      );

      if (response.statusCode == 200) {
        isFriend.value = true;
        friendStatusValue.value = 'friends';
        friendStatus.value = FriendStatus.friends;
        Utils.successSnackBar("Accepted", "Friend request accepted");
        if (Get.isRegistered<MyFriendController>()) {
          Get.find<MyFriendController>().fetchFriendRequests();
        }
        update();
      } else {
        Utils.errorSnackBar("Info", response.message);
      }
    } catch (e) {
      debugPrint("acceptFriendRequest error => ${e.toString()}");
      Utils.errorSnackBar("Error", "Something went wrong");
    }
  }

  Future<void> rejectFriendRequest(String userId) async {
    try {
      final url = ApiEndPoint.friendStatusUpdate + userId;
      final response = await ApiService.patch(
        url,
        body: {"status": 'rejected'},
      );

      if (response.statusCode == 200) {
        isFriend.value = false;
        friendStatusValue.value = 'none';
        friendStatus.value = FriendStatus.none;
        Utils.successSnackBar("Rejected", "Friend request rejected");
        update();
      } else {
        Utils.errorSnackBar("Error", response.message);
      }
    } catch (e) {
      debugPrint("rejectFriendRequest error => ${e.toString()}");
      Utils.errorSnackBar("Error", "Something went wrong");
    }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }
}
