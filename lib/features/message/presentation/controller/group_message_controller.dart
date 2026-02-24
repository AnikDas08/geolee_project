import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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

  /// Messages List (using shared model)
  List<ChatMessage> messages = [];

  /// Current Chat ID
  String chatId = '';

  /// Group Info
  String groupName = '';
  int memberCount = 0;

  /// Scroll Controller
  final ScrollController scrollController = ScrollController();

  /// Initialize with group data
  void initializeGroup(String id, String name, int members) {
    chatId = id;
    groupName = name;
    memberCount = members;
    loadMessages();
  }

  @override
  void onInit() {
    super.onInit();
    listenMessage();
  }

  /// Listen for group messages
  void listenMessage() {
    SocketServices.on("message:new", (data) {
      final String incomingChatId = data['chat'] is String
          ? data['chat']
          : data['chat']['_id'];
      if (incomingChatId == chatId) {
        final newMessage = ChatMessage.fromJson(data);
        if (!messages.any((m) => m.id == newMessage.id)) {
          messages.add(newMessage);
          update();
          _scrollToBottom();
        }
      }
    });
  }

  /// Load Messages from API
  Future<void> loadMessages() async {
    if (chatId.isEmpty) return;

    try {
      // Join room
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
        }
      }
    } catch (e) {
      appLog("❌ Load group messages error: $e");
    } finally {
      update();
      _scrollToBottom();
    }
  }

  /// Send Text Message via API
  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty || chatId.isEmpty) return;

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
      }
    } catch (e) {
      appLog("❌ Send group text error: $e");
    }
  }

  /// Pick and Send Image
  Future<void> pickAndSendImage() async {
    if (chatId.isEmpty) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await ApiService.multipart(
          ApiEndPoint.createMessage,
          imagePath: image.path,
          body: {"chat": chatId, "type": "image"},
        );
      }
    } catch (e) {
      appLog("❌ Send group image error: $e");
    }
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
    if (chatId.isNotEmpty) {
      SocketServices.leaveRoom(chatId);
    }
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
