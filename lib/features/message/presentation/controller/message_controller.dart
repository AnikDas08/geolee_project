import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
import '../../../../utils/enum/enum.dart';

class MessageController extends GetxController {
  RxBool isActive = false.obs;
  RxString distance = ''.obs;

  // -1  → distance unknown (API তে আসেনি)
  //  0  → same location
  // >0  → actual distance in km
  RxDouble rawDistanceKm = (-1.0).obs;
  RxBool isLocationVisible = true.obs;

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
  RxString initialRequestStatus = ''.obs;
  RxBool friendStatusLoaded = false.obs;
  RxBool isProfileLoaded = false.obs;

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
  // PAGINATION
  // ------------------------------------------------
  var isLoadingMore = false.obs;
  var hasMoreMessages = true.obs;
  int _currentPage = 1;
  final int _pageLimit = 20;

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

  /*
  ================================================
  MESSAGING PERMISSION LOGIC
  ================================================

  ✅ Actual friend (friendStatus==friends && friendStatusValue=='friends')
     → সবসময় allow

  ❌ বাকি সব (none, pending, received, none_continued):

   rawDistanceKm values:
    -1.0 → unknown (API তে distance আসেনি)  → BLOCK
     0.0 → same location                    → ALLOW
    >0.0 → actual distance                  → range check

   Check order (important!):
    1. isProfileLoaded false      → block
    2. isLocationVisible false    → block
    3. distance.value empty       → block  ← must be before rawDistanceKm check
    4. rawDistanceKm == 0.0       → allow  ← same location
    5. rawDistanceKm > radiusKm   → block
    6. otherwise                  → allow
*/

  bool get isMessagingBlocked {
    // ── Actual friend → no restriction
    if (friendStatus.value == FriendStatus.friends &&
        friendStatusValue.value == 'friends') {
      return false;
    }

    // ── Profile load না হলে block
    if (!isProfileLoaded.value) return true;

    // ── Location visible না হলে block
    if (!isLocationVisible.value) return true;

    // ── Distance empty → block
    // ── এই check টা rawDistanceKm == 0.0 এর আগে থাকা MUST
    //    কারণ distance empty হলে rawDistanceKm = -1.0 set হয়
    //    এবং -1.0 != 0.0 তাই range check এ যাবে, কিন্তু
    //    distance string empty থাকলে আমরা সবার আগে block করব
    if (distance.value.isEmpty) return true;

    // ── Distance == 0.0 → same location → allow
    if (rawDistanceKm.value == 0.0) return false;

    // ── rawDistanceKm == -1.0 → unknown distance → block
    //    (distance.value.isEmpty check এ আগেই ধরা পড়ার কথা,
    //     কিন্তু extra safety এর জন্য রাখা হলো)
    if (rawDistanceKm.value < 0) return true;

    // ── Range check
    final double radiusKm = double.tryParse(
      Get.isRegistered<ChatController>()
          ? Get.find<ChatController>().currentRadius.value
          : LocalStorage.radius,
    ) ??
        0.0;

    if (rawDistanceKm.value > radiusKm) return true;

    return false;
  }

  // ================================================
  // STATE RESET
  // ================================================
  void _resetState() {
    isProfileLoaded.value = false;
    distance.value = '';
    rawDistanceKm.value = -1.0; // unknown
    isLocationVisible.value = true;
    friendStatus.value = FriendStatus.none;
    friendStatusValue.value = '';
    isFriend.value = false;
    friendStatusLoaded.value = false;
    hasPendingRequest.value = false;
    pendingRequestId.value = '';
    otherUserId.value = '';
    isActive.value = false;
    messages = [];
    isLoading = false;
    isInitialLoading.value = true;
    _currentPage = 1;
    hasMoreMessages.value = true;
    isLoadingMore.value = false;
    clearAllPicks();
  }

  // ================================================
  // LIFECYCLE
  // ================================================
  @override
  void onInit() {
    super.onInit();

    // ✅ শুধু params read করো, API call করো না
    // duplicate call ঠেকাতে onInit এ শুধু params + listeners
    final params = Get.parameters;
    chatId = params['chatId'] ?? '';
    name = params['name'] ?? '';
    image = params['image'] ?? '';
    userId = params['userId'] ?? '';

    listenMessage();
    listenOnlineStatus();
  }

  @override
  void onReady() {
    super.onReady();
    final params = Get.parameters;
    if (params['chatId'] != null) {
      _resetState();

      chatId = params['chatId'] ?? '';
      name = params['name'] ?? '';
      image = params['image'] ?? '';
      userId = params['userId'] ?? '';
      initialRequestStatus.value = params['requestStatus'] ?? '';

      // ✅ এখানেই API call শুরু হয়
      _initializeChatData();
      ChatController.instance.setOpenChat(chatId);
    }
  }

  @override
  void onClose() {
    if (chatId.isNotEmpty) {
      SocketServices.leaveRoom(chatId);
    }
    SocketServices.off("message:new");
    SocketServices.off("chat:update");
    SocketServices.off("user:online");
    SocketServices.off("user:offline");

    messageController.dispose();
    scrollController.dispose();
    ChatController.instance.clearOpenChat();

    Future.microtask(() {
      if (Get.isRegistered<MessageController>()) {
        Get.delete<MessageController>(force: true);
      }
    });

    super.onClose();
  }

  // ================================================
  // INITIALIZATION
  // ================================================

  // ✅ আগে দুটো আলাদা call হতো:
  //    fetchUserProfile(userId) + checkFriendshipStatus(userId)
  //    এখন শুধু fetchUserProfile — কারণ profile response এ
  //    isAlreadyFriend ও pendingFriendRequest already আসে।
  //    এতে message screen এ API call কমে ৬টা → ২টা।
  Future<void> _initializeChatData() async {
    isInitialLoading.value = true;
    update();

    try {
      if (userId.isNotEmpty) {
        // ✅ একটাই call — profile + friendship দুটোই handle হবে
        await fetchUserProfile(userId);
      } else {
        // userId না থাকলে directly friend ধরে নাও
        isFriend.value = true;
        friendStatus.value = FriendStatus.friends;
        friendStatusValue.value = 'friends';
        friendStatusLoaded.value = true;
        isProfileLoaded.value = true;
      }

      await loadMessages(showLoading: false);
    } catch (e) {
      appLog("❌ _initializeChatData error: $e");
    } finally {
      isInitialLoading.value = false;
      update();
    }
  }

  // ================================================
  // SOCKET LISTENERS
  // ================================================
  void listenMessage() {
    SocketServices.on("message:new", (data) {
      final String incomingChatId = data['chat'] is String
          ? data['chat']
          : data['chat']?['_id'] ?? '';

      if (chatId.isNotEmpty && incomingChatId == chatId) {
        final newMessage = ChatMessage.fromJson(data);

        // 👉 duplicate prevent
        if (!messages.any((m) => m.id == newMessage.id)) {
          // ✅ Handle encrypted messages (U2FsdGVk or hex-colon format)
          if (newMessage.isEncrypted) {
            loadMessages(showLoading: false);
            return;
          }

          messages.add(newMessage);
          update();
          _scrollToBottom();
        }
      }
    });

    // 🔄 chat update listener
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
      final XFile? picked = await _imagePicker.pickMedia();
      if (picked != null) {
        final ext = picked.path.toLowerCase().split('.').last;
        final isVideo =
        ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv', '3gp'].contains(ext);
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
      _showErrorSnackBar('Failed to pick media: $e');
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
          'txt',
          'jpg',
          'jpeg',
          'png',
          'mp3',
          'mp4',
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
    } else if (['mp3', 'mp4', 'avi', 'mov', 'mkv', 'flv', 'wav']
        .contains(ext)) {
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
  // LOAD MESSAGES
  // ================================================
  Future<void> loadMessages({bool showLoading = true}) async {
    if (showLoading) {
      isLoading = true;
      update();
    }

    _currentPage = 1;
    hasMoreMessages.value = true;

    try {
      if (chatId.isNotEmpty) {
        SocketServices.joinRoom(chatId);
        if (Get.isRegistered<ChatController>()) {
          Get.find<ChatController>().markChatAsSeen(chatId);
        }
      }

      final response = await ApiService.get(
        "${ApiEndPoint.messages}/$chatId?page=1&limit=$_pageLimit",
      );

      if (response.statusCode == 200) {
        appLog("Message Loading by chat id${response.message}");
        final data = response.data['data'] as List?;
        if (data != null) {
          final List<ChatMessage> newMessages = [];

          for (var json in data) {
            try {
              final msg = ChatMessage.fromJson(json);

              // Skip encrypted messages to avoid showing gibberish
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
        _applyFriendPanelLogic();
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
  // LOAD MORE MESSAGES (pagination)
  // ================================================
  Future<void> loadMoreMessages() async {
    if (isLoadingMore.value || !hasMoreMessages.value) return;
    isLoadingMore.value = true;

    try {
      final nextPage = _currentPage + 1;
      final response = await ApiService.get(
        "${ApiEndPoint.messages}/$chatId?page=$nextPage&limit=$_pageLimit",
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List?;
        if (data == null || data.isEmpty) {
          hasMoreMessages.value = false;
          return;
        }

        final newMessages = data
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

        if (newMessages.isEmpty) {
          hasMoreMessages.value = false;
          return;
        }

        final existingIds = messages.map((m) => m.id).toSet();
        final uniqueNew =
        newMessages.where((m) => !existingIds.contains(m.id)).toList();

        if (uniqueNew.isEmpty) {
          hasMoreMessages.value = false;
          return;
        }

        messages = [...uniqueNew, ...messages];
        _currentPage = nextPage;
        if (data.length < _pageLimit) hasMoreMessages.value = false;
        update();
      }
    } catch (e) {
      appLog("❌ Load more messages error: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ================================================
  // FRIEND PANEL VISIBILITY LOGIC
  // ================================================
  void _applyFriendPanelLogic() {
    // Actual friend → FriendInputArea
    if (friendStatus.value == FriendStatus.friends &&
        friendStatusValue.value == 'friends') {
      isFriend.value = true;
      return;
    }

    // none_continued → FriendInputArea (isMessagingBlocked চেক হবে)
    if (friendStatusValue.value == 'none_continued') {
      isFriend.value = true;
      return;
    }

    // pending → FriendInputArea
    if (friendStatusValue.value == 'pending') {
      isFriend.value = true;
      return;
    }

    // received → NonFriendPanel
    if (friendStatusValue.value == 'received') {
      isFriend.value = false;
      return;
    }

    // none → last message check
    if (messages.isEmpty) {
      isFriend.value = true;
    } else {
      isFriend.value = messages.last.isCurrentUser;
    }
  }

  // ================================================
  // SEND METHODS
  // ================================================
  Future<void> sendMessage() async => await sendTextAndFile();

  Future<void> sendTextAndFile() async {
    final text = messageController.text.trim();
    if (text.isEmpty && !hasPickedImage && !hasPickedFile) {
      return;
    }

    if (text.isNotEmpty) {
      await _sendTextMessage(text);
    }
    if (hasPickedImage || hasPickedFile) await _sendPickedFile();
  }

  Future<void> _sendTextMessage(String text) async {
    isSendingText = true;
    update();

    try {
      final response = await ApiService.post(
        ApiEndPoint.createMessage,
        body: {
          "chat": chatId,
          "type": "text",
          "text": text,
        },
      );

      if (response.statusCode == 200) {
        messageController.clear();
        // Wait a bit to ensure decryption is complete on server before GET
        await Future.delayed(const Duration(milliseconds: 500));
        await loadMessages(showLoading: false);
        if (Get.isRegistered<ChatController>()) {
          ChatController.instance.getChatRepos(showLoading: false);
        }
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
          imageName = "doc";
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
        if (Get.isRegistered<ChatController>()) {
          ChatController.instance.getChatRepos(showLoading: false);
        }
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
  // FETCH USER PROFILE
  // ✅ এখন এই একটা function এই profile + friendship দুটোই handle করে
  //    আগে আলাদা checkFriendshipStatus() call হতো — সেটা বাদ দেওয়া হয়েছে
  //    কারণ profile response এ isAlreadyFriend ও pendingFriendRequest আসে
  // ================================================
  Future<void> fetchUserProfile(String targetUserId) async {
    try {
      // ✅ LocalStorage থেকে lat/lng নাও

      otherUserId.value = targetUserId;

      final double lat = LocalStorage.lat;
      final double lng = LocalStorage.long;

      final response = await ApiService.get(
        "${ApiEndPoint.getUserSingleProfileById}$targetUserId?lat=$lat&lng=$lng",
      );

      if (response.statusCode == 200) {
        appLog("User profile fetched successfully");
        final data = response.data['data'];
        if (data != null) {
          // ── Online status
          isActive.value = data['isOnline'] == true;

          // ── Distance
          // API তে distance আসলে set করো
          // না আসলে distance = '' এবং rawDistanceKm = -1.0 (unknown)
          // -1.0 ব্যবহার করা হচ্ছে কারণ 0.0 মানে "same location" (allow)
          // কিন্তু distance না থাকলে block করতে হবে
          final double? distNum =
          double.tryParse(data['distance']?.toString() ?? '');
          if (distNum != null) {
            rawDistanceKm.value = distNum;
            distance.value = "${distNum.toStringAsFixed(2)}km";
          } else {
            distance.value = '';
            rawDistanceKm.value = -1.0;
          }

          // ── Location visibility
          isLocationVisible.value = data['isLocationVisible'] == true;

          // ── Friendship status
          // ✅ profile response এ isAlreadyFriend ও pendingFriendRequest আসে
          //    তাই আলাদা /friendships/check call করার দরকার নেই
          if (data['isAlreadyFriend'] == true) {
            friendStatus.value = FriendStatus.friends;
            friendStatusValue.value = 'friends';
            isFriend.value = true;
            pendingRequestId.value = '';
          } else if (data['pendingFriendRequest'] != null) {
            final req = data['pendingFriendRequest'];
            final String currentUserId = LocalStorage.userId ?? '';
            final String senderId = req['sender']?.toString() ?? '';

            if (senderId == currentUserId) {
              // আমি request পাঠিয়েছি
              friendStatus.value = FriendStatus.requested;
              friendStatusValue.value = 'pending';
              isFriend.value = true;
            } else {
              // অন্যজন আমাকে request পাঠিয়েছে
              friendStatus.value = FriendStatus.requested;
              friendStatusValue.value = 'received';
              isFriend.value = false;
            }
            pendingRequestId.value = req['_id']?.toString() ?? '';
          } else {
            // কোনো friendship নেই
            friendStatus.value = FriendStatus.none;
            friendStatusValue.value = 'none';
            isFriend.value = false;
            pendingRequestId.value = '';
          }
          friendStatusLoaded.value = true;
        }
      }
    } catch (e) {
      appLog("❌ Fetch user profile error: $e");
      // Error হলেও unknown রাখো
      distance.value = '';
      rawDistanceKm.value = -1.0;
    } finally {
      isProfileLoaded.value = true;
      update();
    }
  }

  // ================================================
  // FRIENDSHIP ACTION METHODS
  // ================================================
  Future<void> checkFriendshipStatus(String targetUserId) async {
    //    এই function টা এখন আর _initializeChatData থেকে call হয় না
    //    fetchUserProfile এই কাজটা করে।
    //    তবে বাইরে থেকে manually call করার প্রয়োজন হলে রাখা হয়েছে।
    if (targetUserId.isEmpty) {
      isFriend.value = true;
      friendStatus.value = FriendStatus.friends;
      friendStatusValue.value = 'friends';
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
          friendStatus.value = FriendStatus.friends;
          friendStatusValue.value = 'friends';
          isFriend.value = true;
          pendingRequestId.value = '';
        } else if (data['pendingFriendRequest'] != null) {
          final req = data['pendingFriendRequest'];
          final String currentUserId = LocalStorage.userId ?? '';
          final String senderId = req['sender']?.toString() ?? '';

          if (senderId == currentUserId) {
            friendStatus.value = FriendStatus.requested;
            friendStatusValue.value = 'pending';
            isFriend.value = true;
          } else {
            friendStatus.value = FriendStatus.requested;
            friendStatusValue.value = 'received';
            isFriend.value = false;
          }
          pendingRequestId.value = req['_id']?.toString() ?? '';
        } else {
          friendStatus.value = FriendStatus.none;
          friendStatusValue.value = 'none';
          isFriend.value = false;
          pendingRequestId.value = '';
        }
      } else {
        friendStatus.value = FriendStatus.none;
        friendStatusValue.value = 'none';
        isFriend.value = false;
      }
    } catch (e) {
      debugPrint("❌ Friendship check error: $e");
      friendStatus.value = FriendStatus.none;
      friendStatusValue.value = 'none';
      isFriend.value = false;
    } finally {
      friendStatusLoaded.value = true;
      hasPendingRequest.value = false;
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
        friendStatus.value = FriendStatus.requested;
        friendStatusValue.value = 'pending';
        isFriend.value = true;
        if (Get.isRegistered<MyFriendController>()) {
          Get.find<MyFriendController>().fetchFriendRequests();
        }
        update();
      } else {
        debugPrint("Friend request error: $response.message");
      }
    } catch (e) {
      debugPrint("❌ Friend request error: $e");

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
        isFriend.value = false;
        hasPendingRequest.value = false;
        friendStatusValue.value = 'none';
        friendStatus.value = FriendStatus.none;
        pendingRequestId.value = '';
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
      final response =
      await ApiService.patch(url, body: {"status": 'accepted'});

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
      final response =
      await ApiService.patch(url, body: {"status": 'rejected'});

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

  // ================================================
  // DISTANCE CALCULATION
  // ================================================

  Future<void> calculateDistanceFromOtherUser(
      double otherLat, double otherLng) async {
    try {
      final double myLat = LocalStorage.lat;
      final double myLng = LocalStorage.long;
      final double distanceInMeters =
      Geolocator.distanceBetween(myLat, myLng, otherLat, otherLng);
      final double distanceInKm = distanceInMeters / 1000;
      rawDistanceKm.value = distanceInKm;
      distance.value = "${distanceInKm.toStringAsFixed(2)}km";
      debugPrint(
          '📍 Distance: ${distance.value} | Radius: ${LocalStorage.radius} km');
    } catch (e) {
      debugPrint('Distance calculation error: $e');
      distance.value = '';
      rawDistanceKm.value = -1.0; // unknown
    }
  }

  // ================================================
  // UPDATE REQUEST STATUS
  // ================================================


  Future<void> updateRequestStatus(String status) async {
    try {
      final response = await ApiService.patch(
        "${ApiEndPoint.noneFriendChatUpdate}$chatId",
        body: {"requestStatus": status},
      );

      appLog(
          "updateRequestStatus [$status] => ${response.statusCode} | ${response.data}");

      if (response.statusCode == 200) {
        if (Get.isRegistered<ChatController>()) {
          await Get.find<ChatController>().getChatRepos();
          update();
        }
      }
    } catch (e) {
      debugPrint("Update Request Status Error: $e");
    }
  }

  // ================================================
  // HELPERS
  // ================================================

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
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}