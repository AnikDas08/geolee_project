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

import '../../../../utils/enum/enum.dart';
import '../controller/message_controller.dart';
import '../widgets/attachment_select_option.dart';
import '../widgets/bubble_content.dart';
import '../widgets/empty_state.dart';
import '../widgets/friend_input_area.dart';
import '../widgets/full_screen_image_view.dart';
import '../widgets/loading_shimer.dart';
import '../widgets/none_friend_input_panel.dart';
import '../widgets/picked_file_preview.dart';
import '../widgets/upload_progress.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late MessageController messageController;

/*  @override
  void initState() {
    super.initState();
    messageController = Get.find<MessageController>();
    messageController.scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initScreen();
    });
  }*/

  @override
  void initState() {
    super.initState();
    messageController = Get.find<MessageController>();
    messageController.scrollController.addListener(_onScroll);

  }

  @override
  void dispose() {
    messageController.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final sc = messageController.scrollController;
    if (!sc.hasClients) return;
    if (sc.position.pixels >= sc.position.maxScrollExtent - 300) {
      messageController.loadMoreMessages();
    }
  }

  // Future<void> _initScreen() async {
  //   await messageController.initializeChat(messageController.userId);
  // }

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
        pageBuilder: (_, __, ___) => FullScreenImageViewer(imageUrl: imageUrl),
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
                return const LoadingShimmer();
              }
              return Column(
                children: [
                  Expanded(
                    child: controller.isLoading
                        ? const LoadingShimmer()
                        : controller.messages.isEmpty
                        ? const EmptyState()
                        : _buildMessageList(controller),
                  ),

                  PickedFilePreview(controller: controller),

                  if (controller.isUploadingImage ||
                      controller.isUploadingMedia ||
                      controller.isUploadingDocument)
                    const UploadProgress(),

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
                    FriendInputArea(
                      controller: controller,
                      onAttachmentTap: () =>
                          _showAttachmentPicker(context, controller),
                    )
                  else
                    NonFriendPanel(controller: controller),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildMessageList(MessageController controller) {
    return ListView.builder(
      reverse: true,
      controller: controller.scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: controller.messages.length + 1,
      itemBuilder: (context, index) {
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
                        "Start",
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
        final prevMsg = reversedIndex < controller.messages.length - 1
            ? controller.messages[reversedIndex + 1]
            : null;
        final showAvatar = prevMsg == null || prevMsg.senderId != msg.senderId;

        return _MessageBubble(
          message: msg,
          showAvatar: showAvatar,
          showTime: true,
          getImageUrl: _getImageUrl,
          onImageTap: (url) => _openImageFullScreen(context, url),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(MessageController controller) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 42.w,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.black87,
          size: 26.sp,
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
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewFriendScreen(
                          isFriend:
                              controller.friendStatus.value ==
                              FriendStatus.friends,
                          userId: controller.userId,
                        ),
                      ),
                    ),
                    child: Text(
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
                  ),
                  Text(
                    (controller.friendStatus.value != FriendStatus.friends)
                        ? (controller.distance.value.isNotEmpty
                            ? 'Distance: ${controller.distance.value}'
                            : 'Offline')
                        : (controller.isActive.value
                            ? 'Active now'
                            : 'Offline'),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: (controller.friendStatus.value !=
                              FriendStatus.friends)
                          ? (controller.distance.value.isNotEmpty
                              ? const Color(0xFFF48201)
                              : Colors.grey[400])
                          : (controller.isActive.value
                              ? const Color(0xFF22C55E)
                              : Colors.grey[400]),
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

          if (controller.friendStatus.value == FriendStatus.none) {
            return IconButton(
              onPressed: () => _showAddFriendDialog(controller),
              icon: CommonImage(imageSrc: AppIcons.addFriend, size: 22.sp),
            );
          }

          if (controller.friendStatus.value == FriendStatus.requested) {
            return IconButton(
              onPressed: () => _showCancelRequestDialog(controller),
              icon: Icon(
                Icons.person_remove_alt_1,
                color: Colors.red,
                size: 22.sp,
              ),
            );
          }

          return const SizedBox.shrink();
        }),
      ],
    );
  }

  void _showAcceptRequestDialog(MessageController controller) {
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
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add_rounded,
                  color: Colors.green,
                  size: 30.sp,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'Friend Request',
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8.h),
              Text(
                '${controller.name} sent you a friend request',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 22.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        Get.back();
                        await controller.rejectFriendRequest(
                          controller.pendingRequestId.value,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        'Decline',
                        style: TextStyle(fontSize: 13.sp, color: Colors.red),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await controller.acceptFriendRequest(
                          controller.pendingRequestId.value,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        'Accept',
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
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
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
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final bool showTime;
  final String Function(String?) getImageUrl;
  final void Function(String url) onImageTap;

  const _MessageBubble({
    required this.message,
    required this.showAvatar,
    required this.showTime,
    required this.getImageUrl,
    required this.onImageTap,
  });

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return DateFormat('hh:mm a').format(time);
    if (diff.inDays == 1) {
      return 'Yesterday ${DateFormat('hh:mm a').format(time)}';
    }
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('dd MMM, hh:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final isMe = message.isCurrentUser;
    return Padding(
      padding: EdgeInsets.only(
        bottom: 10.h,
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
                          ? NetworkImage(getImageUrl(message.senderImage))
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
                BubbleContent(
                  message: message,
                  isMe: isMe,
                  getImageUrl: getImageUrl,
                  onImageTap: onImageTap,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 4.h,
                    left: isMe ? 0 : 4.w,
                    right: isMe ? 4.w : 0,
                  ),
                  child: Text(
                    _formatMessageTime(message.createdAt),
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
}
