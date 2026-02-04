import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

      print("chat id 😍😍😍😍 $chatId");
      print("chat room id 😍😍😍😍 $chatRoomId");
    }

    // Load static messages
    loadMessages();
  }

  /// Load Messages (Static Data)
  void loadMessages() {
    isLoading = true;
    update();

    // Demo service info for banner
    serviceTitle = 'House Cleaning Service';
    serviceImage = 'https://images.pexels.com/photos/4239097/pexels-photo-4239097.jpeg';
    price = 120;
    clientStatus = 'RUNNING';
    postId = 'demo-post-1';

    messages = [
      ChatMessage(
        id: '1',
        senderId: 'other_user',
        senderImage: 'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
        message: 'Hi, I saw your service. Are you available tomorrow?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        isCurrentUser: false,
      ),
      ChatMessage(
        id: '2',
        senderId: currentUserId,
        senderImage: '',
        message: 'Yes, I am available after 3 PM.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        isCurrentUser: true,
      ),
      ChatMessage(
        id: '3',
        senderId: 'other_user',
        senderImage: 'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
        message: 'Great! Can you also bring your own equipment?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isCurrentUser: false,
      ),
      ChatMessage(
        id: '4',
        senderId: currentUserId,
        senderImage: '',
        message: 'Sure, I will bring everything needed.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isCurrentUser: true,
      ),
      ChatMessage(
        id: '5',
        senderId: 'other_user',
        senderImage: 'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
        message: 'Perfect, see you then!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isCurrentUser: false,
      ),
    ];

    isLoading = false;
    update();
    _scrollToBottom();
  }

  /// Send Text Message
  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUserId,
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

    // Add uploading message
    final uploadingMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUserId,
      senderImage: '',
      message: '[Image]',
      imageUrl: imagePath,
      timestamp: DateTime.now(),
      isCurrentUser: true,
      isImage: true,
      isUploading: true,
    );

    messages.add(uploadingMessage);
    update();
    _scrollToBottom();

    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));

    // Remove uploading message and add final message
    messages.removeLast();

    final finalMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUserId,
      senderImage: '',
      message: '[Image]',
      imageUrl: imagePath,
      timestamp: DateTime.now(),
      isCurrentUser: true,
      isImage: true,
      isUploading: false,
    );

    messages.add(finalMessage);
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
  final String senderId;
  final String senderImage;
  final String message;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isCurrentUser;
  final bool isImage;
  final bool isUploading;
  final bool isNotice;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderImage,
    required this.message,
    this.imageUrl,
    required this.timestamp,
    required this.isCurrentUser,
    this.isImage = false,
    this.isUploading = false,
    this.isNotice = false,
  });
}