import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/utils/constants/app_images.dart';
import 'package:intl/intl.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../data/model/chat_message_model.dart';
import '../controller/message_controller.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) return imagePath;
    return imagePath;
  }

  /// Returns an icon and color based on file extension
  ({IconData icon, Color color}) _getFileIconInfo(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'pdf':
        return (icon: Icons.picture_as_pdf_rounded, color: Colors.red);
      case 'doc':
      case 'docx':
        return (icon: Icons.description_rounded, color: Colors.blue);
      case 'xls':
      case 'xlsx':
        return (icon: Icons.table_chart_rounded, color: Colors.green);
      case 'ppt':
      case 'pptx':
        return (icon: Icons.slideshow_rounded, color: Colors.orange);
      case 'txt':
      case 'csv':
        return (icon: Icons.article_rounded, color: Colors.blueGrey);
      default:
        return (icon: Icons.insert_drive_file_rounded, color: Colors.grey);
    }
  }

  /// ========== ATTACHMENT PICKER MODAL ==========
  void _showAttachmentPicker(
      BuildContext context,
      MessageController controller,
      ) {
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
                // ── Photo Library ──────────────────────────────────────
                ListTile(
                  leading: _attachmentIcon(
                    Icons.photo_library,
                    Colors.purple,
                    Colors.purple.shade50,
                  ),
                  title: const Text('Photo Library'),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.pickImageFromGallery();
                  },
                ),

                // ── Camera ─────────────────────────────────────────────
                ListTile(
                  leading: _attachmentIcon(
                    Icons.photo_camera,
                    Colors.blue,
                    Colors.blue.shade50,
                  ),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.pickImageFromCamera();
                  },
                ),

                // ── File (PDF / DOC / XLS …) ───────────────────────────
                ListTile(
                  leading: _attachmentIcon(
                    Icons.attach_file_rounded,
                    Colors.orange,
                    Colors.orange.shade50,
                  ),
                  title: const Text('File'),
                  subtitle: const Text(
                    'PDF, DOC, DOCX, XLS, PNG, JPG …',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.pickFile();
                  },
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
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, color: iconColor),
    );
  }

  @override
  void initState() {
    super.initState();
    final controller = MessageController.instance;

    final params = Get.parameters;
    if (params['chatId'] != null) {
      controller.chatId = params['chatId'] ?? '';
      controller.name = params['name'] ?? '';
      controller.image = params['image'] ?? '';
      controller.loadMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(
      builder: (controller) {
        return WillPopScope(
          onWillPop: () async {
            // Clear picked files when leaving
            controller.clearAllPicks();
            Get.back();
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.grey[100],

            /// ========== APP BAR ==========
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
                        backgroundImage: controller.image.isNotEmpty
                            ? NetworkImage(
                          _getImageUrl(
                            AppImages.baseurl + controller.image,
                          ),
                        )
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
                              border:
                              Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.name.isNotEmpty
                              ? controller.name
                              : 'Chat',
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

            /// ========== BODY ==========
            body: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              children: [
                /// ========== MESSAGES LIST ==========
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

                /// ========== PICKED FILE PREVIEW ==========
                _buildPickedFilePreview(controller),

                /// ========== UPLOAD PROGRESS ==========
                if (controller.isUploadingImage ||
                    controller.isUploadingMedia ||
                    controller.isUploadingDocument)
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          controller.isUploadingImage
                              ? 'Sending image…'
                              : controller.isUploadingMedia
                              ? 'Sending media…'
                              : 'Sending file…',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                /// ========== INPUT AREA ==========
                _buildInputArea(context, controller),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ========== BUILD PICKED FILE PREVIEW ==========
  Widget _buildPickedFilePreview(MessageController controller) {
    return GetBuilder<MessageController>(
      builder: (ctrl) {
        // IMAGE PREVIEW
        if (ctrl.isImagePicked()) {
          return Container(
            color: Colors.grey[50],
            padding: EdgeInsets.all(8.w),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(
                    File(ctrl.pickedImagePath!),
                    height: 120.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8.w,
                  right: 8.w,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: ctrl.clearPickedImage,
                      iconSize: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // FILE PREVIEW
        if (ctrl.isFilePicked()) {
          final fileInfo = _getFileIconInfo(ctrl.pickedFileType);

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
                    child: Icon(
                      fileInfo.icon,
                      color: fileInfo.color,
                      size: 32.sp,
                    ),
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
      },
    );
  }

  /// ========== BUILD INPUT AREA ==========
  Widget _buildInputArea(BuildContext context, MessageController controller) {
    return Container(
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
                onSubmitted: (_) => controller.sendTextAndFile(),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: (controller.isSendingText ||
                controller.isUploadingImage ||
                controller.isUploadingMedia ||
                controller.isUploadingDocument)
                ? null
                : controller.sendTextAndFile,
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: (controller.isSendingText ||
                    controller.isUploadingImage ||
                    controller.isUploadingMedia ||
                    controller.isUploadingDocument)
                    ? Colors.grey
                    : AppColors.primaryColor,
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
    );
  }

  // ─────────────────────────────────────────
  // Message bubble

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
          /// Other user avatar
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

          /// Bubble
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
                        ? const Color(0xFFFFEBEE)
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
                  child: _buildBubbleContent(message),
                ),
                SizedBox(height: 4.h),
                Text(
                  timeFormat.format(message.createdAt),
                  style:
                  TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// BUILD BUBBLE CONTENT
  Widget _buildBubbleContent(ChatMessage message) {
    // ── Image bubble ──────────────────────────
    if (message.isImage) {
      final bool isRemote =
          message.imageUrl != null && message.imageUrl!.startsWith('http');

      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: isRemote
                ? Image.network(
              message.imageUrl!,
              width: 200.w,
              fit: BoxFit.cover,
            )
                : Image.file(
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
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    // ── File bubble ───────────────────────────────────────────────────────
    if (message.isFile) {
      final info = _getFileIconInfo(message.fileExtension);

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

    // ── Text bubble ────────────────────────────────────────────────────...
    return Text(
      message.message,
      style: TextStyle(
        color: message.isCurrentUser ? Colors.black : Colors.black87,
        fontSize: 14.sp,
        height: 1.4,
      ),
    );
  }
}