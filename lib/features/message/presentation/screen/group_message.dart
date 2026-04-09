import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/features/message/data/model/chat_message.dart';
import 'package:giolee78/features/message/presentation/widgets/bubble_content.dart';
import 'package:giolee78/features/message/presentation/widgets/loading_shimer.dart';
import 'package:giolee78/features/message/presentation/widgets/upload_progress.dart';
import 'package:giolee78/features/message/presentation/widgets/video_player_bubble.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:intl/intl.dart';

import '../controller/group_message_controller.dart';
import '../widgets/attachment_select_option.dart';
import '../widgets/full_screen_image_view.dart';

class GroupMessageScreen extends StatefulWidget {
  const GroupMessageScreen({super.key});

  @override
  State<GroupMessageScreen> createState() => _GroupMessageScreenState();
}

class _GroupMessageScreenState extends State<GroupMessageScreen> {
  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('http')) return path;
    String baseUrl = ApiEndPoint.imageUrl;
    if (!baseUrl.endsWith('/')) baseUrl = '$baseUrl/';
    final String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return "$baseUrl$cleanPath";
  }

  void _openImageFullScreen(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => FullScreenImageViewer(imageUrl: imageUrl),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
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
                      final bool isLocal =
                          path.startsWith('/data/') ||
                          path.startsWith('/storage/') ||
                          path.startsWith('file://');
                      return CircleAvatar(
                        radius: 18.r,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: isLocal
                            ? FileImage(File(path)) as ImageProvider
                            : NetworkImage(getImageUrl(path)),
                      );
                    }
                    return CircleAvatar(
                      radius: 18.r,
                      backgroundColor: AppColors.primaryColor,
                      child: Icon(
                        Icons.group,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    );
                  }),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => CommonText(
                            text: controller.groupName.value,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Obx(
                          () => CommonText(
                            text: '${controller.memberCount.value} Members',
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
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
                ? const LoadingShimmer()
                : Column(
                    children: [
                      Expanded(
                        child: controller.messages.isEmpty
                            ? _buildEmptyState()
                            : _buildMessageList(context, controller),
                      ),
                      _buildPickedFilePreview(controller),
                      if (controller.isUploadingImage ||
                          controller.isUploadingMedia ||
                          controller.isUploadingDocument)
                        const UploadProgress(),
                      _buildInputArea(context, controller),
                    ],
                  ),
          ),
        );
      },
    );
  }

  //Message List with pagination loader ===============================
  Widget _buildMessageList(
    BuildContext context,
    GroupMessageController controller,
  ) {
    return ListView.builder(
      reverse: true,
      controller: controller.scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: controller.messages.length + 1,
      itemBuilder: (context, index) {
        // ── Pagination loader at top
        if (index == controller.messages.length) {
          return Obx(() {
            if (controller.isLoadingMore.value) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Center(
                  child: SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              );
            }
            if (!controller.hasMoreMessages.value &&
                controller.messages.length >= 20) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          });
        }

        final reversedIndex = controller.messages.length - 1 - index;
        final msg = controller.messages[reversedIndex];
        return _buildMessageItem(context, msg);
      },
    );
  }

  // Message Item =================================================
  Widget _buildMessageItem(BuildContext context, ChatMessage message) {
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
                      ? NetworkImage(getImageUrl(message.senderImage))
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
                      // ── BubbleContent reused here
                      BubbleContent(
                        message: message,
                        isMe: false,
                        getImageUrl: getImageUrl,
                        onImageTap: (url) => _openImageFullScreen(context, url),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        DateFormat('hh:mm a').format(message.createdAt),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            BubbleContent(
              message: message,
              isMe: true,
              getImageUrl: getImageUrl,
              onImageTap: (url) => _openImageFullScreen(context, url),
            ),
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

  // Empty State================================================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 38.sp,
              color: AppColors.primaryColor.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'Say hello 👋',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  //Picked File Preview ============================================
  Widget _buildPickedFilePreview(GroupMessageController ctrl) {
    if (ctrl.isImagePicked()) {
      return Container(
        color: Colors.grey[50],
        padding: EdgeInsets.all(8.w),
        child: Stack(
          children: [
            ctrl.isVideo
                ? VideoPlayerBubble(
                    videoUrl: ctrl.pickedImagePath ?? '',
                    isMe: true,
                    isFile: true,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.file(
                      File(ctrl.pickedImagePath!),
                      height: 120.h,
                      fit: BoxFit.cover,
                    ),
                  ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: ctrl.clearPickedImage,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
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
                    Text(
                      ctrl.getPickedFileName(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    Text(
                      '${ctrl.getPickedFileType()} • ${ctrl.getPickedFileSize()}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: ctrl.clearPickedFile,
                iconSize: 20.sp,
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // Input Area ============================================================
  Widget _buildInputArea(
    BuildContext context,
    GroupMessageController controller,
  ) {
    final bool isBusy =
        controller.isSendingText ||
        controller.isUploadingImage ||
        controller.isUploadingMedia ||
        controller.isUploadingDocument;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 12.h,
        bottom: MediaQuery.of(context).padding.bottom + 12.h,
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
                  hintText: 'Write your message',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () => _showAttachmentPicker(context, controller),
                    child: Icon(
                      Icons.attach_file,
                      color: Colors.grey[600],
                      size: 22.sp,
                    ),
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
              decoration: BoxDecoration(
                color: isBusy ? Colors.grey : AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }

  // Attachment Picker =========================================================
  void _showAttachmentPicker(
    BuildContext context,
    GroupMessageController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 30.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AttachmentSelectOption(
                  icon: Icons.perm_media_rounded,
                  label: 'Media',
                  color: const Color(0xFF8B5CF6),
                  onTap: controller.pickImageFromGallery,
                ),
                AttachmentSelectOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: const Color(0xFF3B82F6),
                  onTap: controller.pickImageFromCamera,
                ),
                AttachmentSelectOption(
                  icon: Icons.insert_drive_file_rounded,
                  label: 'File',
                  color: const Color(0xFFF59E0B),
                  onTap: controller.pickFile,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _FileIconInfo _fileIconInfo(String? typeOrExt) {
    final t = (typeOrExt ?? '').toLowerCase();
    if (['pdf'].contains(t))
      return const _FileIconInfo(Icons.picture_as_pdf, Colors.red);
    if (['doc', 'docx'].contains(t))
      return const _FileIconInfo(Icons.description, Colors.blue);
    if (['mp4', 'mov', 'video', 'media'].contains(t))
      return const _FileIconInfo(Icons.videocam, Colors.purple);
    return const _FileIconInfo(Icons.insert_drive_file, Colors.blueGrey);
  }
}

class _FileIconInfo {
  final IconData icon;
  final Color color;
  const _FileIconInfo(this.icon, this.color);
}
