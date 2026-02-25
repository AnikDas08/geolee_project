import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:intl/intl.dart';

import 'package:giolee78/features/message/data/model/chat_message.dart';
import '../controller/group_message_controller.dart';

class GroupMessageScreen extends StatefulWidget {
  const GroupMessageScreen({super.key});

  @override
  State<GroupMessageScreen> createState() => _GroupMessageScreenState();
}

class _GroupMessageScreenState extends State<GroupMessageScreen> {
  // ─── ইমেজ ইউআরএল হ্যান্ডেলার ─────────────────────────────
  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";

    // যদি অলরেডি পূর্ণ ইউআরএল থাকে
    if (path.startsWith('http')) return path;

    // বেস ইউআরএল ঠিক করা (স্ল্যাশ হ্যান্ডেল করা)
    String baseUrl = ApiEndPoint.imageUrl;
    if (!baseUrl.endsWith('/')) {
      baseUrl = '$baseUrl/';
    }

    // পাথের শুরু থেকে স্ল্যাশ সরিয়ে ফেলা
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;

    return "$baseUrl$cleanPath";
  }

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments ?? {};
    final String chatId = arguments['chatId'] ?? '';
    final String groupName = arguments['groupName'] ?? 'Group';
    final int memberCount = arguments['memberCount'] ?? 0;

    return GetBuilder<GroupMessageController>(
      init: GroupMessageController()
        ..initializeGroup(chatId, groupName, memberCount),
      builder: (controller) {
        return WillPopScope(
          onWillPop: () async {
            controller.clearAllPicks();
            Get.back();
            return true;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  controller.clearAllPicks();
                  Navigator.pop(context);
                },
              ),
              title: Row(
                children: [
                  Obx(() {
                    final String path = controller.avatarFilePath.value;
                    if (path.isNotEmpty) {
                      bool isActuallyLocalFile = path.startsWith('/data/') || path.startsWith('/storage/') || path.startsWith('file://');

                      return CircleAvatar(
                        radius: 18.r,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: isActuallyLocalFile
                            ? FileImage(File(path)) as ImageProvider
                            : NetworkImage(getImageUrl(path)), // এখানে getImageUrl ব্যবহার করা হয়েছে
                      );
                    } else {
                      return CircleAvatar(
                        radius: 18.r,
                        backgroundColor: AppColors.primaryColor,
                        child: Icon(Icons.group, color: Colors.white, size: 20.sp),
                      );
                    }
                  }),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => CommonText(
                          text: controller.groupName.value,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        )),
                        Obx(() => CommonText(
                          text: '${controller.memberCount.value} Members',
                          fontSize: 12.sp,
                          color: Colors.grey,
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black),
                  onPressed: () {
                    Get.toNamed(
                      AppRoutes.groupSetting,
                      arguments: {'chatId': controller.chatId},
                    );
                  },
                ),
              ],
            ),
            body: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: controller.scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageItem(controller.messages[index]);
                    },
                  ),
                ),
                _buildPickedFilePreview(controller),
                if (controller.isUploadingImage ||
                    controller.isUploadingMedia ||
                    controller.isUploadingDocument)
                  _buildUploadProgress(controller),
                _buildInputArea(context, controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadProgress(GroupMessageController controller) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8.w),
          Text(
            controller.isUploadingImage
                ? 'Sending image…'
                : controller.isUploadingMedia
                ? 'Sending media…'
                : 'Sending file…',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ─── Message Item ───────────────────────────────
  Widget _buildMessageItem(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: message.isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!message.isCurrentUser) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16.r,
                  backgroundImage: message.senderImage.isNotEmpty
                      ? NetworkImage(getImageUrl(message.senderImage)) // আপডেট করা হয়েছে
                      : null,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                  child: message.senderImage.isEmpty
                      ? Text(
                    message.senderName.isNotEmpty
                        ? message.senderName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  )
                      : null,
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.senderName,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      _buildBubble(message, isMe: false),
                      SizedBox(height: 4.h),
                      Text(
                        DateFormat('hh:mm a').format(message.createdAt),
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildBubble(message, isMe: true),
            SizedBox(height: 4.h),
            Text(
              DateFormat('hh:mm a').format(message.createdAt),
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage message, {required bool isMe}) {
    return Container(
      constraints: BoxConstraints(maxWidth: Get.width * 0.70),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFFFEBEE) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
          bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(4.r),
          bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(16.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: message.isImage || message.isFile
          ? EdgeInsets.all(8.w)
          : EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: _buildBubbleContent(message),
    );
  }

  Widget _buildBubbleContent(ChatMessage message) {
    if (message.isImage) {
      final url = message.imageUrl ?? '';
      // যদি লোকাল ফাইল না হয়, তবে getImageUrl ব্যবহার করুন
      final bool isLocal = url.startsWith('/');

      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: isLocal
            ? Image.file(File(url), width: 200.w, fit: BoxFit.cover)
            : Image.network(
          getImageUrl(url), // আপডেট করা হয়েছে
          width: 200.w,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 200.w,
            height: 100.h,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      );
    }

    if (message.isFile) {
      final info = _fileIconInfo(message.fileExtension);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: info.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(info.icon, color: info.color, size: 28.sp),
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? 'File',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  (message.fileExtension ?? '').toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: info.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Text(
      message.message,
      style: TextStyle(fontSize: 14.sp, color: Colors.black87, height: 1.4),
    );
  }

  // ─── Picked file preview & Input Area ────────────────
  Widget _buildPickedFilePreview(GroupMessageController ctrl) {
    if (ctrl.isImagePicked()) {
      return Container(
        color: Colors.grey[50],
        padding: EdgeInsets.all(8.w),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(File(ctrl.pickedImagePath!), height: 120.h, fit: BoxFit.cover),
            ),
            Positioned(
              top: 4, right: 4,
              child: GestureDetector(
                onTap: ctrl.clearPickedImage,
                child: Container(
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (ctrl.isFilePicked()) {
      final fileInfo = _fileIconInfo(ctrl.pickedFileType);
      return Container(
        color: Colors.grey[50],
        padding: EdgeInsets.all(8.w),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12.r),
            color: Colors.white,
          ),
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: fileInfo.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(fileInfo.icon, color: fileInfo.color, size: 32.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ctrl.getPickedFileName(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                    Text('${ctrl.getPickedFileType()} • ${ctrl.getPickedFileSize()}', style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: ctrl.clearPickedFile, iconSize: 20.sp),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildInputArea(BuildContext context, GroupMessageController controller) {
    final bool isBusy = controller.isSendingText || controller.isUploadingImage || controller.isUploadingMedia || controller.isUploadingDocument;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h, bottom: MediaQuery.of(context).padding.bottom + 12.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24.r)),
              child: TextField(
                controller: controller.messageController,
                decoration: InputDecoration(
                  hintText: 'Write your message',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  suffixIcon: GestureDetector(
                    onTap: () => _showAttachmentPicker(context, controller),
                    child: Icon(Icons.attach_file, color: Colors.grey[600], size: 22.sp),
                  ),
                ),
                onSubmitted: (_) => controller.sendTextAndFile(),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: isBusy ? null : controller.sendTextAndFile,
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(color: isBusy ? Colors.grey : AppColors.primaryColor, shape: BoxShape.circle),
              child: Icon(Icons.send, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentPicker(BuildContext context, GroupMessageController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _attachmentOption(icon: Icons.photo_library, label: 'Gallery', color: Colors.purple, onTap: () { Navigator.pop(context); controller.pickImageFromGallery(); }),
              _attachmentOption(icon: Icons.camera_alt, label: 'Camera', color: Colors.blue, onTap: () { Navigator.pop(context); controller.pickImageFromCamera(); }),
              _attachmentOption(icon: Icons.insert_drive_file, label: 'Document', color: Colors.orange, onTap: () { Navigator.pop(context); controller.pickFile(); }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachmentOption({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 60.w, height: 60.w, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16.r)), child: Icon(icon, color: color, size: 28.sp)),
          SizedBox(height: 8.h),
          Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
        ],
      ),
    );
  }

  _FileIconInfo _fileIconInfo(String? typeOrExt) {
    final t = (typeOrExt ?? '').toLowerCase();
    if (['pdf'].contains(t)) return const _FileIconInfo(Icons.picture_as_pdf, Colors.red);
    if (['doc', 'docx'].contains(t)) return const _FileIconInfo(Icons.description, Colors.blue);
    if (['mp4', 'mov', 'video'].contains(t)) return const _FileIconInfo(Icons.videocam, Colors.purple);
    return const _FileIconInfo(Icons.insert_drive_file, Colors.blueGrey);
  }
}

class _FileIconInfo {
  final IconData icon;
  final Color color;
  const _FileIconInfo(this.icon, this.color);
}