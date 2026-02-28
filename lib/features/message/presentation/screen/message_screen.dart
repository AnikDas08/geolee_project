import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:intl/intl.dart';
import '../../../../utils/constants/app_colors.dart';
import 'package:giolee78/features/message/data/model/chat_message.dart';
import '../controller/message_controller.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late MessageController messageController;

  @override
  void initState() {
    super.initState();
    messageController = MessageController.instance;
    final params = Get.parameters;

    if (params['chatId'] != null) {
      messageController.chatId = params['chatId'] ?? '';
      messageController.name = params['name'] ?? '';
      messageController.image = params['image'] ?? '';
      messageController.userId = params['userId'] ?? '';
    }

    _initScreen();
  }

  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('http')) return path;

    String baseUrl = ApiEndPoint.imageUrl;
    if (!baseUrl.endsWith('/')) baseUrl = '$baseUrl/';
    final String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return "$baseUrl$cleanPath";
  }

  ({IconData icon, Color color}) _getFileIconInfo(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'pdf': return (icon: Icons.picture_as_pdf_rounded, color: Colors.red);
      case 'doc':
      case 'docx': return (icon: Icons.description_rounded, color: Colors.blue);
      case 'xls':
      case 'xlsx': return (icon: Icons.table_chart_rounded, color: Colors.green);
      case 'ppt':
      case 'pptx': return (icon: Icons.slideshow_rounded, color: Colors.orange);
      default: return (icon: Icons.insert_drive_file_rounded, color: Colors.grey);
    }
  }

  void _showAttachmentPicker(BuildContext context, MessageController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Wrap(
              children: [
                ListTile(
                  leading: _attachmentIcon(Icons.photo_library, Colors.purple, Colors.purple.shade50),
                  title: const Text('Photo Library'),
                  onTap: () { Navigator.of(context).pop(); controller.pickImageFromGallery(); },
                ),
                ListTile(
                  leading: _attachmentIcon(Icons.photo_camera, Colors.blue, Colors.blue.shade50),
                  title: const Text('Camera'),
                  onTap: () { Navigator.of(context).pop(); controller.pickImageFromCamera(); },
                ),
                ListTile(
                  leading: _attachmentIcon(Icons.attach_file_rounded, Colors.orange, Colors.orange.shade50),
                  title: const Text('File'),
                  onTap: () { Navigator.of(context).pop(); controller.pickFile(); },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _attachmentIcon(IconData icon, Color iconColor, Color bgColor) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10.r)),
      child: Icon(icon, color: iconColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(
      builder: (controller) {
        return WillPopScope(
          onWillPop: () async {
            controller.clearAllPicks();
            Get.back();
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  controller.clearAllPicks();
                  Get.back();
                },
              ),
              title: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: controller.image.isNotEmpty
                            ? NetworkImage(_getImageUrl(controller.image))
                            : null,
                        child: controller.image.isEmpty ? Icon(Icons.person, size: 20.sp, color: Colors.grey) : null,
                      ),
                      if (controller.isActive)
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            width: 12.w, height: 12.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0FE16D),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.name.isNotEmpty ? controller.name : 'Chat',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp, color: Colors.black),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        if (controller.isActive)
                          Text("Active now", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0FE16D))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            body: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: controller.scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                          itemCount: controller.messages.length,
                          itemBuilder: (context, index) => _buildMessageBubble(controller.messages[index]),
                        ),
                      ),

                      _buildPickedFilePreview(controller),

                      if (controller.isUploadingImage || controller.isUploadingMedia)
                        _buildUploadProgress(),

                      Obx(() {
                        final loaded = controller.friendStatusLoaded.value;
                        final isFriend = controller.isFriend.value;
                        if (!loaded || isFriend) {
                          return _buildInputArea(context, controller);
                        }
                        return _buildNonFriendPanel(context, controller);
                      }),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildNonFriendPanel(BuildContext context, MessageController controller) {
    return Obx(() {
      final status = controller.friendStatusValue.value;
      return SafeArea(
        child: Container(
          height: 350.h,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -4))],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10.h, bottom: 6.h),
                  width: 40.w, height: 4.h,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("This User Is Not Your Friend List", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                      SizedBox(height: 16.h),
                      _nonFriendActionTile(
                        label: status == 'pending' ? 'Friend Request Sent' : 'Add Friend',
                        color: AppColors.primaryColor,
                        onTap: status == 'pending' ? null : () async { await controller.sendFriendRequest(controller.otherUserId.value); },
                        iconPath: 'assets/images/add_friend.png',
                      ),
                      Divider(height: 1, color: Colors.grey[200]),
                      _nonFriendActionTile(
                        label: 'Ignore',
                        color: AppColors.primaryColor,
                        onTap: () { controller.clearAllPicks(); Get.back(); },
                        iconPath: 'assets/images/ignore.png',
                      ),
                      Divider(height: 1, color: Colors.grey[200]),
                      _nonFriendActionTile(
                        label: 'Continue With Chat',
                        color: AppColors.primaryColor,
                        onTap: () { controller.isFriend.value = true; },
                        iconPath: 'assets/images/message_icon.png',
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Row(
                    children: [
                      Expanded(child: SizedBox(height: 50.h, child: CommonTextField(controller: controller.messageController, hintText: "Reply"))),
                      SizedBox(width: 10.w),
                      SizedBox(height: 50.h, width: 80.w, child: CommonButton(onTap: controller.sendMessage, titleText: "Send")),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _nonFriendActionTile({required String iconPath, required String label, required Color color, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            SizedBox(height: 24.h, width: 24.w, child: Image.asset(iconPath)),
            SizedBox(width: 14.w),
            Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: onTap == null ? Colors.grey : color)),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Container(
      color: Colors.white, padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(children: [
        SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(strokeWidth: 2)),
        SizedBox(width: 8.w),
        Text('Sending...', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
      ]),
    );
  }

  Widget _buildPickedFilePreview(MessageController controller) {
    return const SizedBox.shrink();
  }

  Widget _buildInputArea(BuildContext context, MessageController controller) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: MediaQuery.of(context).padding.bottom + 16.h, top: 16.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24.r)),
              child: TextField(
                controller: controller.messageController,
                decoration: InputDecoration(
                  hintText: "Write your message", border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  suffixIcon: GestureDetector(
                    onTap: () => _showAttachmentPicker(context, controller),
                    child: Icon(Icons.attach_file, color: Colors.grey[600], size: 22.sp),
                  ),
                ),
                onSubmitted: (_) => controller.sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: controller.sendMessage,
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: const BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
              child: Icon(Icons.send, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: message.isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isCurrentUser) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundImage: message.senderImage.isNotEmpty ? NetworkImage(_getImageUrl(message.senderImage)) : null,
              child: message.senderImage.isEmpty ? Icon(Icons.person, size: 16.sp) : null,
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 250.w),
                  decoration: BoxDecoration(
                    color: message.isCurrentUser ? const Color(0xFFFFEBEE) : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
                  ),
                  padding: EdgeInsets.all(12.w),
                  child: _buildBubbleContent(message),
                ),
                Text(DateFormat('hh:mm a').format(message.createdAt), style: TextStyle(fontSize: 10.sp, color: Colors.grey[500])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleContent(ChatMessage message) {
    if (message.isImage) {
      final url = message.imageUrl ?? '';
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.network(_getImageUrl(url), width: 200.w, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
      );
    }
    return Text(message.message, style: TextStyle(fontSize: 14.sp, height: 1.4));
  }

  Future<void> _initScreen() async {
    await messageController.loadMessages();
    if (messageController.userId.isNotEmpty) {
      await messageController.checkFriendshipStatus(messageController.userId);
    } else {
      messageController.friendStatusLoaded.value = true;
    }
  }


}
