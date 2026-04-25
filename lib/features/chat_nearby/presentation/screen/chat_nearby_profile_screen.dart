import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/chat_nearby/data/nearby_friends_model.dart';
import 'package:giolee78/features/chat_nearby/presentation/controller/chat_nearby_profile_controller.dart';
import 'package:giolee78/features/clicker/presentation/controller/clicker_controller.dart';
import 'package:giolee78/utils/app_utils.dart';
import '../../../../component/button/common_button.dart';
import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../component/text_field/common_text_field.dart';
import '../../../../services/api/api_service.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_icons.dart';
import '../../../../utils/constants/app_images.dart';
import '../../../../utils/enum/enum.dart';

class ChatNearbyProfileScreen extends StatefulWidget {
  const ChatNearbyProfileScreen({
    super.key,
    required this.user,
    this.onTapProfile,
    this.onSendGreetings,
  });

  final NearbyChatUserModel user;
  final VoidCallback? onTapProfile;
  final VoidCallback? onSendGreetings;

  @override
  State<ChatNearbyProfileScreen> createState() =>
      _ChatNearbyProfileScreenState();
}

class _ChatNearbyProfileScreenState extends State<ChatNearbyProfileScreen> {
  late ChatNearbyProfileController controller;
  late ClickerController clickerController;
  late TextEditingController greetingsController;
  bool _navigationHandled = false;

  @override
  void initState() {
    super.initState();

    greetingsController = TextEditingController();
    clickerController = Get.put(ClickerController());

    controller = Get.put(
      ChatNearbyProfileController(),
      tag: widget.user.id.toString(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.fetchUserProfile(widget.user.id.toString());
        _monitorFriendStatus();
      }
    });
  }

  void _monitorFriendStatus() {
    ever<FriendStatus>(controller.friendStatus, (status) {
      if (!_navigationHandled && mounted && status == FriendStatus.friends) {
        _navigationHandled = true;
        clickerController.createOrGetChatAndGo(
          receiverId: widget.user.id.toString(),
          name: widget.user.name,
          image: widget.user.image ?? '',
        );
      }
    });
  }

  @override
  void dispose() {
    greetingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(
          () => _ChatNearbyProfileAppBar(
            status: controller.friendStatus.value,
            isProcessing: controller.isProcessingAction.value,
            onTapAdd: () => controller.addFriend(widget.user.id.toString()),
            onTapCancel: () => controller.cancelRequest(widget.user.id.toString()),
            onTapMessage: () {
              clickerController.createOrGetChatAndGo(
                receiverId: widget.user.id.toString(),
                name: widget.user.name,
                image: widget.user.image ?? '',
              );
            },
            userId: widget.user.id.toString(),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (controller.error.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.r, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    controller.error.value,
                    style: TextStyle(color: Colors.red, fontSize: 14.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () =>
                        controller.fetchUserProfile(widget.user.id.toString()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              children: [
                _ProfileHeader(userProfile: controller.userProfile.value),
                SizedBox(height: 24.h),
                _GreetingsInput(controller: greetingsController),
                SizedBox(height: 24.h),
                Obx(
                  () => CommonButton(
                    titleText: controller.isLoading.value
                        ? 'Sending...'
                        : 'Send Greetings',
                    buttonHeight: 48.h,
                    buttonRadius: 6.r,
                    onTap: () {
                      if (mounted) {
                        controller.sendGreeting(greetingsController);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ChatNearbyProfileAppBar extends StatelessWidget {
  const _ChatNearbyProfileAppBar({
    required this.status,
    this.isProcessing = false,
    required this.onTapAdd,
    required this.onTapCancel,
    required this.onTapMessage,
    required this.userId,
  });

  final FriendStatus status;
  final bool isProcessing;
  final VoidCallback onTapAdd;
  final VoidCallback onTapCancel;
  final VoidCallback onTapMessage;
  final String userId;

  void _showBlockConfirmation(BuildContext context) {
    Utils.showConfirmationDialog(
      context,
      title: "Block User",
      message: "Are you sure you want to block this user? You will no longer see each other's content.",
      onConfirm: () async {
        final response = await ApiService.post(
          ApiEndPoint.createBlock,
          body: {"blockedUser": userId},
        );
        if (response.isSuccess) {
          Get.back(); // Close dialog
          Get.back(); // Go back to nearby list
          Utils.successSnackBar("Blocked", "User has been blocked.");
          if(Get.isRegistered<ClickerController>()){
             Get.find<ClickerController>().getAllPosts();
          }
        }
      },
    );
  }

  void _showReportDialog(BuildContext context) {
    final reportController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text("Report User"),
        content: CommonTextField(
          controller: reportController,
          hintText: "Reason for reporting...",
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              if (reportController.text.isEmpty) return;
              final response = await ApiService.post(
                ApiEndPoint.createReport,
                body: {
                  "reportedUser": userId,
                  "reason": reportController.text,
                },
              );
              if (response.isSuccess) {
                Get.back();
                Get.back();
                Utils.successSnackBar("Reported", "Thank you for your report.");
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: kToolbarHeight,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back, size: 24.sp, color: AppColors.black),
              ),
              Expanded(
                child: Center(
                  child: CommonText(
                    text: 'Profile',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorFirst,
                  ),
                ),
              ),
              if (status == FriendStatus.none)
                IconButton(
                  onPressed: isProcessing ? () {} : onTapAdd,
                  icon: isProcessing
                      ? SizedBox(width: 22.sp, height: 22.sp, child: const CircularProgressIndicator(strokeWidth: 2))
                      : CommonImage(imageSrc: AppIcons.addFriend, size: 22.sp),
                )
              else if (status == FriendStatus.requested)
                IconButton(
                  onPressed: isProcessing ? () {} : onTapCancel,
                  icon: isProcessing
                      ? SizedBox(width: 22.sp, height: 22.sp, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                      : Icon(Icons.person_remove_alt_1, color: Colors.red, size: 22.sp),
                )
              else if (status == FriendStatus.friends)
                IconButton(
                  onPressed: isProcessing ? null : onTapMessage,
                  icon: Icon(Icons.chat_bubble_outline, color: AppColors.primaryColor, size: 22.sp),
                ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'report') _showReportDialog(context);
                  if (value == 'block') _showBlockConfirmation(context);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'report', child: Text("Report User")),
                  const PopupMenuItem(value: 'block', child: Text("Block User", style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic userProfile;
  const _ProfileHeader({this.userProfile});

  @override
  Widget build(BuildContext context) {
    final name = userProfile?['name'] ?? 'User';
    final bio = userProfile?['bio'] ?? 'No bio available';
    final imageUrl = userProfile?['image'] ?? '';
    final location = userProfile?['address'] ?? 'Location not available';
    final distance = userProfile?['distance'] ?? 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipOval(
          child: Container(
            height: 100.h,
            width: 100.w,
            child: imageUrl.isNotEmpty
                ? CommonImage(imageSrc: ApiEndPoint.imageUrl + imageUrl, defaultImage: AppImages.placeHolderImage)
                : Image.asset(AppImages.placeHolderImage, fit: BoxFit.cover),
          ),
        ),
        CommonText(text: name, fontWeight: FontWeight.w600, top: 16),
        CommonText(text: bio, fontSize: 13, color: AppColors.secondaryText, maxLines: 2, left: 40, right: 40, top: 4),
        SizedBox(height: 8.h),
        if (distance != null)
          CommonText(text: 'Within $distance KM', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryColor2),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonImage(imageSrc: AppIcons.location, size: 12.r),
              SizedBox(width: 8.w),
              CommonText(text: location, fontSize: 13, color: AppColors.secondaryText),
            ],
          ),
        ),
      ],
    );
  }
}

class _GreetingsInput extends StatelessWidget {
  const _GreetingsInput({this.controller});
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText(text: 'Type Your Greetings:', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textColorFirst, textAlign: TextAlign.start),
        SizedBox(height: 8.h),
        CommonTextField(controller: controller, maxLines: 6, paddingHorizontal: 12, paddingVertical: 12),
      ],
    );
  }
}
