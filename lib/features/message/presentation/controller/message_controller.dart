import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/socket/socket_service.dart';
import 'package:giolee78/utils/log/app_log.dart';
import 'package:image_picker/image_picker.dart';

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

    // Load static messages
    loadMessages();
  }

  /// Load Messages (Static Data)
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
      //
      // final newMessage = ChatMessage(
      //   id: chatId,
      //   senderId: currentUserId,
      //   senderImage: '',
      //   message: messageController.text.trim(),
      //   isCurrentUser: true,
      //   chatId: '',
      //   senderName: '',
      //   type: '',
      //   seenBy: [],
      //   isDeleted: false,
      //   createdAt:DateTime.now().toUtc(),
      //   updatedAt:DateTime.now().toUtc(),
      //   isSeen:true,
      // );
      //
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

    // messages.add(newMessage);
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
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      Get.snackbar(
        'Error',
        'Failed to capture photo: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Send Image Message
  Future<void> _sendImageMessage(String imagePath) async {
    isUploadingImage = true;

    // // Add uploading message
    // final uploadingMessage = ChatMessage(
    //   id: DateTime.now().millisecondsSinceEpoch.toString(),
    //   senderId: currentUserId,
    //   senderImage: '',
    //   message: '[Image]',
    //   imageUrl: imagePath,
    //   timestamp: DateTime.now(),
    //   isCurrentUser: true,
    //   isImage: true,
    //   isUploading: true,
    // );

    // messages.add(uploadingMessage);
    update();
    _scrollToBottom();

    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));

    // Remove uploading message and add final message
    messages.removeLast();
    //
    // final finalMessage = ChatMessage(
    //   id: DateTime.now().millisecondsSinceEpoch.toString(),
    //   senderId: currentUserId,
    //   senderImage: '',
    //   message: '[Image]',
    //   imageUrl: imagePath,
    //   timestamp: DateTime.now(),
    //   isCurrentUser: true,
    //   isImage: true,
    // );

    // messages.add(finalMessage);
    isUploadingImage = false;
    update();
    _scrollToBottom();

    Get.snackbar(
      'Success',
      'Image sent successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
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

  // void listenMessage(String chatId) {
  //   SocketServices.on('message:new', (data) {
  //     final model = MessageModel.fromJson(data);
  //
  //     messages.insert(0, ChatMessage(
  //       id: model.id,
  //       senderId: model.senderId,
  //       senderImage: model.senderImage,
  //       message: model.message,
  //       imageUrl: model.imageUrl,
  //       timestamp: model.timestamp,
  //       isCurrentUser: model.senderId == currentUserId,
  //       isImage: model.isImage,
  //       isNotice: model.isNotice,
  //     ));
  //
  //     update();
  //   });
  // }

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
  final String type; // text / image / etc
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
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? '',
      chatId: json['chat'] ?? '',
      senderId: json['sender']?['_id'] ?? '',
      senderName: json['sender']?['name'] ?? '',
      senderImage: json['sender']?['image'] ?? '',
      type: json['type'] ?? 'text',
      message: json['content'] ?? '',
      seenBy: List<String>.from(json['seenBy'] ?? []),
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isCurrentUser: json['isMyMessage'] ?? false,
      isSeen: json['isSeen'] ?? false,

      // UI helpers auto derive
      imageUrl: json['type'] == 'image' ? json['content'] : null,
      isImage: json['type'] == 'image',
    );
  }
}
