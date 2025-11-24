import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class GroupMessageController extends GetxController {
  /// Text Controller
  final messageController = TextEditingController();

  /// Image Picker
  final ImagePicker _picker = ImagePicker();

  /// Messages List
  List<GroupMessage> messages = [];

  /// Current User ID
  final String currentUserId = 'current_user';

  /// Group Info
  String groupName = '';
  int memberCount = 0;

  /// Scroll Controller
  final ScrollController scrollController = ScrollController();

  /// Initialize with group data
  void initializeGroup(String name, int members) {
    groupName = name;
    memberCount = members;
    loadMessages();
  }

  /// Load Messages (Static Data)
  void loadMessages() {
    messages = [
      GroupMessage(
        id: '1',
        senderId: 'sarah_chen',
        senderName: 'Sarah Chen',
        senderImage: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg',
        message: 'Hey everyone! Welcome to the team group 👋',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
        isCurrentUser: false,
      ),
      GroupMessage(
        id: '2',
        senderId: 'mike_rodriguez',
        senderName: 'Mike Rodriguez',
        senderImage: 'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg',
        message: 'Thanks for adding me! Excited to work with everyone',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 3)),
        isCurrentUser: false,
      ),
      GroupMessage(
        id: '3',
        senderId: 'current_user',
        senderName: 'You',
        senderImage: '',
        message: 'Great to be here! Looking forward to collaborating',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 2)),
        isCurrentUser: true,
      ),
      GroupMessage(
        id: '4',
        senderId: 'emily_davis',
        senderName: 'Emily Davis',
        senderImage: 'https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg',
        message: 'Perfect timing! I was just about to reach out about the project kickoff',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
        isCurrentUser: false,
      ),
      GroupMessage(
        id: '5',
        senderId: 'sarah_chen',
        senderName: 'Sarah Chen',
        senderImage: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg',
        message: 'Let\'s schedule a meeting for tomorrow at 2 PM. Does that work for everyone?',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 38)),
        isCurrentUser: false,
      ),
      GroupMessage(
        id: '6',
        senderId: 'mike_rodriguez',
        senderName: 'Mike Rodriguez',
        senderImage: 'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg',
        message: 'Works for me!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 37)),
        isCurrentUser: false,
      ),
      GroupMessage(
        id: '7',
        senderId: 'current_user',
        senderName: 'You',
        senderImage: '',
        message: 'Sounds good, I\'ll be there',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 36)),
        isCurrentUser: true,
      ),
    ];
    update();
    _scrollToBottom();
  }

  /// Send Text Message
  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    final newMessage = GroupMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUserId,
      senderName: 'You',
      senderImage: '',
      message: messageController.text.trim(),
      timestamp: DateTime.now(),
      isCurrentUser: true,
    );

    messages.add(newMessage);
    messageController.clear();
    update();
    _scrollToBottom();
  }

  /// Pick and Send Image
  Future<void> pickAndSendImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        final newMessage = GroupMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: currentUserId,
          senderName: 'You',
          senderImage: '',
          message: '[Image]',
          imageUrl: image.path,
          timestamp: DateTime.now(),
          isCurrentUser: true,
          isImage: true,
        );

        messages.add(newMessage);
        update();
        _scrollToBottom();
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
// GROUP MESSAGE MODEL
// ============================================
class GroupMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String message;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isCurrentUser;
  final bool isImage;

  GroupMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.message,
    this.imageUrl,
    required this.timestamp,
    required this.isCurrentUser,
    this.isImage = false,
  });
}