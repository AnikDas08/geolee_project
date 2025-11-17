import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import '../../../../services/api/api_service.dart';
import '../../../../services/socket/socket_service.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/enum/enum.dart';
import '../../../message/data/model/chat_message_model.dart';
import '../../../message/data/model/message_model.dart';

class MessageController extends GetxController {
  bool isLoading = false;
  bool isMoreLoading = false;
  bool isUploadingImage = false;

  List messages = [];

  String chatId = "";
  String chatRoomId = "";
  String name = "";
  String image = "";

  String servicename="";
  String serviceImage="";
  String serviceTitle="";
  num price=0;
  String postId="";

  int page = 1;
  int currentIndex = 0;
  Status status = Status.completed;

  bool isMessage = false;
  bool isInputField = false;
  String clientStatus="";

  File? selectedAttachment;
  String? attachmentType;

  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  static MessageController get instance => Get.put(MessageController());

  MessageModel messageModel = MessageModel.fromJson({});

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

      print("chat id 😍😍😍😍 $chatId");
      print("chat room id 😍😍😍😍 $chatRoomId");
    }

    // Load messages if chatId exists
    if (chatId.isNotEmpty) {
      getMessageRepo();
    }
  }

  // Scroll to bottom with animation
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> getMessageRepo() async {
    if (chatId.isEmpty) return;

    isLoading = true;
    update();

    try {
      var response = await ApiService.get("/message/$chatId");

      if (response.statusCode == 200) {
        var data = response.data['data']; // This is a List

        messages.clear();
        List<ChatMessageModel> tempMessages = [];

        // Extract service information from the first message that has service data
        if (data is List && data.isNotEmpty) {
          // Find first message with non-null service
          var messageWithService = data.firstWhere(
                (msg) => msg['service'] != null,
            orElse: () => null,
          );

          if (messageWithService != null && messageWithService['service'] != null) {
            serviceTitle = messageWithService['service']['title'] ?? "";
            serviceImage = messageWithService['service']['image'] ?? "";
            price = messageWithService['service']['price'] ?? 0;

            // Set clientStatus and postId from the first message with service
            clientStatus = messageWithService['service']['bookingStatus'] ?? "";
            postId = messageWithService['service']['_id'] ?? "";
          } else {
            serviceTitle = "";
            serviceImage = "";
            price = 0;
            clientStatus = "";
            postId = "";
          }

          print("😂😂😂😂 $serviceTitle");

          // Now iterate through all messages
          for (var messageData in data) {
            // Safely access service data with null checks
            String? messageClientStatus;
            if (messageData['service'] != null) {
              messageClientStatus = messageData['service']['bookingStatus'];
            }

            tempMessages.add(
              ChatMessageModel(
                time: DateTime.parse(messageData['createdAt']).toLocal(),
                text: messageData['text'] ?? '',
                image: messageData['sender']['image'] ?? '',
                messageImage: messageData['image'],
                clientStatus: messageClientStatus,
                isNotice: false,
                isMe: LocalStorage.userId == messageData['sender']['_id'],
              ),
            );
          }

          // Sort messages by time - oldest to newest
          tempMessages.sort((a, b) => a.time.compareTo(b.time));

          // Add sorted messages to main list
          messages.addAll(tempMessages);

          // Listen for new messages via socket
          listenMessage(chatId);
        }

        isLoading = false;
        update();

        // Scroll to bottom after loading messages
        scrollToBottom();
      } else {
        Utils.errorSnackBar(response.statusCode.toString(), response.message);
        isLoading = false;
        update();
      }
    } catch (e) {
      print('Error fetching messages: $e');
      Get.snackbar(
        'Error',
        'Failed to load messages',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading = false;
      update();
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        selectedAttachment = File(image.path);
        attachmentType = 'image';
        update();

        await sendMessageWithImage();
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

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        selectedAttachment = File(image.path);
        attachmentType = 'image';
        update();

        await sendMessageWithImage();
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

  Future<void> sendMessageWithImage() async {
    if (selectedAttachment == null) return;

    // Add uploading message at the BOTTOM
    messages.add(
      ChatMessageModel(
        time: DateTime.now(),
        text: "",
        image: LocalStorage.myImage,
        messageImage: selectedAttachment!.path,
        isMe: true,
        isUploading: true,
      ),
    );

    isUploadingImage = true;
    update();
    scrollToBottom();

    try {
      FormData formData = FormData.fromMap({
        'chatId': chatRoomId,
        'image': await MultipartFile.fromFile(
          selectedAttachment!.path,
          filename: selectedAttachment!.path.split('/').last,
        ),
      });

      final response = await ApiService.post("message/create", body: formData);

      // Remove uploading message from BOTTOM
      messages.removeLast();

      if (response.statusCode == 200) {
        var messageData = response.data['data'];

        // Add actual message at BOTTOM
        messages.add(
          ChatMessageModel(
            time: DateTime.parse(messageData['createdAt']).toLocal(),
            text: messageData['text'] ?? '',
            image: LocalStorage.myImage,
            messageImage: messageData['image'],
            isMe: true,
            isUploading: false,
          ),
        );

        update();
        scrollToBottom();

        Get.snackbar(
          'Success',
          'Image sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        print("Image sent successfully");
      } else {
        update();
        Get.snackbar(
          'Error',
          'Failed to send image',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (messages.isNotEmpty && messages.last.isUploading == true) {
        messages.removeLast();
      }
      update();

      print('Error sending image: $e');
      Get.snackbar(
        'Error',
        'Failed to send image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      selectedAttachment = null;
      attachmentType = null;
      isUploadingImage = false;
      update();
    }
  }

  Future<void> addNewMessage() async {
    if (messageController.text.trim().isEmpty) return;

    isMessage = true;
    update();

    // Add message at BOTTOM
    messages.add(
      ChatMessageModel(
        time: DateTime.now(),
        text: messageController.text,
        image: LocalStorage.myImage,
        isMe: true,
      ),
    );

    isMessage = false;
    update();
    scrollToBottom();

    print("chat room id 😍😍😍😍 $chatRoomId");

    var body = {
      "chatId": chatRoomId,
      "text": messageController.text,
    };

    messageController.clear();

    final response = await ApiService.post("message/create", body: body);

    if (response.statusCode == 200) {
      print("Message sent successfully");
    } else {
      Get.snackbar(
        'Error',
        'Failed to send message',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  listenMessage(String chatId) async {
    SocketServices.on('getMessage::$chatId', (data) {
      // Add new message at BOTTOM
      messages.add(
        ChatMessageModel(
          isNotice: data['messageType'] == "notice" ? true : false,
          time: DateTime.parse(data['createdAt']).toLocal(),
          text: data['text'] ?? data['message'] ?? '',
          image: data['sender']['image'] ?? '',
          messageImage: data['image'],
          isMe: LocalStorage.userId == data['sender']['_id'],
        ),
      );

      update();
      scrollToBottom();
    });
  }

  void isEmoji(int index) {
    currentIndex = index;
    isInputField = isInputField;
    update();
  }

  @override
  void onClose() {
    scrollController.dispose();
    messageController.dispose();
    super.onClose();
  }
}