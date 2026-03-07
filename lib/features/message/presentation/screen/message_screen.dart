import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:intl/intl.dart';
import '../../../../utils/constants/app_colors.dart';
import 'package:giolee78/features/message/data/model/chat_message.dart';
import '../../../../component/image/common_image.dart';
import '../../../../utils/constants/app_icons.dart';
import 'package:giolee78/features/friend/presentation/screen/view_friend_screen.dart';
import '../controller/chat_controller.dart';
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
    messageController = Get.find<MessageController>();
    final params = Get.parameters;


    if (params['chatId'] != null) {
      messageController.chatId = params['chatId'] ?? '';
      messageController.name = params['name'] ?? '';
      messageController.image = params['image'] ?? '';
      messageController.userId = params['userId'] ?? '';
      messageController.isActive.value = params['isOnline'] == 'true';
      messageController.distance.value = params['distance'] ?? '';
    }
    _initScreen();
  }

  // ✅ আগে friendship check, তারপর messages load - এখন unified
  Future<void> _initScreen() async {
    await messageController.initializeChat(messageController.userId);
  }

  String _getImageUrl(String? path) {
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
        pageBuilder: (_, __, ___) => _FullScreenImageViewer(imageUrl: imageUrl),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  void _showAttachmentPicker(
    BuildContext context,
    MessageController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bc) => Container(
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
                _attachmentOption(
                  context: bc,
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: const Color(0xFF8B5CF6),
                  onTap: controller.pickImageFromGallery,
                ),
                _attachmentOption(
                  context: bc,
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: const Color(0xFF3B82F6),
                  onTap: controller.pickImageFromCamera,
                ),
                _attachmentOption(
                  context: bc,
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

  Widget _attachmentOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
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
            backgroundColor: const Color(0xFFF5F7FA),
            appBar: _buildAppBar(controller),
            body: Obx(() {
              if (controller.isInitialLoading.value) {
                return _buildLoadingShimmer();
              }
              return Column(
                children: [
                  // ── Messages list
                  Expanded(
                    child: controller.isLoading
                        ? _buildLoadingShimmer()
                        : controller.messages.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      reverse: true,
                      controller: controller.scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final reversedIndex = controller.messages.length - 1 - index;
                        final msg = controller.messages[reversedIndex];

                        final prevMsg = reversedIndex < controller.messages.length - 1
                            ? controller.messages[reversedIndex + 1]
                            : null;

                        final showAvatar =
                            prevMsg == null || prevMsg.senderId != msg.senderId;

                        final showTime =
                            reversedIndex == 0 ||
                                controller.messages[reversedIndex - 1].senderId != msg.senderId;

                        return _buildMessageBubble(
                          context,
                          msg,
                          showAvatar,
                          showTime,
                        );
                      },
                    ),
                  ),

                  // ── Picked file preview
                  _buildPickedFilePreview(controller),

                  // ── Upload progress
                  if (controller.isUploadingImage ||
                      controller.isUploadingMedia ||
                      controller.isUploadingDocument)
                    _buildUploadProgress(),

                  // ── Bottom input / non-friend panel
                  if (!controller.friendStatusLoaded.value)
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(16.h),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    )
                  else if (controller.isFriend.value)
                    _buildInputArea(context, controller)
                  else
                    _buildNonFriendPanel(context, controller),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // AppBar
  // ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(MessageController controller) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 42.w,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black87,
          size: 20.sp,
        ),
        onPressed: () {
          controller.clearAllPicks();
          Get.back();
        },
      ),
      title: Obx(
        () => Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: controller.image.isNotEmpty
                      ? NetworkImage(_getImageUrl(controller.image))
                      : null,
                  child: controller.image.isEmpty
                      ? Icon(
                          Icons.person_rounded,
                          size: 22.sp,
                          color: Colors.grey[400],
                        )
                      : null,
                ),
                if (controller.isActive.value)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 11.w,
                      height: 11.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.name.isNotEmpty ? controller.name : 'Chat',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      color: Colors.black87,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    controller.isActive.value
                        ? 'Active now'
                        : (controller.friendStatus.value !=
                                  FriendStatus.friends &&
                              controller.distance.value.isNotEmpty)
                        ? 'Distance: ${controller.distance.value}'
                        : 'Offline',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: controller.isActive.value
                          ? const Color(0xFF22C55E)
                          : (controller.friendStatus.value !=
                                    FriendStatus.friends &&
                                controller.distance.value.isNotEmpty)
                          ? const Color(0xFFF48201)
                          : Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Obx(() {
          final status = controller.friendStatus.value;
          if (!controller.friendStatusLoaded.value) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Center(
                child: SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            );
          }

          // ✅ বন্ধু — show chat bubble (as in nearby profile)
          if (status == FriendStatus.friends) {
            return IconButton(
              icon: Icon(
                Icons.person_outline_rounded,
                color: AppColors.primaryColor,
                size: 24.sp,
              ),
              onPressed: () {
                Get.to(
                  () => ViewFriendScreen(
                    isFriend: true,
                    userId: controller.userId,
                  ),
                );
              },
            );
          }

          // ✅ Request পাঠিয়েছি — Cancel icon (red as in nearby profile)
          if (status == FriendStatus.requested) {
            return IconButton(
              onPressed: () => _showCancelRequestDialog(controller),
              icon: Icon(
                Icons.person_remove_alt_1,
                color: Colors.red,
                size: 22.sp,
              ),
            );
          }

          // ✅ কোনো relation নেই — Add Friend icon (matching nearby profile)
          return IconButton(
            onPressed: () => _showAddFriendDialog(controller),
            icon: CommonImage(imageSrc: AppIcons.addFriend, size: 22.sp),
          );
        }),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Add Friend Dialog
  // ─────────────────────────────────────────────
  void _showAddFriendDialog(MessageController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(22.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add_rounded,
                  color: AppColors.primaryColor,
                  size: 30.sp,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'Add Friend',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Send a friend request to ${controller.name}?',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 22.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await controller.sendFriendRequest(
                          controller.otherUserId.value,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        'Send Request',
                        style: TextStyle(fontSize: 13.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Cancel Request Dialog
  // ─────────────────────────────────────────────
  void _showCancelRequestDialog(MessageController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(22.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_remove_rounded,
                  color: Colors.orange.shade600,
                  size: 30.sp,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'Cancel Request',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Cancel the friend request sent to ${controller.name}?',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 22.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        'Keep',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await controller.cancelFriendRequest(
                          controller.otherUserId.value,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        'Yes, Cancel',
                        style: TextStyle(fontSize: 13.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Message Bubble
  // ─────────────────────────────────────────────
  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessage message,
    bool showAvatar,
    bool showTime,
  ) {
    final isMe = message.isCurrentUser;
    return Padding(
      padding: EdgeInsets.only(
        bottom: showTime ? 10.h : 2.h,
        top: showAvatar && !isMe ? 4.h : 0,
      ),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            SizedBox(
              width: 30.w,
              child: showAvatar
                  ? CircleAvatar(
                      radius: 13.r,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: message.senderImage.isNotEmpty
                          ? NetworkImage(_getImageUrl(message.senderImage))
                          : null,
                      child: message.senderImage.isEmpty
                          ? Icon(
                              Icons.person_rounded,
                              size: 13.sp,
                              color: Colors.grey,
                            )
                          : null,
                    )
                  : const SizedBox(),
            ),
            SizedBox(width: 6.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildBubbleContent(context, message, isMe),
                if (showTime)
                  Padding(
                    padding: EdgeInsets.only(
                      top: 4.h,
                      left: isMe ? 0 : 4.w,
                      right: isMe ? 4.w : 0,
                    ),
                    child: Text(
                      DateFormat('hh:mm a').format(message.createdAt),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey[400],
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleContent(
    BuildContext context,
    ChatMessage message,
    bool isMe,
  ) {
    if (message.isImage) {
      final url = _getImageUrl(message.imageUrl ?? '');
      return GestureDetector(
        onTap: () => _openImageFullScreen(context, url),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomLeft: Radius.circular(isMe ? 18.r : 4.r),
            bottomRight: Radius.circular(isMe ? 4.r : 18.r),
          ),
          child: Image.network(
            url,
            width: 220.w,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Container(
                    width: 220.w,
                    height: 160.h,
                    color: Colors.grey[100],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                            : null,
                        color: AppColors.primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
            errorBuilder: (_, __, ___) => Container(
              width: 220.w,
              height: 120.h,
              color: Colors.grey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_rounded,
                    color: Colors.grey[400],
                    size: 32.sp,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Image unavailable',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (message.type == 'document') {
      return Container(
        constraints: BoxConstraints(maxWidth: 240.w, minWidth: 140.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryColor.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomLeft: Radius.circular(isMe ? 18.r : 4.r),
            bottomRight: Radius.circular(isMe ? 4.r : 18.r),
          ),
          border: Border.all(
            color: isMe
                ? AppColors.primaryColor.withOpacity(0.2)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.insert_drive_file_rounded,
                color: AppColors.primaryColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Flexible(
              child: Text(
                message.message.isNotEmpty ? message.message : 'Document',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    // Text bubble
    return Container(
      constraints: BoxConstraints(maxWidth: 260.w, minWidth: 40.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFFEEEEE) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          topRight: Radius.circular(18.r),
          bottomLeft: Radius.circular(isMe ? 18.r : 4.r),
          bottomRight: Radius.circular(isMe ? 4.r : 18.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message.message,
        style: TextStyle(
          fontSize: 14.sp,
          height: 1.45,
          color: Colors.black87,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() => ListView.builder(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    itemCount: 9,
    itemBuilder: (_, i) {
      final isMe = i % 3 == 0;
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!isMe) ...[
              _shimmerBox(width: 26.w, height: 26.w, radius: 13.r),
              SizedBox(width: 8.w),
            ],
            _shimmerBox(
              width: (80 + (i * 23) % 130).toDouble().w,
              height: 38.h,
              radius: 16.r,
            ),
          ],
        ),
      );
    },
  );

  Widget _shimmerBox({
    required double width,
    required double height,
    required double radius,
  }) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.35, end: 0.85),
    duration: const Duration(milliseconds: 850),
    builder: (_, v, __) => Opacity(
      opacity: v,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    ),
  );

  Widget _buildEmptyState() => Center(
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

  Widget _buildUploadProgress() => Container(
    color: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    child: Row(
      children: [
        SizedBox(
          width: 14.w,
          height: 14.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          'Sending…',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
        ),
      ],
    ),
  );

  Widget _buildPickedFilePreview(MessageController controller) {
    if (!controller.hasPickedImage && !controller.hasPickedFile) {
      return const SizedBox.shrink();
    }
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 6.h),
      child: Row(
        children: [
          if (controller.hasPickedImage && controller.pickedImagePath != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.network(
                    controller.pickedImagePath!,
                    width: 56.w,
                    height: 56.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56.w,
                      height: 56.w,
                      color: Colors.grey[100],
                      child: const Icon(Icons.image_rounded),
                    ),
                  ),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: GestureDetector(
                    onTap: controller.clearPickedImage,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (controller.hasPickedFile && controller.pickedFileName != null)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file_rounded,
                      color: AppColors.primaryColor,
                      size: 24.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.pickedFileName ?? '',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            controller.getPickedFileSize(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.clearPickedFile,
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.sp,
                        color: Colors.red.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Input Area (friends only)
  // ─────────────────────────────────────────────
  Widget _buildInputArea(BuildContext context, MessageController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 10.h,
        bottom: MediaQuery.of(context).padding.bottom + 12.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () => _showAttachmentPicker(context, controller),
            child: Container(
              width: 40.w,
              height: 40.w,
              margin: EdgeInsets.only(bottom: 1.h),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.attach_file,
                color: Colors.grey[600],
                size: 22.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Container(
              constraints: BoxConstraints(minHeight: 42.h, maxHeight: 120.h),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: TextField(
                controller: controller.messageController,
                maxLines: null,
                style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Write a message…',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 11.h,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: controller.sendMessage,
            child: Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.send_rounded, color: Colors.white, size: 18.sp),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Non-Friend Panel
  // ─────────────────────────────────────────────
  Widget _buildNonFriendPanel(
    BuildContext context,
    MessageController controller,
  ) {
    return Obx(() {
      final status = controller.friendStatusValue.value;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 10.h, bottom: 4.h),
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 15.sp,
                          color: Colors.orange[400],
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'This user is not in your friend list',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Accept Request (if received)
                    if (status == 'received')
                      _nonFriendTile(
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: Colors.green.shade600,
                        label: 'Accept Friend Request',
                        onTap: () async => await controller.acceptFriendRequest(
                          controller.pendingRequestId.value,
                        ),
                      ),
                    if (status == 'received')
                      Divider(height: 1, color: Colors.grey.shade100),

                    // Reject Request (if received)
                    if (status == 'received')
                      _nonFriendTile(
                        icon: Icons.remove_circle_outline_rounded,
                        iconColor: Colors.red.shade400,
                        label: 'Reject Request',
                        onTap: () async => await controller.rejectFriendRequest(
                          controller.pendingRequestId.value,
                        ),
                      ),
                    if (status == 'received')
                      Divider(height: 1, color: Colors.grey.shade100),

                    // Add Friend tile (only if not pending/received/friends)
                    if (status != 'received' && status != 'friends')
                      _nonFriendTile(
                        icon: Icons.person_add_alt_1_rounded,
                        iconColor: AppColors.primaryColor,
                        label: status == 'pending'
                            ? 'Friend Request Sent ✓'
                            : 'Add Friend',
                        disabled: status == 'pending',
                        onTap: () async => await controller.sendFriendRequest(
                          controller.otherUserId.value,
                        ),
                      ),
                    if (status != 'received' && status != 'friends')
                      Divider(height: 1, color: Colors.grey.shade100),

                    // Ignore tile
                    _nonFriendTile(
                      icon: Icons.close_rounded,
                      iconColor: Colors.red.shade400,
                      label: 'Ignore',
                      onTap: () {
                        controller.clearAllPicks();
                        Get.back();
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.shade100),

                    // Continue with Chat tile
                    _nonFriendTile(
                      icon: Icons.chat_rounded,
                      iconColor: Colors.green.shade600,
                      label: 'Continue with Chat',
                      onTap: () {
                        controller.isFriend.value = true;
                        controller.friendStatusValue.value = 'none_continued';
                      },
                    ),
                  ],
                ),
              ),

              // Reply input
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                        child: TextField(
                          controller: controller.messageController,
                          style: TextStyle(fontSize: 14.sp),
                          decoration: InputDecoration(
                            hintText: 'Reply',
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[400],
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 13.h,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: controller.sendMessage,
                      child: Container(
                        width: 46.w,
                        height: 46.w,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      );
    });
  }

  Widget _nonFriendTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    bool disabled = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 2.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: (disabled ? Colors.grey : iconColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                size: 18.sp,
                color: disabled ? Colors.grey[400] : iconColor,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: disabled ? Colors.grey[400] : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Full Screen Image Viewer
// ══════════════════════════════════════════════
class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  const _FullScreenImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    ),
    body: InteractiveViewer(
      panEnabled: true,
      minScale: 0.5,
      maxScale: 5.0,
      child: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
          errorBuilder: (_, __, ___) => const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_rounded, color: Colors.white54, size: 64),
              SizedBox(height: 12),
              Text(
                'Image unavailable',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
