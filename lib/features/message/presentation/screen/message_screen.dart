import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../utils/constants/app_colors.dart';
import '../controller/message_controller.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return imagePath;
  }

  void _showAttachmentPicker(BuildContext context, MessageController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.photo_library, color: Colors.purple),
                  ),
                  title: const Text('Photo Library'),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.pickImageFromGallery();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.photo_camera, color: Colors.blue),
                  ),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.pickImageFromCamera();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final controller = MessageController.instance;

    // Initialize from route parameters if available
    final params = Get.parameters;
    if (params['chatId'] != null) {
      controller.chatId = params['chatId'] ?? '';
      controller.name = params['name'] ?? '';
      controller.image = params['image'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey[100],

          /// App Bar with Profile
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                /// Profile Image with Online Status
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundImage: controller.image.isNotEmpty
                          ? NetworkImage(_getImageUrl(controller.image))
                          : null,
                      child: controller.image.isEmpty
                          ? Icon(Icons.person, size: 20.sp)
                          : null,
                    ),
                    if (controller.isActive)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0FE16D),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(width: 12.w),

                /// Name and Active Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.name.isNotEmpty ? controller.name : 'Chat',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      if (controller.isActive)
                        Text(
                          "Active now",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                            color: const Color(0xFF0FE16D),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),

          /// Body with Messages
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              /// Messages List
              Expanded(
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),

              /// Input Area
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  bottom: MediaQuery.of(context).padding.bottom + 16.h,
                  top: 16.h,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: TextField(
                          controller: controller.messageController,
                          decoration: InputDecoration(
                            hintText: "Write your message",
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[400],
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 12.h,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () => _showAttachmentPicker(context, controller),
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Icon(
                                  Icons.attach_file,
                                  color: Colors.grey[600],
                                  size: 22.sp,
                                ),
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                          ),
                          onSubmitted: (value) => controller.sendMessage(),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: controller.isUploadingImage
                          ? null
                          : controller.sendMessage,
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final timeFormat = DateFormat('hh:mm a');

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: message.isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          /// Other user's avatar (left side)
          if (!message.isCurrentUser) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundImage: message.senderImage.isNotEmpty
                  ? NetworkImage(_getImageUrl(message.senderImage))
                  : null,
              child: message.senderImage.isEmpty
                  ? Icon(Icons.person, size: 16.sp)
                  : null,
            ),
            SizedBox(width: 8.w),
          ],

          /// Message Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: message.isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 250.w),
                  decoration: BoxDecoration(
                    color: message.isCurrentUser
                        ? Color(0xFFFFEBEE)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: message.isCurrentUser
                          ? Radius.circular(16.r)
                          : Radius.circular(4.r),
                      bottomRight: message.isCurrentUser
                          ? Radius.circular(4.r)
                          : Radius.circular(16.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: message.isImage
                      ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          File(message.imageUrl!),
                          width: 200.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (message.isUploading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                      : Text(
                    message.message,
                    style: TextStyle(
                      color: message.isCurrentUser
                          ? Colors.black
                          : Colors.black87,
                      fontSize: 14.sp,
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  timeFormat.format(message.timestamp),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          /// Current user's avatar (right side)
          /*if (message.isCurrentUser) ...[
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 16.r,
              backgroundColor: const Color(0xFF1ABC9C),
              child: Icon(Icons.person, color: Colors.white, size: 16.sp),
            ),
          ],*/
        ],
      ),
    );
  }
}