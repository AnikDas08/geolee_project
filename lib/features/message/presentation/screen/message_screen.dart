import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart'; // ApiEndPoint ইম্পোর্ট নিশ্চিত করুন
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


  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('http')) return path;

    String baseUrl = ApiEndPoint.imageUrl;
    if (!baseUrl.endsWith('/')) {
      baseUrl = '$baseUrl/';
    }

    final String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return "$baseUrl$cleanPath";
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
                ListTile(
                  leading: _attachmentIcon(Icons.photo_library, Colors.purple, Colors.purple.shade50),
                  title: const Text('Photo Library'),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.pickImageFromGallery();
                  },
                ),
                ListTile(
                  leading: _attachmentIcon(Icons.photo_camera, Colors.blue, Colors.blue.shade50),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.pickImageFromCamera();
                  },
                ),
                ListTile(
                  leading: _attachmentIcon(Icons.attach_file_rounded, Colors.orange, Colors.orange.shade50),
                  title: const Text('File'),
                  subtitle: const Text('PDF, DOC, XLS, PNG, JPG …', style: TextStyle(fontSize: 12)),
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
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10.r)),
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
                        child: controller.image.isEmpty
                            ? Icon(Icons.person, size: 20.sp, color: Colors.grey)
                            : null,
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
                if (controller.isUploadingImage || controller.isUploadingMedia || controller.isUploadingDocument)
                  _buildUploadProgress(),
                _buildInputArea(context, controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadProgress() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 8.w),
          Text('Sending...', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildPickedFilePreview(MessageController controller) {
    if (controller.isImagePicked()) {
      return Container(
        color: Colors.grey[50],
        padding: EdgeInsets.all(8.w),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(File(controller.pickedImagePath!), height: 120.h, width: double.infinity, fit: BoxFit.cover),
            ),
            Positioned(top: 8.w, right: 8.w, child: CircleAvatar(backgroundColor: Colors.red, radius: 14.r, child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 12), onPressed: controller.clearPickedImage))),
          ],
        ),
      );
    }
    if (controller.isFilePicked()) {
      final fileInfo = _getFileIconInfo(controller.pickedFileType);
      return Container(
        color: Colors.grey[50], padding: EdgeInsets.all(8.w),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12.r), color: Colors.white),
          child: Row(
            children: [
              Icon(fileInfo.icon, color: fileInfo.color, size: 32.sp),
              SizedBox(width: 12.w),
              Expanded(child: Text(controller.getPickedFileName(), maxLines: 1, overflow: TextOverflow.ellipsis)),
              IconButton(icon: const Icon(Icons.close), onPressed: controller.clearPickedFile),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildInputArea(BuildContext context, MessageController controller) {
    final bool isBusy = controller.isSendingText || controller.isUploadingImage || controller.isUploadingMedia || controller.isUploadingDocument;
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
                  hintText: "Write your message",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  suffixIcon: GestureDetector(onTap: () => _showAttachmentPicker(context, controller), child: Icon(Icons.attach_file, color: Colors.grey[600], size: 22.sp)),
                ),
                onSubmitted: (_) => controller.sendTextAndFile(),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: isBusy ? null : controller.sendTextAndFile,
            child: Container(padding: EdgeInsets.all(10.w), decoration: BoxDecoration(color: isBusy ? Colors.grey : AppColors.primaryColor, shape: BoxShape.circle), child: Icon(Icons.send, color: Colors.white, size: 20.sp)),
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
      final bool isLocal = url.startsWith('/');
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: isLocal
            ? Image.file(File(url), width: 200.w, fit: BoxFit.cover)
            : Image.network(_getImageUrl(url), width: 200.w, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
      );
    }
    if (message.isFile) {
      final info = _getFileIconInfo(message.fileExtension);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, color: info.color, size: 28.sp),
          SizedBox(width: 10.w),
          Flexible(child: Text(message.fileName ?? 'File', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
        ],
      );
    }
    return Text(message.message, style: TextStyle(fontSize: 14.sp, height: 1.4));
  }
}